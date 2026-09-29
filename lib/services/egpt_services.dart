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
  final List<ProviderService> providers;
  CalendarService? get calendar {
    final linked = auth.identities;
    for (final provider in providers) {
      if (linked.contains(provider.identity)) return provider.calendar;
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
