import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class MeetingCalendar<T extends Meeting> extends CalendarSource<T>
    implements EGPTData<T> {
  MeetingCalendar({super.label});

  List<T> get data => events;

  @override
  Map<String, T> get() => {for (final e in events) e.id!: e};

  @override
  void add(Iterable<T> items) {
    if (items.isEmpty) return;
    insertEvents(items, false);
  }

  @override
  void put(Iterable<T> items) {
    if (items.isEmpty) return;
    modifyEvents(items, false);
  }

  @override
  void del(Iterable<T> items) {
    if (items.isEmpty) return;
    removeEvents(items, false);
  }
}


typedef MeetingSource = MeetingCalendar<Meeting>;
typedef PresenceSource = MeetingCalendar<Presence>;


class ScheduleSource extends CalendarSources<Event> {
  static const meetingsLabel = 'meetings';
  static const presencesLabel = 'presences';

  static final instance = ScheduleSource._singleton(
    MeetingSource(label: meetingsLabel),
    PresenceSource(label: presencesLabel),
  );
  factory ScheduleSource() => instance;

  ScheduleSource._singleton(this.meetingSource, this.presenceSource)
    : super({meetingSource, presenceSource});

  final MeetingSource meetingSource;
  final PresenceSource presenceSource;

  List<Meeting> get meetings => meetingSource.events;
  List<Presence> get presences => presenceSource.events;

  void buildMeetings(List<Meeting> meetings) {
    meetingSource.set(meetings);
    notifyListeners();
  }
  void buildPresences(List<Presence> presences) {
    presenceSource.set(presences);
    notifyListeners();
  }

  // Register ─────────────────────────────────────────────────────────────────
  void modifyMember(Member member) {
    for (final product in member.products) {
      meetingSource.put(meetings.where((m) => m.productId == product.id).map((m) => m.copy()));
      presenceSource.put(presences.where((p) => p.productId == product.id).map((p) => p.copy()));
    }
    notifyListeners();
  }

  void removeMember(Member member) {
    for (final product in member.products) {
      meetingSource.del(meetings.where((m) => m.product == product));
      presenceSource.del(presences.where((s) => s.product == product));
    }
    notifyListeners();
  }

  void modifyProduct(Product product) {
    meetingSource.put(meetings.where((m) => m.product == product));
    presenceSource.put(presences.where((s) => s.product == product));
    notifyListeners();
  }

  void removeProduct(Product product) {
    meetingSource.del(meetings.where((m) => m.product == product));
    presenceSource.del(presences.where((s) => s.product == product));
    notifyListeners();
  }

  // Meeting ──────────────────────────────────────────────────────────────────
  Meeting meeting(String id) =>
      meetingSource.find(id) ?? (throw MissingMeetingException(id));

  Meeting insertMeeting(Meeting meeting) {
    meetingSource.insertEvents([meeting], true);
    return meeting;
  }

  Meeting modifyMeeting(Meeting meeting) {
    meetingSource.modifyEvents([meeting], true);
    return meeting;
  }

  Meeting removeMeeting(Meeting meeting) {
    meetingSource.removeEvents([meeting], true);
    return meeting;
  }

  // Presence ─────────────────────────────────────────────────────────────────
  Presence presence(String id) =>
      presenceSource.find(id) ?? (throw MissingPresenceException(id));

  Presence? presenceOrNull(String id) =>
      presenceSource.find(id);

  Presence insertPresence(Presence presence) {
    presenceSource.insertEvents([presence], true);
    return presence;
  }

  Presence modifyPresence(Presence presence) {
    presenceSource.modifyEvents([presence], true);
    return presence;
  }

  Presence removePresence(Presence presence) {
    presenceSource.removeEvents([presence], true);
    return presence;
  }
}
