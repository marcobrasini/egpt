import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api/database_service.dart';
import '../services/egpt_services.dart';
import '../sources/source_database.dart';
import '../sources/source_register.dart';
import '../sources/source_schedule.dart';
import '../models/meeting.dart';
import '../models/member.dart';
import '../models/product.dart';
import '../models/session.dart';
import '../typedef.dart';


class UserSource extends ChangeNotifier {
  UserSource({required this.services});

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
    } finally {
      _building = false;
      notifyListeners();
    }
    watch();
  }

  void watch() {
    if (_subscriptions.isNotEmpty || _building) return;
    _listen<Member>('members', db.watchMembers(register));
    _listen<Product>('products', db.watchProducts(register));
    _listen<Meeting>('meetings', db.watchMeetings(schedule));
    _listen<Session>('sessions', db.watchSessions(schedule));
  }

  void _listen<T extends EGPTItem>(
    String name,
    Stream<DatabaseData<T>> stream,
  ) {
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

  @override
  void dispose() {
    // _pending?.cancel();
    // for (final sub in _subscriptions) {
    //   sub.cancel();
    // }
    super.dispose();
  }
}
