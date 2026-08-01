import "package:flutter/material.dart";
import "package:flutter_login/flutter_login.dart";
import "package:egpt/services/supabase_service.dart";
import "package:egpt/services/api/provider_service.dart";
import "package:egpt/services/providers/google_provider.dart";


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final supabase = SupabaseService();
  static final List<ProviderService> providers = [
    GoogleService(),
  ];

  Future<String?> _login(LoginData data) => supabase.signIn(
    email: data.name.trim(),
    password: data.password,
  );

  Future<String?> _recoverPassword(String email) =>
      supabase.recoverPassword(email: email.trim());


  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'EGPT',
      userType: LoginUserType.email,
      onLogin: _login,
      onRecoverPassword: _recoverPassword,
      navigateBackAfterRecovery: true,
      onSubmitAnimationCompleted: () =>
          Navigator.of(context).pushReplacementNamed("/"),

      loginProviders: [
        for (final provider in providers)
          if (provider.available)
            LoginProvider(
              icon: provider.icon,
              label: provider.label,
              callback: () => supabase.signInWith(provider),
            ),
      ],

      messages: LoginMessages(
        userHint: "Email",
        passwordHint: "Password",
        forgotPasswordButton: "Password dimenticata?",
        loginButton: "ACCEDI",
        recoverPasswordButton: "INVIA",
        recoverPasswordIntro: "Reimposta la tua password",
        recoverPasswordDescription:
        "Inserisci l'email del tuo account: riceverai un link "
            "per impostare una nuova password.",
        recoverPasswordSuccess: "Link inviato",
        goBackButton: "INDIETRO",
        flushbarTitleError: "Errore",
        flushbarTitleSuccess: "Fatto",
      ),

      theme: LoginTheme(
        primaryColor: Theme.of(context).colorScheme.primary,
        errorColor: Theme.of(context).colorScheme.error,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

