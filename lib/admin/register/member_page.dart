import 'package:flutter/material.dart';
// downloaded
import 'package:provider/provider.dart';
// admin
import 'package:egpt/admin/source_admin.dart';
// models
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
// widget
import 'package:egpt/admin/widgets/product_widget.dart';
import 'package:egpt/admin/widgets/member_widget.dart';
import 'package:egpt/admin/register/product_list.dart';


class MemberPage extends StatefulWidget {
  final Member member;
  const MemberPage(this.member, {super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final _memberWidgetKey = GlobalKey<MemberWidgetState>();
  final _productListKey = GlobalKey<ProductListState>();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setMember(BuildContext context) async {
    if (!context.mounted) return;
    final source = context.read<AdminSource>();
    final data = _memberWidgetKey.currentState?.data;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modifica fallita.')),
      );
    } else {
      await source.updateMember(
          widget.member.set(data)
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modifica salvata.')),
      );
    }
  }

  Future<void> _addProduct(BuildContext context) async {
    if (_editing) return;
    final source = context.read<AdminSource>();
    final productWidget = GlobalKey<ProductWidgetState>();
    final product = await showDialog<Product?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nuovo Abbonamento"),
          content: ProductWidget(null, key: productWidget),
          actions: [
            TextButton(
              child: const Text("Sottoscrivi"),
              onPressed: () async {
                final data = productWidget.currentState!.data;
                if (data == null) {
                  Navigator.of(context).pop(null);
                } else {
                  data['memberId'] = widget.member.id;
                  Navigator.of(context).pop(Product.make(data: data));
                }
              },
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sottoscrizione fallita.')),
      );
    } else {
      await source.createProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sottoscrizione riuscita.')),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_editing) _setMember(context);
                _editing = !_editing;
                _memberWidgetKey.currentState?.enable(_editing);
                _productListKey.currentState?.enable(!_editing);
              });
            },
            icon: _editing ? Icon(Icons.save) : Icon(Icons.edit),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: MemberWidget(
                widget.member,
                enabled: _editing,
                key: _memberWidgetKey
              ),
            ),
            Text("Abbonamenti:"),
            Expanded(
              child: ProductList(
                widget.member,
                enabled: !_editing,
                key: _productListKey
              ),
            ),
            ElevatedButton(
              onPressed: () => _addProduct(context),
              child: Text('Nuovo abbonamento'),
            )
          ],
        ),
      ),
    );
  }
}
