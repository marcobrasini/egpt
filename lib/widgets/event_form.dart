import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:egpt/widgets/forms.dart';


class EventForm extends StatefulWidget {
  final Event? event;
  final DateTime? datetime;
  final bool enabled;

  const EventForm(
      this.event, {
        this.datetime,
        this.enabled = true,
        super.key,
      });

  Fixture? get fixture => (datetime != null)
      ? (datetime is Date)
          ? Fixture(start: datetime as Date)
          : Fixture(start: datetime!, stop: datetime!.add(Duration(hours: 1)))
      : event;

  @override
  State<EventForm> createState() => EventFormState();
}

class EventFormState extends State<EventForm> {
  final _eventForm = GlobalKey<FormBuilderState>();
  final _fixtureForm = GlobalKey<FixtureFormState>();
  bool get _editing => widget.enabled;

  Widget subjectForm() => FormBuilderTextField(
    name: 'subject',
    enabled: _editing,
    decoration: const InputDecoration(labelText: 'Descrizione'),
    initialValue: widget.event?.subject,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
  );

  Widget fixtureForm() => FixtureForm(
    widget.event ?? widget.fixture,
    enabled: _editing,
    key: _fixtureForm,
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _eventForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          subjectForm(),
          fixtureForm(),
        ],
      ),
    );
  }
}
