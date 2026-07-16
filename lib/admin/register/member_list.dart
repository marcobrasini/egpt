import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/register/member_tile.dart';
import 'package:egpt/admin/register/member_page.dart';


class MemberList extends StatefulWidget {
  final bool enabled;
  final bool searching;
  const MemberList({
    this.enabled = true,
    this.searching = true,
    super.key
  });

  @override
  State<MemberList> createState() => MemberListState();
}


class MemberListState extends State<MemberList> {
  late bool _enabled;
  String _pattern = "";

  void enable(bool enabled) {
    setState(() {
      _enabled = enabled;
    });
  }

  List<Member> _filterMembers(List<Member> members) {
    if (_pattern.isEmpty) return members;
    return members.where((member) {
      return member.name.toLowerCase().contains(_pattern.toLowerCase());
    }).toList();
  }

  Future<void> _setMember(BuildContext context, Member member) async {
    if (!_enabled) return;
    final source = context.read<AdminSource>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<AdminSource>.value(
          value: source,
          child: MemberPage(member),
        ),
      ),
    );
  }

  Future<void> _delMember(BuildContext context, Member member) async {
    if (!_enabled) return;
    final source = context.read<AdminSource>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: Colors.black,
                fontSize: 18.0,
              ),
              children: [
                const TextSpan(text: "Vuoi eliminare il membro\n"),
                TextSpan(
                  text: "'${member.name}'?",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Elimina"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true && context.mounted) {
      try {
        await source.deleteMember(member);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membro eliminato.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eliminazione fallita: $error')),
        );
      }
      
    }
  }

  @override
  void initState() {
    _enabled = widget.enabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searching) TextField(
          onChanged: (value) => setState(() {
            _pattern = value;
          }),
          decoration: const InputDecoration(
            icon: Icon(Icons.search),
            labelText: 'Cerca',
          ),
        ),
        Expanded(
          child: Consumer<AdminSource>(
            builder: (context, source, child) {
              final register = source.register;
              final filtered = _filterMembers(register.members);
              if (filtered.isEmpty) {
                return Center(child: Text(
                  _pattern.isEmpty
                      ? "Nessun membro"
                      : "Nessuna corrispondenza"
                ));
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => MemberTile(
                  filtered[index],
                  _setMember,
                  _delMember
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
