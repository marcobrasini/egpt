import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/session.dart';
import 'package:egpt/typedef.dart';


class MeetingCalendar<T extends Meeting> extends CalendarSource<T> implements EGPTData<T> {
  MeetingCalendar({super.label});

  List<T> get data => events;

  @override
  Map<String, T> get() => {for (final e in events) e.id!: e};

  @override
  void set(Iterable<T> events) {
    super.set(data.toList());
  }

  @override
  void add(Iterable<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      insertEvent(e, false);
    }
  }

  @override
  void put(Iterable<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      modifyEvent(e, false);
    }
  }

  @override
  void del(Iterable<T> items) {
    if (items.isEmpty) return;
    for (final e in items) {
      removeEvent(e, false);
    }
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
      meetingSource.find(id) ?? (throw MissingMeetingException(id));

  Session session(String id) =>
      sessionSource.find(id) ?? (throw MissingSessionException(id));


  Future<void> modifyMember(Member member) async {
    for (final product in member.products) {
      meetingSource.put(meetings.where((m) => m.product == product));
      sessionSource.put(sessions.where((s) => s.product == product));
    }
    notifyListeners();
  }

  Future<void> removeMember(Member member) async {
    for (final product in member.products) {
      meetingSource.del(meetings.where((m) => m.product == product));
      sessionSource.del(sessions.where((s) => s.product == product));
    }
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    meetingSource.del(meetings.where((m) => m.product == product));
    sessionSource.del(sessions.where((s) => s.product == product));
    notifyListeners();
  }

  Meeting insertMeeting(Meeting meeting) {
    meetingSource.insertEvent(meeting, true);
    return meeting;
  }

  Meeting modifyMeeting(Meeting meeting) {
    meetingSource.modifyEvent(meeting, true);
    return meeting;
  }

  Meeting removeMeeting(Meeting meeting) {
    meetingSource.removeEvent(meeting, true);
    return meeting;
  }

  Session insertSession(Session session) {
    sessionSource.insertEvent(session, true);
    return session;
  }

  Session modifySession(Session session) {
    sessionSource.modifyEvent(session, true);
    return session;
  }

  Session removeSession(Session session) {
    sessionSource.removeEvent(session, true);
    return session;
  }
}
