import 'package:egpt/sources/source_register.dart';
import 'package:egpt/sources/source_training.dart';
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
  late final GlobalKey<MemberFormState> memberForm;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    memberForm = GlobalKey<MemberFormState>();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            MemberForm(widget.member, enabled: _editing, key: memberForm),
            IconButton(
              icon: Icon(_editing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (_editing) {
                  if (memberForm.currentState?.data case final data?) {
                    if (_saving) return ; _saving = true;
                    final training = context.read<TrainingSource>();
                    await training.modifyMember(widget.member.set(data));
                  }
                }
                setState(() {
                  _saving = false;
                  _editing = !_editing;
                });
              },
            ),
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
                onPressed: () async {
                  final confirm = await showDeleteDialog(
                    context: context,
                    title: "Cancella abbonamento",
                    message: ""
                      "Stai eliminando il membro '${widget.member.name}' "
                      "con tutti gli abbonamenti e le sessioni associate."
                      "\nVuoi rimuovere il membro?",
                    string: ""
                      "egpt/${widget.member.name}".replaceAll(" ", ""),
                  );
                  if (confirm && context.mounted) {
                    final training = context.read<TrainingSource>();
                    await training.removeMember(widget.member);
                  }
                }
              ),
            ],
          ),
        ),
      ],
    );
  }
}
