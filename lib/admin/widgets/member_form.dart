import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:calendar/calendar.dart';
import '../../models/member.dart';
import '../../typedef.dart';


const colorSize = 250.0;


class MemberForm extends StatefulWidget {
  const MemberForm(this.member, {this.enabled = true, super.key});

  final Member? member;
  final bool enabled;

  @override
  State<MemberForm> createState() => MemberFormState();
}

class MemberFormState extends State<MemberForm> {
  final _memberForm = GlobalKey<FormBuilderState>();
  bool get _editing => widget.enabled || widget.member == null;

  DataMap? get data {
    if (_memberForm.currentState?.saveAndValidate() ?? false) {
      final data = DataMap.from(_memberForm.currentState!.value);
      return data;
    }
    return null;
  }

  Color get _color =>
      _memberForm.currentState?.fields["color"]?.value ??
      (widget.member?.color ?? Theme.of(context).primaryColor);

  String get _name => _memberForm.currentState?.fields["name"]?.value ?? "";

  void _defaultName(String? firstName, String? lastName) {
    final form = _memberForm.currentState;
    if (form == null) return;
    setState(() {
      form.fields['name']?.didChange(
        [firstName, lastName]
            .where((string) => string != null && string.trim().isNotEmpty)
            .join(' '),
      );
    });
  }

  Widget nameForm() => FormBuilderTextField(
    name: 'name',
    maxLines: null,
    enabled: _editing,
    decoration: const InputDecoration(border: InputBorder.none),
    style: const TextStyle(fontSize: 24, color: Colors.black),
    textAlign: TextAlign.center,
    initialValue: widget.member?.name,
    valueTransformer: (value) => value?.trim(),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
  );

  Widget firstNameForm() => FormBuilderTextField(
    name: 'firstName',
    enabled: _editing,
    decoration: const InputDecoration(labelText: 'Nome'),
    initialValue: widget.member?.firstName,
    valueTransformer: (value) => value?.trim(),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
    onChanged: (value) => _defaultName(
      value,
      _memberForm.currentState?.fields['lastName']?.value,
    ),
  );

  Widget lastNameForm() => FormBuilderTextField(
    name: 'lastName',
    enabled: _editing,
    decoration: const InputDecoration(labelText: 'Cognome'),
    initialValue: widget.member?.lastName,
    valueTransformer: (value) => value?.trim(),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
    onChanged: (value) => _defaultName(
      _memberForm.currentState?.fields['firstName']?.value,
      value,
    ),
  );

  Future<Color?> colorPick(Color color) => showDialog<Color?>(
    context: context,
    builder: (context) => FittedBox(
      child: AlertDialog(
        title: const Center(child: Text('Scegli un colore')),
        content: StatefulBuilder(
          builder: (context, setDialogState) => ColorPicker(
            pickerColor: color,
            hexInputBar: false,
            enableAlpha: false,
            paletteType: PaletteType.hueWheel,
            onColorChanged: (value) => setDialogState(() => color = value),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Annulla', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(color),
            child: const Text('Conferma', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    ),
  );
  Widget colorForm() => FormBuilderField<Color>(
    name: 'color',
    enabled: _editing,
    initialValue: widget.member?.color ?? Theme.of(context).primaryColor,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
    builder: (FormFieldState<Color> field) => FilledButton(
      onPressed: _editing
          ? () async {
              final picked = await colorPick(field.value!);
              if (picked != null) setState(() => field.didChange(picked));
            }
          : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: field.value,
      ),
      child: Container(
        width: colorSize,
        height: colorSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: field.value),
      ),
    ),
  );

  Widget photoForm() => FormBuilderImagePicker(
    name: 'photo',
    enabled: _editing,
    iconColor: _color,
    backgroundColor: HSLColor.fromColor(_color).withLightness(0.8).toColor(),
    previewWidth: 200,
    previewHeight: 200,
    transformImageWidget: (context, displayImage) => Card(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox.expand(child: displayImage),
    ),
    maxImages: 1,
    showDecoration: false,
    previewAutoSizeWidth: false,
    initialValue: [widget.member?.photo],
    valueTransformer: (images) {
      if (images == null) return null;
      final photo = images.singleOrNull;
      return photo;
    },
  );

  Widget birthForm() => FormBuilderDateTimePicker(
    name: 'birth',
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: 'Data di nascita',
      icon: Icon(Icons.calendar_month),
    ),
    inputType: InputType.date,
    format: DateFormat('dd/MM/yyyy'),
    initialValue: widget.member?.birth,
    valueTransformer: (value) => value?.date,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.dateTime(),
    ]),
  );

  Widget emailForm() => FormBuilderTextField(
    name: 'email',
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: 'email',
      icon: Icon(Icons.mail_outline),
    ),
    initialValue: widget.member?.email,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.email(checkNullOrEmpty: false),
    ]),
  );

  Widget phoneForm() => FormBuilderTextField(
    name: 'phone',
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: 'phone',
      icon: Icon(Icons.phone_android),
    ),
    initialValue: widget.member?.phone,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.phoneNumber(checkNullOrEmpty: false),
    ]),
  );

  @override
  Widget build(BuildContext context) => FormBuilder(
    key: _memberForm,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        nameForm(),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            colorForm(),
            ClipOval(child: photoForm()),
          ],
        ), // color, photo
        firstNameForm(),
        lastNameForm(),
        birthForm(),
        emailForm(),
        phoneForm(),
      ],
    ),
  );
}
