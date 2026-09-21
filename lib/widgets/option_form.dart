import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:egpt/models/models.dart';


class OptionForm extends StatefulWidget {
  final MeetingType option;
  final bool enabled;
  const OptionForm({
    this.option = MeetingType.exception,
    this.enabled = true,
    super.key,
  });

  @override
  State<OptionForm> createState() => OptionFormState();
}

class OptionFormState extends State<OptionForm> {
  final _meetingType = GlobalKey<FormBuilderState>();
  late MeetingType _type;
  MeetingType get option => _type;

  MeetingType? get meetingType {
    final meetingType = _meetingType.currentState;
    if (meetingType?.saveAndValidate() ?? false) {
      final data = Map<String, dynamic>.from(meetingType!.value);
      return data["meetingType"];
    }
    return null;
  }

  @override
  void initState() {
    _type = widget.option;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _meetingType,
      child: FormBuilderRadioGroup(
        name: 'meetingType',
        enabled: widget.enabled,
        decoration: InputDecoration(border: InputBorder.none),
        options: [
          FormBuilderFieldOption(
            value: MeetingType.exception,
            child: Text("il singolo evento"),
          ),
          FormBuilderFieldOption(
            value: MeetingType.deviation,
            child: Text("tutti gli eventi successivi"),
          ),
          FormBuilderFieldOption(
            value: MeetingType.recurrence,
            child: Text("tutti gli eventi ricorrenti"),
          ),
        ],
        initialValue: widget.option,
      ),
    );
  }
}
