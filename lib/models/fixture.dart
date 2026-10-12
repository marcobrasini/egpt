import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';


extension MeetingFixture on Fixture {

  Date get date => start.date;
  Time get from => start.time;
  Time get to => stop.time;

}
