import 'package:flutter/material.dart';


typedef FormCallback<T> = Future<T?> Function(BuildContext context);


class FormAction<T> extends StatefulWidget {
  const FormAction(this.label, {
    this.onPressed,
    this.color,
    super.key,
  });

  final String label;
  final Color? color;
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
      child: Text(widget.label,
          style: TextStyle(
            fontSize: 16,
            color: widget.color,
          )
      ),
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
    content: SingleChildScrollView(child: content),
    actions: actions,
    actionsAlignment: ((actions?.length ?? 0) > 1)
        ? MainAxisAlignment.spaceBetween
        : MainAxisAlignment.center,
  ),
);
