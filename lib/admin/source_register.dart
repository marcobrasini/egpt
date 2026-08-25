import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';


class RegisterSource {
  static final instance = RegisterSource._singleton();
  RegisterSource._singleton();
  factory RegisterSource() {
    return instance;
  }

  final List<Member> _members = [];

  void append(List<Member> members) => _members.addAll(members);

  List<Member> get members => _members;

  Member member(String memberId) => members.singleWhere((m) => m.id == memberId);

  Future<void> createMember(Member member) async {
    _members.add(member);
  }

  Future<void> updateMember(Member member) async {
    //
  }

  Future<void> deleteMember(Member member) async {
    _members.remove(member);
  }

  List<Product> get products => _members.expand((m) => m.products).toList();

  Product product(String productId) => products.singleWhere((p) => p.id == productId);

  Future<void> createProduct(Product product) async {
    member(product.memberId).products.add(product);
  }

  Future<void> updateProduct(Product product) async {
  }

  Future<void> deleteProduct(Product product) async {
    member(product.memberId).products.remove(product);
  }

  (Member, Product) getMemberAndProduct(String productId) {
    final member = members.firstWhere((m) => m.products.any((p) => p.id == productId));
    final product = member.products.firstWhere((p) => p.id == productId,);
    return (member, product);
  }

  List<String> get memberNames =>
      members.map((member) => member.name).toList();

  List<String> get memberFirstNames =>
      members.map((member) => member.firstName).toList();

  List<String> get memberLastNames =>
      members.map((member) => member.lastName).toList();

  // Analytics
  int get membersTraining => members.where((member) => member.training).length;
  int get membersExpiring => members.where((member) => member.expiring).length;
  int get membersFinished => members.where((member) => member.finished).length;
}
