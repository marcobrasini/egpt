import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;


late final tz.Location location;


void initTimeZones(String locationName) {
  tzdata.initializeTimeZones();
  location = tz.getLocation(locationName);
}


extension TZTime on DateTime {
  DateTime tzToUtc() =>
      tz.TZDateTime(location, year, month, day, hour, minute, second).toUtc();
}

DateTime utcToTz(DateTime utc) {
  final t = tz.TZDateTime.from(utc, location);
  return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
}
