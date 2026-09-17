import 'package:calendar/calendar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/sqlite3.dart' as sql;
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/product.dart';
import '../models/session.dart';
import '../models/meeting.dart';
import '../utils/color.dart';
import '../typedef.dart';


typedef Database = sql.Database;


class LocalService {
  //}extends DatabaseService {
  static const _databaseVersion = 1;
  static const _databaseFile = "egpt-local.db";

  // Member ──────────────────────────────────────────────────────────────────
  static const String memberTable = "members";
  static const String memberColumnId = "id";
  static const String memberColumnName = "name";
  static const String memberColumnFirstName = "first_name";
  static const String memberColumnLastName = "last_name";
  static const String memberColumnBirth = "birth";
  static const String memberColumnColor = "color";
  static const String memberColumnEmail = "email";
  static const String memberColumnPhone = "phone";
  //static const memberColumnPhoto = "photo";

  static DataMap memberToLocal(
    Member member, {
    String? id,
    bool make = false,
  }) => {
    if (make) memberColumnId: id ?? member.id,
    memberColumnName: member.name,
    memberColumnFirstName: member.firstName,
    memberColumnLastName: member.lastName,
    memberColumnColor: member.color.toHexString(),
    memberColumnBirth: member.birth.toString(),
    memberColumnEmail: member.email,
    memberColumnPhone: member.phone,
  };

  static Member memberFromLocal(DataMap row) => Member(
    id: row[memberColumnId],
    name: row[memberColumnName],
    firstName: row[memberColumnFirstName],
    lastName: row[memberColumnLastName],
    color: (row[memberColumnColor] as String).toColor(),
    birth: Date.fromString(row[memberColumnBirth]),
    email: row[memberColumnEmail],
    phone: row[memberColumnPhone],
  );

  // Product ─────────────────────────────────────────────────────────────────
  static const String productTable = "products";
  static const String productColumnId = "id";
  static const String productColumnMemberId = "member_id";
  static const String productColumnSummary = "summary";
  static const String productColumnLength = "length";
  static const String productColumnStart = "start";
  static const String productColumnStop = "stop";

  static DataMap productToLocal(
    Product product, {
    String? id,
    bool make = false,
  }) => {
    if (make) productColumnId: id ?? product.id,
    if (make) productColumnMemberId: product.member.id,
    productColumnSummary: product.summary,
    productColumnLength: product.length,
    productColumnStart: product.start.toString(),
    productColumnStop: product.stop.toString(),
  };

  static Product productFromLocal(DataMap row) => Product.build(
    id: row[productColumnId],
    memberId: row[productColumnMemberId],
    summary: row[productColumnSummary],
    length: row[productColumnLength],
    start: Date.fromString(row[productColumnStart]),
    stop: Date.fromString(row[productColumnStop]),
  );

  // Session ─────────────────────────────────────────────────────────────────
  static const sessionTable = "sessions";
  static const sessionColumnId = "id";
  static const sessionColumnMemberId = "member_id";
  static const sessionColumnProductId = "product_id";
  static const sessionColumnStart = "start";
  static const sessionColumnStop = "stop";
  static const sessionColumnPresence = "presence";

  static DataMap sessionToLocal(
    Session session, {
    String? id,
    bool make = false,
  }) => {
    if (make) sessionColumnId: id ?? session.id,
    if (make) sessionColumnProductId: session.product.id,
    sessionColumnStart: session.start.toString(),
    sessionColumnStop: session.stop.toString(),
    sessionColumnPresence: session.presence,
  };

  static Session sessionFromLocal(DataMap row) => Session.build(
    id: row[sessionColumnId],
    productId: row[sessionColumnProductId],
    start: DateTime.parse(row[sessionColumnStart]),
    stop: DateTime.parse(row[sessionColumnStop]),
    presence: row[sessionColumnPresence] > 0,
  );

