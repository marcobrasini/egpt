import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/session.dart';
import 'package:egpt/typedef.dart';


class MeetingCalendar<T extends Meeting> extends CalendarSource<T> implements EGPTData<T> {
  MeetingCalendar({super.label});

  @override
  List<T> get data => events;

  @override
  Map<String, T> get() => {for (final e in events) e.id!: e};

  @override
  void add(List<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      insertEvent(e, false);
    }
    notifyListeners();
  }

  @override
  void put(List<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      modifyEvent(e, false);
    }
    notifyListeners();
  }

  @override
  void del(List<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      removeEvent(e, false);
    }
    notifyListeners();
  }
}


typedef MeetingSource = MeetingCalendar<Meeting>;
typedef SessionSource = MeetingCalendar<Session>;


class ScheduleSource extends CalendarSources<Meeting> {
  static const meetingsLabel = 'meetings';
  static const sessionsLabel = 'sessions';

  static final instance = ScheduleSource._singleton(
    MeetingSource(label: meetingsLabel),
    SessionSource(label: sessionsLabel),
  );
  factory ScheduleSource() => instance;

  ScheduleSource._singleton(this.meetingSource, this.sessionSource)
      : super({meetingSource, sessionSource});

  final MeetingSource meetingSource;
  final SessionSource sessionSource;

  List<Meeting> get meetings => meetingSource.events;
  List<Session> get sessions => sessionSource.events;

  void buildMeeting(List<Meeting> meetings) => meetingSource.set(meetings);

  void buildSession(List<Session> sessions) =>  sessionSource.set(sessions);

  Meeting meeting(String id) =>
      meetingSource.find(id) ?? (throw 'No meeting with id: $id');

  Session session(String id) =>
      sessionSource.find(id) ?? (throw 'No session with id: $id');
}
