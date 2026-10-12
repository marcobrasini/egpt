import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';


abstract class CalendarService {

  Future<bool> get authorized;

  Future<void> authorize();

  Future<List<CalendarSource>> build();
}