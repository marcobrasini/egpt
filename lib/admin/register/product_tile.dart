import 'package:flutter/material.dart';
import 'package:egpt/models/product.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


class ProductTile extends StatelessWidget {
  final void Function(BuildContext context, Product product) setProduct;
  final void Function(BuildContext context, Product product) delProduct;
  final Product product;
  const ProductTile(this.product, this.setProduct, this.delProduct ,{super.key});

  IconData statusSymbol() {
    if (product.isComplete()) {
      return Icons.check;
    } else if (product.isExpired()) {
      return Icons.close;
    } else {
      return Icons.directions_run;
    }
  }

  Widget tileProgress() => CircularPercentIndicator(
    radius: 24,
    center: Icon(statusSymbol()),
    progressColor: product.statusColor(),
    percent: product.pastDays/product.duration,
  );

  Widget tileDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Inizio: ${product.start}"),
      Text("Fine: ${product.stop}"),
    ],
  );

  Widget tilePresence() => Text(
    "${product.done}(${product.redo})/${product.length}",
    style: TextStyle(
      fontSize: 18,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: tileProgress(),
      title: Text(product.summary),
      subtitle: tileDetails(),
      trailing: tilePresence(),
      onTap: () => setProduct(context, product),
      onLongPress: () => delProduct(context, product),
    );
  }
}