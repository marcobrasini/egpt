import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/providers/google_provider.dart';
import 'services/services.dart';
import 'style.dart';
import 'auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TimeZones.initialize('Europe/Rome');

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<EGPTServices>.value(value: services),
      ],
      builder: (context, _) => MaterialApp(
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: colorSeed,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: colorSeed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: context.watch<ThemeController>().mode,
        builder: (context, child) {
          Intl.defaultLocale = Localizations.localeOf(context).toString();
          return child!;
        },
        home: const AuthGate(),
      ),
    );
  }
}
