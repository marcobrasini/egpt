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


class AdminSource extends ChangeNotifier {
  AdminSource({required this.services});

  final EGPTServices services;
  final register = RegisterSource();
  final schedule = ScheduleSource();
  DatabaseService get db => services.database;

  // Stato ─────────────────────────────────────────────────────────────────
  bool _building = false;
  bool get loading => _building;

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
    } catch (error) {
      _error = error;
    } finally {
      _building = false;
      notifyListeners();
    }
  }

  Future<Member> insertMember(Member m) async =>
      register.insertMember(await db.createMember(m));
  Future<Member> modifyMember(Member m) async {
    db.updateMember(m);
    schedule.modifyMember(m);
    register.modifyMember(m);
    return m;
  }
  Future<Member> removeMember(Member m) async {
    db.deleteMember(m);
    schedule.removeMember(m);
    register.removeMember(m);
    return m;
  }

  Future<Product> insertProduct(Product p) async =>
      register.insertProduct(await db.createProduct(p));
  Future<Product> modifyProduct(Product p) async {
    db.updateProduct(p);
    register.modifyProduct(p);
    return p;
  }
  Future<Product> removeProduct(Product p) async {
    db.deleteProduct(p);
    schedule.removeProduct(p);
    register.removeProduct(p);
    return p;
  }

  Future<Meeting?> insertMeeting(Meeting m) async {
    try {
      return schedule.insertMeeting(await db.createMeeting(m));
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }
  Future<Meeting?> modifyMeeting(Meeting m) async {
    try {
      db.updateMeeting(m);
      schedule.modifyMeeting(m);
      return m;
    } on MissingMeetingException catch (_) {
      schedule.removeMeeting(m);
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }
  Future<Meeting?> removeMeeting(Meeting m) async {
    try {
      db.deleteMeeting(m);
      schedule.removeMeeting(m);
      return m;
    } on MissingMeetingException catch (_) {
      schedule.removeMeeting(m);
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }

  Future<Session?> insertSession(Session s) async {
    try {
      return schedule.insertSession(await db.createSession(s));
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }
  Future<Session?> modifySession(Session s) async {
    try {
      db.updateSession(s);
      schedule.modifySession(s);
      return s;
    } on MissingSessionException catch (_) {
      schedule.removeSession(s);
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }
  Future<Session?> removeSession(Session s) async {
    try {
      db.deleteSession(s);
      schedule.removeSession(s);
      return s;
    } on MissingSessionException catch (_) {
      schedule.removeSession(s);
    } on RegisterException catch (_) {
      build();
    }
    return null;
  }
}
