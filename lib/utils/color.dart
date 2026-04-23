import 'dart:ui';


extension MemberColor on Color {
  String toHexString({bool includeAlpha = true}) {
    final alpha = includeAlpha ? this.alpha.toRadixString(16).padLeft(2, '0') : '';
    final red = this.red.toRadixString(16).padLeft(2, '0');
    final green = this.green.toRadixString(16).padLeft(2, '0');
    final blue = this.blue.toRadixString(16).padLeft(2, '0');
    return '$alpha$red$green$blue'.toUpperCase();
  }
}


extension StringColor on String {
  Color toColor() => Color(int.parse(this, radix: 16));
}
