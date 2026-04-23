class Date extends DateTime {
  Date(super.year, super.month, super.day);

  static Date now() {
    final now = DateTime.now();
    return Date(now.year, now.month, now.day);
  }

  DateTime toDateTime([Time? time]) =>
      DateTime(year, month, day, time?.hour ?? 0, time?.minute ?? 0);

  factory Date.fromDateTime(DateTime datetime) =>
      Date(datetime.year, datetime.month, datetime.day);

  Date copy() => Date(year, month, day);

  @override
  String toString() {
    String y = year.toString().padLeft(4, '0');
    String m = month.toString().padLeft(2, '0');
    String d = day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  factory Date.fromString(String dateString) {
    List<String> date = dateString.split("-");
    final int year = int.parse(date[0]);
    final int month = int.parse(date[1]);
    final int day = int.parse(date[2]);
    return Date(year, month, day);
  }

  factory Date.fromISOString(String dateString) => Date.fromDateTime(
      DateTime.parse(dateString)
  );


  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  bool operator <(DateTime dateTime) => isBefore(Date.fromDateTime(dateTime));

  bool operator >(DateTime dateTime) => isAfter(Date.fromDateTime(dateTime));

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Date operator +(int days) => Date.fromDateTime(add(Duration(days: days)));

  Date operator -(int days) =>
      Date.fromDateTime(subtract(Duration(days: days)));

  int operator %(DateTime dateTime) =>
      difference(Date.fromDateTime(dateTime)).inDays;
}

class Time {
  final int hour;
  final int minute;

  Time(this.hour, this.minute);

  static Time now() {
    final now = DateTime.now();
    return Time(now.hour, now.minute);
  }

  @override
  String toString() {
    final String h = hour.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  factory Time.fromString(String timeString) {
    List<String> time = timeString.split(":");
    final int hour = int.parse(time[0]);
    final int minute = int.parse(time[1]);
    return Time(hour, minute);
  }

  DateTime toDateTime([Date? date]) => DateTime(
    date?.year ?? 1, date?.month ?? 1, date?.day ?? 1,
    hour, minute
  );

  factory Time.fromDateTime(DateTime datetime) => Time(
      datetime.hour, datetime.minute
  );

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is DateTime) return hour == other.hour && minute == other.minute;
    if (other is Time) return hour == other.hour && minute == other.minute;
    return false;
  }

  bool operator <(Object other) {
    final time = (other is DateTime) ? Time.fromDateTime(other) : other;
    if (time is Time) {
      return (hour == time.hour) ? (minute < time.minute) : hour < time.hour;
    }
    return false;
  }

  bool operator >(Object other) {
    final time = (other is DateTime) ? Time.fromDateTime(other) : other;
    if (time is Time) {
      return (hour == time.hour) ? (minute > time.minute) : hour > time.hour;
    }
    return false;
  }

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Time operator +(int minutes) =>
      toDateTime().add(Duration(minutes: minutes)).time;

  Time operator -(int minutes) =>
      toDateTime().subtract(Duration(minutes: minutes)).time;

  int operator %(DateTime dateTime) =>
      toDateTime().difference(dateTime).inMinutes;

  Time round(int step) {
    final totalMinutes = hour * 60 + minute;
    final roundMinutes = ((totalMinutes + step ~/ 2) ~/ step) * step;
    final finalMinutes = roundMinutes % (24 * 60);
    return Time(finalMinutes ~/ 60, finalMinutes % 60);
  }
}

extension DateAndTime on DateTime {
  Date get date => Date(year, month, day);
  Time get time => Time(hour, minute);

  String toISOFormat() => ''
      '${year.toString().padLeft(4, '0')}'
      '${month.toString().padLeft(2, '0')}'
      '${day.toString().padLeft(2, '0')}T'
      '${hour.toString().padLeft(2, '0')}'
      '${minute.toString().padLeft(2, '0')}'
      '${second.toString().padLeft(2, '0')}Z';
}
