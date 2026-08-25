import 'package:egpt/admin/register/member_tile.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/widgets/member_widget.dart';
import 'package:egpt/models/member.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _searchController = TextEditingController();
  late final AdminSource admin;
  String _pattern = "";

  List<Member> _filter(List<Member> members) {
    if (_pattern.isEmpty) return members;
    return members.where((member) {
      return member.name.toLowerCase().contains(_pattern.toLowerCase());
    }).toList();
  }

  Future<void> _addMember(BuildContext context) async {
    final memberWidgetKey = GlobalKey<MemberWidgetState>();
    final member = await showDialog<Member?>(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider<AdminSource>.value(
          value: admin,
          child: AlertDialog(
            title: Center(child: Text("Nuovo Membro")),
            content: MemberWidget(null, key: memberWidgetKey),
            actions: [
              TextButton(
                child: const Text("Registra"),
                onPressed: () async {
                  final data = memberWidgetKey.currentState?.data;
                  Navigator.of(context).pop(
                      (data != null) ? Member.make(data: data) : null
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    final register = admin.register;
    if (!context.mounted || member == null) return;
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

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AdminSource>();
    final scheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          automaticallyImplyLeading: false,
          automaticallyImplyActions: false,
          centerTitle: true,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {
                        _pattern = value;
                      }),
                      showCursor: true,
                      decoration: InputDecoration(
                        labelText: 'Cerca',
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () => _addMember(context),
                )
              ],
            ),
          ),
        ),
        Consumer<AdminSource>(
          builder: (context, source, _) {
            final members = _filter(source.register.members);
            if (members.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(_pattern.isEmpty
                      ? "Nessun membro"
                      : "Nessuna corrispondenza",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: scheme.outline,
                    ),
                  ),
                ),
              );
            }
            return SliverList.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return MemberTile(
                  key: ValueKey(member.id),
                  member,
                  (context, member) {},
                  (context, member) {},
                );
              },
            );
          },
        ),
      ],
    );
  }
}

