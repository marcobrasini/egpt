import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/schedule/fixture_widget.dart';
import 'package:egpt/admin/schedule/pattern_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:provider/provider.dart';


class MeetingWidget extends StatefulWidget {
  final Meeting? meeting;
  final DateTime? datetime;
  final bool enabled;

  const MeetingWidget(this.meeting, {
    this.datetime,
    this.enabled = true,
    super.key
  });

  bool get creating => meeting == null;

  @override
  State<MeetingWidget> createState() => MeetingWidgetState();
}

class MeetingWidgetState extends State<MeetingWidget> {
  late final AdminSource admin;
  final _meetingForm = GlobalKey<FormBuilderState>();
  final _fixtureForm = GlobalKey<FixtureWidgetState>();
  final _patternForm = GlobalKey<PatternWidgetState>();
  Product? _product;
  Member? _member;


  Map<String, dynamic>? get data {
    final meetingForm = _meetingForm.currentState;
    final fixtureForm = _fixtureForm.currentState;
    final patternForm = _patternForm.currentState;
    if ((meetingForm?.saveAndValidate() ?? false)
        && fixtureForm != null && patternForm != null) {
      final fixture = fixtureForm.data;
      final pattern = patternForm.data;
      if (fixture != null && pattern != null) {
        final data = Map<String, dynamic>.from(meetingForm!.value);
        return {
          ...data,
          ...fixture,
          if (pattern["repeat"]) "pattern": Pattern(
            type: PatternType.weekly,
            until: pattern["until"],
          )
        };
      }
    }
    return null;
  }

  @override
  void initState() {
    admin = context.read<AdminSource>();
    _member = widget.meeting?.member;
    _product = widget.meeting?.product;
    super.initState();
  }

  Widget memberForm() => FormBuilderTypeAhead<String>(
    name: 'member',
    itemBuilder: (context, name) => ListTile(title: Text(name)),
    decoration: const InputDecoration(
      labelText: "Membro",
    ),
    initialValue: _member?.name,
    enabled: widget.enabled && widget.creating,
    suggestionsCallback: (pattern) {
      if (pattern.isNotEmpty) {
        return admin.register.memberNames.where(
            (name) => name.toLowerCase().contains(pattern.toLowerCase()
        )).toList(growable: false);
      } else {
        return admin.register.memberNames;
      }
    },
    onChanged: (name) {
      if (name != null && name != _member?.name) {
        setState(() {
          _member = admin.register.members.firstWhere((m) => m.name == name);
          final valid = _member!.products.where((p) => p.isValid()).toList();
          if (valid.length == 1) {
            _product = valid.first;
          } else {
            _product = null;
          }
        });
      }
    },
    valueTransformer: (value) => _member,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Seleziona un membro.',
      ),
    ]),
  );

  Widget productForm() => FormBuilderDropdown(
    name: "product",
    items: _member?.products.where((product) => product.isValid()).map(
        (product) => DropdownMenuItem<String>(
          value: product.id,
          child: Text(product.summary),
        )).toList() ?? [],
    decoration: const InputDecoration(labelText: "Abbonamento"),
    initialValue: _product?.id,
    enabled: widget.enabled && widget.creating && _member != null,
    onChanged: (productId) {
      if (productId != null) {
        setState(() {
          _product = _member!.products.singleWhere((p) => p.id == productId);
        });
      }
    },
    valueTransformer: (value) => _product,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Seleziona un abbonamento.',
      ),
    ]),
  );

  Widget fixtureForm() => FixtureWidget(
    (widget.meeting == null)
        ? ((widget.datetime == null) ? null : Fixture(
          start: widget.datetime!,
          stop: widget.datetime!.add(Duration(hours: 1)),
        )) : Fixture(
          start: widget.meeting!.start,
          stop: widget.meeting!.stop,
        ),
    enabled: widget.enabled && _product != null,
    // fixDate: widget.meeting?.isInstance ?? false,
    key: _fixtureForm,
  );

  Widget patternForm() => PatternWidget(
    _product,
    widget.meeting?.pattern,
    allow: widget.creating,
    enabled: widget.enabled && _product != null,
    key: _patternForm,
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _meetingForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          memberForm(),
          productForm(),
          fixtureForm(),
          if (widget.meeting?.pattern != null || widget.creating) patternForm(),
        ],
      ),
    );
  }
}
