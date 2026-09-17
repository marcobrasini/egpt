import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/egpt_services.dart';
import 'admin_register.dart';
import 'admin_schedule.dart';
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

  Widget mainDrawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Amministratore',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
        ),
        // Voce Logout
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => _logout(),
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    admin = AdminSource(services: context.read<EGPTServices>());
    admin.build();
  }

  @override
  void dispose() {
    admin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminSource>.value(
      value: admin,
      child: Builder(
        builder: (context) {
          final loading = context.select((AdminSource admin) => admin.loading);
          return DefaultTabController(
            length: 3,
            initialIndex: 1,
            child: Scaffold(
              drawer: mainDrawer(context),
              appBar: AppBar(
                centerTitle: true,
                title: const Text("EGPT", style: TextStyle(fontSize: 28)),
              ),
              body: loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : const TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Center(child: Text("Schedule")),//SchedulePage()),
                  Center(child: Text("Presence")),//PresencePage()),
                  Center(child: RegisterPage()),
                ],
              ),
              bottomNavigationBar: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.calendar_today)),
                  Tab(icon: Icon(Icons.home)),
                  Tab(icon: Icon(Icons.person)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
