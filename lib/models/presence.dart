import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class Presence extends Meeting implements EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();

  final bool presence;

  Presence({
    required super.id,
    required super.productId,
    required super.start,
    required super.stop,
    required this.presence,
  }) : super(
    pattern: null,
    parentId: null,
  );

  factory Presence.make({
    String? id,
    required DataMap data,
  }) => Presence(
    id: id,
    productId: data['productId'],
    presence: data['presence'],
    start: data['start'],
    stop: data['stop'],
  );

  factory Presence.from({
    required Meeting meeting,
    required bool presence,
  }) => Presence(
    id: meeting.id,
    productId: meeting.productId,
    start: meeting.start,
    stop: meeting.stop,
    presence: presence,
  );

  @override
  DataMap get() => {
    ...super.get(),
    "presence": presence,
  };

  @override
  Presence set(DataMap data) => Presence(
    id: id,
    productId: productId,
    presence: data['presence'] ?? presence,
    start: data['start'] ?? start,
    stop: data['stop'] ?? stop,
  );

  @override
  Presence copy() => Presence.make(id: id, data: get());

  @override
  List<Object?> get props => [super.props, presence];
}
