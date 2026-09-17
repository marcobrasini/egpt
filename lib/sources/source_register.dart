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
  void set(List<T> data) => _data
    ..clear()
    ..addAll({for (T item in data) item.id!: item});

  @override
  void add(List<T> data) {
    for (T item in data) {
      _data.putIfAbsent(item.id!, () => item);
    }
  }

  @override
  void put(List<T> data) {
    for (T item in data) {
      _data[item.id!]?.set(item.get());
    }
  }

  @override
  void del(List<T> data) {
    for (T item in data) {
      _data.remove(item.id!);
    }
  }

  T? operator [](String id) => _data[id];
}

class MemberSource extends EGPTSource<Member> {}

class ProductSource extends EGPTSource<Product> {
  @override
  void add(List<Product> data) {
    for (var item in data) {
      item.member.products.add(item);
    }
    super.add(data);
  }

  @override
  void del(List<Product> data) {
    for (var item in data) {
      item.member.products.remove(item);
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

  void buildMembers(List<Member> members) => memberSource.set(members);
  void buildProducts(List<Product> products) {
    for (var product in products) {
      product.member.products.add(product);
    }
    productSource.set(products);
  }

  Member member(String id) =>
      memberSource[id] ?? (throw "No member with id: $id");

  Product product(String id) =>
      productSource[id] ?? (throw "No product with id: $id");

  void notifyMembers() => notifyListeners();
}
