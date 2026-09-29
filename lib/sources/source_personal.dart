import 'package:flutter/foundation.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';
import 'source_services.dart';


class SessionSource implements EGPTData<Session> {
  final Map<String, Map<String, Session>> _data = {};

  List<Session> get data => _data.values.expand((v) => v.values).toList();

  @override
  Map<String, Session> get() =>
      Map.fromEntries(_data.values.expand((v) => v.entries));

  @override
  void set(Iterable<Session> data) {
    _data.clear();
    add(data);
  }

  @override
  void add(Iterable<Session> items) {
    for (final session in items) {
      _data.update(
        session.productId,
        (s) => {...s, session.id!: session},
        ifAbsent: () => {session.id!: session},
      );
    }
  }

  @override
  void put(Iterable<Session> items) {
    for (final session in items) {
      _data.update(
        session.productId,
        (s) => {...s, session.id!: session},
      );
    }
  }

  @override
  void del(Iterable<Session> items) {
    for (final session in items) {
      _data[session.productId]?.remove(session.id!);
    }
  }

  List<Session>? operator [](String id) => _data[id]?.values.toList();
}


class PersonalSource extends ChangeNotifier {
  PersonalSource(this.source) {
    source.addListener(build);
  }

  final ServiceSource source;

  final sessionSource = SessionSource();
  String? _memberId;
  Member? _member;

  String get name => _member?.name ?? "";
  Member get member => _member ??= source.register.member(_memberId!);
  List<Product> get products => member.products;

  Product product(String productId) => member.product(productId);
  List<Session> sessions(String productId) => sessionSource[productId] ?? [];
  Session session(String sessionId, [String? productId]) {
    final session = (productId == null)
        ? sessionSource.data.where((s) => s.id == sessionId).singleOrNull
        : sessionSource._data[productId]?[sessionId];
    return session ?? (throw MissingProductException(productId));
  }
  void buildSessions(List<Session> sessions) => sessionSource.set(sessions);

  Member? get current => source.register.memberSource[_memberId!];
  bool get healthy => _memberId != null && current != null;

  bool _building = false;
  bool get loading => _building;

  Object? _error;
  Object? get error => _error;

  Future<void> build() async {
    _building = true;
    _error = null;
    notifyListeners();
    try {
      await source.database.buildPersonal(this);
    } catch (error) {
      _error = error;
      debugPrint(error.toString());
    } finally {
      _building = false;
      notifyListeners();
    }
  }

  void open(String id) {
    _memberId = id;
    _member = source.register.member(id);
  }
  void close() {
    _member = null;
    _memberId = null;
  }

  @override
  void dispose() {
    _building = false;
    source.removeListener(build);
    super.dispose();
  }

  // Member ───────────────────────────────────────────────────────────────────

  Future<Member> modifyMember(Member member) async {
    try {
      _member = await source.modifyMember(member);
    } on MissingMemberException catch (_) {
      await source.build();
    }
    notifyListeners();
    return member;
  }

  Future<Member> removeMember(Member member) async {
    try {
      await source.removeMember(member);
    } on MissingMemberException catch (_) {
      await source.build();
    }
    notifyListeners();
    return member;
  }

  // Product ──────────────────────────────────────────────────────────────────
  Future<Product> insertProduct(Product product) async {
    try {
      product = await source.insertProduct(product);
    } on MissingMemberException catch (_) {
      await source.build();
    }
    notifyListeners();
    return product;
  }

  Future<Product> modifyProduct(Product product) async {
    try {
      product = await source.modifyProduct(product);
    } on MissingProductException catch (_) {
      source.register.removeProduct(product);
    } on MissingMemberException catch (_) {
      await source.build();
    }
    notifyListeners();
    return product;
  }

  Future<Product> removeProduct(Product product) async {
    try {
      product = await source.removeProduct(product);
    } on MissingProductException catch (_) {
      source.register.removeProduct(product);
    } on MissingMemberException catch (_) {
      await source.build();
    }
    notifyListeners();
    return product;
  }

  // Session ──────────────────────────────────────────────────────────────────
  Future<Session> insertSession(Session session) async {
    try {
      sessionSource.add([session]);
    } on RegisterException catch (_) {
      await source.build();
    }
    notifyListeners();
    return session;
  }

  Future<Session> modifySession(Session session) async {
    try {
      sessionSource.put([session]);
    } on MissingSessionException catch (_) {
      sessionSource.del([session]);
    } on RegisterException catch (_) {
      await source.build();
    }
    notifyListeners();
    return session;
  }

  Future<Session> removeSession(Session session) async {
    try {
      await source.removeSession(session);
      sessionSource.del([session]);
    } on MissingSessionException catch (_) {
      sessionSource.del([session]);
    } on RegisterException catch (_) {
      await source.build();
    }
    notifyListeners();
    return session;
  }
}
