import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as flt_supabase;
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';
import 'api/database_service.dart';
import '../sources/source_database.dart';
import '../sources/source_register.dart';
import '../sources/source_schedule.dart';
import '../models/meeting.dart';
import '../models/member.dart';
import '../models/product.dart';
import '../models/session.dart';
import '../typedef.dart';
import 'local_service.dart';
import 'supabase_service.dart';

class PowerSyncService implements DatabaseService {
  static const _databaseFile = 'egpt-powersync.db';

  static const _databaseSchema = Schema([
    Table(LocalService.memberTable, [
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text(LocalService.memberColumnName),
      Column.text(LocalService.memberColumnFirstName),
      Column.text(LocalService.memberColumnLastName),
      Column.text(LocalService.memberColumnBirth),
      Column.text(LocalService.memberColumnColor),
      Column.text(LocalService.memberColumnEmail),
      Column.text(LocalService.memberColumnPhone),
    ]),
    Table(LocalService.productTable, [
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text(LocalService.productColumnMemberId),
      Column.integer(LocalService.productColumnLength),
      Column.text(LocalService.productColumnStart),
      Column.text(LocalService.productColumnStop),
      Column.text(LocalService.productColumnSummary),
    ]),
    Table(LocalService.sessionTable, [
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text(LocalService.sessionColumnProductId),
      Column.text(LocalService.sessionColumnStart),
      Column.text(LocalService.sessionColumnStop),
      Column.integer(LocalService.sessionColumnPresence),
    ]),
    Table(LocalService.meetingTable, [
      Column.text('created_at'),
      Column.text('updated_at'),
      Column.text(LocalService.meetingColumnProductId),
      Column.text(LocalService.meetingColumnParentId),
      Column.text(LocalService.meetingColumnStart),
      Column.text(LocalService.meetingColumnStop),
      Column.text(LocalService.meetingColumnPatternRule),
    ]),
  ]);

  static PowerSyncService? _instance;
  PowerSyncService._singleton(this.backend);
  factory PowerSyncService(SupabaseService supabase) {
    return _instance ??= PowerSyncService._singleton(supabase);
  }

  late final PowerSyncDatabase db;
  final SupabaseService backend;
  SupabaseConnector? connector;

  StreamSubscription<flt_supabase.AuthState>? _authSub;

