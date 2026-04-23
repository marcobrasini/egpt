import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:egpt/utils/datetime.dart';

void main() {
  final today = Date.now();
  final clock = Time.now();
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final day = now.day;
  final hour = now.hour;
  final minute = now.minute;

  group('Date', () {
    test('Date now', () {
      expect(today, isA<Date>());
      expect(today.year, now.year);
      expect(today.month, now.month);
      expect(today.day, now.day);
    });

    test('Date constructor', () {
      final date = Date(year, month, day);
      expect(date, isA<DateTime>());
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date fromDateTime constructor', () {
      final date = Date.fromDateTime(now);
      expect(date, isA<Date>());
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('Date toDateTime constructor', () {
      final datetime = today.toDateTime();
      expect(datetime, isA<DateTime>());
      expect(datetime.year, today.year);
      expect(datetime.month, today.month);
      expect(datetime.day, today.day);
    });

    test('Date toString', () {
      final date = Date(year, month, day);
      final string = DateFormat("yyyy-MM-dd").format(now);
      expect(date.toString(), string.split(' ')[0]);
    });

    test('Date fromString', () {
      final string = now.toString();
      final date = Date.fromString(string.split(' ')[0]);
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date operator ==', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today == now, true);
      expect(today == tomorrow, false);
      expect(today == yesterday, false);
    });

    test('Date operator <', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today < now, false);
      expect(today < tomorrow, true);
      expect(today < yesterday, false);
    });

    test('Date operator <=', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today <= today, true);
      expect(today <= tomorrow, true);
      expect(today < yesterday, false);
    });

    test('Date operator >', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today > now, false);
      expect(today > tomorrow, false);
      expect(today > yesterday, true);
    });

    test('Date operator >=', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today >= now, true);
      expect(today >= tomorrow, false);
      expect(today >= yesterday, true);
    });

    test('Date operator +', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today + 1 == tomorrow, true);
      expect(today + -1 == yesterday, true);
    });

    test('Date operator -', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today - 1 == yesterday, true);
      expect(today - -1 == tomorrow, true);
    });

    test('Date operator %', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today % tomorrow == -1, true);
      expect(today % yesterday == 1, true);
    });
  });

  group('Time', () {
    test('Time now', () {
      expect(clock, isA<Time>());
      expect(clock.hour, hour);
      expect(clock.minute, minute);
    });

    test('Time constructor', () {
      final time = Time(hour, minute);
      expect(time, isA<Time>());
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time fromDateTime', () {
      final time = Time.fromDateTime(now);
      expect(time, isA<Time>());
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time toDateTime', () {
      final datetime = clock.toDateTime();
      expect(datetime, isA<DateTime>());
      expect(datetime.year, 1);
      expect(datetime.month, 1);
      expect(datetime.day, 1);
      expect(datetime.hour, hour);
      expect(datetime.minute, minute);
    });

    test('Time toString', () {
      final time = Time(hour, minute);
      final string = DateFormat("HH:mm").format(now);
      expect(time.toString(), string);
    });

    test('Time fromString', () {
      final string = now.toString();
      final time = Time.fromString(string.split(' ')[1].split('.')[0]);
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time operator ==', () {
      final after = now.add(Duration(minutes: 1));
      final before = now.add(Duration(minutes: -1));
      expect(clock == now, true);
      expect(clock == after, false);
      expect(clock == before, false);
    });

    test('Time operator <', () {
      expect(clock < now, false);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock < afterMinute, true);
      expect(clock < beforeMinute, false);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock < afterHour, true);
      expect(clock < beforeHour, false);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock < after, true);
      expect(clock < before, false);
    });

    test('Time operator >', () {
      expect(clock > now, false);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock > afterMinute, false);
      expect(clock > beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock > afterHour, false);
      expect(clock > beforeHour, true);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock > after, false);
      expect(clock > before, true);
    });

    test('Time operator <=', () {
      expect(clock <= now, true);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock <= afterMinute, true);
      expect(clock <= beforeMinute, false);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock <= afterHour, true);
      expect(clock <= beforeHour, false);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock <= after, true);
      expect(clock <= before, false);
    });

    test('Time operator >=', () {
      expect(clock >= now, true);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock >= afterMinute, false);
      expect(clock >= beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock >= afterHour, false);
      expect(clock >= beforeHour, true);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock >= after, false);
      expect(clock >= before, true);
    });
  });
}
