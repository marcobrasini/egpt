import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egpt/types.dart';
import 'api/provider_service.dart';
import 'api/auth_service.dart';


class SupabaseService extends ChangeNotifier implements AuthService {

  static OAuthProvider _oAuth(ProviderService provider) =>
      switch (provider.identity) {
        ProviderIdentity.google => OAuthProvider.google,
        ProviderIdentity.apple  => OAuthProvider.apple,
      };

  static final _instance = SupabaseService._singleton();
  SupabaseService._singleton() {
    _authSubscription = client.auth.onAuthStateChange.listen((_) {
      _initialized = true;
      notifyListeners();
    });
  }
  factory SupabaseService() => _instance;

  late final StreamSubscription<AuthState> _authSubscription;

  @override SupabaseClient get client => Supabase.instance.client;
  @override Session? get session => client.auth.currentSession;
  User? get user => client.auth.currentUser;

  @override
  bool get initialized => _initialized;
  bool _initialized = false;

  @override
  Future<String?> signIn({required String email, required String password}) async {
    try {
      final result = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.user == null) return "Login failed.";
      if (role == null) return "User role undefined.";
      return null;
    } on AuthException catch (error) {
      return "Authentication error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  @override
  Future<String?> signInWith({required ProviderService provider}) async {
    try {
      final tokens = await provider.authenticate();
      await client.auth.signInWithIdToken(
        provider: _oAuth(provider),
        idToken: tokens.identityToken,
        accessToken: tokens.accessToken,
        nonce: tokens.rawNonce,
      );
      if (user == null) return "Login failed.";
      if (role == null) return "User role undefined.";
      return null;
    } on IdentityCancelled catch (error) {
      return error.toString();
    } on IdentityFailure catch (error) {
      return error.message;
    } on AuthException catch (error) {
      return "Authentication error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  @override
  Future<String?> recoverPassword({required String email}) async => null;

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  void dispose() {
    unawaited(_authSubscription.cancel());
    super.dispose();
  }

  @override
  AuthRole? get role {
    final token = session?.accessToken;
    if (token == null) return null;
    return AuthRole.parse(_decode(token)?['auth_role'] as String?);
  }

  @override
  bool get privileged => role == AuthRole.admin;

  DataMap? _decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return jsonDecode(utf8.decode(payload)) as DataMap;
  }
}

