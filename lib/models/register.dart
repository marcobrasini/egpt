import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';


class Register {
  static final instance = Register._singleton();
  Register._singleton();
  factory Register() {
    return instance;
  }

  final List<Member> members = [];
  List<Product> get products => members.expand((m) => m.products).toList();

  void clear() => members.clear();

  void insertMember(Member member) => members.add(member);

  void removeMember(Member member) => members.remove(member);

  void insertProduct(Product product) => member(product.memberId)
      .products.add(product);

  void removeProduct(Product product) => member(product.memberId)
      .products.remove(product);

  Member member(String memberId) => members
      .firstWhere((m) => m.id == memberId);

  Product product(String productId) => products
      .firstWhere((p) => p.id == productId);

  (Member, Product) getMemberAndProduct(String productId) {
    final member = members.firstWhere((m) => m.products.any((p) => p.id == productId));
    final product = member.products.firstWhere((p) => p.id == productId,);
    return (member, product);
  }

  List<String> get memberNames => members.map(
          (member) => member.name
  ).toList();
  List<String> get memberFirstNames => members.map(
          (member) => member.firstName
  ).toList();
  List<String> get memberLastNames => members.map(
          (member) => member.lastName
  ).toList();
}
