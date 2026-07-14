import 'package:egpt/admin/source_register.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/fixture.dart';
import 'package:egpt/models/register.dart';
import 'package:egpt/services/supabase_service.dart';
import 'package:egpt/utils/datetime.dart';


enum MeetingType {
  occurrence,
  recurrence,
  deviation,
  exception,
}


class Meeting extends Fixture {
  static final register = RegisterSource();

  final String? id;
  final Product product;
  final Member member;
  String? recurrenceId;
  String? recurrenceRule;
  final Set<Date> exceptionsList;

  Meeting({
    this.id,
    required this.member,
    required this.product,
    required super.date,
    required super.from,
    required super.to,
    this.recurrenceId,
    this.recurrenceRule,
    this.exceptionsList = const {},
  });

  Meeting copy()
  => Meeting(
      member: member,
      product: product,
      date: date,
      from: from,
      to: to,
      recurrenceId: recurrenceId,
      recurrenceRule: recurrenceRule,
      exceptionsList: exceptionsList,
  );

  factory Meeting.make({
      String? id,
      required Map<String, dynamic> data,
  })
  => Meeting(
      id: id,
      product: data['product'],
      member: data['member'],
      date: data['date'],
      from: data['from'],
      to: data['to'],
      recurrenceId: data['recurrenceId'],
      recurrenceRule: data['recurrenceRule'],
      exceptionsList: data['exceptionsList'] ?? {},
  );

  factory Meeting.build({
    required String id,
    required String memberId,
    required String productId,
    required DateTime start,
    required DateTime stop,
    String? recurrenceId,
    String? recurrenceRule,
    Set<Date>? exceptionsList,
  })
  {
    final member = register.member(memberId);
    final product = member.products.singleWhere((p) => p.id == productId);
    return Meeting(
      id: id,
      member: member,
      product: product,
      date: start.date,
      from: start.time,
      to: stop.time,
      recurrenceId: recurrenceId,
      recurrenceRule: recurrenceRule,
      exceptionsList: exceptionsList ?? {},
    );
  }

  factory Meeting.instance(
      Meeting recurrence,
      Fixture fixture
      )
  => Meeting.make(
      data: {
        "product": recurrence.product,
        "member": recurrence.member,
        "date": fixture.date,
        "from": fixture.from,
        "to": fixture.to,
        "recurrenceId": recurrence.id,
        "recurrenceRule": recurrence.recurrenceRule,
      }
  );

  Map<String, dynamic> get() => {
    ...{
      "id": id,
      "product": product,
      "member": member,
    },
    ...super.get(),
    ...{
      "recurrenceId": recurrenceId,
      "recurrenceRule": recurrenceRule,
      "exceptionsList": exceptionsList,
    },
  };

  Meeting set(Map<String, dynamic> data) {
    super.set(data);
    recurrenceId = data["recurrenceId"] ?? recurrenceId;
    recurrenceRule = data["recurrenceRule"] ?? recurrenceRule;
    if (data["exceptions"] != null) {
      exceptionsList.clear();
      exceptionsList.addAll(data["exceptions"]);
    }
    return this;
  }

  Meeting setRecurrence(Map<String, dynamic> data) {
    date += data["date"].weekday - date.weekday;
    from = data["from"];
    to = data["to"];
    recurrenceRule = data["recurrenceRule"] ?? recurrenceRule;
    if (data["exceptions"] != null) {
      exceptionsList.clear();
      exceptionsList.addAll(data["exceptions"]);
    }
    return this;
  }

  int get duration => to % from.toDateTime();

  Date? get recurrenceUntil => (recurrenceRule != null)
      ? Date.fromISOString(
          RegExp(r'UNTIL=(\d{8}T\d{6}Z?)').stringMatch(
              recurrenceRule!
          )!.substring(6)
      ) : null;

  set recurrenceUntil(DateTime datetime) {
    exceptionsList.removeWhere((d) => d > datetime);
    recurrenceRule = recurrenceRule!.replaceAllMapped(
      RegExp(r'UNTIL=\d{8}T\d{6}Z'),
      (match) => 'UNTIL=${datetime.toISOFormat()}',
    );
  }

  void exceptionInsert(Date date) {
    exceptionsList.add(date);
  }

  void exceptionRemove(Date date) {
    exceptionsList.remove(date);
  }

  bool get isSignificant {
    if (isRecurrence) {
      Date instanceDate = date.copy();
      while (recurrenceUntil! > instanceDate) {
        if (!exceptionsList.contains(instanceDate)) return true;
        instanceDate += 7;
      }
      return false;
    }
    return true;
  }
  bool get isOccurrence => recurrenceRule==null || (recurrenceRule?.isEmpty ?? false);
  bool get isRecurrence => recurrenceRule!=null && recurrenceRule!.isNotEmpty;
  bool get isException => recurrenceId!=null && recurrenceRule==null;
  bool get isDeviation => recurrenceId!=null && isRecurrence;
  bool get isInstance => id == null && recurrenceRule!=null;

  bool? hasInstance(Meeting meeting) {
    if (!isRecurrence || (meeting.recurrenceId != id)) return null;
    return (
        (meeting.date % date) % 7 == 0
        && meeting.from == from
        && meeting.to == to
    );
  }

  bool? hasDeviation(Meeting meeting) {
    if (!isRecurrence || (meeting.recurrenceId != id)) return null;
    return (
        (meeting.date % date) % 7 == 0
            && meeting.from == from
            && meeting.to == to
    );
  }
}