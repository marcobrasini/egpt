import '../sources/source_register.dart';
import 'meeting.dart';


class Session extends Meeting implements EGPTData {
  static final register = RegisterSource();

  final bool presence;

  Session({
    required super.id,
    required super.product,
    required super.start,
    required super.stop,
    required this.presence,
  }) : super(
    pattern: null,
    parentId: null,
  );

  factory Session.make({
    String? id,
    required Map<String, dynamic> data,
  }) => Session(
    id: id,
    product: data['product'],
    start: data['start'],
    stop: data['stop'],
    presence: data['presence'],
  );

  factory Session.build({
    String? id,
    required String productId,
    required DateTime start,
    required DateTime stop,
    required bool presence,
  }) => Session(
    id: id,
    product: register.product(productId),
    start: start,
    stop: stop,
    presence: presence,
  );

  factory Session.from({
    required Meeting meeting,
    required bool presence,
  }) => Session(
    id: meeting.id,
    product: meeting.product,
    start: meeting.start,
    stop: meeting.stop,
    presence: presence,
  );

  @override
  Map<String, dynamic> get() => {
    ...super.get(),
    "presence": presence,
  };
}
