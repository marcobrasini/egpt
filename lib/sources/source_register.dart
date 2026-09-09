import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';


class RegisterSource {
  static final List<Member> _members = [];
  static final _instance = RegisterSource._singleton();
  RegisterSource._singleton();
  factory RegisterSource() => _instance;

  List<Member> get members => _members;
  List<Product> get products => members.expand((m) => m.products).toList();
  void set(List<Member> members) => _members..clear()..addAll(members);

  // Member ────────────────────────────────────────────────────────────────────
  Member member(String memberId) {
    final member = members.where((m) => m.id == memberId).singleOrNull;
    if (member == null) throw("No member with id: $memberId");
    return member;
  }

  Member insertMember(Member member) {
    _members.add(member);
    return member;
  }

  Member modifyMember(Member member) {
    //
    return member;
  }

  Member removeMember(Member member) {
    _members.remove(member);
    return member;
  }

  List<String> get memberNames => members.map((m) => m.name).toList();

  // Product ───────────────────────────────────────────────────────────────────
  Product product(String productId) {
    final product = products.where((m) => m.id == productId).singleOrNull;
    if (product == null) throw("No product with id: $productId");
    return product;
  }

  Product insertProduct(Product product) {
    product.member.products.add(product);
    return product;
  }

  Product modifyProduct(Product product) {
    //
    return product;
  }

  Product removeProduct(Product product) {
    product.member.products.remove(product);
    return product;
  }
}


abstract class EGPTData {
  static final register = RegisterSource();
}