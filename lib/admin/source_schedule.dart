import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';


class ScheduleSource extends CalendarSource<Meeting> {
  static final instance = ScheduleSource._singleton();
  ScheduleSource._singleton();
  factory ScheduleSource() {
    return instance;
  }

  List<Meeting> get meetings => events;

  Meeting meeting(String meetingId) => super.find(meetingId);

  Future<Meeting> insertMeeting(Meeting meeting) async {
    insertEvent(meeting);
    return meeting;
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    modifyEvent(meeting);
    return meeting;
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    for (final m in meetings.where((m) => m.parentId == meeting.id)) {
      m.parentId = meeting.parentId;
    }
    removeEvent(meeting);
    return meeting;
  }

}
