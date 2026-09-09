import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:calendar/calendar.dart';
import '../../models/product.dart';
import '../../typedef.dart';


class PatternForm extends StatefulWidget {
  final Pattern? pattern;
  final Product? product;
  final bool enabled;

  const PatternForm(
    this.pattern, {
    this.product,
    this.enabled = true,
    super.key,
  });

  @override
  State<PatternForm> createState() => PatternFormState();
}

class PatternFormState extends State<PatternForm> {
  final _patternForm = GlobalKey<FormBuilderState>();
  bool get _editable => widget.enabled;
  bool get _settable => widget.product != null;
  late bool _repeat;

  @override
  void initState() {
    super.initState();
    _repeat = widget.pattern != null;
  }

  DataMap? get data {
    final patternForm = _patternForm.currentState;
    if (patternForm?.saveAndValidate() ?? false) {
      final data = DataMap.from(patternForm!.value);
      return {
        "pattern": (_repeat)
            ? Pattern(type: PatternType.weekly, until: data["until"])
            : null,
      };
    }
    return null;
  }

  Widget untilForm() => FormBuilderDateTimePicker(
    key: ValueKey(widget.pattern?.until ?? widget.product?.stop),
    name: "until",
    enabled: _settable,
    decoration: const InputDecoration(border: InputBorder.none),
    style: const TextStyle(
      fontSize: 14,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.solid,
    ),
    textAlign: TextAlign.center,
    format: DateFormat('dd/MM/yyyy'),
    inputType: InputType.date,
    lastDate: widget.product?.stop,
    firstDate: widget.product?.start,
    initialValue: widget.pattern?.until ?? widget.product?.stop,
    valueTransformer: (value) => value!.date,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
  );

  Widget repeatForm() => FormBuilderField<bool>(
    name: "repeat",
    initialValue: _repeat,
    builder: (FormFieldState<bool> field) => Switch.adaptive(
      value: field.value!,
      onChanged: _editable
          ? (value) {
              field.didChange(value);
              setState(() => _repeat = value);
            }
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _patternForm,
      // enabled: _editing,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Ripeti fino al"),
          Expanded(child: untilForm()),
          repeatForm(),
        ],
      ),
    );
  }
}
