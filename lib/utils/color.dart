import 'dart:ui';


extension MemberColor on Color {
  String toHexString({bool includeAlpha = true}) {
    return toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  }
}


extension StringColor on String {
  Color toColor() => Color(int.parse(this, radix: 16));
}
