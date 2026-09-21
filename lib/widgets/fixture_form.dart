import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/models.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:egpt/types.dart';


class FixtureForm extends StatefulWidget {
  final Fixture? fixture;
  final bool enabled;

  const FixtureForm(this.fixture, {
    this.enabled = true,
    super.key
  });

  @override
  State<FixtureForm> createState() => FixtureFormState();
}

class FixtureFormState extends State<FixtureForm> {
  final _fixtureForm = GlobalKey<FormBuilderState>();
  bool get _editing => widget.enabled || widget.fixture == null;

  DataMap? get data {
    final form = _fixtureForm.currentState;
    if (form?.saveAndValidate() ?? false) {
      final data = DataMap.from(form!.value);
      return {
        "start": (data["date"] as Date) & (data["from"] as Time),
        "stop": (data["date"] as Date) & (data["to"] as Time),
      };
    }
    return null;
  }

  Widget dateForm() => FormBuilderDateTimePicker(
    name: "date",
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: "Data",
      icon: Icon(Icons.calendar_month),
    ),
    inputType: InputType.date,
    format: DateFormat('dd/MM/yyyy'),
    initialValue: widget.fixture?.date,
    valueTransformer: (value) => value!.date,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
  );

  void _defaultTo(DateTime value) {
    final form = _fixtureForm.currentState;
    if (form != null) {
      final to = form.fields["to"]?.value;
      if (to == null || to.isBefore(value)) {
        form.fields["to"]?.didChange(value.add(Duration(hours: 1)));
      }
    }
  }
  Widget fromForm() => FormBuilderDateTimePicker(
    name: "from",
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: "dalle",
      icon: Icon(Icons.schedule),
    ),
    inputType: InputType.time,
    initialValue: widget.fixture?.from,
    valueTransformer: (value) => value!.time,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      _defaultTo(value);
    },
  );

  void _defaultFrom(DateTime value) {
    final form = _fixtureForm.currentState;
    if (form != null) {
      final from = form.fields["from"]?.value;
      if (from == null || from.isAfter(value)) {
        form.fields["from"]?.didChange(value.add(Duration(hours: -1)));
      }
    }
  }
  Widget toForm() => FormBuilderDateTimePicker(
    name: "to",
    enabled: _editing,
    inputType: InputType.time,
    decoration: const InputDecoration(
      labelText: "alle",
      icon: Icon(Icons.schedule),
    ),
    initialValue: widget.fixture?.to,
    valueTransformer: (value) => value!.time,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      _defaultFrom(value);
    },
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _fixtureForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
