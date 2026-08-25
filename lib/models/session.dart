import 'package:egpt/models/meeting.dart';


class Session extends Meeting {

  final bool presence;

  Session({
    required super.id,
    required super.member,
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
    member: data['member'],
    product: data['product'],
    start: data['start'],
    stop: data['stop'],
    presence: data['presence'],
  );

  factory Session.build({required Meeting meeting, required bool presence}) => Session(
    id: meeting.id,
    member: meeting.member,
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
