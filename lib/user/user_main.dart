import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/services/services.dart';
import 'package:egpt/style.dart';
import 'source_user.dart';


class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final UserSource user;

  void _logout() async {
    await user.services.signOut();
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
                    Text('Utente',
                      style: TextStyle(color: scheme.onPrimary, fontSize: 24),
                    ),
                    FittedBox(
                      child: Text(user.email ?? "",
                        style: TextStyle(color: scheme.onPrimary),
                      ),
                    ),
                  ],
                )
              ],
            ),
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
    user = UserSource(services: context.read<EGPTServices>());
    unawaited(user.build());
  }

  @override
  void dispose() {
    user.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserSource>.value(
      value: user,
      child: Builder(
        builder: (context) {
          return (user.loading)
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
              drawer: mainDrawer(context),
              appBar: AppBar(
                centerTitle: true,
                title: Text("STUDIO EG",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              body: Center(
                child: Text(
                  "Benvenuto ${user.name ?? "Utente"}!"
                ),
              )
            );
        }
      )
    );
  }
}