  // Meeting ─────────────────────────────────────────────────────────────────
  static const meetingTable = "meetings";
  static const meetingColumnId = "id";
  static const meetingColumnProductId = "product_id";
  static const meetingColumnStart = "start";
  static const meetingColumnStop = "stop";
  static const meetingColumnParentId = "recurrence_id";
  static const meetingColumnPatternRule = "recurrence_rule";

  static DataMap meetingToLocal(
    Meeting meeting, {
    String? id,
    bool make = false,
  }) => {
    if (make) meetingColumnId: id ?? meeting.id,
    if (make) meetingColumnProductId: meeting.product.id,
    meetingColumnStart: meeting.start.toString(),
    meetingColumnStop: meeting.stop.toString(),
    meetingColumnParentId: meeting.parentId,
    meetingColumnPatternRule: meeting.patternRule,
  };

  static Meeting meetingFromLocal(DataMap row) => Meeting.build(
    id: row[meetingColumnId],
    productId: row[meetingColumnProductId],
    parentId: row[meetingColumnParentId],
    start: DateTime.parse(row[meetingColumnStart]),
    stop: DateTime.parse(row[meetingColumnStop]),
    patternRule: row[meetingColumnPatternRule],
  );

  // Database ────────────────────────────────────────────────────────────────

  static LocalService? _instance;
  LocalService._singleton();
  factory LocalService() {
    return _instance ??= LocalService._singleton();
  }

  late final Database db;

