import 'package:egpt/admin/source_register.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/fixture.dart';


typedef MeetingType = EventType;


class Meeting extends Event {
  static final register = RegisterSource();

  final Product product;
  final Member member;

  Date get date => start.date;
  Time get from => start.time;
  Time get to => stop.time;
  String? get patternRule => pattern?.toICSString();
  bool get isRepeating => id != null && pattern != null;

  DateTime? get patternUntil => pattern?.until;
  void patternConclude(DateTime until) => pattern?.until = until;

  Set<DateTime>? get exceptionsList => pattern?.exceptions;
  void exceptionInsert(DateTime datetime) => pattern?.exceptions.add(datetime);
  void exceptionRemove(DateTime datetime) => pattern?.exceptions.remove(datetime);
  void exceptionShift(Duration duration) {
    final shifted = pattern!.exceptions.map((e) => e.add(duration)).toSet();
    pattern!.exceptions = shifted;
  }

  Meeting({
    super.id,
    required this.member,
    required this.product,
    required super.start,
    required DateTime super.stop,
    super.pattern,
    super.parentId,
  }) : super(
    subject: member.name,
    color: member.color,
  );

  factory Meeting.make({
      String? id,
      required Map<String, dynamic> data,
  }) => Meeting(
      id: id,
      member: data['member'],
      product: data['product'],
      start: data['start'],
      stop: data['stop'],
      pattern: data['pattern'],
      parentId: data['parentId'],    
  );

  factory Meeting.build({
    required String id,
    required String memberId,
    required String productId,
    required DateTime start,
    required DateTime stop,
    String? parentId,
    String? patternRule,
  }) {
    final member = register.member(memberId);
    final product = member.products.singleWhere((p) => p.id == productId);
    final pattern = (patternRule != null)
        ? Pattern.fromICSString(patternRule)
        : null;
    return Meeting(
      id: id,
      member: member,
      product: product,
      start: start,
      stop: stop,
      pattern: pattern,
      parentId: parentId,
    );
  }

  Meeting copy() => Meeting.make(id: id, data: get());

  @override
  Map<String, dynamic> get() => {
    ...super.get(),
    "product": product,
    "member": member,
  };

  @override
  Meeting set(Map<String, dynamic> data) {
    super.set(data);
    return this;
  }

  Meeting shift(Duration duration) {
    if (pattern != null) exceptionShift(duration);
    return set({
        "start": start.add(duration),
        "stop": stop.add(duration),
    });
  }

  bool get isSignificant {
    if (isRepeating) {
      final iterator = pattern!.iterator(start);
      while (iterator.moveNext()) {
        return true;
      }
    }
    return false;
  }

  bool? hasInstance(Meeting meeting, [Fixture? fixture]) {
    if (!isRepeating) return null;
    return ((fixture?.date ?? meeting.date) % date) % 7 == 0
        && (fixture?.from ?? meeting.from) == from
        && (fixture?.to ?? meeting.to) == to
        && meeting.member == member
        && meeting.product == product;
  }

  bool? hasDeviation(Meeting meeting, [Fixture? fixture]) {
    if (!isRepeating && patternUntil == null) return null;
    final days = patternUntil!.date % start.date;
    final until = start.date + (days ~/ 7).ceil() * 7;
    return ((fixture?.date ?? meeting.date) % until) == 0
        && (fixture?.from ?? meeting.from) == from
        && (fixture?.to ?? meeting.to) == to
        && meeting.member == member
        && meeting.product == product;
  }

  @override
  Meeting instance([Map<String, dynamic>? data]) => Meeting.make(data: {
    ...get(),
    ...data ?? {},
    "parentId": id,
  });

  Meeting? exception(Meeting instance, Fixture fixture) {
    if (pattern == null) return null;
    final meeting = Meeting.make(data: {
        ...instance.get(),
        ...fixture.get(),
        "pattern": null,
      },
    );
    exceptionInsert(instance.start);
    return meeting;
  }

  Meeting? deviation(Meeting instance, Fixture fixture) {
    if (pattern == null) return null;
    final meeting = Meeting.make(data: {
      ...instance.get(),
      ...fixture.get(),
      "pattern": Pattern(type: pattern!.type, until: patternUntil),
    });
    patternConclude(instance.start);
    return meeting;
  }

}