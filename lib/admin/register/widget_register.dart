import 'package:egpt/admin/register/member_tile.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/models/member.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  late final AdminSource admin;
  String _pattern = "";

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  List<Member> _filter(List<Member> members) {
    if (_pattern.isEmpty) return members;
    return members.where((member) {
      return member.name.toLowerCase().contains(_pattern.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 12.0,
          centerTitle: true,
          titleSpacing: 12.0,
          title: Text("Membri",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          automaticallyImplyActions: false,
          backgroundColor: Theme.of(context).primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(20.0),
                  child: TextField(
                    onChanged: (value) => setState(() {
                      _pattern = value;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Cerca',
                      labelStyle: TextStyle(color: Colors.white),
                      icon: Icon(Icons.search),
                      iconColor: Colors.white,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
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
                      : "Nessuna corrispondenza"),
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

