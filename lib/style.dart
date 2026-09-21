import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:egpt/models/models.dart';
export 'utils/color.dart';


IconData statusSymbol(Product product) {
  if (product.isComplete()) {
    return Icons.check;
  } else if (product.isExpired()) {
    return Icons.close;
  } else {
    return FontAwesomeIcons.dumbbell;
  }
}

Color statusColor(Product product) {
  if (product.isComplete()) {
    return Colors.green;
  } else if (product.isExpired()) {
    return Colors.red;
  } else if (product.isWarning()) {
    return Colors.yellow;
  } else if (product.isOngoing()) {
    return Colors.blue;
  } else {
    return Colors.grey;
  }
}