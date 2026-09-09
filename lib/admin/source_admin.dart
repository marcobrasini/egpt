import "package:flutter/foundation.dart";
import "../sources/source_register.dart";
import "../sources/source_schedule.dart";
import "../sources/source_training.dart";
import "../services/egpt_services.dart";
import "../models/meeting.dart";
import "../models/member.dart";
import "../models/product.dart";
import "../models/session.dart";


class AdminSource extends ChangeNotifier {
  AdminSource({required this.services});

  bool _loading = false;
  Object? _error;

  bool get isLoading => _loading;
  Object? get error => _error;

  final EGPTServices services;
  final register = RegisterSource();
  final schedule = ScheduleSource();
  final training = TrainingSource();

  Future<void> build() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await services.database.buildRegister(register);
      await services.database.buildSchedule(schedule);
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Member> insertMember(Member member) async {
    final m = await services.database.createMember(member);
    register.insertMember(m);
    notifyListeners();
    return m;
  }

  Future<Member> modifyMember(Member member) async {
    await services.database.updateMember(member);
    register.modifyMember(member);
    notifyListeners();
    return member;
  }

  Future<Member> removeMember(Member member) async {
    await services.database.deleteMember(member);
    register.removeMember(member);
    notifyListeners();
    return member;
  }

  Future<Product> insertProduct(Product product) async {
    final p = await services.database.createProduct(product);
    register.insertProduct(p);
    notifyListeners();
    return p;
  }

  Future<Product> modifyProduct(Product product) async {
    await services.database.updateProduct(product);
    register.modifyProduct(product);
    notifyListeners();
    return product;
  }

  Future<Product> removeProduct(Product product) async {
    await services.database.deleteProduct(product);
    register.removeProduct(product);
    notifyListeners();
    return product;
  }

  Future<Meeting> insertMeeting(Meeting meeting) async {
    final m = await services.database.createMeeting(meeting);
    schedule.insertMeeting(m);
    notifyListeners();
    return m;
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    await services.database.updateMeeting(meeting);
    schedule.modifyMeeting(meeting);
    notifyListeners();
    return meeting;
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    await services.database.deleteMeeting(meeting);
    schedule.removeMeeting(meeting);
    notifyListeners();
    return meeting;
  }

  Future<Session> insertSession(Session session) async {
    final s = await services.database.createSession(session);
    schedule.insertSession(s);
    notifyListeners();
    return s;
  }

  Future<Session> modifySession(Session session) async {
    await services.database.updateSession(session);
    schedule.modifySession(session);
    notifyListeners();
    return session;
  }

  Future<Session> removeSession(Session session) async {
    await services.database.deleteSession(session);
    schedule.removeSession(session);
    notifyListeners();
    return session;
  }
}
