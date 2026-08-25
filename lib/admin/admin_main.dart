import 'package:egpt/admin/admin_presence.dart';
import 'package:egpt/admin/register/widget_register.dart';
import 'package:egpt/services/egpt_services.dart';
import 'package:egpt/admin/admin_schedule.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final AdminSource admin;

  void _logout() async {
    await admin.services.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
    }
  }

  Widget mainDrawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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
    return ChangeNotifierProvider.value(
      value: admin,
      child: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          drawer: mainDrawer(context),
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Egpt",
              style: TextStyle(fontSize: 28),
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              SchedulePage(),
              PresencePage(),
              RegisterWidget(),
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
      ),
    );
  }
}