import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/sources/source_register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


typedef FormCallback<T> = Future<T?> Function(BuildContext context);


class FormAction<T> extends StatefulWidget {
  const FormAction(this.label, {this.onPressed, super.key});

  final String label;
  final FormCallback<T>? onPressed;

  @override
  State<FormAction<T>> createState() => _FormActionState<T>();
}

class _FormActionState<T> extends State<FormAction<T>> {
  bool _busy = false;

  void close(T? result) => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.onPressed == null)
          ? () => close(null)
          : () async {
            if (_busy) return; _busy = true;
            try {
              await widget.onPressed!(context);
            } catch (error) {
              close(null);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Errore: $error'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            } finally {
              _busy = false;
            }
          },
      child: Text(widget.label, style: const TextStyle(fontSize: 16)),
    );
  }
}


Future<T?> showFormDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<FormAction>? actions,
}) => showDialog<T>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title, textAlign: TextAlign.center),
    content: content,
    actions: actions,
    actionsAlignment: MainAxisAlignment.spaceBetween,
  ),
);
