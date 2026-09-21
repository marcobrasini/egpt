import 'package:equatable/equatable.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class Session extends Equatable implements EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();

  @override final String? id;
  final String memberId;
  final String productId;
  final Presence? presence;

  Member get member => register.member(memberId);
  Product get product => register.product(productId, memberId);
  String? get presenceId => presence?.id;

  Session({
    this.id,
    required this.productId,
    Presence? presence,
  }) : memberId = register.product(productId).memberId,
        presence = (presence != null)
            ? Presence.make(id: id, data: presence.get())
            : null;

  factory Session.make({
    String? id,
    required DataMap data,
  }) => Session(
    id: id,
    productId: data['productId'],
    presence: data['presence'],
  );

  factory Session.build({
    required String id,
    required String productId,
  }) => Session(
    id: id,
    productId: productId,
    presence: schedule.presenceOrNull(id),
  );

  @override
  DataMap get() => {
    'id': id,
    'productId': productId,
    'presence': ?presence,
  };

  @override
  Session set(DataMap data) => Session(
    id: id,
    productId: productId,
    presence: data['presence'] ?? presence,
  );

  @override
  List<Object?> get props => [id, memberId, productId, presence?.props];
}