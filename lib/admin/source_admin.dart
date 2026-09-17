import 'dart:async';
import 'package:egpt/services/api/database_service.dart';
import 'package:egpt/typedef.dart';
import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import '../models/member.dart';
import '../models/product.dart';
import '../models/session.dart';
import '../services/egpt_services.dart';
import '../sources/source_database.dart';
import '../sources/source_register.dart';
import '../sources/source_schedule.dart';


class AdminSource extends ChangeNotifier {
  AdminSource({required this.services});

  final EGPTServices services;
  final register = RegisterSource();
  final schedule = ScheduleSource();
  DatabaseService get db => services.database;

  // Stato ─────────────────────────────────────────────────────────────────
  static const _streams = {'members', 'products', 'meetings', 'sessions'};
  final Set<String> _received = {};
  final List<StreamSubscription> _subscriptions = [];
  bool _building = false;
  bool get loading => _building || !_received.containsAll(_streams);
  Object? _error;
  Object? get error => _error;

  // Avvio ─────────────────────────────────────────────────────────────────
  Future<void> build() async {
    _building = true;
    _error = null;
    notifyListeners();
    try {
      await db.buildRegister(register);
      await db.buildSchedule(schedule);
    } catch (e) {
      _error = e;
      print(_error);
    } finally {
      _building = false;
      watch();
    }
  }

  void watch() {
    if (_subscriptions.isNotEmpty || _building) return;
    _listen<Member>('members', db.watchMembers(register));
    _listen<Product>('products', db.watchProducts(register));
    _listen<Meeting>('meetings', db.watchMeetings(schedule));
    _listen<Session>('sessions', db.watchSessions(schedule));
  }

  void _listen<T extends EGPTItem>(String name, Stream<DatabaseData<T>> stream) {
    _subscriptions.add(
      stream.listen(
            (data) {
          _received.add(name);
          _error = null;
          _notify();
        },
        onError: (Object e) {
          _error = e;
          _received.add(name);
          _notify();
        },
      ),
    );
  }

  // Più stream per la stessa transazione → una sola rebuild
  Timer? _pending;
  void _notify() {
    _pending ??= Timer(Duration.zero, () {
      _pending = null;
      notifyListeners();
    });
  }

  // Scritture: solo DB, le cache si aggiornano dagli stream ─────────────
  Future<Member> insertMember(Member m) => db.createMember(m);
  Future<Member> modifyMember(Member m) => db.updateMember(m);
  Future<Member> removeMember(Member m) => db.deleteMember(m);

  Future<Product> insertProduct(Product p) => db.createProduct(p);
  Future<Product> modifyProduct(Product p) => db.updateProduct(p);
  Future<Product> removeProduct(Product p) => db.deleteProduct(p);

  Future<Meeting> insertMeeting(Meeting m) => db.createMeeting(m);
  Future<Meeting> modifyMeeting(Meeting m) => db.updateMeeting(m);
  Future<Meeting> removeMeeting(Meeting m) => db.deleteMeeting(m);

  Future<Session> insertSession(Session s) => db.createSession(s);
  Future<Session> modifySession(Session s) => db.updateSession(s);
  Future<Session> removeSession(Session s) => db.deleteSession(s);

  // Chiusura ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _pending?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
