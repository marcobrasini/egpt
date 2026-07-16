import 'package:calendar/calendar.dart';


extension MeetingFixture on Fixture {

  Date get date => start.date;
  Time get from => start.time;
  Time get to => stop.time;

}
