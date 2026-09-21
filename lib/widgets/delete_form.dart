import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


class DeleteForm extends StatefulWidget {
  const DeleteForm(this.confirm, {super.key});

  final String confirm;

  @override
  State<DeleteForm> createState() => DeleteFormState();
}

class DeleteFormState extends State<DeleteForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  String get _errorMessage => "Digita '${widget.confirm}'";

  bool? get confirm {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      return _formKey.currentState!.fields["confirm"]!.value == widget.confirm;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => FormBuilder(
    key: _formKey,
    child: FormBuilderTextField(
      name: 'confirm',
      initialValue: null,
      decoration: InputDecoration(
        helper: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: "Digita '"),
              TextSpan(
                text: widget.confirm,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "'"),
            ],
          ),
        ),
        icon: Icon(Icons.keyboard),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: _errorMessage),
        FormBuilderValidators.equal(widget.confirm, errorText: _errorMessage),
      ]),
    ),
  );
}


Future<bool> showDeleteDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String string,
}) async {
  final deleteForm = GlobalKey<DeleteFormState>();
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          DeleteForm(string, key: deleteForm),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.delete_forever),
          label: const Text("Elimina", style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialog).colorScheme.error,
            foregroundColor: Theme.of(dialog).colorScheme.onError,
          ),
          onPressed: () {
            if (deleteForm.currentState?.confirm case final confirmation?) {
              Navigator.of(dialog).pop(confirmation);
            }
          },
        ),
      ],
    ),
  );
  return confirm ?? false;
}
