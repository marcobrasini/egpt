import 'package:egpt/models/session.dart';
import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/admin/source_admin.dart';
import 'package:egpt/admin/widgets/meeting_form.dart';
import 'package:egpt/admin/widgets/option_form.dart';
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

  Future<MeetingType?> confirm(Meeting meeting, String action) async {
    final typeForm = GlobalKey<OptionFormState>();
    final lower = action.toLowerCase();
    return await showDialog<MeetingType?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
        value: admin,
        child: AlertDialog(
          title: Text("$action appuntamento", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meeting.isInstance) Column(
                children: [
                  Text("Stai ${lower}ndo un evento ricorrente."
                      "\nApplica le modifiche a:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: OptionForm(
                      option: MeetingType.exception,
                      key: typeForm,
                    ),
                  ),
                ],
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                    color: Colors.black,
                    fontSize: 16.0,
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
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text(action),
              onPressed: () async => Navigator.of(context).pop(
                  typeForm.currentState!.meetingType
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Meeting?> makeMeeting(DateTime datetime) async {
    final meetingForm = GlobalKey<MeetingFormState>();
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
        value: admin,
        child: AlertDialog(
          title: const Text("Nuovo meeting", textAlign: TextAlign.center),
          content: MeetingForm(null, datetime: datetime, key: meetingForm),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Annulla", style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text("Conferma", style: TextStyle(fontSize: 16)),
              onPressed: () async {
                try {
                  final data = meetingForm.currentState?.data;
                  if (data == null) return;
                  final meeting = await admin.insertMeeting(Meeting.make(data: data));
                  if (context.mounted) Navigator.of(context).pop(meeting);
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

  Future<Meeting?> editMeeting(Meeting meeting) async {
    final meetingForm = GlobalKey<MeetingFormState>();
    final isSession = meeting is Session;
    return await showDialog<Meeting?>(
      context: context,
      builder: (context) => ChangeNotifierProvider<AdminSource>.value(
        value: admin,
        child: AlertDialog(
          title: Text(isSession ? "Sessione" : "Appuntamento",
              textAlign: TextAlign.center
          ),
          content: MeetingForm(meeting, key: meetingForm, enabled: !isSession),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: (isSession) ? null : [
            TextButton(
              child: const Text("Cancella"),
              onPressed: () async {
                final deleted = await delMeeting(meeting);
                if (context.mounted) Navigator.of(context).pop(deleted);
              },
            ),
            TextButton(
              child: const Text("Modifica"),
              onPressed: () async {
                final data = meetingForm.currentState!.data!;
                final fixture = Fixture(start: data["start"], stop: data["stop"]);
                final updated = await setMeeting(meeting, fixture);
                if (context.mounted) Navigator.of(context).pop(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Meeting?> delMeeting(Meeting meeting) async {
    final option = (meeting.isInstance)
        ? await confirm(meeting, "Cancella")
        : MeetingType.occurrence;
    switch (option) {
      case MeetingType.occurrence:
        return await admin.removeMeeting(meeting);
      case MeetingType.recurrence:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        return await admin.removeMeeting(recurrence);
      case MeetingType.deviation:
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence.patternConclude(meeting.start.date);
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

  Future<Meeting?> setMeeting(Meeting meeting, Fixture fixture) async {
    final option = (meeting.isInstance)
        ? await confirm(meeting, "Modifica")
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
        final duration = fixture.duration;
        final difference = fixture.start.difference(meeting.start);
        final recurrence = admin.schedule.meeting(meeting.parentId!);
        if (recurrence.isDeviation) {
          final parent = admin.schedule.meeting(recurrence.parentId!);
          if (parent.hasDeviation(recurrence, fixture) ?? false) {
            parent.patternConclude(recurrence.patternUntil!);
            await admin.modifyMeeting(parent);
            await admin.removeMeeting(recurrence);
            return recurrence.shift(difference, duration);
          }
        }
        return await admin.modifyMeeting(recurrence.shift(difference, duration));
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
      eventConfig: EventConfig(
        textStyle: TextStyle(color: Colors.white),
        draggable: (meeting) => meeting is! Session,
        resizable: (meeting) => meeting is! Session,
        padding: 2.0,
      ),
      onFrameTap: (datetime) {
        makeMeeting(datetime);
      },
      onEventTap: (meeting) {
        editMeeting(meeting);
      },
      onEventDragged: (meeting, fixture) {
        setMeeting(meeting, fixture);
      },
      onEventResized: (meeting, fixture) {
        setMeeting(meeting, fixture);
      },
    );
  }
}


