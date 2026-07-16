import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/product.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class PatternWidget extends StatefulWidget {
  final Product? product;
  final Pattern? pattern;
  final bool allow;
  final bool enabled;

  const PatternWidget(this.product, this.pattern, {
    this.allow = true,
    this.enabled = true,
    super.key
  });

  @override
  State<PatternWidget> createState() => PatternWidgetState();
}

class PatternWidgetState extends State<PatternWidget> {
  final _patternForm = GlobalKey<FormBuilderState>();

  Map<String, dynamic>? get data {
    final patternForm = _patternForm.currentState;
    if (patternForm?.saveAndValidate() ?? false) {
      return Map<String, dynamic>.from(patternForm!.value);
    }
    return null;
  }

  Widget untilForm() {
    return FormBuilderDateTimePicker(
        key: ValueKey(widget.pattern?.until ?? widget.product?.stop),
        name: "until",
        format: DateFormat('dd/MM/yyyy'),
        inputType: InputType.date,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 12,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.solid,
        ),
        lastDate: widget.product?.stop,
        firstDate: widget.product?.start,
        initialValue: widget.pattern?.until ?? widget.product?.stop,
        valueTransformer: (value) => value!.date,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.dateTime(),
        ]),
      );
}

  Widget repeatSwitch() => FormBuilderSwitch(
    key: ValueKey(widget.pattern != null),
    name: "repeat",
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text("Ripeti fino")),
        Expanded(child: untilForm()),
      ],
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
    ),
    enabled: widget.allow,
    initialValue: widget.pattern != null,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _patternForm,
      enabled: widget.enabled && widget.product != null,
      child: repeatSwitch(),
    );
  }

}
