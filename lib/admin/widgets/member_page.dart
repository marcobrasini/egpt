import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../source_admin.dart';
import 'member_form.dart';
import 'delete_form.dart';


class MemberPage extends StatefulWidget {
  const MemberPage(this.member, {super.key});

  final Member member;

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  bool _editing = false;

  Future<void> _delMember(BuildContext context, Member member) async {
    final admin = context.read<AdminSource>();
    final form = GlobalKey<DeleteFormState>();
    await showDialog<Member>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Membro")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Stai eliminando il membro '${member.name}' con tutti "
              "gli abbonamenti e tutte le sessioni di allenamento associate."
              "\nVuoi rimuovere il membro?",
            ),
            DeleteForm(
              "egpt/${widget.member.name}".replaceAll(" ", ""),
              key: form,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text("Annulla", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text("Elimina", style: TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (form.currentState?.confirm ?? false) {
                await admin.removeMember(member);
                navigator.pop(member);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminSource>();
    final scheme = Theme.of(context).colorScheme;
    final memberForm = GlobalKey<MemberFormState>();
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            MemberForm(widget.member, enabled: _editing, key: memberForm),
            IconButton(
              icon: Icon(_editing ? Icons.save : Icons.edit),
              onPressed: () => setState(() {
                if (_editing) {
                  final data = memberForm.currentState?.data;
                  if (data != null) {
                    admin.modifyMember(widget.member.set(data));
                  }
                }
                _editing = !_editing;
              }),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 16.0,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("Abilita accesso"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text("Elimina membro"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                onPressed: () => _delMember(context, widget.member),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
