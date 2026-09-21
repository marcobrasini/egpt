import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/providers/google_provider.dart';
import 'services/api/auth_service.dart';
import 'services/supabase_service.dart';
import 'services/powersync_service.dart';
import 'services/egpt_services.dart';
import 'auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = SupabaseService();
  final database = PowerSyncService(supabase);
  await database.open();

  runApp(EGPTApp(
    services: EGPTServices(
      auth: supabase,
      database: database,
      providers: [
        GoogleService(),
      ],
    ),
  ));
}


class EGPTApp extends StatelessWidget {
  const EGPTApp({
    super.key,
    required this.services,
  });

  final EGPTServices services;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: services.auth),
        Provider<EGPTServices>.value(value: services),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
          Locale('en', 'US'),
        ],
        locale: const Locale('it', 'IT'),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}