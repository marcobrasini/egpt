import 'package:flutter/material.dart';
import 'package:egpt/models/product.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


class ProductView extends StatelessWidget {
  final Product product;
  const ProductView(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4.0,
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
        LinearPercentIndicator(
          percent: product.pastDays/product.duration,
          backgroundColor: Colors.grey.shade500,
          progressColor: product.statusColor(),
        ),
      ],
    );
  }

}
