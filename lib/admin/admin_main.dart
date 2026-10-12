import 'dart:async';
import 'package:egpt/widgets/separator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:egpt/services/services.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/style.dart';
import 'admin_schedule.dart';
import 'admin_register.dart';
import 'admin_presence.dart';
import 'source_admin.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final AdminSource admin;

  void _logout() async {
    await admin.services.signOut();
  }

  Widget mainDrawer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: scheme.primary),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset('assets/logo.png', height: 72),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amministratore',
                        style: TextStyle(color: scheme.onPrimary, fontSize: 24),
                      ),
                      FittedBox(
                        child: Text(admin.email ?? "",
                          style: TextStyle(color: scheme.onPrimary),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListenableBuilder(
              listenable: admin.schedule,
              builder: (context, _) {
                final schedule = admin.schedule;
                final device = admin.services.device.sources.sources;
                return Column(
                  children: [
                    const Separator(text: "Calendario"),
                    _sourceTile('Appuntamenti', schedule.meetingSource),
                    _sourceTile('Sessioni', schedule.presenceSource),
                    if (device.isNotEmpty) ...[
                      const Separator(text: "Privato"),
                      for (final source in device) _deviceTile(source),
                    ],
                    const Divider(),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: (scheme.brightness == Brightness.light)
                  ? Text('Stile: Chiaro')
                  : Text('Stile: Scuro'),
              trailing: const ThemeSwitch(),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Logout', style: TextStyle(color: scheme.error)),
              onTap: () => _logout(),
            ),
          ],
        ),
      );
    }

  @override
  void initState() {
    super.initState();
    admin = AdminSource(services: context.read<EGPTServices>());
    unawaited(admin.build());
  }

  @override
  void dispose() {
    admin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminSource>.value(value: admin),
        ChangeNotifierProvider<RegisterSource>.value(value: admin.register),
      ],
      child: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          drawer: mainDrawer(context),
          appBar: AppBar(
            centerTitle: true,
            title: Text("STUDIO EG",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              final loading = context.select((AdminSource admin) =>
              admin.loading);
              return loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : const TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Center(child: SchedulePage()),
                  Center(child: PresencePage()),
                  Center(child: RegisterPage()),
                ],
              );
            }
          ),
          bottomNavigationBar: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today)),
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sourceTile(String title, CalendarSource source, {String? subtitle}) =>
    SwitchListTile.adaptive(
      title: Text(title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: (subtitle != null)
          ? Text(subtitle,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
          : null,
      value: source.visible,
      onChanged: (value) => source.visible = value,
    );

Widget _deviceTile(CalendarSource source) {
  final label = source.label ?? '';
  final split = label.indexOf(':');
  return (split < 0)
      ? _sourceTile(label, source)
      : _sourceTile(label.substring(split + 1), source);
}