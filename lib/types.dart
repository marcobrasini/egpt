import 'package:egpt/sources/sources.dart';


typedef DataMap = Map<String, dynamic>;

typedef EGPTMake<T> = T Function(DataMap);


abstract interface class EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();

  final String? id;
  EGPTItem({this.id});

  DataMap get();
  EGPTItem set(DataMap data);
}

extension Let<T extends EGPTItem> on T {
  R let<R>(R Function(T) f) => f(this);
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

class MissingPresenceException extends ScheduleException {
  const MissingPresenceException(this.id);
  final String? id;
}

class MissingMeetingException extends ScheduleException {
  const MissingMeetingException(this.id);
  final String? id;
}


class PersonalException implements Exception {
  const PersonalException();
}

class MissingSessionException extends PersonalException {
  const MissingSessionException(this.id);
  final String? id;
}