import 'package:flutter/material.dart';
import 'package:egpt/admin/source_register.dart';
import 'package:egpt/admin/source_schedule.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
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

  void build() async {
    await Future.wait([_buildRegister()]);
    await Future.wait([_buildSchedule()]);
    notifyListeners();
  }

  Future<void> _buildRegister() async {
    register.members = await supabase.buildRegister();
  }

  Future<void>  _buildSchedule() async {
    schedule.appointments = await supabase.buildSchedule();
  }

  Future<Member> createMember(Member member) async {
    final _member = await supabase.createMember(member);
    register.createMember(_member);
    notifyListeners();
    return _member;
  }

  Future<Member> updateMember(Member member) async {
    await supabase.updateMember(member);
    register.updateMember(member);
    notifyListeners();
    return member;
  }

  Future<Member> deleteMember(Member member) async {
    await supabase.deleteMember(member);
    register.deleteMember(member);
    notifyListeners();
    return member;
  }

  Future<Product> createProduct(Product product) async {
    final _product = await supabase.createProduct(product);
    register.createProduct(_product);
    notifyListeners();
    return _product;
  }

  Future<Product> updateProduct(Product product) async {
    await supabase.updateProduct(product);
    register.updateProduct(product);
    notifyListeners();
    return product;
  }

  Future<Product> deleteProduct(Product product) async {
    await supabase.deleteProduct(product);
    register.deleteProduct(product);
    notifyListeners();
    return product;
  }

  Future<Meeting> insertMeeting(Meeting meeting) async {
    final _meeting = await supabase.createMeeting(meeting);
    schedule.insertMeeting(_meeting);
    return _meeting;
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    await supabase.updateMeeting(meeting);
    schedule.modifyMeeting(meeting);
    return meeting;
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    await supabase.deleteMeeting(meeting);
    schedule.removeMeeting(meeting);
    return meeting;
  }

}