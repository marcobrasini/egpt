import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/widgets/forms.dart';
import 'widgets/register_tile.dart';
import 'admin_personal.dart';
import 'source_admin.dart';


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

  List<Member> listMembers(List<Member> members) {
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
      content: SizedBox(
        height: 650,
        child: SingleChildScrollView(
          child: MemberForm(null, key: memberForm)),
        ),
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

  Future<void> editMember(BuildContext context, String memberId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<AdminSource>.value(
          value: admin,
          child: AdminPersonal(memberId),
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator.adaptive(
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
        Selector<RegisterSource, List<String>>(
          selector: (_, register) => listMembers(admin.register.members)
              .map((m) => m.id!)
              .toList(),
          builder: (context, ids, _) {
            if (ids.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(_pattern.isEmpty
                      ? "Nessun membro"
                      : "Nessuna corrispondenza",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              );
            }
            return SliverList.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) =>
                RegisterTile(ids[index],
                  open: () => editMember(context, ids[index]),
                  key: ValueKey(ids[index]),
                ),
            );
          },
        ),
      ],
    ),
  );
}
