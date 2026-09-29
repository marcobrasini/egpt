import 'dart:async';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';


class UserSource extends ServiceSource {
  UserSource({required super.services});

  late final personal = PersonalSource(this);

  // Avvio ─────────────────────────────────────────────────────────────────
  // static const _streams = {'members', 'products', 'meetings', 'presences'};
  // final Set<String> _received = {};
  // final List<StreamSubscription> _subscriptions = [];

  bool _building = false;
  bool get loading => _building;// || !_received.containsAll(_streams);

  Object? _error;
  Object? get error => _error;

  @override
  Future<void> build() async {
    _building = true;
    _error = null;
    notifyListeners();
    try {
      // watch();
    } catch (e) {
      _error = e;
    } finally {
      _building = false;
      notifyListeners();
    }
  }

  // void watch() {
  //   if (_subscriptions.isNotEmpty || _building) return;
  //   _listen<Member>('members', database.watchMembers(register));
  //   _listen<Product>('products', database.watchProducts(register));
  //   _listen<Meeting>('meetings', database.watchMeetings(schedule));
  //   _listen<Presence>('presences', database.watchPresences(schedule));
  // }
  //
  // void _listen<T extends EGPTItem>(
  //   String name,
  //   Stream<DatabaseData<T>> stream,
  // ) {
  //   _subscriptions.add(
  //     stream.listen(
  //       (data) {
  //         _received.add(name);
  //         _error = null;
  //         _notify();
  //       },
  //       onError: (Object e) {
  //         _error = e;
  //         _received.add(name);
  //         _notify();
  //       },
  //     ),
  //   );
  // }
  //
  // // Più stream per la stessa transazione → una sola rebuild
  // Timer? _pending;
  // void _notify() {
  //   _pending ??= Timer(Duration.zero, () {
  //     _pending = null;
  //     notifyListeners();
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   _pending?.cancel();
  //   for (final sub in _subscriptions) {
  //     sub.cancel();
  //   }
  //   super.dispose();
  // }

  @override
  Future<Member> insertMember(Member member) {
    // TODO: implement insertMember
    throw UnimplementedError();
  }

  @override
  Future<Member> modifyMember(Member member) {
    // TODO: implement modifyMember
    throw UnimplementedError();
  }

  @override
  Future<Member> removeMember(Member member) {
    // TODO: implement removeMember
    throw UnimplementedError();
  }

  @override
  Future<Product> insertProduct(Product product) {
    // TODO: implement insertProduct
    throw UnimplementedError();
  }

  @override
  Future<Product> modifyProduct(Product product) {
    // TODO: implement modifyProduct
    throw UnimplementedError();
  }

  @override
  Future<Product> removeProduct(Product product) {
    // TODO: implement removeProduct
    throw UnimplementedError();
  }

  @override
  Future<Session?> insertSession(Session session) {
    // TODO: implement insertSession
    throw UnimplementedError();
  }

  @override
  Future<Session?> modifySession(Session session) {
    // TODO: implement modifySession
    throw UnimplementedError();
  }

  @override
  Future<Session?> removeSession(Session session) {
    // TODO: implement removeSession
    throw UnimplementedError();
  }
}
