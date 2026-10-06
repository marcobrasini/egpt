import 'package:flutter/widgets.dart';
import 'package:device_calendar_plus/device_calendar_plus.dart' as dcp;
import 'package:calendar/calendar.dart';
import 'api/calendar_service.dart';


extension on dcp.Calendar {
  String get label => "$accountName:$name";
}

class DeviceCalendar extends CalendarService {
  DeviceCalendar({this.excluded = const {}});

  final Set<String> excluded;
  late final DeviceSources sources = DeviceSources(this);
  final _plugin = dcp.DeviceCalendar.instance;

  bool visible(dcp.Calendar calendar) =>
      !(calendar.hidden || excluded.contains(calendar.label));

  @override
  Future<bool> get authorized async =>
      await _plugin.hasPermissions() == dcp.CalendarPermissionStatus.granted;

  @override
  Future<void> authorize() async {
    if (await authorized) return;
    await _plugin.requestPermissions();
  }

  @override
  Future<List<CalendarSource<Event>>> build([String? calendarId]) async {
    await authorize();
    if (!await authorized) return const [];
    await sources.buildCalendar();
    return [sources];
  }

  Future<List<dcp.Calendar>> calendars() async {
    final calendars = await _plugin.listCalendars();
    return calendars.where(visible).toList();
  }

  Future<bool?> fetch(dcp.Calendar calendar, DateTime from, DateTime to) async {
    try {
      if (!await authorized) return null;
      final list = await _plugin.listEvents(from, to, calendarIds: [calendar.id]);
      final events = [
        for (final event in list)
          if (event.status != dcp.EventStatus.canceled)
            fromDevice(calendar, event)
      ];
      return sources.source(calendar.label).sync(events as Iterable<Event>);
    } on dcp.DeviceCalendarException {
      return null;
    }
  }

  Event fromDevice(dcp.Calendar calendar, dcp.Event event) {
    return Event(
      id: 'device:${event.instanceId}',
      subject: event.title,
      color: event.color ?? calendar.color ?? const Color(0xFF9E9E9E),
      start: event.isAllDay ? event.startDate.date : event.startDate,
      stop: event.isAllDay ? null : event.endDate,
    );
  }
}


class DeviceSources extends CalendarSources<Event> {
  DeviceSources(this.service) : super({}) {
    _lifecycle = AppLifecycleListener(onResume: refresh);
  }

  final DeviceCalendar service;
  final Map<String, CalendarSource<Event>> _byId = {};
  late final AppLifecycleListener _lifecycle;
  List<dcp.Calendar> _calendars = [];

  Date? _from, _to;
  bool _pending = false, _busy = false;


  CalendarSource<Event>? byId(String id) => _byId[id];

  Future<void> buildCalendar() async {
    _calendars = await service.calendars();
    final ids = {for (final calendar in _calendars) calendar.id};
    for (final id in _byId.keys.where((id) => !ids.contains(id)).toList()) {
      final source = _byId.remove(id)!;
      detach(source);
      source.dispose();
    }
    for (final calendar in _calendars) {
      _byId.putIfAbsent(calendar.id, () {
        final source = CalendarSource<Event>(label: calendar.label);
        attach(source);
        return source;
      });
    }
    await refresh();
  }

  @override
  void load(Date from, Date to) async {
    super.load(from, to);
    if (_from == null || from < _from! || to > _to!) {
      _from = (_from == null || from < _from!) ? from : _from;
      _to = (_to == null || to > _to!) ? to : _to;
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_from == null || _calendars.isEmpty) return;
    if (_busy) { _pending = true; return; }
    _busy = true;
    try {
      do {
        _pending = false;
        var changed = false;
        for (final calendar in _calendars) {
          changed = (await service.fetch(calendar, _from!, _to!) ?? false) || changed;
        }
        if (changed) notifyListeners();
      } while (_pending);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }
}