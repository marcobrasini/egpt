import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_login/flutter_login.dart";
import "package:egpt/services/services.dart";


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final services = context.read<EGPTServices>();
    return FlutterLogin(
      logo: const AssetImage('assets/logo/logo.png'),
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
        logoWidth: 80.0,
        pageColorLight: scheme.surface,
        pageColorDark: scheme.primary,
        primaryColor: scheme.primary,
        errorColor: scheme.error,
        titleStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
    );
  }
}