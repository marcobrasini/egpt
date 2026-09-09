import 'package:flutter/material.dart';
import '../../models/meeting.dart';


class PresenceTile extends StatefulWidget {
  const PresenceTile({
    super.key,
    required this.meeting,
    required this.onChanged,
    this.presence,
  });
  final Meeting meeting;
  final ValueChanged<bool?> onChanged;
  final bool? presence;

  @override
  State<PresenceTile> createState() => _PresenceTileState();
}

class _PresenceTileState extends State<PresenceTile> {
  bool? presence;

  Widget _radioButton(String label, bool value, Color color) {
    final selected = (presence == value);
    return OutlinedButton(
        onPressed: () => setState(() {
          presence = selected ? null : value;
          widget.onChanged(presence);
        }),
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.black : color,
          backgroundColor: selected ? color : Colors.transparent,
          side: BorderSide(color: color),
          shape: const StadiumBorder(),
        ),
        child: Text(label),
    );
  }

  @override
  void initState() {
    super.initState();
    presence = widget.presence;
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.meeting.subject,
            style: TextStyle(color: color, fontSize: 20),
          ),
          Text("${widget.meeting.from} - ${widget.meeting.to}",
            style: TextStyle(color: color),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _radioButton("Presente", true, color),
                _radioButton("Recupero", false, color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}