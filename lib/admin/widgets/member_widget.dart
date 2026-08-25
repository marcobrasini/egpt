import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/member.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class MemberWidget extends StatefulWidget {
  final Member? member;
  final bool enabled;
  const MemberWidget(this.member, {this.enabled = true, super.key});

  @override
  State<MemberWidget> createState() => MemberWidgetState();
}

class MemberWidgetState extends State<MemberWidget> {
  final _memberKey = GlobalKey<FormBuilderState>();
  late bool _enabled;
  late bool _editing;
  late bool _editable;
  late Color _color;

  Map<String, dynamic>? get data {
    if (_memberKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_memberKey.currentState!.value);
      return data;
    }
    return null;
  }

  void enable(bool enabled) {
    setState(() {
      _enabled = enabled;
    });
  }

  @override
  void initState() {
    super.initState();
    _editing = false;
    _enabled = widget.enabled;
    _editable = widget.member?.name == null ? false : true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color = widget.member?.color ?? Theme.of(context).primaryColor;
  }

  Widget nameForm() => Stack(
    alignment: AlignmentDirectional.bottomEnd,
    children: [
      FormBuilderTextField(
        name: 'name',
        enabled: _enabled && _editing,
        initialValue: widget.member?.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
      if ((_enabled && _editable) || _editing) IconButton(
        onPressed: () {
          setState(() {
            _editing = !_editing;
          });
        },
        icon: _editing ? Icon(Icons.save) : Icon(Icons.edit),
      ),
    ],
  );

  Widget colorForm(double size) => FormBuilderField(
    name: "color",
    enabled: _enabled,
    initialValue: _color,
    valueTransformer: (value) => _color,
    builder: (FormFieldState<dynamic> field) => FilledButton(
      onPressed: _enabled ? () {
        showDialog(
          context: (context),
          builder: (context) => FittedBox(
            child: AlertDialog(
              title: Text("Scegli un colore"),
              content: ColorPicker(
                paletteType: PaletteType.hueWheel,
                hexInputBar: true,
                enableAlpha: false,
                pickerColor: _color,
                onColorChanged: (color) {
                  setState(() {
                    _color = color;
                  });
                },
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  child: Text("Annulla"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Conferma"),
                  onPressed: () {
                    field.didChange(_color);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      } : null,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: _color,
        disabledBackgroundColor: _color,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
        ),
      )
    ),
  );

  Widget firstNameForm() => FormBuilderTextField(
    name: 'firstName',
    enabled: _enabled,
    decoration: const InputDecoration(
        labelText: 'Nome'
    ),
    initialValue: widget.member?.firstName,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      final lastName = _memberKey.currentState!.fields["lastName"]?.value;
      final username = [value, lastName].where(
              (e) => e != null && e.isNotEmpty
      ).join(" ");
      _memberKey.currentState!.fields["name"]!.didChange(username);
      setState(() {
        _editable = username.isNotEmpty;
      });
    },
  );

  Widget lastNameForm() => FormBuilderTextField(
    name: 'lastName',
    enabled: _enabled,
    decoration: const InputDecoration(
        labelText: 'Cognome'
    ),
    initialValue: widget.member?.lastName,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      final firstName = _memberKey.currentState!.fields["firstName"]?.value;
      final username = [firstName, value].where(
              (e) => e != null && e.isNotEmpty
      ).join(" ");
      _memberKey.currentState!.fields["name"]!.didChange(username);
      setState(() {
        _editable = username.isNotEmpty;
      });
    },
  );

  Widget birthForm() => FormBuilderDateTimePicker(
    name: "birth",
    enabled: _enabled,
    decoration: const InputDecoration(
      labelText: "Data di nascita",
      icon: Icon(Icons.calendar_month),
    ),
    initialValue: widget.member?.birth,
    inputType: InputType.date,
    format: DateFormat('dd/MM/yyyy'),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    valueTransformer: (value) => value!.date,
  );

  Widget emailForm() => FormBuilderTextField(
    name: 'email',
    enabled: false,
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
    enabled: false,
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
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _memberKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          nameForm(),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              colorForm(250)
              // FormBuilderImagePicker(
              //   name: 'photo',
              //   enabled: _enabled,
              //   maxImages: 1,
              //   valueTransformer: (files) =>
              //     files?.isNotEmpty == true ? files!.first : null,
              //   // valueTransformer: (images) {
              //   //   if (images == null) return null;
              //   //   final photo = images.singleOrNull;
              //   //   return photo;
              //   // },
              //   iconColor: _color,
              //   backgroundColor: HSLColor.fromColor(_color)
              //       .withLightness(0.8).toColor(),
              //   previewBuilder: (context, children, addButton) {
              //     return SizedBox(
              //       width: 180,
              //       height: 180,
              //       child: Stack(
              //         alignment: Alignment.center,
              //         children: [
              //           if (children.isNotEmpty)
              //             ClipOval(
              //               child: SizedBox.expand(child: children.first),
              //             ),
              //         ],
              //       ),
              //     );
              //   },
              // )
            ]
          ),
          firstNameForm(),
          lastNameForm(),
          birthForm(),
          emailForm(),
          phoneForm(),
        ],
      ),
    );
  }
}

