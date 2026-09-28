import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/style.dart';


class ProductView extends StatelessWidget {
  const ProductView(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.summary),
            Text("${product.done}(${product.redo})/${product.length}",
              textAlign: TextAlign.right,
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Column(
          children: [
            LinearPercentIndicator(
              percent: product.done / product.length,
              backgroundColor: scheme.neutral,
              progressColor: scheme.primary,
            ),
            LinearPercentIndicator(
              percent: product.pastDays / product.duration,
              backgroundColor: scheme.neutral,
              progressColor: product.isWarning()
                  ? scheme.warning
                  : scheme.outline,
            ),
          ],
        ),
      ],
    );
  }
}
