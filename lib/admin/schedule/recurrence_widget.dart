//flutter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//downloaded
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//models
import 'package:egpt/models/product.dart';
//widgets
//extras
import 'package:egpt/utils/datetime.dart';


class RecurrenceWidget extends StatefulWidget {
  final Product? product;
  final Date? until;
  final bool repeat;
  final bool allow;
  final bool enabled;

  const RecurrenceWidget(this.product, this.until, this.repeat, {
    this.allow = true,
    this.enabled = true,
    super.key
  });

  @override
  State<RecurrenceWidget> createState() => RecurrenceWidgetState();
}

class RecurrenceWidgetState extends State<RecurrenceWidget> {
  final _recurrenceForm = GlobalKey<FormBuilderState>();

  String? get recurrenceRule {
    final form = _recurrenceForm.currentState;
    if (form?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(form!.value);
      if (data["repeat"]) {
        final Date until = data["until"];
        return "FREQ=DAILY;INTERVAL=7;UNTIL=${until.toISOFormat()}";
      }
    }
    return null;
  }

  Widget untilForm() {
    return FormBuilderDateTimePicker(
        key: ValueKey(widget.until ?? widget.product?.stop),
        name: "until",
        format: DateFormat('dd/MM/yyyy'),
        inputType: InputType.date,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 14,
        ),
        lastDate: widget.product?.stop,
        firstDate: widget.product?.start,
        initialValue: widget.until ?? widget.product?.stop,
        valueTransformer: (value) => Date.fromDateTime(value!),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.dateTime(),
        ]),
      );
}

  Widget repeatSwitch() => FormBuilderSwitch(
    key: ValueKey(widget.repeat),
    name: "repeat",
    title: const Text(""),
    decoration: const InputDecoration(
      border: InputBorder.none,
    ),
    enabled: widget.allow,
    initialValue: widget.repeat,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _recurrenceForm,
      enabled: widget.enabled && widget.product != null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: Text("Ripeti fino al ")),
          Expanded(child: untilForm()),
          Expanded(child: repeatSwitch()),
        ],
      ),
    );
  }

}
