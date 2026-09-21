import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';
import 'admin/admin_main.dart';
import 'user/user_main.dart';
import 'login.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.session == null) return const LoginPage();
    return auth.privileged
        ? const AdminPage()
        : const UserPage();
  }
}