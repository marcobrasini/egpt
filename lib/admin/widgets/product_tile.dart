import 'package:flutter/material.dart';
import 'package:egpt/models/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProductTile extends StatelessWidget {
  final VoidCallback setProduct;
  final VoidCallback delProduct;
  final Product product;

  const ProductTile(
    this.product,
    this.setProduct,
    this.delProduct, {
    super.key,
  });

  IconData statusSymbol() {
    if (product.isComplete()) {
      return Icons.check;
    } else if (product.isExpired()) {
      return Icons.close;
    } else {
      return FontAwesomeIcons.dumbbell;
    }
  }

  Widget tileProgress() => CircularPercentIndicator(
    radius: 32,
    lineWidth: 5,
    center: FaIcon(statusSymbol()),
    progressColor: product.statusColor(),
    percent: product.pastDays / product.duration,
  );

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: setProduct,
    onLongPress: delProduct,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 16.0,
          children: [
            tileProgress(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.summary,
                        style: TextStyle(fontSize: 18.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Inizio: ${product.start}"),
                          Text("Fine:   ${product.stop}"),
                        ],
                      ),
                      Text(product.recap, style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
