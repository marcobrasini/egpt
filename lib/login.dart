import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_login/flutter_login.dart";
import "package:egpt/services/services.dart";


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.read<EGPTServices>();

    return FlutterLogin(
      title: 'EGPT',
      userType: LoginUserType.email,
      onLogin: (data) => services.auth.signIn(
        email: data.name.trim(),
        password: data.password,
      ),
      onRecoverPassword: (email) => services.auth.recoverPassword(email: email),
      navigateBackAfterRecovery: true,
      loginProviders: [
        for (final provider in services.providers)
          if (provider.available)
            LoginProvider(
              icon: provider.icon,
              label: provider.label,
              callback: () => services.auth.signInWith(provider: provider),
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