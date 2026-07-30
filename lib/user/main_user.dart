import 'package:egpt/services/supabase_service.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = SupabaseService();

  void _logout(BuildContext context) async {
    await supabase.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      "/",(route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("EGPT")),
          actions: [
            IconButton(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout),
            ),
          ],
          leading: Drawer()
        ),
        body: Center(child: Text("User"))
      ),
    );
  }
}