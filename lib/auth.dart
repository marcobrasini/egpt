import 'package:flutter/material.dart';
import 'services/supabase_service.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final navigator = Navigator.of(context);
    if (_supabase.session == null) {
      navigator.pushReplacementNamed("/login");
      return;
    }
    if (!mounted) return;
    navigator.pushReplacementNamed(
        _supabase.privileged == true
            ? "/admin"
            : "/user"
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(
          child: CircularProgressIndicator()
      )
  );
}