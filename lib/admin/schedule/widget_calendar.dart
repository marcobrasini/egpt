import 'package:flutter/material.dart';
//downloaded
import 'package:syncfusion_flutter_calendar/calendar.dart';
//widgets
import 'package:egpt/admin/schedule/meeting_widget.dart';
import 'package:egpt/admin/schedule/meetingType_widget.dart';
//sources
import 'package:egpt/admin/source_admin.dart';
//models
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/fixture.dart';
//utils
import 'package:egpt/utils/datetime.dart';


class CalendarWidget extends StatefulWidget {
  final bool enabled;
  const CalendarWidget({this.enabled = true, super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static final admin = AdminSource();
  Fixture? initFixture;

  Future<MeetingType?> confirm(
      BuildContext context,
      Meeting meeting,
      String action,
      ) async
  {
    final typeKey = GlobalKey<MeetingTypeWidgetState>();
    return await showDialog<MeetingType?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action appuntamento"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meeting.isInstance) Column(
                children: [
                  Text("Stai ${action.toLowerCase()}ndo un evento ricorrente."
                      "\nApplica le modifiche a:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: MeetingTypeWidget(
                      option: MeetingType.exception,
                      key: typeKey,
                    ),
                  ),
                ],
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    children: [
                      TextSpan(
                          text: "Vuoi ${action.toLowerCase()}re l'appuntamento\ncon "),
                      TextSpan(
                        text: meeting.member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  )
              ),
            ]
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text("Annulla"),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: Text(action),
            onPressed: () async {
              Navigator.of(context).pop(
                  typeKey.currentState!.meetingType!
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Meeting?> makeMeeting(
      BuildContext context,
      DateTime datetime
      ) async
  {
    final meetingWidgetKey = GlobalKey<MeetingWidgetState>();
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuovo meeting"),
          content: MeetingWidget(null, datetime: datetime, key: meetingWidgetKey),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text("Conferma"),
              onPressed: () async {
                // try {
                final data = meetingWidgetKey.currentState?.data;
                if (data != null) {
                  if (context.mounted) {
                    Navigator.of(context).pop(
                        await admin.insertMeeting(
                            Meeting.make(
                                data: data
                            )
                        )
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Salvataggio riuscito.')),
                    );
                  }
                }
                // } catch (e) {
                //   if (context.mounted) {
                //     Navigator.of(context).pop(null);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Salvataggio fallito: $e')),
                //     );
                //   }
                // }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Meeting?> editMeeting(
      BuildContext context,
      Meeting meeting,
      ) async
  {
    final meetingWidgetKey = GlobalKey<MeetingWidgetState>();
    return await showDialog<Meeting?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Meeting"),
            content: MeetingWidget(meeting, key: meetingWidgetKey),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                child: const Text("Cancella"),
                onPressed: () async {
                  final deleted = await delMeeting(context, meeting);
                  Navigator.of(context).pop(deleted);
                },
              ),
              TextButton(
                child: const Text("Modifica"),
                onPressed: () async {
                  final data = meetingWidgetKey.currentState!.data!;
                  final updated = await setMeeting(context, meeting.set(data));
                  Navigator.of(context).pop(updated);
                },
              ),
            ],
          );
        }
    );
  }

  Future<Meeting?> newMeeting(
      BuildContext context,
      DateTime datetime
      ) async
  {
    final meetingWidgetKey = GlobalKey<MeetingWidgetState>();
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuovo meeting"),
          content: MeetingWidget(null, datetime: datetime, key: meetingWidgetKey),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text("Conferma"),
              onPressed: () async {
                // try {
                  final data = meetingWidgetKey.currentState?.data;
                  if (data != null) {
                    if (context.mounted) {
                      Navigator.of(context).pop(
                          await admin.insertMeeting(
                              Meeting.make(
                                  data: data
                              )
                          )
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salvataggio riuscito.')),
                      );
                    }
                  }
                // } catch (e) {
                //   if (context.mounted) {
                //     Navigator.of(context).pop(null);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Salvataggio fallito: $e')),
                //     );
                //   }
                // }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Meeting?> delMeeting(
      BuildContext context,
      Meeting meeting,
  ) async
  {
    final option = (meeting.isInstance)
        ? await confirm(context, meeting, "Cancella")
        : MeetingType.occurrence;
    switch (option) {
      case null:
        return null;
      case MeetingType.occurrence:
        return await admin.removeMeeting(meeting);
      case MeetingType.recurrence:
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        return await admin.removeMeeting(recurrence);
      case MeetingType.exception:
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        recurrence.exceptionInsert(meeting.date);
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
      case MeetingType.deviation:
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        recurrence.recurrenceUntil = meeting.date;
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
    }
  }

  Future<Meeting?> setMeeting(
      BuildContext context,
      Meeting meeting
      ) async
  {
    final option = (meeting.isInstance)
        ? await confirm(context, meeting, "Modifica")
        : MeetingType.occurrence;
    switch (option) {
      case null:
        return null;
      case MeetingType.occurrence:
        if (meeting.isException) {
          final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
          if (recurrence.hasInstance(meeting) ?? false) {
            recurrence.exceptionRemove(meeting.date);
            await admin.modifyMeeting(recurrence);
            return await admin.removeMeeting(meeting);
          }
        }
        return await admin.modifyMeeting(meeting);
      case MeetingType.recurrence:
        if (meeting.isDeviation) {}
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        recurrence.setRecurrence(meeting.get());
        return await admin.modifyMeeting(recurrence);
      case MeetingType.exception:
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        final difference = meeting.date.weekday - recurrence.date.weekday;
        recurrence.exceptionInsert(meeting.date - difference);
        meeting.recurrenceRule = null;
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(meeting);
      case MeetingType.deviation:
        final recurrence = admin.schedule.meeting(meeting.recurrenceId!);
        recurrence.recurrenceUntil = meeting.date - (meeting.date.weekday-1);
        meeting.recurrenceId = null;
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(meeting);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.week,
      dataSource: admin.schedule,
      allowedViews: [
        CalendarView.month,
        CalendarView.week,
        CalendarView.day,
      ],
      firstDayOfWeek: 1,
      todayHighlightColor: Colors.red,
      appointmentTextStyle: TextStyle(
        color: Colors.white,
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        timeFormat: 'HH:mm',
      ),
      onTap: (CalendarTapDetails details) {
        if (details.appointments == null) {
          newMeeting(context, details.date!);
        } else {
          final appointment = details.appointments!.single;
          initFixture = Fixture.make(data: appointment.get());
          if (appointment.isRecurrence) {
            final meeting = Meeting.instance(
                appointment,
                Fixture.make(data: {
                  "date": Date.fromDateTime(details.date!),
                  "from": appointment.from,
                  "to": appointment.to,
                })
            );
            editMeeting(context, meeting);
          } else {
            editMeeting(context, appointment);
          }
          initFixture = null;
        }
      },
      allowDragAndDrop: true,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      dragAndDropSettings: DragAndDropSettings(
        allowScroll: true,
        allowNavigation: false,
        showTimeIndicator: true,
        indicatorTimeFormat: "hh:mm",
      ),
    );
  }

  void onDragStart(AppointmentDragStartDetails details) {
    dynamic appointment = details.appointment!;
    initFixture = Fixture.make(data: appointment.get());
  }

  void onDragEnd(AppointmentDragEndDetails details) async {
    dynamic appointment = details.appointment!;
    final dropFixture = Fixture.make(data: {
      "date": details.droppingTime!.date,
      "from": details.droppingTime!.time.round(15),
      "to": details.droppingTime!.time.round(15) + appointment.duration,
    });
    // admin.schedule.meetings.forEach((m) => print(m.get()));
    if (appointment.isRecurrence) {
      if (admin.schedule.meetings.last.id == appointment.id) {
        admin.schedule.meetings.removeLast();
        admin.schedule.meeting(appointment.id).set(initFixture!.get());
        final meeting = Meeting.instance(appointment, dropFixture);
        await setMeeting(context, meeting);
      }
    } else {
      final meeting = appointment.set(dropFixture.get());
      print(meeting.get());
      await setMeeting(context, meeting);
    }
    initFixture = null;
  }
}


