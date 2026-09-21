import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/egpt_services.dart';
import '../user/source_user.dart';


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

  @override
  void initState() {
    super.initState();
    user = UserSource(services: context.read<EGPTServices>());
    user.build();
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
              appBar: AppBar(
                  title: Center(child: Text("EGPT")),
                  actions: [
                    IconButton(
                      onPressed: () => _logout(),
                      icon: Icon(Icons.logout),
                    ),
                  ],
                  leading: Drawer()
              ),
              body: Center(
                child: TextButton(
                  onPressed: _logout,
                  child: Text("User")
                ),
              )
            );
        }
      )
    );
  }
}