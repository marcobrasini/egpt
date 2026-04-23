import 'package:flutter/material.dart';
// widgets
import 'package:egpt/admin/register/product_view.dart';
// models
import 'package:egpt/models/member.dart';


class MemberTile extends StatelessWidget {
  final void Function(BuildContext context, Member member) setMember;
  final void Function(BuildContext context, Member member) delMember;
  final Member member;
  const MemberTile(
      this.member,
      this.setMember,
      this.delMember, {
        super.key
      });

  Widget tileAvatar({
    required double radius,
    required double ratio,
    required Color color
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        "${member.firstName[0]}${member.lastName[0]}".toUpperCase(),
        style: TextStyle(
          fontSize: ratio*radius,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget tileProducts({
      required double spacing
  }) {
    return Column(
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: member.products
          .where((product) => product.isValid())
          .map((product) => ProductView(product))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: tileAvatar(
          radius: 35,
          ratio: 0.75,
          color: member.color,
        ),
        title: Text(member.name,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        subtitle: tileProducts(
            spacing: 8.0
        ),
        onTap: () => setMember(context, member),
        onLongPress: () => delMember(context, member),
      ),
    );
  }
}
