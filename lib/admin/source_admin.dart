import 'package:flutter/material.dart';
import 'package:egpt/admin/source_register.dart';
import 'package:egpt/admin/source_schedule.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/services/supabase_service.dart';


class AdminSource extends ChangeNotifier{
  static final instance = AdminSource._singleton();
  final supabase = SupabaseService();
  final register = RegisterSource();
  final schedule = ScheduleSource();

  AdminSource._singleton();

  factory AdminSource() {
    return instance;
  }

  void reset() {
    register.members.clear();
    schedule.clear();
  }

  void build() async {
    await Future.wait([_buildRegister()]);
    await Future.wait([_buildSchedule()]);
  }

  Future<void> _buildRegister() async {
    register.members = await supabase.buildRegister();
  }

  Future<void>  _buildSchedule() async {
    schedule.append(await supabase.buildSchedule());
  }

  // ── Member ──────────────────────────────────────────────────────────────

  Member? _findMember(String id) =>
      register.members.where((m) => m.id == id).singleOrNull;

  Future<Member> createMember(Member member) async {
    register.createMember(member);
    notifyListeners();
    try {
      await supabase.createMember(member);
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
      await supabase.updateMember(member);
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
      await supabase.deleteMember(member);
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
      await supabase.createProduct(product);
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
      await supabase.updateProduct(product);
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
      await supabase.deleteProduct(product);
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
      final _meeting = await supabase.createMeeting(meeting);
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
      await supabase.updateMeeting(meeting);
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
      await supabase.deleteMeeting(meeting);
      return meeting;
    } catch (e) {
      schedule.insertMeeting(toDelete);
      notifyListeners();
      rethrow;
    }
  }
}
