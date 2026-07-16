import 'dart:math';
import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';


class Product {

  static const _warning = 10;

  final String? id;
  final String memberId;
  String summary;
  int length;
  Date start;
  Date stop;
  int todo;
  int redo;
  int done;

  Product({
    this.id,
    required this.memberId,
    required this.summary,
    required this.length,
    required this.start,
    required this.stop,
    this.todo = 0,
    this.redo = 0,
    this.done = 0,
  });

  factory Product.make({
    String? id,
    required Map<String, dynamic> data
  }) => Product(
    id: id,
    memberId: data['memberId'],
    summary: data['summary'],
    length: data['length'],
    start: data['start'],
    stop: data['stop'],
  );

  Map<String, dynamic> get() => {
    'memberId': memberId,
    'summary': summary,
    'length': length,
    'start': start,
    'stop': stop,
  };

  Product set(Map<String, dynamic> data) {
    length = data['length'];
    summary = data['summary'];
    start = data['start'];
    stop = data['stop'];
    return this;
  }

  int get duration => stop % start;
  int get pastDays => min(max(Date.now() % start, 0), duration);
  int get leftDays => min(max(stop % Date.now(), 0), duration);
  String get recap => "$summary ($done($redo)/$length)";

  bool isComplete() => done >= length;
  bool isStarted() => start <= Date.now();
  bool isExpired() => stop <= Date.now();
  bool isWarning() => stop % Date.now() <= _warning;
  bool isOngoing() => isStarted() && !isExpired();
  bool isValid() => isOngoing() && !isComplete();

  Color statusColor() {
    if (isComplete()) {
      return Colors.green;
    } else if (isExpired()) {
      return Colors.red;
    } else if (isWarning()) {
      return Colors.yellow;
    } else if (isOngoing()) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }
}