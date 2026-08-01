import 'package:egpt/models/meeting.dart';


abstract class CalendarService {

  Future<bool> get authorized;

  Future<void> authorize();

  Future<void> createMeeting(Meeting meeting);

  Future<void> updateMeeting(Meeting meeting);

  Future<void> deleteMeeting(Meeting meeting);

  Future<List<Meeting>> meetings();
}