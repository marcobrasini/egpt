import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/product.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:numberpicker/numberpicker.dart';


class ProductWidget extends StatefulWidget {
  final Product? product;
  final bool enabled;
  const ProductWidget(this.product, {this.enabled = true, super.key});

  @override
  State<ProductWidget> createState() => ProductWidgetState();
}

class ProductWidgetState extends State<ProductWidget> {
  final _productKey = GlobalKey<FormBuilderState>();
  late bool _enabled;
  late int _length;
  int? _months;

  static const templates = {
    "2 Mesi": [2, 17],
    "6 Mesi": [6, 50],
    "12 Mesi": [12, 100],
  };

  Map<String, dynamic>? get data {
    if (_productKey.currentState?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(_productKey.currentState!.value);
      return data;
    }
    return null;
  }

  void enable(bool enabled) {
    setState(() {
      _enabled = enabled;
    });
  }

  void _applyTemplate(String key) {
    if (!templates.containsKey(key)) return;
    setState(() {
      _months = templates[key]![0];
      _length = templates[key]![1];
    });
    final form = _productKey.currentState;
    if (form != null) {
      form.fields['summary']!.didChange(key);
      form.fields['length']!.didChange(_length);
      final start = form.fields["start"]?.value;
      if (start!=null) {
        form.fields["stop"]?.didChange(
            Date(start.year, start.month+_months, start.day)
        );
      }
    }
  }


  @override
  void initState() {
    _enabled = widget.enabled;
    _length = widget.product?.length ?? 0;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _productKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'summary',
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  enabled: _enabled,
                  initialValue: widget.product?.summary,
                ),
              ),
              if (widget.product==null) PopupMenuButton<String>(
                icon: Icon(Icons.more_vert), // L'icona del pulsante
                enabled: _enabled,
                itemBuilder: (BuildContext context) {
                  return templates.keys.map((key) {
                    return PopupMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList();
                },
                onSelected: _applyTemplate,
              ),
            ],
          ),
          FormBuilderField(
            name: "length",
            builder: (FormFieldState<dynamic> field) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: "Sessioni",
                ),
                child: NumberPicker(
                  minValue: 0,
                  maxValue: 100,
                  value: _length,
                  onChanged: (value) {
                    setState(() {
                      _length = value;
                      field.didChange(value);
                    });
                  },
                  axis: Axis.horizontal,
                ),
              );
            },
            enabled: _enabled,
            initialValue: _length,
            valueTransformer: (value) => _length,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
            ]),
          ),
          FormBuilderDateTimePicker(
            name: "start",
            format: DateFormat('dd/MM/yyyy'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.dateTime(),
            ]),
            inputType: InputType.date,
            decoration: InputDecoration(
              labelText: "Inizio",
              icon: Icon(Icons.calendar_month),
            ),
            enabled: _enabled,
            initialValue: widget.product?.start,
            onChanged: (value) {
              if (value==null) return;
              final form = _productKey.currentState!;
              final stop = form.fields["stop"]?.value;
              if (stop!=null) {
                if (stop.isBefore(value)) {
                  form.fields["stop"]?.didChange(
                      value.add(Duration(days: 0))
                  );
                }
              } else if (_months!=null) {
                form.fields["stop"]?.didChange(
                  Date(value.year, value.month+_months!, value.day)
                );
              }
            },
            valueTransformer: (value) => value!.date,
          ),
          FormBuilderDateTimePicker(
            name: "stop",
            format: DateFormat('dd/MM/yyyy'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.dateTime(),
            ]),
            inputType: InputType.date,
            decoration: InputDecoration(
              labelText: "Fine",
              icon: Icon(Icons.calendar_month),
            ),
            enabled: _enabled,
            initialValue: widget.product?.stop,
            onChanged: (value) {
              if (value==null) return;
              final form = _productKey.currentState!;
              final start = form.fields["start"]?.value;
              if (start!=null) {
                if (start.isAfter(value)) {
                  form.fields["start"]?.didChange(
                      value.add(Duration(days: 0))
                  );
                }
              }
            },
            valueTransformer: (value) => value!.date,
          ),
        ],
      ),
    );
  }
}
