import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/types.dart';


class AdminSource extends ServiceSource {
  AdminSource({required super.services});

  late final personal = PersonalSource(this);
  String? get email => services.auth.email;

  // Build ─────────────────────────────────────────────────────────────────
  bool _building = false;
  bool get loading => _building;

  Object? _error;
  Object? get error => _error;

  @override
  Future<void> build() async {
    _building = true;
    _error = null;
    notifyListeners();
    try {
      await database.buildRegister(register);
      await database.buildSchedule(schedule);
      if (calendar case final calendar?) {
        try {
          schedule.attach(await calendar.build());
        } catch (error) {
          debugPrint("calendar error: $error");
        }
      }
    } catch (error) {
      _error = error;
    } finally {
      _building = false;
      notifyListeners();
    }
  }

  // Member ───────────────────────────────────────────────────────────────────
  @override
  Future<Member> insertMember(Member m) async =>
      register.insertMember(await database.createMember(m));
  @override
  Future<Member> modifyMember(Member m) async {
    await database.updateMember(m);
    register.modifyMember(m);
    schedule.modifyMember(m);
    return m;
  }

  @override
  Future<Member> removeMember(Member m) async {
    await database.deleteMember(m);
    register.removeMember(m);
    schedule.removeMember(m);
    return m;
  }

  // Product ──────────────────────────────────────────────────────────────────
  @override
  Future<Product> insertProduct(Product p) async =>
      register.insertProduct(await database.createProduct(p));

  @override
  Future<Product> modifyProduct(Product p) async {
    await database.updateProduct(p);
    schedule.modifyProduct(p);
    register.modifyProduct(p);
    return p;
  }

  @override
  Future<Product> removeProduct(Product p) async {
    await database.deleteProduct(p);
    schedule.removeProduct(p);
    register.removeProduct(p);
    return p;
  }

  // Meeting ──────────────────────────────────────────────────────────────────
  Future<Meeting?> insertMeeting(Meeting m) async {
    try {
      final id = m.id ?? const Uuid().v4();
      final meeting = Meeting.make(id: id, data: m.get());
      await database.createMeeting(meeting);
      schedule.insertMeeting(meeting);
      return meeting;
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("createMeeting error: ${error.toString()}");
    }
    return null;
  }

  Future<Meeting?> modifyMeeting(Meeting m) async {
    try {
      await database.updateMeeting(m);
      schedule.modifyMeeting(m);
      return m;
    } on MissingMeetingException catch (_) {
      schedule.removeMeeting(m);
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("updateMeeting error: ${error.toString()}");
    }
    return null;
  }

  Future<Meeting?> removeMeeting(Meeting m) async {
    try {
      await database.deleteMeeting(m);
      schedule.removeMeeting(m);
      return m;
    } on MissingMeetingException catch (_) {
      schedule.removeMeeting(m);
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("deleteMeeting error: ${error.toString()}");
    }
    return null;
  }

  // Presence ─────────────────────────────────────────────────────────────────
  Future<Presence?> insertPresence(Presence p) async {
    try {
      final id = p.id ?? const Uuid().v4();
      final presence = Presence.make(id: id, data: p.get());
      await database.createPresence(presence);
      schedule.insertPresence(presence);
      return presence;
    } catch (error) {
      debugPrint("createPresence error: ${error.toString()}");
    }
    return null;
  }

  Future<Presence?> modifyPresence(Presence p) async {
    try {
      await database.updatePresence(p);
      schedule.modifyPresence(p);
      return p;
    } on MissingPresenceException catch (_) {
      schedule.removePresence(p);
    } catch (error) {
      debugPrint("updatePresence error: ${error.toString()}");
    }
    return null;
  }

  Future<Presence?> removePresence(Presence p) async {
    try {
      await database.deletePresence(p);
      schedule.removePresence(p);
      return p;
    } on MissingPresenceException catch (_) {
      schedule.removePresence(p);
    } catch (error) {
      debugPrint("deletePresence error: ${error.toString()}");
    }
    return null;
  }

  // Session ──────────────────────────────────────────────────────────────────
  @override
  Future<Session?> insertSession(Session s) async {
    try {
      final id = s.id ?? const Uuid().v4();
      final session = Session.make(id: id, data: s.get());
      await database.createSession(session);
      await session.presence?.let(insertPresence);
      register.insertSession(session);
      return session;
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("createSession error: ${error.toString()}");
    }
    return null;
  }

  @override
  Future<Session?> modifySession(Session s) async {
    try {
      if (s.presence != null) {
        await modifyPresence(s.presence!);
      } else {
        await removePresence(s.presence!);
      }
      await database.updateSession(s);
      register.modifySession(s);
      return s;
    } on MissingSessionException catch (_) {
      register.removeSession(s);
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("updateSession error: ${error.toString()}");
    }
    return null;
  }

  @override
  Future<Session?> removeSession(Session s) async {
    try {
      await s.presence?.let(removePresence);
      await database.deleteSession(s);
      register.removeSession(s);
      return s;
    } on MissingSessionException catch (_) {
      register.removeSession(s);
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("deleteSession error: ${error.toString()}");
    }
    return null;
  }
}
