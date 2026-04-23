import 'package:flutter/material.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/admin/register/member_list.dart';
import 'package:egpt/admin/widgets/member_widget.dart';
import 'package:egpt/admin/source_register.dart';
import 'package:provider/provider.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

  Future<void> _addMember(BuildContext context) async {
    final register = context.read<RegisterSource>();
    final memberWidgetKey = GlobalKey<MemberWidgetState>();
    final member = await showDialog<Member?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text("Nuovo Membro")),
          content: MemberWidget(null, key: memberWidgetKey),
          actions: [
            TextButton(
              child: const Text("Registra"),
              onPressed: () async {
                final data = memberWidgetKey.currentState?.data;
                if (data == null) {
                  Navigator.of(context).pop(null);
                } else {
                  Navigator.of(context).pop(
                    Member.make(data: data)
                  );
                }
              },
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrazione fallita.')),
      );
    } else {
      if (register.members.any((m) => m.name == member.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nome già esistente')),
        );
      } else {
        await register.createMember(member);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrazione riuscita.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membri'),
        actions: [
          IconButton(
              onPressed: () => _addMember(context),
              icon: Icon(Icons.person_add)
          )
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: MemberList(),
      ),
    );
  }

}
