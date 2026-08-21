// import 'package:egpt/models/session.dart';
// import 'package:flutter/material.dart';
//
//
// class SessionWidget extends StatefulWidget {
//   const SessionWidget({
//     super.key,
//     required this.session,
//   });
//
//   final Session session;
//
//   @override
//   State<SessionWidget> createState() => _SessionWidgetState();
// }
//
// class _SessionWidgetState extends State<SessionWidget> {
//   bool? presence;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 8.0,
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         children: [
//           ListTile(
//             title: Text(widget.session.subject,
//               style: TextStyle(
//                 fontSize: 18,
//               ),
//             ),
//             subtitle: Text("${widget.session.from} ─ ${widget.session.to}"),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: ChoiceButton(
//                   label: 'Presente',
//                   selected: widget.session.presence ?? false,
//                   onPressed: () => setState(() {
//                     widget.session.presence = true;
//                   }),
//                 ),
//               ),
//               const SizedBox(width: 8.0),
//               Expanded(
//                 child: ChoiceButton(
//                   label: 'Recupero',
//                   selected: !(widget.session.presence ?? true),
//                   onPressed: () => setState(() {
//                     widget.session.presence = false;
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// class ChoiceButton extends StatelessWidget {
//   const ChoiceButton({
//     required this.label,
//     required this.selected,
//     required this.onPressed,
//   });
//
//   final String label;
//   final bool selected;
//   final VoidCallback? onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return selected ? ElevatedButton(
//       onPressed: onPressed,
//       child: Text(label),
//     ) : OutlinedButton(
//       onPressed: onPressed,
//       child: Text(label),
//     );
//   }
// }
