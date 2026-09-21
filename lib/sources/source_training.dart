import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/typedef.dart';
import 'package:flutter/foundation.dart';


class TrainingSource extends ChangeNotifier {
  TrainingSource(this.admin, {required this.memberId})
      : _member = admin.register.member(memberId) {
    admin.addListener(_adminSync);
  }

  final AdminSource admin;
  final String memberId;
  late Member _member;
  Member get member => _member;

  bool _deleted = false;
  bool get deleted => _deleted;
  bool get expired => admin.register.memberSource[member.id!] == null;

  void _adminSync() {
    if (_deleted) return;
    if (expired) {
      admin.removeListener(_adminSync);
      _deleted = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    admin.removeListener(_adminSync);
    super.dispose();
  }

  Future<Member> modifyMember(Member member) async {
    try {
      await admin.modifyMember(member);
    } on MissingMemberException catch (_) {
      await admin.build();
    }
    notifyListeners();
    return member;
  }

  Future<Member> removeMember(Member member) async {
    try {
      await admin.removeMember(member);
    } on MissingMemberException catch (e) {
      print(e);
      await admin.build();
    }
    notifyListeners();
    return member;
  }

  Future<Product> insertProduct(Product product) async {
    try {
      product = await admin.insertProduct(product);
    } on MissingMemberException catch (_) {
      await admin.build();
    }
    notifyListeners();
    return product;
  }

  Future<Product> modifyProduct(Product product) async {
    try {
      product = await admin.modifyProduct(product);
    } on MissingProductException catch (_) {
      admin.register.removeProduct(product);
    } on MissingMemberException catch (_) {
      await admin.build();
      _deleted = true;
    }
    notifyListeners();
    return product;
  }

  Future<Product> removeProduct(Product product) async {
    try {
      product = await admin.removeProduct(product);
    } on MissingProductException catch (_) {
      admin.register.removeProduct(product);
    } on MissingMemberException catch (_) {
      await admin.build();
      _deleted = true;
    }
    notifyListeners();
    return product;
  }


}