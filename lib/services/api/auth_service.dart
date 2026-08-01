import "package:egpt/services/api/provider_service.dart";


enum AuthRole {
  admin,
  user;

  static AuthRole? parse(String? value) {
    for (final role in AuthRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }
}


abstract class AuthService {

  Future<String?> signIn({required String email, required String password});

  Future<String?> signInWith(ProviderService provider);

  Future<String?> recoverPassword({required String email});

  Future<void> signOut();

  AuthRole? get role;

  bool get privileged;
}
