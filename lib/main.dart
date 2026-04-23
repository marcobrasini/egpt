import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egpt/admin/main_admin.dart';
import 'package:egpt/user/main_user.dart';
import 'package:egpt/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://nuxbtafdllyeeiozexzi.supabase.co",
    anonKey: "sb_publishable_VC7yPrSbOe9Bl6oJIKi3lA_K2PIQ0iW",
  );

  runApp(EGPTApp());
}


class EGPTApp extends StatelessWidget {
  const EGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it', 'IT'), // Italiano
        const Locale('en', 'US'), // Inglese
      ],
      locale: const Locale('it', 'IT'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => LoginPage(),
        "/user": (context) => UserPage(),
        "/admin": (context) => AdminPage(),
      },
    );
  }
}
