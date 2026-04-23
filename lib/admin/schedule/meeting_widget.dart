import 'package:egpt/admin/schedule/recurrence_widget.dart';
import 'package:flutter/material.dart';
// downloaded
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
// sources
import 'package:egpt/admin/source_admin.dart';
// models
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/fixture.dart';
import 'package:egpt/models/meeting.dart';
// widgets
import 'package:egpt/utils/datetime.dart';
import 'package:egpt/admin/schedule/fixture_widget.dart';


class MeetingWidget extends StatefulWidget {
  final Meeting? meeting;
  final DateTime? datetime;
  final bool enabled;

  const MeetingWidget(this.meeting, {
    this.datetime,
    this.enabled = true,
    super.key
  });

  bool get isNew => meeting == null;

  @override
  State<MeetingWidget> createState() => MeetingWidgetState();
}

class MeetingWidgetState extends State<MeetingWidget> {
  static final admin = AdminSource();
  static final register = admin.register;
  final _meetingForm = GlobalKey<FormBuilderState>();
  final _fixtureForm = GlobalKey<FixtureWidgetState>();
  final _repeatForm = GlobalKey<RecurrenceWidgetState>();
  Product? _product;
  Member? _member;

  Map<String, dynamic>? get data {
    final meetingForm = _meetingForm.currentState;
    final fixtureForm = _fixtureForm.currentState;
    final repeatForm = _repeatForm.currentState;
    if ((meetingForm?.saveAndValidate() ?? false) && fixtureForm != null) {
      final fixture = fixtureForm.data;
      if (fixture != null) {
        final data = Map<String, dynamic>.from(meetingForm!.value);
        return {
          ...data,
          ...fixture,
          if (repeatForm != null) "recurrenceRule": repeatForm.recurrenceRule,
        };
      }
    }
    return null;
  }

  @override
  void initState() {
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
    enabled: widget.enabled && widget.isNew,
    suggestionsCallback: (pattern) {
      if (pattern.isNotEmpty) {
        return register.memberNames.where((name) => name
            .toLowerCase().contains(pattern.toLowerCase())
        ).toList(growable: false);
      } else {
        return register.memberNames;
      }
    },
    onChanged: (name) {
      if (name != null && name != _member?.name) {
        setState(() {
          _member = register.members.firstWhere((m) => m.name == name);
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
    items: _member == null
        ? []
        : _member!.products.where((product) => product.isValid())
        .map((product) => DropdownMenuItem<String>(
      value: product.id,
      child: Text(product.summary),
    )).toList(),
    decoration: const InputDecoration(
      labelText: "Abbonamento",
    ),
    initialValue: _product?.id,
    enabled: widget.enabled && widget.isNew && _member != null,
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
        ? (
        (widget.datetime == null)
            ? null
            : Fixture(
                date: widget.datetime!.date,
                from: widget.datetime!.time,
                to: widget.datetime!.add(Duration(hours: 1)).time,
            )
        )
        : Fixture(
          date: widget.meeting!.date,
          from: widget.meeting!.from,
          to: widget.meeting!.to,
        ),
    enabled: widget.enabled && _product != null,
    fixDate: widget.meeting?.isInstance ?? false,
    key: _fixtureForm,
  );

  Widget recurrenceForm() => RecurrenceWidget(
    _product,
    widget.meeting?.recurrenceUntil ?? _product?.stop,
    widget.meeting?.recurrenceRule != null,
    allow: widget.isNew,
    enabled: widget.enabled && _product != null,
    key: _repeatForm,
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
          if (!(widget.meeting?.isOccurrence ?? false)) Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: recurrenceForm()
          ),
        ],
      ),
    );
  }
}
