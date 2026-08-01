// import 'package:egpt/models/session.dart';
// import 'package:flutter/material.dart';
//
//
// class SessionWidget extends StatelessWidget {
//   const SessionWidget({
//     super.key,
//     required this.session,
//     required this.onChanged,
//   });
//
//   final Session session;
//   final ValueChanged<bool>? onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4.0,
//       margin: const EdgeInsets.all(12.0),
//       color: session.member.color,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(session.subject, style: Theme.of(context).textTheme.titleMedium),
//             Text("${session.from} ", style: Theme.of(context).textTheme.bodySmall),
//             const SizedBox(height: 12.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: _ChoiceButton(
//                     label: 'Presente',
//                     selected: session.presence,
//                     onPressed: onChanged == null ? null : () => onChanged!(true),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 Expanded(
//                   child: _ChoiceButton(
//                     label: 'Recupero',
//                     selected: !session.presence,
//                     onPressed: onChanged == null ? null : () => onChanged!(false),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class _ChoiceButton extends StatelessWidget {
//   const _ChoiceButton({
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