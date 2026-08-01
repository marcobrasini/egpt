import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';


class Session extends Meeting {

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

  factory Session.build({required Meeting meeting}) => Session(
    id: meeting.id,
    member: meeting.member,
    product: meeting.product,
    start: meeting.start,
    stop: meeting.stop,
    presence: null,
  );

  bool? presence;
}
