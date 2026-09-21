import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/widgets/forms.dart';


class MeetingForm extends StatefulWidget {
  final RegisterSource register;
  final Meeting? meeting;
  final DateTime? datetime;
  final bool enabled;

  const MeetingForm(
    this.register,
    this.meeting, {
    this.datetime,
    this.enabled = true,
    super.key,
  });

  bool get creating => meeting == null;
  Fixture? get fixture => (datetime != null)
      ? Fixture(start: datetime!, stop: datetime!.add(Duration(hours: 1)))
      : null;

  @override
  State<MeetingForm> createState() => MeetingFormState();
}

class MeetingFormState extends State<MeetingForm> {
  final _meetingForm = GlobalKey<FormBuilderState>();
  final _fixtureForm = GlobalKey<FixtureFormState>();
  final _patternForm = GlobalKey<PatternFormState>();
  Product? _product;
  Member? _member;
  bool get _making => widget.creating;
  bool get _editing => widget.enabled;

  Map<String, dynamic>? get data {
    final meetingForm = _meetingForm.currentState;
    final fixtureForm = _fixtureForm.currentState;
    final patternForm = _patternForm.currentState;
    if ((meetingForm?.saveAndValidate() ?? false) && fixtureForm != null) {
      final fixture = fixtureForm.data;
      final pattern = patternForm?.data;
      if (fixture != null) {
        final data = Map<String, dynamic>.from(meetingForm!.value);
        return {...data, ...fixture, if (pattern != null) ...pattern};
      }
    }
    return null;
  }

  @override
  void initState() {
    _product = widget.meeting?.product;
    _member = widget.meeting?.product.member;
    super.initState();
  }

  List<String> _filterNames(List<String> names, String pattern) => names
      .where((name) => name.toLowerCase().contains(pattern.toLowerCase()))
      .toList(growable: false);
  Widget memberForm() => FormBuilderTypeAhead<String>(
    key: ValueKey(_member),
    name: 'memberId',
    enabled: _editing && _making,
    decoration: const InputDecoration(labelText: "Membro"),
    initialValue: _member?.name,
    itemBuilder: (context, name) => ListTile(title: Text(name)),
    valueTransformer: (value) => _member?.id!,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Seleziona un membro.'),
    ]),
    suggestionsCallback: (pattern) {
      final names = widget.register.memberNames;
      return (pattern.isNotEmpty) ? _filterNames(names, pattern) : names;
    },
    onChanged: (name) {
      if (name == null && name == _member?.name) return;
      final member = widget.register.members
          .where((m) => m.name == name)
          .singleOrNull;
      if (member == null) return;
      setState(() {
        _member = member;
        final valid = member.products.where((p) => p.isValid()).toList();
        _product = (valid.length == 1) ? valid.first : null;
      });
    },
  );

  Widget productForm() => FormBuilderDropdown(
    key: ValueKey(_product),
    name: "productId",
    enabled: _editing && _making && _member != null,
    decoration: const InputDecoration(labelText: "Abbonamento"),
    items:
        _member?.products
            .where((product) => product.isValid())
            .map(
              (product) => DropdownMenuItem<String>(
                value: product.id,
                child: Text(product.summary),
              ),
            )
            .toList() ??
        [],
    initialValue: _product?.id,
    valueTransformer: (value) => _product?.id!,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Seleziona un abbonamento.'),
    ]),
    onChanged: (productId) {
      if (productId == null) return;
      setState(() {
        _product = _member!.products.singleWhere((p) => p.id == productId);
      });
    },
  );

  Widget fixtureForm() => FixtureForm(
    widget.meeting ?? widget.fixture,
    enabled: _editing && _product != null,
    key: _fixtureForm,
  );

  Widget patternForm() => PatternForm(
    widget.meeting?.pattern,
    enabled: _editing && _making && _product != null,
    product: _product,
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
          if (widget.meeting?.pattern != null || _making) patternForm(),
        ],
      ),
    );
  }
}
