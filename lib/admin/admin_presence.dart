import 'package:egpt/admin/admin_statistic.dart';
import 'package:egpt/admin/presence/presence_widget.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/admin/source_admin.dart';


class PresencePage extends StatefulWidget {
  const PresencePage({super.key});

  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage>
    with AutomaticKeepAliveClientMixin {

  final Map<ValueKey, bool?> _presences = {};
  late final AdminSource admin;
  late DateTime lastDate;
  late DateTime nextDate;

  ValueKey<Meeting> _key(Meeting meeting) => ValueKey<Meeting>(meeting);

  Future<Meeting?> delMeeting(BuildContext context, Meeting meeting) async {
    _presences.remove(_key(meeting));
    if (meeting.isOccurrence || meeting.isException) {
      return await admin.removeMeeting(meeting);
    }
    if (meeting.isInstance) {
      final recurrence = admin.schedule.meeting(meeting.parentId!);
      recurrence.exceptionInsert(meeting.start);
      return (recurrence.isSignificant)
          ? await admin.modifyMeeting(recurrence)
          : await admin.removeMeeting(recurrence);
    }
    return null;
  }

  Future<Session?> addSession(BuildContext context, Meeting meeting) async {
    admin.schedule.meetings.forEach((m) => print(m.get()));
    admin.schedule.sessions.forEach((m) => print(m.get()));
    final presence = _presences[_key(meeting)];
    if (presence == null)  return null;
    final session = Session.build(meeting: meeting, presence: presence);
    return await admin.insertSession(session);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final week = Week.now();
    lastDate = week.weekStart;
    nextDate = week.weekEnd;
    admin = context.read<AdminSource>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        AdminStatistic(),
        SliverFillRemaining(
          child: Agenda<Meeting>(
            source: admin.schedule.meetingSource,
            view: CalendarView.weekly,
            scroll: CalendarScroll.sequential,
            negligibleAgenda: true,
            fixLastAnchor: false,
            fixNextAnchor: false,
            centredView: false,
            lastAnchorBuilder: (context) => Container(
              color: scheme.inversePrimary,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text("Attenzione: ci sono vecchie presenze non registrate."),
                ),
              ),
            ),
            headerBuilder: (context, start, stop) => Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(start.format("dd MMMM yyyy"),
                  style: TextStyle(fontSize: 16),
                ),
                const Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(),
                )),
                Text(stop.format("dd MMMM yyyy"),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            emptyBuilder: (context) => Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: scheme.outlineVariant)),
                    ),
                    child: Text("Non ci sono presenze\nda segnare",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: scheme.outline,
                      ),
                    ),
                  ),
                )
              ],
            ),
            eventBuilder: (context, meeting) => PresenceWidget(
              meeting: meeting,
              presence: _presences[_key(meeting)],
              onChanged: (value) => _presences[_key(meeting)] = value,
            ),
            leftSwipeBuilder: (context) => ColoredBox(
              color: scheme.tertiaryContainer,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete,
                        color: scheme.onTertiaryContainer,
                        size: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("Cancella",
                          style: TextStyle(
                            color: scheme.onTertiaryContainer,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            rightSwipeBuilder: (context) => ColoredBox(
              color: scheme.secondaryContainer,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("Archivia",
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.archive,
                        color: scheme.onSecondaryContainer,
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onEventSwipedLeft: (meeting, fixture) async {
              await delMeeting(context, meeting);
            },
            onEventSwipedRight: (meeting, fixture) async {
              final session = await addSession(context, meeting);
              if (session != null) delMeeting(context, meeting);
            },
            swipeableEvent: true,
          ),
        ),
      ],
    );
  }
}


