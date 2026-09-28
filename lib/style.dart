import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:egpt/models/models.dart';
import 'package:provider/provider.dart';
export 'utils/color.dart';


const colorSeed = Color(0xFF72B13F);


extension WarningColors on ColorScheme {
  static final _light = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFFA000),
    brightness: Brightness.light,
  );
  static final _dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFFA000),
    brightness: Brightness.dark,
  );

  ColorScheme get _warning => brightness == Brightness.dark ? _dark : _light;

  Color get seed => colorSeed;
  Color get neutral => const Color(0x80808080);
  Color get warning => _warning.primary;
  Color get onWarning => _warning.onPrimary;
  Color get warningContainer => _warning.primaryContainer;
  Color get onWarningContainer => _warning.onPrimaryContainer;
}


class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.watch<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Switch(
      value: isDark,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      inactiveThumbColor: scheme.onPrimary,
      inactiveTrackColor: scheme.primary,
      activeThumbColor: scheme.onPrimary,
      activeTrackColor: scheme.primary,
      thumbIcon: WidgetStateProperty.resolveWith(
        (states) => switch(Theme.of(context).brightness) {
          Brightness.light => Icon(Icons.light_mode, color: scheme.primary),
          Brightness.dark => Icon(Icons.dark_mode, color: scheme.primary),
        }
      ),
      onChanged: (dark) => switch(Theme.of(context).brightness) {
        Brightness.light => controller.setMode(ThemeMode.dark),
        Brightness.dark => controller.setMode(ThemeMode.light),
      },
    );
  }
}



IconData statusSymbol(Product product) {
  if (product.isComplete()) {
    return Icons.check;
  } else if (product.isExpired()) {
    return Icons.close;
  } else {
    return FontAwesomeIcons.dumbbell;
  }
}

Color statusColor(Product product, ColorScheme scheme) {
  if (product.isComplete()) {
    return scheme.secondary;
  } else if (product.isExpired()) {
    return scheme.error;
  } else if (product.isWarning()) {
    return scheme.warning;
  } else if (product.isOngoing()) {
    return scheme.primary;
  } else {
    return scheme.neutral;
  }
}