  static Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, _databaseFile);
  }

  void _databaseBuild() {
    db.execute("""
      CREATE TABLE IF NOT EXISTS $memberTable(
        $memberColumnId TEXT PRIMARY KEY,
        $memberColumnName TEXT NOT NULL,
        $memberColumnFirstName TEXT NOT NULL,
        $memberColumnLastName TEXT NOT NULL,
        $memberColumnColor TEXT NOT NULL,
        $memberColumnBirth TEXT,
        $memberColumnEmail TEXT,
        $memberColumnPhone TEXT
      )
    """);
    db.execute("""
      CREATE TABLE IF NOT EXISTS $productTable (
        $productColumnId TEXT PRIMARY KEY,
        $productColumnMemberId TEXT NOT NULL,
        $productColumnLength INTEGER NOT NULL,
        $productColumnStart TEXT NOT NULL,
        $productColumnStop TEXT NOT NULL,
        $productColumnSummary TEXT,
        FOREIGN KEY ($productColumnMemberId)
        REFERENCES $memberTable($memberColumnId) ON DELETE CASCADE
        )
    """);
    db.execute("""
      CREATE TABLE IF NOT EXISTS $sessionTable (
        $sessionColumnId TEXT PRIMARY KEY,
        $sessionColumnProductId TEXT NOT NULL,
        $sessionColumnStart TEXT NOT NULL,
        $sessionColumnStop TEXT NOT NULL,
        $sessionColumnPresence INTEGER,
        FOREIGN KEY ($sessionColumnProductId)
        REFERENCES $productTable($productColumnId) ON DELETE CASCADE
        )
    """);
    db.execute("""
      CREATE TABLE IF NOT EXISTS $meetingTable (
        $meetingColumnId TEXT PRIMARY KEY,
        $meetingColumnProductId TEXT NOT NULL,
        $meetingColumnStart TEXT NOT NULL,
        $meetingColumnStop TEXT NOT NULL,
        $meetingColumnPatternRule TEXT,
        $meetingColumnParentId TEXT,
        FOREIGN KEY ($meetingColumnProductId)
        REFERENCES $productTable($productColumnId) ON DELETE CASCADE
        )
    """);
    db.execute('PRAGMA user_version = $_databaseVersion;');
  }

  @override
  Future<void> open() async {
    final databasePath = await getDatabasePath();
    db = sql.sqlite3.open(databasePath);
    db.execute('PRAGMA foreign_keys = ON;');
    final versionRow = db.select('PRAGMA user_version;').first;
    final currentVersion = versionRow['user_version'] as int;
    if (currentVersion < _databaseVersion) {
      _databaseBuild();
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> reset() async {
    db.execute('DROP TABLE IF EXISTS $memberTable');
    db.execute('DROP TABLE IF EXISTS $productTable');
    db.execute('DROP TABLE IF EXISTS $sessionTable');
    db.execute('DROP TABLE IF EXISTS $meetingTable');
    _databaseBuild();
    db.execute('PRAGMA user_version = $_databaseVersion;');
  }

  // Helper ────────────────────────────────────────────────────────────────────
  void _insert(Database db, String table, DataMap values) {
    final columns = values.keys.join(', ');
    final placeholders = List.filled(values.length, '?').join(', ');
    db.execute(
      'INSERT INTO $table ($columns) VALUES ($placeholders)',
      values.values.toList(),
    );
  }

  void _update(Database db, String table, DataMap values, {
    required String where,
    required List<Object?> whereArgs,
  }) {
    final setClause = values.keys.map((k) => '$k = ?').join(', ');
    db.execute('UPDATE $table SET $setClause WHERE $where', [
      ...values.values,
      ...whereArgs,
    ]);
  }

  void _delete(Database db, String table, {
    required String where,
    required List<Object?> whereArgs,
  }) {
    db.execute('DELETE FROM $table WHERE $where', whereArgs);
  }

  // Create ────────────────────────────────────────────────────────────────────
  @override
  Future<Member> createMember(Member member, [String? id]) async {
    id ??= const Uuid().v4();
    _insert(db, memberTable, memberToLocal(member, id: id, make: true));
    return Member.make(id: id, data: member.get());
  }

  @override
  Future<Product> createProduct(Product product, [String? id]) async {
    id ??= const Uuid().v4();
    _insert(db, productTable, productToLocal(product, id: id, make: true));
    return Product.make(id: id, data: product.get());
  }

  @override
  Future<Session> createSession(Session session, [String? id]) async {
    id ??= const Uuid().v4();
    _insert(db, sessionTable, sessionToLocal(session, id: id, make: true));
    return Session.make(id: id, data: session.get());
  }

  @override
  Future<Meeting> createMeeting(Meeting meeting, [String? id]) async {
    id ??= const Uuid().v4();
    _insert(db, meetingTable, meetingToLocal(meeting, id: id, make: true));
    return Meeting.make(id: id, data: meeting.get());
  }

  // Update ────────────────────────────────────────────────────────────────────
  @override
  Future<void> updateMember(Member member) async {
    _update(
      db,
      memberTable,
      memberToLocal(member),
      where: '$memberColumnId = ?',
      whereArgs: [member.id!],
    );
  }

  @override
  Future<void> updateProduct(Product product) async {
    _update(
      db,
      productTable,
      productToLocal(product),
      where: '$productColumnId = ?',
      whereArgs: [product.id!],
    );
  }

  @override
  Future<void> updateSession(Session session) async {
    _update(
      db,
      sessionTable,
      sessionToLocal(session),
      where: '$sessionColumnId = ?',
      whereArgs: [session.id!],
    );
  }

  @override
  Future<void> updateMeeting(Meeting meeting) async {
    _update(
      db,
      meetingTable,
      meetingToLocal(meeting),
      where: '$meetingColumnId = ?',
      whereArgs: [meeting.id!],
    );
  }

  // Delete ────────────────────────────────────────────────────────────────────
  @override
  Future<void> deleteMember(Member member) async {
    _delete(
      db,
      memberTable,
      where: '$memberColumnId = ?',
      whereArgs: [member.id],
    );
  }

  @override
  Future<void> deleteProduct(Product product) async {
    _delete(
      db,
      productTable,
      where: '$productColumnId = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<void> deleteSession(Session session) async {
    _delete(
      db,
      sessionTable,
      where: '$sessionColumnId = ?',
      whereArgs: [session.id],
    );
  }

  @override
  Future<void> deleteMeeting(Meeting meeting) async {
    _delete(
      db,
      meetingTable,
      where: '$meetingColumnId = ?',
      whereArgs: [meeting.id],
    );
  }
}
