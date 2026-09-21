import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class Product extends Equatable implements EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();
  static const _warning = 10;

  @override final String? id;
  final String memberId;
  final String summary;
  final int length;
  final Date start;
  final Date stop;

  const Product({
    this.id,
    required this.memberId,
    required this.summary,
    required this.length,
    required this.start,
    required this.stop,
  });

  factory Product.make({
    String? id,
    required DataMap data
  }) => Product(
    id: id,
    memberId: data['memberId'],
    summary: data['summary'],
    length: data['length'],
    start: data['start'],
    stop: data['stop'],
  );

  // factory Product.build({
  //   required String id,
  //   required String memberId,
  //   required String summary,
  //   required int length,
  //   required Date start,
  //   required Date stop,
  // }) => Product(
  //   id: id,
  //   memberId: memberId,
  //   summary: summary,
  //   length: length,
  //   start: start,
  //   stop: stop,
  // );

  @override
  DataMap get() => {
    'id': id,
    'memberId': memberId,
    'summary': summary,
    'length': length,
    'start': start,
    'stop': stop,
  };

  @override
  Product set(DataMap data) => Product(
    id: id,
    memberId: memberId,
    summary: data['summary'] ?? summary,
    length: data['length'] ?? length,
    start: data['start'] ?? start,
    stop: data['stop'] ?? stop,
  );

  Member get member => register.member(memberId);

  List<Meeting> get meetings => schedule.meetings.where((m) => m.productId == id).toList();

  List<Presence> get presences => schedule.presences.where((s) => s.productId == id).toList();

  int get redo => presences.where((s) => !s.presence).length;
  int get done => presences.where((s) =>  s.presence).length;

  int get duration => stop % start;
  int get pastDays => min(max(Date.now() % start, 0), duration);
  int get leftDays => min(max(stop % Date.now(), 0), duration);
  String get recap => "$done($redo)/$length";

  bool isComplete() => done >= length;
  bool isStarted() => start <= Date.now();
  bool isExpired() => stop <= Date.now();
  bool isWarning() => stop % Date.now() <= _warning;
  bool isOngoing() => isStarted() && !isExpired();
  bool isValid() => isOngoing() && !isComplete();

  @override
  List<Object?> get props => [id, memberId, summary, length, start, stop];
}