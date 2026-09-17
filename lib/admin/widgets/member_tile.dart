import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:flutter/material.dart';
import 'product_view.dart';


class MemberTile extends StatelessWidget {
  const MemberTile(
      this.member, {
        required this.setMember,
        super.key,
      });

  final Member member;
  final VoidCallback setMember;

  Iterable<Product> get products =>
      member.products.where((product) => product.isValid());

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: CircleAvatar(
        radius: 32,
        backgroundColor: member.color,
        child: Text(
          "${member.firstName[0]}${member.lastName[0]}".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(member.name, style: const TextStyle(fontSize: 18)),
      subtitle: (products.isEmpty)
          ? null
          : Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: member.products
            .where((product) => product.isValid())
            .map((product) => ProductView(product))
            .toList(),
      ),
      onTap: setMember,
    ),
  );
}
