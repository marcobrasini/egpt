import 'package:calendar/calendar.dart';
import '../sources/source_register.dart';
import '../typedef.dart';
import 'fixture.dart';
import 'product.dart';
import 'member.dart';


typedef MeetingType = EventType;


class Meeting extends Event implements EGPTItem {
  static final register = RegisterSource();

  final Product product;

  Member get member => product.member;
  Date get date => start.date;
  Time get from => start.time;
  Time get to => stop.time;
  String? get patternRule => pattern?.toICSString();
  bool get isRepeating => id != null && pattern != null;

  DateTime? get patternUntil => pattern?.until;
  void patternConclude(DateTime until) => pattern?.until = until;

  Set<DateTime>? get exceptionsList => pattern?.exceptions;
  void exceptionInsert(DateTime datetime) => pattern?.exceptions.add(datetime);
  void exceptionRemove(DateTime datetime) =>
      pattern?.exceptions.remove(datetime);
  void exceptionShift(Duration duration) {
    final shifted = pattern!.exceptions.map((e) => e.add(duration)).toSet();
    pattern!.exceptions = shifted;
  }

  Meeting({
    super.id,
    required this.product,
    required super.start,
    required DateTime super.stop,
    super.pattern,
    super.parentId,
  }) : super(
    subject: product.member.name,
    color: product.member.color,
  );

  factory Meeting.make({
    String? id,
    required Map<String, dynamic> data,
  }) => Meeting(
    id: id,
    product: data['product'],
    start: data['start'],
    stop: data['stop'],
    pattern: data['pattern'],
    parentId: data['parentId'],
  );

  factory Meeting.build({
    required String id,
    required String productId,
    required DateTime start,
    required DateTime stop,
    String? parentId,
    String? patternRule,
  }) => Meeting(
    id: id,
    product: register.product(productId),
    start: start,
    stop: stop,
    parentId: parentId,
    pattern: (patternRule != null)
        ? Pattern.fromICSString(patternRule)
        : null,
  );

  Meeting copy() => Meeting.make(id: id, data: get());

  @override
  Map<String, dynamic> get() => {
    ...super.get(),
    "product": product,
  };

  @override
  Meeting set(Map<String, dynamic> data) {
    super.set(data);
    return this;
  }

  Meeting shift(Duration difference, Duration? duration) {
    if (pattern != null) exceptionShift(difference);
    final shifted = start.add(difference);
    return set({
        "start": shifted,
        "stop": shifted.add(duration ?? this.duration),
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
        && meeting.product == product;
  }

  bool? hasDeviation(Meeting meeting, [Fixture? fixture]) {
    if (!isRepeating && patternUntil == null) return null;
    final days = patternUntil!.date % start.date;
    final until = start.date + (days ~/ 7).ceil() * 7;
    return ((fixture?.date ?? meeting.date) % until) == 0
        && (fixture?.from ?? meeting.from) == from
        && (fixture?.to ?? meeting.to) == to
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