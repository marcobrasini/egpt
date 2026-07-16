import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/widgets/product_widget.dart';
import 'package:egpt/admin/register/product_tile.dart';


class ProductList extends StatefulWidget {
  final Member member;
  final bool enabled;
  const ProductList(this.member, {this.enabled = true, super.key});

  @override
  State<ProductList> createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  late bool _enabled;

  void enable(bool enabled) {
    setState(() {
      _enabled = enabled;
    });
  }

  Future<void> _setProduct(BuildContext context, Product product) async {
    if (!_enabled) return;
    final source = context.read<AdminSource>();
    final productWidget = GlobalKey<ProductWidgetState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Abbonamento"),
          content: ProductWidget(product, key: productWidget),
          actions: [
            TextButton(
              child: const Text("Modifica"),
              onPressed: () async {
                final data = productWidget.currentState!.data;
                if (data == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Modifica fallita.')),
                  );
                } else {
                  await source.updateProduct(product.set(data));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Modifica salvata.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _delProduct(BuildContext context, Product product) async {
    if (!_enabled) return;
    final source = context.read<AdminSource>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: Colors.black,
                fontSize: 18.0,
              ),
              children: [
                const TextSpan(text: "Vuoi eliminare l'abbonamento\n"),
                TextSpan(
                  text: "'${product.summary}'",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " di ${widget.member.name}?"),
              ],
            )
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Elimina"),
              onPressed: () async {
                await source.deleteProduct(product);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Abbonamento eliminato.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _enabled = widget.enabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSource>(
      builder: (context, source, child) {
        final register = source.register;
        final member = register.member(widget.member.id!);
        final products = member.products;
        if (products.isEmpty) {
          return Center(
              child: Text("Nessun abbonamento",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          );
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductTile(
              product,
              _setProduct,
              _delProduct,
            );
          }
        );
      },
    );
  }
}
