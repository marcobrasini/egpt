import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'product_view.dart';


class RegisterTile extends StatelessWidget {
  const RegisterTile(this.memberId, {
    required this.open,
    super.key,
  });

  final String memberId;
  final VoidCallback open;

  @override
  Widget build(BuildContext context){
    return Selector<RegisterSource, (Member, List<Product>)>(
      selector: (_, register) {
        final member = register.member(memberId);
        return (member, member.products);
      },
      builder: (context, data, _) {
        final (member, allProducts) = data;
        final products = allProducts.where((p) => p.isValid()).toList();
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsetsGeometry.all(8.0),
            leading: CircleAvatar(
              backgroundColor: member.color,
              radius: 32,
              child: Text(
                "${member.firstName[0]}${member.lastName[0]}".toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            title: Text(member.name, style: const TextStyle(fontSize: 18)),
            subtitle: products.isNotEmpty ? Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: products.map(ProductView.new).toList(),
            ) : null,
            onTap: open,
          ),
        );
      },
    );
  }
}
