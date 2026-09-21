import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/types.dart';


class AdminSource extends ServiceSource {
  AdminSource({required super.services});

  late final personal = PersonalSource(this);

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
      await db.buildRegister(register);
      await db.buildSchedule(schedule);
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
      register.insertMember(await db.createMember(m));
  @override
  Future<Member> modifyMember(Member m) async {
    await db.updateMember(m);
    register.modifyMember(m);
    schedule.modifyMember(m);
    return m;
  }

  @override
  Future<Member> removeMember(Member m) async {
    await db.deleteMember(m);
    register.removeMember(m);
    schedule.removeMember(m);
    return m;
  }

  // Product ──────────────────────────────────────────────────────────────────
  @override
  Future<Product> insertProduct(Product p) async =>
      register.insertProduct(await db.createProduct(p));

  @override
  Future<Product> modifyProduct(Product p) async {
    await db.updateProduct(p);
    schedule.modifyProduct(p);
    register.modifyProduct(p);
    return p;
  }

  @override
  Future<Product> removeProduct(Product p) async {
    await db.deleteProduct(p);
    schedule.removeProduct(p);
    register.removeProduct(p);
    return p;
  }

  // Meeting ──────────────────────────────────────────────────────────────────
  Future<Meeting?> insertMeeting(Meeting m) async {
    try {
      return schedule.insertMeeting(await db.createMeeting(m));
    } on RegisterException catch (_) {
      await build();
    } catch (error) {
      debugPrint("createMeeting error: ${error.toString()}");
    }
    return null;
  }

  Future<Meeting?> modifyMeeting(Meeting m) async {
    try {
      schedule.modifyMeeting(m);
      await db.updateMeeting(m);
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
      schedule.removeMeeting(m);
      await db.deleteMeeting(m);
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
      final presence = await db.createPresence(p);
      schedule.insertPresence(presence);
      return presence;
    } catch (error) {
      debugPrint("createPresence error: ${error.toString()}");
    }
    return null;
  }

  Future<Presence?> modifyPresence(Presence p) async {
    try {
      await db.updatePresence(p);
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
      await db.deletePresence(p);
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
      await db.createSession(session);
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
      await db.updateSession(s);
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
      await db.deleteSession(s);
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
