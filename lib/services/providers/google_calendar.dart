import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:calendar/calendar.dart';
import '../api/provider_service.dart';
import '../api/calendar_service.dart';
import '../../models/meeting.dart';
import 'google_provider.dart';


typedef CalendarApi = gcal.CalendarApi;
typedef CalendarListEntry = gcal.CalendarListEntry;


class GoogleCalendar implements CalendarService {
  static const _scopes = [CalendarApi.calendarEventsScope];

  GoogleCalendar({required this.provider});

  final GoogleService provider;

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

  @override
  Future<List<Event>> listEvents([String calendarId = "primary"]) async {
    if (!await authorized) await authorize();
    final apiCalendar = await api();
    final events = <Event>[];
    String? page;
    do {
      final response = await apiCalendar.events.list(
        calendarId,
        pageToken: page,
      );
      for (final event in response.items ?? const <Event>[]) {
        events.add(EGPTfromGoogle(event as gcal.Event));
      }
      page = response.nextPageToken;
    } while (page != null);
    return events;
  }

  static String uuidToGoogle(String uuid) => uuid.replaceAll("-", "");

  static String googleToUuid(String hex) => '${hex.substring(0,8)}-'
      '${hex.substring(8,12)}-${hex.substring(12,16)}-${hex.substring(16,20)}'
      '-${hex.substring(20)}';

  static Event EGPTfromGoogle(gcal.Event event) => Event(
    id: event.id!,
    subject: event.summary!,
    color: Colors.grey,
    start: event.start!.dateTime!,
    stop: event.end!.dateTime!,
    pattern: event.recurrence != null
        ? Pattern.fromICSString(event.recurrence!.join(""))
        : null,
  );
}