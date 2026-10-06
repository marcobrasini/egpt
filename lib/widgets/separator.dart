import 'package:flutter/material.dart';


class Separator extends StatelessWidget {
  const Separator({
    required this.text,
    this.alignment = MainAxisAlignment.center,
    this.style,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if ([MainAxisAlignment.center, MainAxisAlignment.end].contains(alignment))
          const Expanded(child: Divider()),
        Text(text, style: style),
        if ([MainAxisAlignment.center, MainAxisAlignment.start].contains(alignment))
          const Expanded(child: Divider()),
      ],
    );
  }
}
