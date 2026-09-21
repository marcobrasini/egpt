import 'package:egpt/admin/admin_training.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/widgets/dialog_form.dart';
import 'package:egpt/admin/widgets/member_tile.dart';
import 'package:egpt/admin/widgets/member_form.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/sources/source_register.dart';
import 'package:egpt/sources/source_training.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AdminSource admin;
  late final RegisterSource register;
  final _searchController = TextEditingController();
  String _pattern = "";

  List<Member> _filter(List<Member> members) {
    if (_pattern.isEmpty) return members;
    final pattern = _pattern.toLowerCase();
    return members
        .where((m) => m.name.toLowerCase().contains(pattern))
        .toList();
  }

  Future<void> makeMember(BuildContext context) async {
    final memberForm = GlobalKey<MemberFormState>();
    await showFormDialog(
      context: context,
      title: 'Nuovo Membro',
      content: MemberForm(null, key: memberForm),
      actions: [
        FormAction('Annulla'),
        FormAction('Conferma',
          onPressed: (dialog) async {
            if (memberForm.currentState?.data case final data?) {
              final member = await admin.insertMember(Member.make(data: data));
              if (dialog.mounted) Navigator.of(dialog).pop(member);
            }
          },
        )
      ],
    );
  }

  Future<void> editMember(BuildContext context, Member member) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => TrainingSource(admin, memberId: member.id!),
          child: AdminTraining(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
    register = context.read<RegisterSource>();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator.adaptive(
      onRefresh: () => admin.build(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            automaticallyImplyActions: false,
            centerTitle: true,
            title: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      showCursor: true,
                      decoration: InputDecoration(
                        labelText: 'Cerca',
                        icon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => _pattern = value),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () => makeMember(context),
                ),
              ],
            ),
          ),
          Consumer<RegisterSource>(
            builder: (context, register, _) {
              final members = _filter(register.members);
              if (members.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _pattern.isEmpty
                          ? "Nessun membro"
                          : "Nessuna corrispondenza",
                      style: TextStyle(fontSize: 16.0, color: scheme.outline),
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return MemberTile(
                    member,
                    setMember: () => editMember(context, member),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
