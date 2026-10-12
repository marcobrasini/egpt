import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/widgets/forms.dart';
import 'package:egpt/style.dart';
import 'source_admin.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  late final AdminSource admin;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  Future<MeetingType?> confirm(Meeting meeting, String action) async {
    final typeForm = GlobalKey<OptionFormState>();
    final lower = action.toLowerCase();
    return await showFormDialog(
      context: context,
      title: "$action appuntamento",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (meeting.isInstance) Column(
            children: [
              Text(
                "Stai ${lower}ndo un evento ricorrente."
                "\nApplica le modifiche a:",
              ),
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
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(fontSize: 16.0),
              children: [
                TextSpan(text: "Vuoi ${lower}re l'appuntamento\ncon "),
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
      actions: [
        FormAction("Annulla"),
        FormAction(action,
          color: (action == "Cancella")
              ? Theme.of(context).colorScheme.error
              : null,
          onPressed: (dialog) async {
            if (typeForm.currentState?.meetingType case final type?) {
              Navigator.of(context).pop(type);
            }
          }
        ),
      ],
    );
  }

  Future<void> openEvent(BuildContext context, Event event) async {
    final eventForm = GlobalKey<EventFormState>();
    return await showFormDialog(
      context: context,
      title: "Evento",
      content: EventForm(event, key: eventForm, enabled: false),
      actions: [FormAction("Annulla")],
    );
  }

  Future<Meeting?> makeMeeting(BuildContext context, DateTime datetime) async {
    final meetingForm = GlobalKey<MeetingFormState>();
    return await showFormDialog(
      context: context,
      title: "Nuovo appuntamento",
      content: MeetingForm(admin.register, null, datetime: datetime, key: meetingForm),
      actions: [
        FormAction("Annulla"),
        FormAction("Conferma",
          onPressed: (dialog) async {
            if (meetingForm.currentState?.data case final data?) {
              final meeting = await admin.insertMeeting(Meeting.make(data: data));
              if (dialog.mounted) {
                Navigator.of(dialog).pop(meeting);
                if (meeting == null) {
                  ScaffoldMessenger.of(dialog).showSnackBar(
                    SnackBar(content: Text("Salvataggio fallito")),
                  );
                }
              }
            }
          },
        )
      ],
    );
  }

  Future<Meeting?> editMeeting(BuildContext context, Meeting meeting) async {
    final meetingForm = GlobalKey<MeetingFormState>();
    final isSession = meeting is Presence;
    return await showFormDialog(
      context: context,
      title: isSession ? "Sessione" : "Appuntamento",
      content: MeetingForm(admin.register, meeting, key: meetingForm, enabled: !isSession),
      actions: (isSession) ? null : [
        FormAction("Cancella",
          color: Theme.of(context).colorScheme.error,
          onPressed: (dialog) async {
            final deleted = await delMeeting(meeting);
            if (dialog.mounted) {
              Navigator.of(context).pop(deleted);
              if (deleted == null) {
                ScaffoldMessenger.of(dialog).showSnackBar(
                  SnackBar(content: Text("Cancellazione fallita")),
                );
              }
            }
          },
        ),
        FormAction("Modifica",
          onPressed: (dialog) async {
            if (meetingForm.currentState?.data case final data?) {
              final fixture = Fixture(start: data["start"], stop: data["stop"]);
              final updated = await setMeeting(meeting, fixture);
              if (context.mounted) {
                Navigator.of(context).pop(updated);
                if (updated == null) {
                  ScaffoldMessenger.of(dialog).showSnackBar(
                    SnackBar(content: Text("Modifica fallita")),
                  );
                }
              }
            }
          },
        ),
      ]
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
        final expiration = (meeting.start.date - 7) & meeting.start.time;
        var recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence = recurrence.setPatternUntil(expiration);
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
      case MeetingType.exception:
        var recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence = recurrence.addPatternException(meeting.start);
        return (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
      default:
        return null;
    }
  }

  Future<Meeting?> setMeeting(Meeting meeting, Fixture fixture) async {
    final option = (meeting.isInstance)
        ? (fixture.isAllDay)
            ? MeetingType.exception
            : await confirm(meeting, "Modifica")
        : MeetingType.occurrence;
    switch (option) {
      case MeetingType.occurrence:
        if (meeting.isAllDay) {
          fixture = Fixture(
            start: fixture.start,
            stop: fixture.start.add(Duration(hours: 1)),
          );
        }
        if (meeting.isException) {
          var recurrence = admin.schedule.meeting(meeting.parentId!);
          if (recurrence.hasInstance(meeting, fixture) ?? false) {
            recurrence = recurrence.delPatternException(fixture.start);
            await admin.modifyMeeting(recurrence);
            await admin.removeMeeting(meeting);
            return meeting.set(fixture.get());
          }
        }
        return await admin.modifyMeeting(meeting.set(fixture.get()));
      case MeetingType.recurrence:
        final variation = fixture.start.difference(meeting.start);
        var recurrence = admin.schedule.meeting(meeting.parentId!);
        if (recurrence.isDeviation) {
          final expiration = recurrence.patternUntil!.add(variation);
          var parent = admin.schedule.meeting(recurrence.parentId!);
          if (parent.hasDeviation(recurrence, fixture) ?? false) {
            parent = parent.setPatternUntil(expiration);
            await admin.modifyMeeting(parent);
            await admin.removeMeeting(recurrence);
            return recurrence.shift(variation, fixture.duration);
          }
        }
        return await admin.modifyMeeting(recurrence.shift(variation, fixture.duration));
      case MeetingType.deviation:
        final expiration = (meeting.start.date - 7) & meeting.start.time;
        var recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence = recurrence.setPatternUntil(expiration);
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(meeting.deviation(fixture));
      case MeetingType.exception:
        var recurrence = admin.schedule.meeting(meeting.parentId!);
        recurrence = recurrence.addPatternException(meeting.start);
        (recurrence.isSignificant)
            ? await admin.modifyMeeting(recurrence)
            : await admin.removeMeeting(recurrence);
        return await admin.insertMeeting(meeting.exception(fixture));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator.adaptive(
      onRefresh: () => admin.build(),
      child: Calendar(
        view: CalendarView.daily,
        source: admin.schedule,
        dateScheme: DateScheme.weekly(),
        timeScheme: TimeScheme(6, 24, round: 15),
        lineConfig: LineConfig(color: scheme.neutral),
        timeConfig: TextConfig(textStyle: TextStyle(fontSize: 14)),
        dateConfig: TextConfig(padding: 8.0),
        headerBuilder: (context, start, stop) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(start.format("dd MMMM yyyy"), style: TextStyle(fontSize: 14)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(),
              ),
            ),
            Text(stop.format("dd MMMM yyyy"), style: TextStyle(fontSize: 14)),
          ],
        ),
        eventConfig: EventConfig(
          textStyle: TextStyle(color: Colors.white),
          textStyleOf: (e) => e is Meeting && e is! Presence
              ? null : const TextStyle(color: Colors.black),
          draggable: (e) => e is Meeting && e is! Presence,
          resizable: (e) => e is Meeting && e is! Presence,
          padding: 4.0,
          margin: 2.0
        ),
        onFrameTap: (datetime) => makeMeeting(context, datetime),
        onEventTap: (event) => switch (event) {
          Meeting m => editMeeting(context, m),
          _ => openEvent(context, event),
        },
        onEventDragged: (event, fixture) async {
          if (event is! Meeting) return;
          final messenger = ScaffoldMessenger.of(context);
          if (fixture.start.isBefore(event.product.start)) {
            messenger.showSnackBar(
              SnackBar(content: Text(
                "Modifica fallita: l'abbonamento inizia il "
                "${event.product.start.format("dd/MM/yyyy")}.")),
            );
            return;
          }
          final dragged = await setMeeting(event, fixture);
          if (dragged == null) {
            messenger.showSnackBar(
              SnackBar(content: Text("Modifica fallita")),
            );
          }
        },
        onEventResized: (event, fixture) async {
          if (event is! Meeting) return;
          final messenger = ScaffoldMessenger.of(context);
          final resized = await setMeeting(event, fixture);
          if (resized == null) {
            messenger.showSnackBar(
              SnackBar(content: Text("Modifica fallita")),
            );
          }
        },
      ),
    );
  }
}
