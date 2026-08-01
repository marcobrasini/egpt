import 'package:egpt/services/egpt_services.dart';
import 'package:egpt/services/providers/google_provider.dart';
import 'package:egpt/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egpt/admin/admin_main.dart';
import 'package:egpt/user/main_user.dart';
import 'package:egpt/login.dart';
import 'package:egpt/auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://nuxbtafdllyeeiozexzi.supabase.co",
    anonKey: "sb_publishable_VC7yPrSbOe9Bl6oJIKi3lA_K2PIQ0iW",
  );

  final supabase = SupabaseService();
  final google = GoogleService();

  runApp(EGPTApp(
    services: EGPTServices(
      auth: supabase,
      database: supabase,
      calendar: google.calendar,
      providers: [google],
    ),
  ));
}

class EGPTApp extends StatefulWidget {
  const EGPTApp({
    super.key,
    required this.services
  });

  final EGPTServices services;

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
    return Provider<EGPTServices>.value(
      value: widget.services,
      child: MaterialApp(
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
      ),
    );
  }
}
