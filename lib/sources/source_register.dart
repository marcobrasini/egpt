import 'package:flutter/foundation.dart';
import 'package:egpt/services/services.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class MemberSource implements EGPTData<Member> {
  final Map<String, Member> _data = {};

  List<Member> get data => _data.values.toList();

  @override
  Map<String, Member> get() => _data;

  @override
  void set(Iterable<Member> data) => _data
    ..clear()
    ..addAll({for (Member item in data) item.id!: item});

  @override
  void add(Iterable<Member> data) {
    for (Member item in data) {
      _data.putIfAbsent(item.id!, () => item);
    }
  }

  @override
  void put(Iterable<Member> data) {
    for (Member item in data) {
      _data.update(item.id!, (_) => item);
    }
  }

  @override
  void del(Iterable<Member> data) {
    for (Member item in data) {
      _data.remove(item.id!);
    }
  }

  Member? operator [](String id) => _data[id];
}


class ProductSource implements EGPTData<Product> {
  final Map<String, Map<String, Product>> _data = {};

  List<Product> get data => _data.values.expand((v) => v.values).toList();

  @override
  Map<String, Product> get() =>
      Map.fromEntries(_data.values.expand((v) => v.entries));

  @override
  void set(Iterable<Product> items) {
    _data.clear();
    add(items);
  }

  @override
  void add(Iterable<Product> items) {
    for (final product in items) {
      _data.update(
        product.memberId,
        (p) => {...p, product.id!: product},
        ifAbsent: () => {product.id!: product},
      );
    }
  }

  @override
  void put(Iterable<Product> items) {
    for (final product in items) {
      _data.update(
        product.memberId,
        (p) => {...p, product.id!: product},
      );
    }
  }

  @override
  void del(Iterable<Product> items) {
    for (final product in items) {
      _data[product.memberId]?.remove(product.id!);
    }
  }

  List<Product>? operator [](String id) => _data[id]?.values.toList();
}


class RegisterSource extends ChangeNotifier {
  RegisterSource._singleton(this.memberSource, this.productSource);
  static final _instance = RegisterSource._singleton(
    MemberSource(),
    ProductSource(),
  );
  factory RegisterSource() => _instance;

  final MemberSource memberSource;
  List<Member> get members => memberSource.data;
  Member member(String memberId) {
    final member = memberSource[memberId];
    return member ?? (throw MissingMemberException(memberId));
  }

  final ProductSource productSource;
  List<Product> products(String memberId) => productSource[memberId] ?? [];
  Product product(String productId, [String? memberId]) {
    final product = (memberId == null)
        ? productSource.data.where((p) => p.id == productId).singleOrNull
        : productSource._data[memberId]?[productId];
    return product ?? (throw MissingProductException(productId));
  }

  void buildMembers(List<Member> members) => memberSource.set(members);
  void buildProducts(List<Product> products) => productSource.set(products);
  Future<void> build(DatabaseService database) async {
    buildMembers(await database.listMembers());
    buildProducts(await database.listProducts());
    notifyListeners();
  }

  List<String> get memberNames => members.map((m) => m.name).toList();

  // Member ───────────────────────────────────────────────────────────────────
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
    productSource._data.remove(member.id);
    memberSource.del([member]);
    notifyListeners();
    return member;
  }

  // Product ──────────────────────────────────────────────────────────────────
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

  // Presence ─────────────────────────────────────────────────────────────────
  Session insertSession(Session session) {
    notifyListeners();
    return session;
  }

  Session modifySession(Session session) {
    notifyListeners();
    return session;
  }

  Session removeSession(Session session) {
    notifyListeners();
    return session;
  }
}
