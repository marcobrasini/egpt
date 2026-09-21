import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/sources/sources.dart';


class SessionList extends StatelessWidget {
  const SessionList({required this.sessions, super.key});
  final List<Session> sessions;
  List<Presence> get presences => [for (final s in sessions) ?(s.presence)];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in presences) Row(
          children: [
            p.presence
                ? Icon(Icons.play_circle_outline, color: Colors.green)
                : Icon(Icons.pause_circle_outline, color: Colors.red),
            SizedBox(width: 8.0),
            Expanded(
              child: Text("${p.date.format("dd/MM/yyyy")}: ${p.from} - ${p.to}",
                  style: TextStyle(fontSize: 16.0)
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 16),
              onPressed: () async {
                final personal = context.read<PersonalSource>();
                await personal.removeSession(personal.session(p.id!));
              },
            )
          ],
        ),
      ],
    );
  }
}
