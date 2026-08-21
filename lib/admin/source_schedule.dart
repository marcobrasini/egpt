import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/session.dart';


class ScheduleSource extends CalendarSources<Meeting> {
  static const meetingsLabel = 'meetings';
  static const sessionsLabel = 'sessions';

  static final instance = ScheduleSource._singleton();
  factory ScheduleSource() => instance;

  ScheduleSource._singleton() : super({
    CalendarSource<Meeting>(label: meetingsLabel),
    CalendarSource<Session>(label: sessionsLabel),
  });

  CalendarSource<Meeting> get meetingSource => source(meetingsLabel);
  CalendarSource<Session> get sessionSource =>
      source(sessionsLabel) as CalendarSource<Session>;

  List<Meeting> get meetings => meetingSource.events;
  List<Session> get sessions => sessionSource.events;

  Meeting meeting(String meetingId) {
    final meeting = meetingSource.find(meetingId);
    if (meeting == null) throw("No meeting with id: $meetingId");
    return meeting;
  }

  Session session(String sessionId) {
    final session = sessionSource.find(sessionId);
    if (session == null) throw("No session with id: $sessionId");
    return session;
  }

  Future<Meeting> insertMeeting(Meeting meeting) async {
    meetingSource.insertEvent(meeting);
    return meeting;
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    meetingSource.modifyEvent(meeting);
    return meeting;
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    for (final m in meetings.where((m) => m.parentId == meeting.id)) {
      m.parentId = meeting.parentId;
    }
    meetingSource.removeEvent(meeting);
    return meeting;
  }

  Future<Session> insertSession(Session session) async {
    sessionSource.insertEvent(session);
    return session;
  }

  Future<Session> modifySession(Session session) async {
    sessionSource.modifyEvent(session);
    return session;
  }

  Future<Session> removeSession(Session session) async {
    sessionSource.removeEvent(session);
    return session;
  }
}
