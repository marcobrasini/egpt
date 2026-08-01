import 'package:egpt/models/meeting.dart';
import 'package:egpt/services/api/calendar_service.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:egpt/services/api/provider_service.dart';
import 'google_provider.dart';


class GoogleCalendar implements CalendarService {
  static const _scopes = [CalendarApi.calendarEventsScope];

  GoogleCalendar({required this.provider});

  final GoogleService provider;

  GoogleSignInClientAuthorization? _authorization;
  Future<GoogleSignInClientAuthorization?> get authorization async {
    final client = await provider.client;
    _authorization ??= await client.authorizationForScopes(_scopes);
    return _authorization;
  }

  @override
  Future<bool> get authorized async => await authorization != null;

  @override
  Future<void> authorize() async {
    try {
      final client = await provider.client;
      await client.authorizeScopes(_scopes);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const IdentityCancelled();
      }
      throw IdentityFailure(
          "GoogleCalendar error ${error.code.name}: ${error.details}"
      );
    }
  }

  Future<CalendarApi> api() async {
    final apiAuthorization = await authorization;
    if (apiAuthorization == null) {
      throw const IdentityFailure("GoogleCalendar access refused.");
    }
    return CalendarApi(apiAuthorization.authClient(scopes: _scopes));
  }

  Future<List<CalendarListEntry>> calendars() async {
    final apiCalendar = await api();
    final list = await apiCalendar.calendarList.list();
    return list.items ?? const [];
  }

  Future<List<Event>> events([String calendarId = "primary"]) async {
    if (!await authorized) await authorize();
    final apiCalendar = await api();
    final eventsCalendar = <Event>[];
    String? page;
    do {
      final response = await apiCalendar.events.list(
        calendarId,
        pageToken: page,
      );
      for (final event in response.items ?? const <Event>[]) {
        eventsCalendar.add(event);
      }
      page = response.nextPageToken;
    } while (page != null);
    return eventsCalendar;
  }

  static Event meetingToGoogle(Meeting meeting) => Event(
    id: meeting.id,
    summary: meeting.subject,
    start: EventDateTime(dateTime: meeting.start, timeZone: 'UTC'),
    end: EventDateTime(dateTime: meeting.stop, timeZone: 'UTC'),
    attendees: [
      EventAttendee(
        id: meeting.product.id!,
        displayName: meeting.member.id!),
    ],
    recurrence: (meeting.pattern != null) ? [meeting.pattern!.toICSString()] : null,
    recurringEventId: meeting.parentId,
  );

  static Meeting googleToMeeting(Event event) => Meeting.build(
    id: event.id!,
    memberId: event.attendees![0].displayName!,
    productId: event.attendees![0].id!,
    start: event.start!.dateTime!,
    stop: event.end!.dateTime!,
    patternRule: event.recurrence?[0],
  );

  @override
  Future<List<Meeting>> meetings() async {
    final eventsCalendar = await events();
    print(eventsCalendar);
    return [];
    return eventsCalendar.map((event) => googleToMeeting(event)).toList();
  }

  @override
  Future<void> createMeeting(Meeting meeting) async {
    final calendar = await api();
    final event = meetingToGoogle(meeting);
    calendar.events.insert(event, "primary");
  }

  @override
  Future<void> updateMeeting(Meeting meeting) async {
    final calendar = await api();
    final event = meetingToGoogle(meeting);
    calendar.events.update(event, "primary", meeting.id!);
  }

  @override
  Future<void> deleteMeeting(Meeting meeting) async {
    final calendar = await api();
    calendar.events.delete("primary", meeting.id!);
  }
}