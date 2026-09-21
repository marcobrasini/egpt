import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/widgets/forms.dart';
import 'package:egpt/sources/sources.dart';


class MemberPage extends StatefulWidget {
  const MemberPage(this.member, {super.key});

  final Member member;

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late final GlobalKey<MemberFormState> memberForm;
  late final PersonalSource personal;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    memberForm = GlobalKey<MemberFormState>();
    personal = context.read<PersonalSource>();
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
                    await personal.modifyMember(widget.member.set(data));
                  }
                }
                setState(() => _editing = !_editing);
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
                    await personal.removeMember(widget.member);
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
