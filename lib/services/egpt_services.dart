import "package:egpt/services/api/auth_service.dart";
import "package:egpt/services/api/calendar_service.dart";
import "package:egpt/services/api/database_service.dart";
import "package:egpt/services/api/provider_service.dart";


class EGPTServices {

  const EGPTServices({
    required this.auth,
    required this.database,
    required this.calendar,
    this.providers = const [],
  });

  final AuthService auth;
  final DatabaseService database;
  final CalendarService calendar;
  final List<ProviderService> providers;

  Future<void> signOut() async {
    for (final provider in providers) {
      await provider.signOut();
    }
    await auth.signOut();
  }
}
