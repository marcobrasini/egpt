import "package:flutter/material.dart";
import "provider_service.dart";


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


abstract class AuthService extends ChangeNotifier {

  Future<String?> signIn({required String email, required String password});

  Future<String?> signInWith({required ProviderService provider});

  Future<String?> recoverPassword({required String email});

  Future<void> signOut();

  Object? get client;

  Object? get session;

  AuthRole? get role;

  bool get privileged;

  bool get initialized;
}
