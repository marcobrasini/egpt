import 'package:egpt/models/session.dart';
import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/schedule/meeting_widget.dart';
import 'package:egpt/admin/schedule/option_widget.dart';
import 'package:provider/provider.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  late final AdminSource admin;

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  @override
  bool get wantKeepAlive => true;

  Future<MeetingType?> confirm(BuildContext context, Meeting meeting, String action) async {
    final typeKey = GlobalKey<OptionWidgetState>();
    final lower = action.toLowerCase();
    return await showDialog<MeetingType?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
        value: admin,
        child: AlertDialog(
          title: Text("$action appuntamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meeting.isInstance) Column(
                children: [
                  Text("Stai ${lower}ndo un evento ricorrente."
                      "\nApplica le modifiche a:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: OptionWidget(
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
                          text: "Vuoi ${lower}re l'appuntamento\ncon "),
                      TextSpan(
                        text: meeting.member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  )
              ),
            ],
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
      ),
    );
  }

  Future<Meeting?> makeMeeting(BuildContext context, DateTime datetime) async {
    final meetingWidgetKey = GlobalKey<MeetingWidgetState>();
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
        value: admin,
        child: AlertDialog(
          title: const Center(child: Text("Nuovo meeting")),
          content: MeetingWidget(null, key: meetingWidgetKey, datetime: datetime),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text("Conferma"),
              onPressed: () async {
                try {
                  final data = meetingWidgetKey.currentState?.data;
                  if (data != null) {
                    if (context.mounted) {
                      Navigator.of(context).pop(
                          await admin.insertMeeting(Meeting.make(data: data))
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salvataggio riuscito.')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Salvataggio fallito: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Meeting?> editMeeting(BuildContext context, Meeting meeting) async {
    final meetingWidgetKey = GlobalKey<MeetingWidgetState>();
    final isSession = meeting is Session;
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
          value: admin,
          child: AlertDialog(
            title: Center(child: Text(isSession ? "Sessione" : "Incontro")),
            content: MeetingWidget(meeting, key: meetingWidgetKey, enabled: !isSession,),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: (isSession) ? null : [
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
                  final fixture = Fixture(start: data["start"], stop: data["stop"]);
                  final updated = await setMeeting(context, meeting, fixture);
                  if (mounted) Navigator.of(context).pop(updated);
                },
              ),
            ],
          )
      ),
    );
  }

  Future<Meeting?> delMeeting(BuildContext context, Meeting meeting) async {
    final option = (meeting.isInstance)
        ? await confirm(context, meeting, "Cancella")
        : MeetingType.occurrence;
    switch (option) {
      case MeetingType.occurrence:
        return await admin.removeMeeting(meeting);
      case MeetingType.recurrence:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        return await admin.removeMeeting(recurrence);
      case MeetingType.deviation:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence.patternConclude(meeting.start);
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
      case MeetingType.exception:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence.exceptionInsert(meeting.start);
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
      default:
        return null;
    }
  }

  Future<Meeting?> setMeeting(BuildContext context, Meeting meeting, Fixture fixture) async {
    final option = (meeting.isInstance)
        ? await confirm(context, meeting, "Modifica")
        : MeetingType.occurrence;
    switch (option) {
      case null:
        return null;
      case MeetingType.occurrence:
        if (meeting.isException) {
          final recurrence = admin.schedule.meeting(meeting.parentId!);
          if (recurrence.hasInstance(meeting, fixture) ?? false) {
            recurrence.exceptionRemove(fixture.start);
            await admin.modifyMeeting(recurrence);
            await admin.removeMeeting(meeting);
            return meeting.set(fixture.get());
          }
        }
        return await admin.modifyMeeting(meeting.set(fixture.get()));
      case MeetingType.recurrence:
        final difference = fixture.start.difference(meeting.start);
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        if (recurrence.isDeviation) {
          final parent = admin.schedule.meeting(recurrence.parentId!);
          if (parent.hasDeviation(recurrence, fixture) ?? false) {
            parent.patternConclude(recurrence.patternUntil!);
            await admin.modifyMeeting(parent);
            await admin.removeMeeting(recurrence);
            return recurrence.shift(difference);
          }
        }
        return await admin.modifyMeeting(recurrence.shift(difference));
      case MeetingType.deviation:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        final deviation = recurrence.deviation(meeting, fixture);
        if (deviation == null) return null;
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(deviation);
      case MeetingType.exception:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        final exception = recurrence.exception(meeting, fixture);
        if (exception == null) return null;
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(exception);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Calendar<Meeting>(
      view: CalendarView.weekly,
      source: admin.schedule,
      timeScheme: TimeScheme(6, 24, round: 15),
      headerBuilder: (context, start, stop) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(start.format("dd MMMM yyyy"),
            style: TextStyle(fontSize: 16),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(),
          )),
          Text(stop.format("dd MMMM yyyy"),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      onFrameTap: (datetime) {
        makeMeeting(context, datetime);
      },
      onEventTap: (meeting) {
        editMeeting(context, meeting);
      },
      onEventDragged: (meeting, fixture) {
        setMeeting(context, meeting, fixture);
      },
      onEventResized: (meeting, fixture) {
        setMeeting(context, meeting, fixture);
      },
    );
  }
}


