//flutter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//downloaded
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//models
import 'package:egpt/models/fixture.dart';
//widgets
//extras
import 'package:egpt/utils/datetime.dart';


class FixtureWidget extends StatefulWidget {
  final Fixture? fixture;
  final bool enabled;
  final bool fixDate;

  const FixtureWidget(this.fixture, {
    this.enabled = true,
    this.fixDate = false,
    super.key
  });

  @override
  State<FixtureWidget> createState() => FixtureWidgetState();
}

class FixtureWidgetState extends State<FixtureWidget> {
  final _fixtureForm = GlobalKey<FormBuilderState>();

  Map<String, dynamic>? get data {
    final form = _fixtureForm.currentState;
    if (form?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(form!.value);
      return data;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget dateForm() => FormBuilderDateTimePicker(
    name: "date",
    format: DateFormat('dd/MM/yyyy'),
    inputType: InputType.date,
    decoration: const InputDecoration(
      labelText: "Data",
      icon: Icon(Icons.calendar_month),
    ),
    enabled: widget.enabled && !widget.fixDate,
    initialValue: widget.fixture?.date,
    valueTransformer: (value) => Date.fromDateTime(value!),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
  );

  Widget fromForm() => FormBuilderDateTimePicker(
    name: "from",
    inputType: InputType.time,
    decoration: const InputDecoration(
      labelText: "dalle",
      icon: Icon(Icons.schedule),
    ),
    enabled: widget.enabled,
    initialValue: widget.fixture?.from.toDateTime(),
    valueTransformer: (value) => Time.fromDateTime(value!),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      final to = _fixtureForm.currentState!.fields["to"]?.value;
      if (to == null || to.isBefore(value)) {
        _fixtureForm.currentState!.fields["to"]?.didChange(
            value!.add(Duration(hours: 1))
        );
      }
    },
  );

  Widget toForm() => FormBuilderDateTimePicker(
    name: "to",
    inputType: InputType.time,
    decoration: const InputDecoration(
      labelText: "alle",
      icon: Icon(Icons.schedule),
    ),
    enabled: widget.enabled,
    initialValue: widget.fixture?.to.toDateTime(),
    valueTransformer: (value) => Time.fromDateTime(value!),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      final from = _fixtureForm.currentState!.fields["from"]?.value;
      if (from == null || from.isAfter(value)) {
        _fixtureForm.currentState!.fields["from"]?.didChange(
            value!.add(Duration(hours: -1))
        );
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _fixtureForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dateForm(),
          Row(
            children: [
              Expanded(child: fromForm()),
              Expanded(child: toForm()),
            ],
          ),
        ],
      ),
    );
  }
}
