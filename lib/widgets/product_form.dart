import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class ProductForm extends StatefulWidget {
  const ProductForm(this.product, {this.enabled = true, super.key});

  final Product? product;
  final bool enabled;

  @override
  State<ProductForm> createState() => ProductFormState();
}

class ProductFormState extends State<ProductForm> {
  static const templates = {
    "12 Mesi": (12, 100),
    "6 Mesi": (6, 50),
    "2 Mesi": (2, 17),
  };

  final _productForm = GlobalKey<FormBuilderState>();
  bool get _editing => widget.enabled || widget.product == null;
  (int, int)? _template;
  int? get _months => _template?.$1;
  int? get _length => _template?.$2;

  DataMap? get data {
    if (_productForm.currentState?.saveAndValidate() ?? false) {
      final data = DataMap.from(_productForm.currentState!.value);
      return data;
    }
    return null;
  }

  void _applyTemplate(String key) {
    final form = _productForm.currentState;
    if (form == null) return;
    _template = templates[key];
    form.fields['summary']!.didChange(key);
    form.fields['length']!.didChange(_length);
    final start = form.fields["start"]?.value;
    if (start != null) {
      form.fields["stop"]?.didChange(
        Date(start.year, start.month + _months, start.day),
      );
    }
  }

  Widget templatePick() => PopupMenuButton<String>(
    enabled: _editing,
    icon: Icon(Icons.more_vert),
    onSelected: _applyTemplate,
    itemBuilder: (context) {
      return templates.keys
          .map((key) => PopupMenuItem<String>(value: key, child: Text(key)))
          .toList();
    },
  );
  Widget summaryForm() => FormBuilderTextField(
    name: 'summary',
    enabled: _editing,
    decoration: const InputDecoration(labelText: 'Descrizione'),
    initialValue: widget.product?.summary,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]),
  );

  Widget lengthPick(FormFieldState<int> field) => StatefulBuilder(
    builder: (context, setState) => NumberPicker(
      axis: Axis.horizontal,
      minValue: 0,
      maxValue: 200,
      value: field.value!,
      onChanged: (value) =>
          _editing ? setState(() => field.didChange(value)) : {},
    ),
  );
  Widget lengthForm() => FormBuilderField<int>(
    name: "length",
    enabled: _editing,
    initialValue: widget.product?.length ?? _length ?? 0,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.numeric(),
    ]),
    builder: (FormFieldState<int> field) => InputDecorator(
      decoration: const InputDecoration(labelText: "Sessioni"),
      child: lengthPick(field),
    ),
  );

  Widget startForm() => FormBuilderDateTimePicker(
    name: "start",
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: "Inizio",
      icon: Icon(Icons.calendar_month),
    ),
    inputType: InputType.date,
    format: DateFormat('dd/MM/yyyy'),
    initialValue: widget.product?.start,
    valueTransformer: (value) => value!.date,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      final form = _productForm.currentState!;
      final stop = form.fields["stop"]?.value;
      if (stop != null) {
        if (stop.isBefore(value)) {
          form.fields["stop"]?.didChange(value.add(Duration(days: 0)));
        }
      } else if (_months != null) {
        form.fields["stop"]?.didChange(
          Date(value.year, value.month + _months!, value.day),
        );
      }
    },
  );

  Widget stopForm() => FormBuilderDateTimePicker(
    name: "stop",
    enabled: _editing,
    decoration: const InputDecoration(
      labelText: "Fine",
      icon: Icon(Icons.calendar_month),
    ),
    inputType: InputType.date,
    format: DateFormat('dd/MM/yyyy'),
    initialValue: widget.product?.stop,
    valueTransformer: (value) => value!.date,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.dateTime(),
    ]),
    onChanged: (value) {
      if (value == null) return;
      final form = _productForm.currentState!;
      final start = form.fields["start"]?.value;
      if (start != null) {
        if (start.isAfter(value)) {
          form.fields["start"]?.didChange(value.add(Duration(days: 0)));
        }
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _productForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: summaryForm()),
              if (widget.product == null) templatePick(),
            ],
          ),
          lengthForm(),
          startForm(),
          stopForm(),
        ],
      ),
    );
  }
}
