import 'package:egpt/admin/admin_training.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/widgets/member_tile.dart';
import 'package:egpt/admin/widgets/member_form.dart';
import 'package:egpt/models/member.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _searchController = TextEditingController();
  String _pattern = "";

  List<Member> _filter(List<Member> members) {
    if (_pattern.isEmpty) return members;
    return members.where((member) {
      return member.name.toLowerCase().contains(_pattern.toLowerCase());
    }).toList();
  }

  Future<void> _addMember(BuildContext context) async {
    final admin = context.read<AdminSource>();
    final form = GlobalKey<MemberFormState>();
    await showDialog<Member>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Nuovo Membro')),
        content: MemberForm(null, key: form),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text('Annulla', style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text('Conferma', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final data = form.currentState?.data;
              if (data != null) {
                final member = await admin.insertMember(
                  Member.make(data: data),
                );
                navigator.pop(member);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setMember(BuildContext context, Member member) async {
    final admin = context.read<AdminSource>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<AdminSource>.value(
          value: admin,
          child: AdminTraining(member),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomScrollView(
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
                onPressed: () => _addMember(context),
              ),
            ],
          ),
        ),
        Consumer<AdminSource>(
          builder: (context, source, _) {
            final members = _filter(source.register.members);
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
                  setMember: () => _setMember(context, member),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
