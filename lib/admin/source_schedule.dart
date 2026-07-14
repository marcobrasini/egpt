import 'package:flutter/material.dart';
//downloaded
import 'z
// models
import 'package:egpt/models/meeting.dart';
// extra
import 'package:egpt/utils/datetime.dart';


class ScheduleSource extends CalendarDataSource<Meeting> {
  static final instance = ScheduleSource._singleton();
  ScheduleSource._singleton() {
    appointments = [];
  }
  factory ScheduleSource() {
    return instance;
  }

  void build() {}

  List<Meeting> get meetings => appointments!.cast<Meeting>();

  @override
  String? getId(int index) => appointments![index].id;

  @override
  Color getColor(int index) => appointments![index].member.color;

  @override
  String getSubject(int index) => appointments![index].member.name;

  @override
  DateTime getStartTime(int index) => appointments![index].start;

  @override
  DateTime getEndTime(int index) => appointments![index].stop;

  @override
  String? getRecurrenceId(int index) => appointments![index].recurrenceId;

  @override
  String? getRecurrenceRule(int index) => appointments![index].recurrenceRule;

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index)
  => (appointments![index].exceptionsList.isNotEmpty)
      ? List<DateTime>.from(appointments![index].exceptionsList)
      : null;

  @override
  Meeting convertAppointmentToObject(
      Meeting meeting,
      Appointment appointment
  ) => meeting.set({
     if(!meeting.isRecurrence) "date": appointment.startTime.date,
     "from": appointment.startTime.time,
     "to": appointment.endTime.time,
   });
      // (meeting.isRecurrence)
      //     ? Meeting.instance(
      //     meeting,
      //     Fixture.make(data: {
      //       "date": appointment.startTime.date,
      //       "from": appointment.startTime.time,
      //       "to": appointment.endTime.time,
      //     })
      // )
      //     : meeting.set({
      //   "date": appointment.startTime.date,
      //   "from": appointment.startTime.time,
      //   "to": appointment.endTime.time,
      // });

  Future<Meeting> insertMeeting(Meeting meeting) async {
    meetings.add(meeting);
    notifyListeners(CalendarDataSourceAction.add, [meeting]);
    return meeting;
  }

  Future<Meeting> modifyMeeting(Meeting meeting) async {
    notifyListeners(CalendarDataSourceAction.reset, meetings);
    return meeting;
  }

  Future<Meeting> removeMeeting(Meeting meeting) async {
    meetings.remove(meeting);
    notifyListeners(CalendarDataSourceAction.remove, [meeting]);
    return meeting;
  }

  Future<List<Meeting>> insertMeetings(List<Meeting> meetingList) async {
    meetings.addAll(meetingList);
    notifyListeners(CalendarDataSourceAction.add, meetingList);
    return meetingList;
  }

  Future<List<Meeting>> modifyMeetings(List<Meeting> meetingList) async {
    notifyListeners(CalendarDataSourceAction.reset, meetings);
    return meetingList;
  }

  Future<List<Meeting>> removeMeetings(List<Meeting> meetingList) async {
    meetingList.forEach(meetings.remove);
    notifyListeners(CalendarDataSourceAction.remove, meetingList);
    return meetingList;
  }

  Meeting meeting(String meetingId) => meetings.singleWhere((m) => m.id == meetingId);
}
