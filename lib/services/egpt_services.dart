import "package:egpt/services/device_service.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "api/auth_service.dart";
import "api/database_service.dart";
import "api/provider_service.dart";
import "api/calendar_service.dart";


class EGPTServices {

  EGPTServices({
    required this.auth,
    required this.database,
    this.providers = const [],
  });

  final AuthService auth;
  final DatabaseService database;
  final DeviceCalendar device = DeviceCalendar(
    excluded: {"${dotenv.get('EGPT_ROOT')}:${dotenv.get('EGPT_CALENDAR')}"}
  );
  final List<ProviderService> providers;

  bool get root => auth.email == dotenv.get('EGPT_ROOT');

  CalendarService? get calendar {
    return device;
    if (root) return null;
    final linked = auth.identities;
    for (final provider in providers) {
      if (linked.contains(provider.identity)) {
        return provider.calendar;
      }
    }
    return null;
  }

  Future<void> signOut() async {
    for (final provider in providers) {
      await provider.signOut();
    }
    await database.reset();
    await auth.signOut();
  }
}
