import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:calendar/calendar.dart';
import '../api/provider_service.dart';
import '../api/calendar_service.dart';
import 'google_provider.dart';


typedef CalendarApi = gcal.CalendarApi;
typedef CalendarListEntry = gcal.CalendarListEntry;


class GoogleCalendar implements CalendarService {
  static const _scopes = [CalendarApi.calendarEventsScope];

  GoogleCalendar({required this.provider});

  final GoogleService provider;
  final GoogleCalendarSource source = GoogleCalendarSource();

  Future<GoogleSignInClientAuthorization?> get authorization async {
    final client = await provider.client;
    return await client.authorizationForScopes(_scopes);
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


  void eventFromGoogle(gcal.Event e) {
    if (e.id == null) return;
    if (e.id!.contains("_")) {
      source.exceptions.add(e.id!);
    }
    final start = e.start?.dateTime?.toTZ() ?? e.start?.date;
    final stop = e.end?.dateTime?.toTZ() ?? e.end?.date;
    if (start == null || stop == null) return;
    source.insertEvents([
      Event(
        id: e.id!,
        subject: e.summary ?? "(senza titolo)",
        color: Colors.grey,
        start: start,
        stop: stop,
        location: e.location,
        parentId: e.recurringEventId,
        pattern: (e.recurrence?.isNotEmpty ?? false)
            ? Pattern.fromICSString(e.recurrence!.join(""))
            : null,
      )
    ], false);
  }

  @override
  Future<CalendarSource> build([String calendarId = "primary"]) async {
    source.clear();
    final calendar = await api();
    final today = Date.now();
    String? page;
    do {
      final response = await calendar.events.list(calendarId,
        timeMin: Date(today.year, today.month - 6, today.days),
        timeMax: Date(today.year + 1, today.month, today.days),
        pageToken: page,
      );
      for (final event in response.items ?? const []) {
        eventFromGoogle(event);
      }
      page = response.nextPageToken;
    } while (page != null);
    return source..build();
  }
}


class GoogleCalendarSource extends CalendarSource {
  GoogleCalendarSource() : super(label: "google");

  final List<String> exceptions = [];

  @override
  void clear() {
    super.clear();
    notifyListeners();
  }

  void build() {
    for (final exception in exceptions) {
      final values = exception.split("_");
      final exdate = DateTime.parse(values[1]).toTZ();
      if (find(values[0]) case final event?) {
        if (event.pattern?.addException(exdate) case final pattern?) {
          modifyEvents([event.setPattern(pattern)], false);
        }
      }
    }
    exceptions.clear();
    notifyListeners();
  }
}