// import "dart:convert";
// import "dart:math";
// import 'package:flutter/foundation.dart';
// import "package:crypto/crypto.dart";
// import "package:sign_in_with_apple/sign_in_with_apple.dart";c'e
// import "package:egpt/services/provider_service.dart";
// import "package:egpt/services/provider_identity.dart";
//
// bool get isApplePlatform =>
//     defaultTargetPlatform == TargetPlatform.iOS ||
//         defaultTargetPlatform == TargetPlatform.macOS;
//
// class AppleService implements ProviderService {
//
//   static final instance = AppleService._singleton();
//   AppleService._singleton();
//
//   factory AppleService() => instance;
//
//   static const _alphabet =
//       "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._";
//
//   @override
//   ProviderIdentity get identity => ProviderIdentity.apple;
//
//   @override
//   String get label => "Apple";
//
//   @override
//   bool get available => isApplePlatform;
//
//   @override
//   Future<void> initialize() async {}
//
//   String _nonce([int length = 32]) {
//     final random = Random.secure();
//     return List.generate(
//       length,
//           (_) => _alphabet[random.nextInt(_alphabet.length)],
//     ).join();
//   }
//
//   @override
//   Future<ProviderTokens> authenticate() async {
//     final raw = _nonce();
//     final hashed = sha256.convert(utf8.encode(raw)).toString();
//     try {
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: const [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         nonce: hashed,
//       );
//
//       final identityToken = credential.identityToken;
//       if (identityToken == null) {
//         throw const IdentityFailure("Apple provided no ID token.");
//       }
//       return ProviderTokens(
//         identity: ProviderIdentity.apple,
//         identityToken: identityToken,
//         rawNonce: raw,
//       );
//     } on SignInWithAppleAuthorizationException catch (error) {
//       if (error.code == AuthorizationErrorCode.canceled) {
//         throw const IdentityCancelled();
//       }
//       throw IdentityFailure("Apple error: ${error.message}");
//     } on SignInWithAppleException catch (error) {
//       throw IdentityFailure("Apple error: ${error.message}");
//     }
//   }
//
//   /// Apple non espone alcuna revoca lato client: la sessione vive solo
//   /// dentro Supabase, quindi qui non c'è niente da fare.
//   @override
//   Future<void> signOut() async {}
// }
