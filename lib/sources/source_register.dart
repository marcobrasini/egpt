import 'package:egpt/services/api/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/typedef.dart';


class EGPTSource<T extends EGPTItem> implements EGPTData<T> {
  final Map<String, T> _data = {};

  List<T> get data => _data.values.toList();

  @override
  Map<String, T> get() => _data;

  @override
  void set(Iterable<T> data) => _data
    ..clear()
    ..addAll({for (T item in data) item.id!: item});

  @override
  void add(Iterable<T> data) {
    for (T item in data) {
      _data.putIfAbsent(item.id!, () => item);
    }
  }

  @override
  void put(Iterable<T> data) {
    for (T item in data) {
      _data.update(item.id!, (_) => item);
    }
  }

  @override
  void del(Iterable<T> data) {
    for (T item in data) {
      _data.remove(item.id!);
    }
  }

  T? operator [](String id) => _data[id];
}


class MemberSource extends EGPTSource<Member> {}


class ProductSource extends EGPTSource<Product> {

  @override
  void set(Iterable<Product> data) {
    for (final product in data) {
      product.member.products.add(product);
    }
    super.set(data);
  }

  @override
  void add(Iterable<Product> data) {
    for (final product in data) {
      product.member.products.add(product);
    }
    super.add(data);
  }

  @override
  void del(Iterable<Product> data) {
    for (final product in data) {
      product.member.products.remove(product);
    }
    super.del(data);
  }
}


class RegisterSource extends ChangeNotifier {
  static final _instance = RegisterSource._singleton();
  RegisterSource._singleton();
  factory RegisterSource() => _instance;

  final MemberSource memberSource = MemberSource();
  List<Member> get members => memberSource.data;
  List<String> get memberNames => members.map((m) => m.name).toList();

  final ProductSource productSource = ProductSource();
  List<Product> get products => productSource.data;

  Future<void> build(DatabaseService db) async {
    memberSource.set(await db.listMembers());
    productSource.set(await db.listProducts());
  }

  void buildMembers(List<Member> members) => memberSource.set(members);
  void buildProducts(List<Product> products) => productSource.set(products);

  Member member(String id) =>
      memberSource[id] ?? (throw MissingMemberException(id));

  Member insertMember(Member member) {
    memberSource.add([member]);
    notifyListeners();
    return member;
  }

  Member modifyMember(Member member) {
    memberSource.put([member]);
    notifyListeners();
    return member;
  }

  Member removeMember(Member member) {
    productSource.del(products.where((p) => p.member.id == member.id));
    memberSource.del([member]);
    notifyListeners();
    return member;
  }

  Product product(String id) =>
      productSource[id] ?? (throw MissingProductException(id));

  Product insertProduct(Product product) {
    productSource.add([product]);
    notifyListeners();
    return product;
  }

  Product modifyProduct(Product product) {
    productSource.put([product]);
    notifyListeners();
    return product;
  }

  Product removeProduct(Product product) {
    productSource.del([product]);
    notifyListeners();
    return product;
  }
}
