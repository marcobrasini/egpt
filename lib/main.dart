import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egpt/admin/main_admin.dart';
import 'package:egpt/user/main_user.dart';
import 'package:egpt/login.dart';
import 'package:egpt/auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://nuxbtafdllyeeiozexzi.supabase.co",
    anonKey: "sb_publishable_VC7yPrSbOe9Bl6oJIKi3lA_K2PIQ0iW",
  );

  runApp(EGPTApp());
}

class EGPTApp extends StatefulWidget {
  const EGPTApp({super.key});

  @override
  State<EGPTApp> createState() => _EGPTAppState();
}

class _EGPTAppState extends State<EGPTApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState
            ?.pushNamedAndRemoveUntil("/login", (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it', 'IT'),
        const Locale('en', 'US'),
      ],
      locale: const Locale('it', 'IT'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      routes: {
        "/": (context) => const AuthGate(),
        "/login": (context) => LoginPage(),
        "/admin": (context) => AdminPage(),
        "/user": (context) => UserPage(),
      },
    );
  }
}
