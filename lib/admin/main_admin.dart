import 'package:egpt/admin/admin_register.dart';
import 'package:egpt/admin/admin_schedule.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/source_register.dart';
import 'package:egpt/admin/source_schedule.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/services/supabase_service.dart';


class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final admin = AdminSource();

  void _logout(BuildContext context) async {
    await admin.supabase.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/", (route) => false,
      );
    }
  }

  Widget mainDrawer(context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Amministratore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        // Voce Logout
        ListTile(
          leading: const Icon(
              Icons.logout,
              color: Colors.red
          ),
          title: const Text('Logout',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          onTap: () => _logout(context),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    admin.build();

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminSource>.value(
              value: admin
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text("EGPT"),
            titleTextStyle: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true,
          ),
          drawer: mainDrawer(context),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Center(child: SchedulePage()),
              Center(child: Text("Presence")),
              Center(child: RegisterPage()),
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_month)),
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }
}