import 'package:egpt/utils/timezone.dart';
import 'package:meta/meta.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


typedef MeetingType = EventType;


class Meeting extends Event implements EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();

  final String memberId;
  final String productId;

  Meeting({
    super.id,
    required this.productId,
    required super.start,
    required super.stop,
    super.pattern,
    super.parentId,
  }) : memberId = register.product(productId).member.id!, super(
    subject: register.product(productId).member.name,
    color: register.product(productId).member.color,
  );

  factory Meeting.make({
    String? id,
    required DataMap data,
  }) => Meeting(
    id: id,
    productId: data['productId'],
    parentId: data['parentId'],
    pattern: data['pattern'],
    start: data['start'],
    stop: data['stop'],
  );

  @override
  DataMap get() => {
    ...super.get(),
    'productId': productId,
  };

  @override
  Meeting set(DataMap data) => Meeting(
    id: id,
    productId: productId,
    parentId: data['parentId'] ?? parentId,
    pattern: data['pattern'] ?? pattern,
    start: data['start'] ?? start,
    stop: data['stop'] ?? stop,
  );

  @override
  Meeting copy() => Meeting.make(id: id, data: get());

  Member get member => register.member(memberId);
  Product get product => register.product(productId, memberId);

  Date get date => start.date;
  Time get from => start.time;
  Time get to => stop.time;

  String? get patternRule => pattern?.toICSString();
  bool get isRepeating => id != null && pattern != null;

  DateTime? get patternUntil => pattern?.until;
  Set<DateTime>? get exceptionsList => pattern?.exceptions;

  @useResult
  Meeting setPatternUntil(DateTime until) =>
      set({'pattern': pattern?.setUntil(until.tzToUtc())});

  @useResult
  Meeting addPatternException(DateTime datetime) =>
      set({'pattern': pattern?.addException(datetime.tzToUtc())});

  @useResult
  Meeting delPatternException(DateTime datetime) =>
      set({'pattern': pattern?.delException(datetime.tzToUtc())});

  @useResult
  Meeting shift(Duration variation, Duration? duration) => set({
    'start':    start.add(variation),
    'stop':     start.add(variation).add(duration ?? this.duration),
    'pattern':  pattern?.shift(variation),
  });

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
  List<Meeting> expand(DateTime? from, DateTime? to) =>
      super.expand(from ?? product.start, to ?? product.stop).cast<Meeting>();

  @override
  Meeting instance(Fixture fixture) => Meeting.make(data: {
    ...get(), ...fixture.get(),
    "pattern": pattern,
    "parentId": id,
  });

  @override
  Meeting exception(Fixture fixture) => Meeting.make(data: {
    ...get(), ...fixture.get(),
    "pattern": null,
    "parentId": id ?? parentId,
  });

  @override
  Meeting deviation(Fixture fixture) => Meeting.make(data: {
    ...get(), ...fixture.get(),
    "pattern": pattern,
    "parentId": id ?? parentId,
  });

  @override
  List<Object?> get props => [super.props, productId, memberId];
}