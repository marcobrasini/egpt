// import 'package:calendar/calendar.dart';
// import 'package:egpt/admin/register/session_widget.dart';
// import 'package:egpt/models/meeting.dart';
// import 'package:egpt/models/session.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
//
// class PresencePage extends StatelessWidget {
//   const PresencePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final source = context.watch<CalendarSource>();
//     final meetings = source.forDate(Date.now());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Agenda'),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.sync),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(0.0),
//         child: ListView.builder(
//           itemCount: meetings.length,
//           itemBuilder: (context, index) => SessionWidget(
//             session: Session.build(
//               meeting: meetings[index] as Meeting,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
