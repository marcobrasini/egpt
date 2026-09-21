import 'package:calendar/calendar.dart';


abstract class CalendarService {

  Future<bool> get authorized;

  Future<void> authorize();

  Future<List<Event>> listEvents();
}