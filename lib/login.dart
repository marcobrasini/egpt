import "package:flutter/material.dart";
import "package:flutter_login/flutter_login.dart";
import "package:egpt/services/supabase_service.dart";


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final supabase = SupabaseService();

  Future<String?> _login(LoginData data) async {
    final login = await supabase.signIn(
        email: data.name,
        password: data.password
    );
    if (login == null) {
      final role = await supabase.role;
      switch (role) {
        case "admin": return null;
        case "user": return null;
        default:
          return role;
      }
    }
    return login;
  }

  Future<String?> _recoverPassword(String name) =>
      supabase.recoverPassword(email: name);


  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'EGPT',
      onLogin: _login,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () async {
        final permission = await supabase.privileged;
        if (permission != null) {
          (permission)
              ? Navigator.of(context).pushReplacementNamed("/admin")
              : Navigator.of(context).pushReplacementNamed("/user");
        }
      },
    );
  }
}

