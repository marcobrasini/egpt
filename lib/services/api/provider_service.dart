import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


enum ProviderIdentity {
  google,
  apple
}


class ProviderTokens {
  const ProviderTokens({
    required this.identity,
    required this.identityToken,
    this.accessToken,
    this.rawNonce,
  });

  final ProviderIdentity identity;
  final String identityToken;
  final String? accessToken;
  final String? rawNonce;
}


abstract class ProviderService {

  ProviderIdentity get identity;

  IconData get icon;

  String get label;

  OAuthProvider get oAuth;

  bool get available => true;

  Future<void> initialize() async {}

  Future<ProviderTokens> authenticate();

  Future<void> signOut() async {}
}

class IdentityCancelled implements Exception {
  const IdentityCancelled();
  @override toString() => "Authentication cancelled.";
}


class IdentityFailure implements Exception {
  final String message;
  const IdentityFailure(this.message);
  @override toString() => message;
}


bool get isApplePlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
