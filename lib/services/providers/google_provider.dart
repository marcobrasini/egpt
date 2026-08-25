import "package:egpt/services/providers/google_calendar.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:egpt/services/api/provider_service.dart";


class GoogleService implements ProviderService {

  static const _scopes = ["email", "profile"];
  static const _webClientId = "916778905809-dasm6f3n19s6dikq494i35qa6pp1pu91.apps.googleusercontent.com";
  static const _iosClientId = "916778905809-67sj1b31rvda56h07ilad83rc3r8iscn.apps.googleusercontent.com";
  static final instance = GoogleService._singleton();
  GoogleService._singleton();

  factory GoogleService() => instance;
  late final GoogleCalendar calendar = GoogleCalendar(provider: this);

  @override get identity => ProviderIdentity.google;
  @override get oAuth => OAuthProvider.google;
  @override get icon => FontAwesomeIcons.google;
  @override get label => "Google";
  @override get available => true;

  bool _ready = false;

  GoogleSignInAccount? _account;
  Future<GoogleSignInAccount> get account async {
    await initialize();
    _account ??= await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (_account == null) {
      throw const IdentityFailure("No Google account associated.");
    }
    return _account!;
  }

  GoogleSignInAuthorizationClient? _client;
  Future<GoogleSignInAuthorizationClient> get client async {
    _client ??= (await account).authorizationClient;
    if (_client == null) {
      throw const IdentityFailure("No Google client associated.");
    }
    return _client!;
  }

  @override
  Future<void> initialize() async {
    if (_ready) return;
    await GoogleSignIn.instance.initialize(
      clientId: isApplePlatform ? _iosClientId : null,
      serverClientId: _webClientId,
    );
    _ready = true;
  }

  @override
  Future<ProviderTokens> authenticate() async {
    try {
      await initialize();
      _account = await GoogleSignIn.instance.authenticate();
      final authenticatedAccount = await account;
      final authenticationToken = authenticatedAccount.authentication.idToken;
      if (authenticationToken == null) {
        throw const IdentityFailure("No Google token provided.");
      }
      final authenticatedClient = await client;
      final authorization =
          await authenticatedClient.authorizationForScopes(_scopes)
              ?? await authenticatedClient.authorizeScopes(_scopes);
      return ProviderTokens(
        identity: ProviderIdentity.google,
        identityToken: authenticationToken,
        accessToken: authorization.accessToken,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const IdentityCancelled();
      }
      throw IdentityFailure(
          "Google error ${error.code.name}: ${error.description}"
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (!_ready) return;
    await GoogleSignIn.instance.signOut();
  }

}
