import "package:flutter/foundation.dart";
import "package:egpt/admin/source_register.dart";
import "package:egpt/admin/source_schedule.dart";
import "package:egpt/models/meeting.dart";
import "package:egpt/models/member.dart";
import "package:egpt/models/product.dart";
import "package:egpt/services/egpt_services.dart";
import "package:egpt/services/api/calendar_service.dart";
import "package:egpt/services/api/database_service.dart";


class AdminSource extends ChangeNotifier {

  AdminSource({required this.services});

  final EGPTServices services;

  DatabaseService get database => services.database;
  CalendarService get calendar => services.calendar;

  final register = RegisterSource();
  final schedule = ScheduleSource();

  bool _loading = false;
  Object? _error;

  bool get loading => _loading;
  Object? get error => _error;

  void reset() {
    register.members.clear();
    schedule.clear();
  }

  Future<void> build() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      print("meetings ${calendar.meetings()}");
      await Future.wait([_buildRegister()]);
      await Future.wait([_buildSchedule()]);
    } catch (error) {
      _error = error;
      print("error $error");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _buildRegister() async {
    register.append(await database.buildRegister());
  }

  Future<void>  _buildSchedule() async {
    schedule.append(await database.buildSchedule());
  }

  // ── Member ──────────────────────────────────────────────────────────────

  Member? _findMember(String id) =>
      register.members.where((m) => m.id == id).singleOrNull;

  Future<Member> createMember(Member member) async {
    register.createMember(member);
    notifyListeners();
    try {
      await database.createMember(member);
      return member;
    } catch (e) {
      register.deleteMember(member);
      notifyListeners();
      rethrow;
    }
  }

  Future<Member> updateMember(Member member) async {
    final previous = _findMember(member.id!);
    register.updateMember(member);
    notifyListeners();
    try {
      await database.updateMember(member);
      return member;
    } catch (e) {
      if (previous != null) {
        register.updateMember(previous);
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<Member> deleteMember(Member member) async {
    final previous = _findMember(member.id!);
    register.deleteMember(member);
    notifyListeners();
    try {
      await database.deleteMember(member);
      return member;
    } catch (e) {
      if (previous != null) {
        register.updateMember(previous);
        notifyListeners();
      }
      rethrow;
    }
  }

  // ── Product ─────────────────────────────────────────────────────────────

  Product? _findProduct(String id) =>
      register.products.where((p) => p.id == id).singleOrNull;

  Future<Product> createProduct(Product product) async {
    register.createProduct(product);
    notifyListeners();
    try {
      await database.createProduct(product);
      return product;
    } catch (e) {
      register.deleteProduct(product);
      notifyListeners();
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    final previous = _findProduct(product.id!);
    register.updateProduct(product);
    notifyListeners();
    try {
      await database.updateProduct(product);
      return product;
    } catch (e) {
      if (previous != null) {
        register.updateProduct(previous);
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<Product> deleteProduct(Product product) async {
    final previous = _findProduct(product.id!);
    register.deleteProduct(product);
    notifyListeners();
    try {
      await database.deleteProduct(product);
      return product;
    } catch (e) {
      if (previous != null) {
        register.updateProduct(previous);
        notifyListeners();
      }
      rethrow;
    }
  }

  // ── Meeting ─────────────────────────────────────────────────────────────

  Meeting? _findMeeting(String id) =>
      schedule.meetings.where((m) => m.id == id).singleOrNull;

  Future<Meeting> insertMeeting(Meeting meeting) async {
    try {
      final _meeting = await database.createMeeting(meeting);
      schedule.insertMeeting(_meeting);
      notifyListeners();
      return _meeting;
    } catch (e) {
      rethrow;
    }
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    final toUpdate = _findMeeting(meeting.id!)!.copy();
    schedule.modifyMeeting(meeting);
    notifyListeners();
    try {
      await database.updateMeeting(meeting);
      return meeting;
    } catch (e) {
      schedule.modifyMeeting(toUpdate);
      notifyListeners();
      rethrow;
    }
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    final toDelete = _findMeeting(meeting.id!)!.copy();
    schedule.removeMeeting(meeting);
    notifyListeners();
    try {
      await database.deleteMeeting(meeting);
      return meeting;
    } catch (e) {
      schedule.insertMeeting(toDelete);
      notifyListeners();
      rethrow;
    }
  }
}
