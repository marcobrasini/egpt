import 'package:flutter/foundation.dart';
import 'package:egpt/services/services.dart';
import 'package:egpt/models/models.dart';
import 'source_register.dart';
import 'source_schedule.dart';


abstract class ServiceSource extends ChangeNotifier {
  ServiceSource({required this.services});

  final EGPTServices services;
  String? get email => services.auth.email;
  String? get name => services.auth.name;

  final register = RegisterSource();
  final schedule = ScheduleSource();
  DatabaseService get database => services.database;
  CalendarService? get calendar => services.calendar;

  Future<void> build();

  Future<Member> insertMember(Member member);
  Future<Member> modifyMember(Member member);
  Future<Member> removeMember(Member member);

  Future<Product> insertProduct(Product product);
  Future<Product> modifyProduct(Product product);
  Future<Product> removeProduct(Product product);

  Future<Session?> insertSession(Session session);
  Future<Session?> modifySession(Session session);
  Future<Session?> removeSession(Session session);
}