  static Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, _databaseFile);
  }

  @override
  Future<void> open() async {
    final databasePath = await getDatabasePath();
    db = PowerSyncDatabase(schema: _databaseSchema, path: databasePath);
    await db.initialize();
    if (backend.session?.accessToken != null) {
      connector = SupabaseConnector(backend);
      await db.connect(connector: connector!);
    }
    _authSub = backend.client.auth.onAuthStateChange.listen((data) async {
      switch (data.event) {
        case flt_supabase.AuthChangeEvent.signedIn:
          final status = db.currentStatus;
          if (status.connected || status.connecting) break;
          connector = SupabaseConnector(backend);
          await db.connect(connector: connector!);
          break;
        case flt_supabase.AuthChangeEvent.signedOut:
          await db.disconnect();
          connector = null;
          break;
        case flt_supabase.AuthChangeEvent.tokenRefreshed:
          connector?.prefetchCredentials();
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await db.disconnect();
  }

  @override
  Future<void> reset() async {
    await db.disconnectAndClear();
  }

  // Helper ────────────────────────────────────────────────────────────────
  Future<void> _create(String table, String id, DataMap values) async {
    final columns = values.keys.join(', ');
    final placeholders = List.filled(values.length, '?').join(', ');
    await db.execute(
      'INSERT INTO $table ($columns) VALUES ($placeholders)',
      values.values.toList(),
    );
  }

  Future<void> _update(String table, String id, DataMap values) async {
    final setClause = values.keys.map((k) => '$k = ?').join(', ');
    await db.execute('UPDATE $table SET $setClause WHERE id = ?', [
      ...values.values,
      id,
    ]);
  }

  Future<void> _delete(String table, String id) async {
    await db.execute('DELETE FROM $table WHERE id = ?', [id]);
  }

  // Member ────────────────────────────────────────────────────────────────
  @override
  Future<Member> createMember(Member member) async {
    final id = member.id ?? Uuid().v4();
    final data = LocalService.memberToLocal(member, id: id, make: true);
    await _create(LocalService.memberTable, id, data);
    return Member.make(id: id, data: member.get());
  }

  @override
  Future<Member> updateMember(Member member) async {
    final data = LocalService.memberToLocal(member);
    await _update(LocalService.memberTable, member.id!, data);
    return member;
  }

  @override
  Future<Member> deleteMember(Member member) async {
    await _delete(LocalService.memberTable, member.id!);
    return member;
  }

  // Product ───────────────────────────────────────────────────────────────
  @override
  Future<Product> createProduct(Product product) async {
    final id = product.id ?? Uuid().v4();
    final data = LocalService.productToLocal(product, id: id, make: true);
    await _create(LocalService.productTable, id, data);
    return Product.make(id: id, data: product.get());
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final data = LocalService.productToLocal(product);
    await _update(LocalService.productTable, product.id!, data);
    return product;
  }

  @override
  Future<Product> deleteProduct(Product product) async {
    await _delete(LocalService.productTable, product.id!);
    return product;
  }

  // Session ───────────────────────────────────────────────────────────────
  @override
  Future<Session> createSession(Session session) async {
    final id = session.id ?? Uuid().v4();
    final data = LocalService.sessionToLocal(session, id: id, make: true);
    await _create(LocalService.sessionTable, id, data);
    return Session.make(id: id, data: session.get());
  }

  @override
  Future<Session> updateSession(Session session) async {
    final data = LocalService.sessionToLocal(session);
    await _update(LocalService.sessionTable, session.id!, data);
    return session;
  }

  @override
  Future<Session> deleteSession(Session session) async {
    await _delete(LocalService.sessionTable, session.id!);
    return session;
  }

  // Meeting ───────────────────────────────────────────────────────────────
  @override
  Future<Meeting> createMeeting(Meeting meeting) async {
    final id = meeting.id ?? Uuid().v4();
    final data = LocalService.meetingToLocal(meeting, id: id, make: true);
    await _create(LocalService.meetingTable, id, data);
    return Meeting.make(id: id, data: meeting.get());
  }

  @override
  Future<Meeting> updateMeeting(Meeting meeting) async {
    final data = LocalService.meetingToLocal(meeting);
    await _update(LocalService.meetingTable, meeting.id!, data);
    return meeting;
  }

  @override
  Future<Meeting> deleteMeeting(Meeting meeting) async {
    await _delete(LocalService.meetingTable, meeting.id!);
    return meeting;
  }

  // Builders ───────────────────────────────────────────────────────────────
  Future<List<Member>> listMembers() async {
    final rows = await db.getAll("""
      SELECT * FROM ${LocalService.memberTable} 
      ORDER BY ${LocalService.memberColumnName}
    """);
    return rows.map((row) =>
        LocalService.memberFromLocal(DataMap.from(row))
    ).toList();
  }
  Future<List<Product>> listProducts() async {
    final rows = await db.getAll("""
      SELECT * FROM ${LocalService.productTable} 
      ORDER BY ${LocalService.productColumnStart}
    """);
    return rows.map((row) =>
        LocalService.productFromLocal(DataMap.from(row))
    ).toList();
  }
  @override
  Future<void> buildRegister(RegisterSource register) async {
    if (!db.currentStatus.hasSynced!) await db.waitForFirstSync();
    register.buildMembers(await listMembers());
    register.buildProducts(await listProducts());
  }

  Future<List<Meeting>> listMeeting() async {
    final rows = await db.getAll("""
      SELECT * FROM ${LocalService.meetingTable} 
      ORDER BY ${LocalService.meetingColumnStart}
    """);
    return rows.map((row) =>
        LocalService.meetingFromLocal(DataMap.from(row))
    ).whereType<Meeting>().toList();
  }
  Future<List<Session>> listSession() async {
    final rows = await db.getAll("""
      SELECT * FROM ${LocalService.sessionTable}
      ORDER BY ${LocalService.sessionColumnStart}
    """);
    return rows.map((row) =>
        LocalService.sessionFromLocal(DataMap.from(row))
    ).whereType<Session>().toList();
  }
  @override
  Future<void> buildSchedule(ScheduleSource schedule) async {
    if (!db.currentStatus.hasSynced!) await db.waitForFirstSync();
    schedule.buildMeeting(await listMeeting());
    schedule.buildSession(await listSession());
  }

  // Watchers ───────────────────────────────────────────────────────────────
  static const _throttle = Duration(milliseconds: 30);

  Stream<DatabaseData<T>> _watch<T extends EGPTItem>(
      String sql,
      T Function(DataMap row) fromDatabase,
      EGPTData<T> source,
      ) {
    final reconcile = DatabaseSource<T>(source, fromDatabase);
    return db
        .watch(sql, throttle: _throttle)
        .map(reconcile.call)
        .where((list) => list != null)
        .cast<DatabaseData<T>>();
  }

  @override
  Stream<DatabaseData<Member>> watchMembers(RegisterSource register) =>
      _watch<Member>(
        'SELECT * FROM ${LocalService.memberTable} '
            'ORDER BY ${LocalService.memberColumnName}',
        LocalService.memberFromLocal,
        register.memberSource,
      );

  @override
  Stream<DatabaseData<Product>> watchProducts(RegisterSource register) =>
      _watch<Product>(
        'SELECT * FROM ${LocalService.productTable} '
            'ORDER BY ${LocalService.productColumnStart}',
        LocalService.productFromLocal,
        register.productSource,
      );

  @override
  Stream<DatabaseData<Meeting>> watchMeetings(ScheduleSource schedule) =>
      _watch<Meeting>(
        'SELECT * FROM ${LocalService.meetingTable} '
            'ORDER BY ${LocalService.meetingColumnStart}',
        LocalService.meetingFromLocal,
        schedule.meetingSource,
      );

  @override
  Stream<DatabaseData<Session>> watchSessions(ScheduleSource schedule) =>
      _watch<Session>(
        'SELECT * FROM ${LocalService.sessionTable} '
            'ORDER BY ${LocalService.sessionColumnStart}',
        LocalService.sessionFromLocal,
        schedule.sessionSource,
      );
}


class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseService supabase;
  SupabaseConnector(this.supabase);

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;
    final rest = supabase.client.rest;
    try {
      for (var operation in transaction.crud) {
        final id = operation.id;
        final table = rest.from(operation.table);
        switch (operation.op) {
          case UpdateType.put:
            final data = DataMap.of(operation.opData!);
            data["id"] = id;
            await table.upsert(data);
            break;
          case UpdateType.patch:
            await table.update(operation.opData!).eq("id", id);
            break;
          case UpdateType.delete:
            await table.delete().eq("id", id);
            break;
        }
      }
      await transaction.complete();
    } on flt_supabase.PostgrestException catch (e) {
      if (e.code != null) {
        await transaction.complete();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = supabase.session;
    if (session == null) return null;
    return PowerSyncCredentials(
      endpoint: "https://6aa00e7f8453e7cf8335537d.powersync.journeyapps.com",
      token: session.accessToken,
    );
  }
}
