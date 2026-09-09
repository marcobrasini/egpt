import "api/auth_service.dart";
import "api/database_service.dart";
import "api/provider_service.dart";


class EGPTServices {

  const EGPTServices({
    required this.auth,
    required this.database,
    this.providers = const [],
  });

  final AuthService auth;
  final DatabaseService database;
  final List<ProviderService> providers;

  Future<void> signOut() async {
    for (final provider in providers) {
      await provider.signOut();
    }
    await database.reset();
    await auth.signOut();
  }
}
