// import 'package:egpt/blocs/member_bloc.dart';
// import 'package:egpt/typedef.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:calendar/calendar.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:form_builder_image_picker/form_builder_image_picker.dart';
// import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
//
// class MemberForm extends StatelessWidget {
//   const MemberForm({
//     super.key,
//     required this.formKey,
//     this.colorSize = 250,
//   });
//
//   final GlobalKey<FormBuilderState> formKey;
//   final double colorSize;
//
//   static void submit(BuildContext context,GlobalKey<FormBuilderState> formKey) {
//     final form = formKey.currentState;
//     if (form != null && form.saveAndValidate()) {
//       context.read<MemberBloc>().add(MemberSubmitted(DataMap.from(form.value)));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Compila i campi obbligatori.'),
//       ));
//     }
//   }
//
//   void _defaultName(String? firstName, String? lastName) {
//     final form = formKey.currentState;
//     if (form == null) return;
//     final name = [firstName, lastName]
//         .where((string) => string != null && string.trim().isNotEmpty)
//         .join(' ');
//     form.fields['name']?.didChange(name);
//   }
//
//   Widget nameForm(BuildContext context, MemberState state) =>
//       FormBuilderTextField(
//     name: 'name',
//     enabled: state.editing && state.naming,
//     decoration: const InputDecoration(border: InputBorder.none),
//     style: const TextStyle(fontSize: 24, color: Colors.black),
//     textAlign: TextAlign.center,
//     initialValue: state.member?.name,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.required(),
//     ]),
//   );
//
//   Widget firstNameForm(BuildContext context, MemberState state) =>
//       FormBuilderTextField(
//     name: 'firstName',
//     enabled: state.editing,
//     decoration: const InputDecoration(labelText: 'Nome'),
//     initialValue: state.member?.firstName,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.required(),
//     ]),
//     onChanged: (value) => _defaultName(
//       value, formKey.currentState?.fields['lastName']?.value,
//     ),
//   );
//
//   Widget lastNameForm(BuildContext context, MemberState state) =>
//       FormBuilderTextField(
//     name: 'lastName',
//     enabled: state.editing,
//     decoration: const InputDecoration(labelText: 'Cognome'),
//     initialValue: state.member?.lastName,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.required(),
//     ]),
//     onChanged: (value) => _defaultName(
//       formKey.currentState?.fields['firstName']?.value, value
//     ),
//   );
//
//   Future<Color?> colorPick(BuildContext context, Color color) =>
//       showDialog<Color?>(
//         context: context,
//         builder: (context) => FittedBox(
//           child: AlertDialog(
//             title: const Center(child: Text('Scegli un colore')),
//             content: StatefulBuilder(
//               builder: (context, setDialogState) => ColorPicker(
//                 pickerColor: color,
//                 hexInputBar: false,
//                 enableAlpha: false,
//                 paletteType: PaletteType.hueWheel,
//                 onColorChanged: (value) => setDialogState(() => color = value),
//               ),
//             ),
//             actionsAlignment: MainAxisAlignment.spaceBetween,
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(null),
//                 child: const Text('Annulla', style: TextStyle(fontSize: 16)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(color),
//                 child: const Text('Conferma', style: TextStyle(fontSize: 16)),
//               ),
//             ],
//           ),
//         ),
//       );
//   Widget colorForm(BuildContext context, MemberState state) =>
//       FormBuilderField<Color>(
//     name: 'color',
//     enabled: state.editing,
//     initialValue: state.member?.color ?? Theme.of(context).primaryColor,
//     builder: (FormFieldState<Color> field) =>  FilledButton(
//       onPressed: state.editing
//           ? () async {
//               final color = await colorPick(context, field.value!);
//               if (color != null) field.didChange(color);
//             }
//           : null,
//       style: ElevatedButton.styleFrom(shape: const CircleBorder()),
//       child: Container(
//         width: colorSize,
//         height: colorSize,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: field.value,
//         ),
//       ),
//     ),
//   );
//
//   Widget birthForm(BuildContext context, MemberState state) =>
//       FormBuilderDateTimePicker(
//     name: 'birth',
//     enabled: state.editing,
//     decoration: const InputDecoration(
//       labelText: 'Data di nascita',
//       icon: Icon(Icons.calendar_month),
//     ),
//     inputType: InputType.date,
//     format: DateFormat('dd/MM/yyyy'),
//     initialValue: state.member?.birth,
//     valueTransformer: (value) => value?.date,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.required(),
//       FormBuilderValidators.dateTime(),
//     ]),
//   );
//
//   Widget emailForm(BuildContext context, MemberState state) =>
//       FormBuilderTextField(
//     name: 'email',
//     enabled: state.editing,
//     decoration: const InputDecoration(
//       labelText: 'email',
//       icon: Icon(Icons.mail_outline),
//     ),
//     initialValue: state.member?.email,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.email(checkNullOrEmpty: false),
//     ]),
//   );
//
//   Widget phoneForm(BuildContext context, MemberState state) =>
//       FormBuilderTextField(
//     name: 'phone',
//     enabled: state.editing,
//     decoration: const InputDecoration(
//       labelText: 'phone',
//       icon: Icon(Icons.phone_android),
//     ),
//     initialValue: state.member?.phone,
//     validator: FormBuilderValidators.compose([
//       FormBuilderValidators.phoneNumber(checkNullOrEmpty: false),
//     ]),
//   );
//
//   @override
//   Widget build(BuildContext context) => FormBuilder(
//     child: BlocBuilder<MemberBloc, MemberState>(
//       builder: (context, state) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Stack(
//             alignment: AlignmentDirectional.bottomEnd,
//             children: [
//               nameForm(context, state),
//               if (state.editing)
//                 IconButton(
//                   icon: Icon(state.naming ? Icons.save : Icons.edit),
//                   onPressed: () => context.read<MemberBloc>().add(
//                       const MemberNaming()
//                   ),
//                 ),
//             ],
//           ),
//           Stack(
//             alignment: AlignmentDirectional.center,
//             children: [
//               colorForm(context, state),
//             ],
//           ),
//           firstNameForm(context, state),
//           lastNameForm(context, state),
//           birthForm(context, state),
//           emailForm(context, state),
//           phoneForm(context, state),
//         ],
//       ),
//     ),
//   );
// }
