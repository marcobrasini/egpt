import 'package:egpt/sources/source_register.dart';
import 'package:equatable/equatable.dart';

typedef DataMap = Map<String, dynamic>;

typedef EGPTMake<T> = T Function(DataMap);


abstract interface class EGPTItem {
  static final register = RegisterSource();

  final String? id;
  EGPTItem({this.id});

  DataMap get();
  EGPTItem set(DataMap data);
}


abstract interface class EGPTData<T extends EGPTItem> {
  Map<String, T> get();
  void set(Iterable<T> data);
  void add(Iterable<T> items);
  void put(Iterable<T> items);
  void del(Iterable<T> items);
}


class RegisterException implements Exception {
  const RegisterException();
}

class MissingMemberException extends RegisterException {
  const MissingMemberException(this.id);
  final String? id;
}

class MissingProductException extends RegisterException {
  const MissingProductException(this.id);
  final String? id;
}

class ScheduleException implements Exception {
  const ScheduleException();
}

class MissingSessionException extends ScheduleException {
  const MissingSessionException(this.id);
  final String? id;
}

class MissingMeetingException extends ScheduleException {
  const MissingMeetingException(this.id);
  final String? id;
}