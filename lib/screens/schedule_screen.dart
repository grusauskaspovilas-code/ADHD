import 'package:flutter/material.dart';
import 'package:device_calendar_plus/device_calendar_plus.dart';

import '../l10n/app_language.dart';
import '../models/user_routine.dart';
import '../services/user_routine_service.dart';
import '../services/calendar_service.dart';

class ScheduleScreen extends StatefulWidget {
  final AppLanguage language;

  const ScheduleScreen({
    super.key,
    required this.language,
  });

  @override
  State<ScheduleScreen> createState() =>
      _ScheduleScreenState();
}

class _ScheduleScreenState
    extends State<ScheduleScreen> {
  UserRoutine _routine = const UserRoutine();

  List<Event> _calendarEvents = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final routine =
        await UserRoutineService.loadRoutine();

    final events =
        await CalendarService.getUpcomingEvents();

    if (!mounted) return;

    setState(() {
      _routine = routine;
      _calendarEvents = events;
      _isLoading = false;
    });
  }

  String get _title {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Mano dienotvarkė';
      case AppLanguage.german:
        return 'Mein Tagesplan';
      default:
        return 'My schedule';
    }
  }

  String get _subtitle {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Tavo šiandienos planas';
      case AppLanguage.german:
        return 'Dein heutiger Tagesplan';
      default:
        return 'Your schedule for today';
    }
  }

  String get _wakeUpText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kėlimasis';
      case AppLanguage.german:
        return 'Aufstehen';
      default:
        return 'Wake up';
    }
  }

  String get _sleepText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Miegas';
      case AppLanguage.german:
        return 'Schlafen';
      default:
        return 'Sleep';
    }
  }

  String get _calendarEventText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kalendorius';
      case AppLanguage.german:
        return 'Kalender';
      default:
        return 'Calendar';
    }
  }

  String get _freeTimeText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Laisvas laikas';
      case AppLanguage.german:
        return 'Freie Zeit';
      default:
        return 'Free time';
    }
  }

  String get _nowText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Dabar';
      case AppLanguage.german:
        return 'Jetzt';
      default:
        return 'Now';
    }
  }

  String get _emptyText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Šiandienos dienotvarkė tuščia.';
      case AppLanguage.german:
        return 'Der heutige Tagesplan ist leer.';
      default:
        return 'Today\'s schedule is empty.';
    }
  }

  String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      switch (widget.language) {
        case AppLanguage.lithuanian:
          return '$minutes min.';
        case AppLanguage.german:
          return '$minutes Min.';
        default:
          return '$minutes min';
      }
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      switch (widget.language) {
        case AppLanguage.lithuanian:
          return '$hours val.';
        case AppLanguage.german:
          return '$hours Std.';
        default:
          return '$hours h';
      }
    }

    switch (widget.language) {
      case AppLanguage.lithuanian:
        return '$hours val. $remainingMinutes min.';
      case AppLanguage.german:
        return '$hours Std. $remainingMinutes Min.';
      default:
        return '$hours h $remainingMinutes min';
    }
  }

  bool _blockIsToday(
    RoutineBlock block,
  ) {
    return block.weekdays.contains(
      DateTime.now().weekday,
    );
  }

  bool _eventIsToday(
    Event event,
  ) {
    final now = DateTime.now();
    final date = event.startDate;

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _minutesFromDateTime(
    DateTime date,
  ) {
    return date.hour * 60 + date.minute;
  }

  int _currentMinutes() {
    final now = DateTime.now();

    return now.hour * 60 + now.minute;
  }

  List<_BusyPeriod> _createBusyPeriods() {
    final periods = <_BusyPeriod>[];

    for (final block
        in _routine.blocks.where(_blockIsToday)) {
      periods.add(
        _BusyPeriod(
          startMinutes: block.startMinutes,
          endMinutes: block.endMinutes,
        ),
      );
    }

    for (final event
        in _calendarEvents.where(_eventIsToday)) {
      final start =
          _minutesFromDateTime(event.startDate);

      final endDate = event.endDate;

      var end = endDate != null
          ? _minutesFromDateTime(endDate)
          : start + 30;

      if (end <= start) {
        end = start + 30;
      }

      periods.add(
        _BusyPeriod(
          startMinutes: start,
          endMinutes: end,
        ),
      );
    }

    periods.sort(
      (a, b) => a.startMinutes.compareTo(
        b.startMinutes,
      ),
    );

    final merged = <_BusyPeriod>[];

    for (final period in periods) {
      if (merged.isEmpty) {
        merged.add(period);
        continue;
      }

      final last = merged.last;

      if (period.startMinutes <=
          last.endMinutes) {
        merged[merged.length - 1] =
            _BusyPeriod(
          startMinutes: last.startMinutes,
          endMinutes:
              period.endMinutes > last.endMinutes
                  ? period.endMinutes
                  : last.endMinutes,
        );
      } else {
        merged.add(period);
      }
    }

    return merged;
  }

  List<_ScheduleEntry> _createEntries() {
    final entries = <_ScheduleEntry>[];

    final nowMinutes = _currentMinutes();

    //
    // Kėlimasis
    //
    if (_routine.wakeUpMinutes != null) {
      entries.add(
        _ScheduleEntry(
          sortMinutes:
              _routine.wakeUpMinutes!,
          time: _formatMinutes(
            _routine.wakeUpMinutes!,
          ),
          title: _wakeUpText,
          icon: Icons.wb_sunny_outlined,
          type: _ScheduleEntryType.routine,
        ),
      );
    }

    //
    // Rutinos blokai
    //
    for (final block
        in _routine.blocks.where(_blockIsToday)) {
      entries.add(
        _ScheduleEntry(
          sortMinutes: block.startMinutes,
          time:
              '${_formatMinutes(block.startMinutes)}'
              '–'
              '${_formatMinutes(block.endMinutes)}',
          title: block.title,
          icon: Icons.event_repeat_outlined,
          type: _ScheduleEntryType.routine,
        ),
      );
    }

    //
    // Telefono kalendorius
    //
    for (final event
        in _calendarEvents.where(_eventIsToday)) {
      final start =
          _minutesFromDateTime(event.startDate);

      final endDate = event.endDate;

      String time =
          _formatMinutes(start);

      if (endDate != null) {
        final end =
            _minutesFromDateTime(endDate);

        if (end > start) {
          time =
              '${_formatMinutes(start)}'
              '–'
              '${_formatMinutes(end)}';
        }
      }

      entries.add(
        _ScheduleEntry(
          sortMinutes: start,
          time: time,
          title: event.title.trim().isEmpty
              ? _calendarEventText
              : event.title,
          icon: Icons.event_outlined,
          type: _ScheduleEntryType.calendar,
        ),
      );
    }

    //
    // Laisvas laikas tik nuo DABAR
    //
    final wakeUp =
        _routine.wakeUpMinutes;

    final sleep =
        _routine.sleepStartMinutes;

    if (wakeUp != null &&
        sleep != null &&
        sleep > wakeUp &&
        nowMinutes < sleep) {
      final busyPeriods =
          _createBusyPeriods();

      //
      // Jei dar prieš kėlimosi laiką,
      // pradedame nuo kėlimosi.
      // Jei jau atsikėlimo laikas praėjo,
      // pradedame nuo realaus dabartinio laiko.
      //
      var cursor = nowMinutes > wakeUp
          ? nowMinutes
          : wakeUp;

      for (final period in busyPeriods) {
        if (period.endMinutes <= cursor) {
          continue;
        }

        if (period.startMinutes >= sleep) {
          break;
        }

        final busyStart =
            period.startMinutes < wakeUp
                ? wakeUp
                : period.startMinutes;

        final busyEnd =
            period.endMinutes > sleep
                ? sleep
                : period.endMinutes;

        if (busyStart > cursor) {
          final freeMinutes =
              busyStart - cursor;

          entries.add(
            _ScheduleEntry(
              sortMinutes: cursor,
              time:
                  '${_formatMinutes(cursor)}'
                  '–'
                  '${_formatMinutes(busyStart)}',
              title:
                  '$_freeTimeText · '
                  '${_formatDuration(freeMinutes)}',
              icon: Icons.schedule_outlined,
              type:
                  _ScheduleEntryType.freeTime,
              isNow:
                  nowMinutes >= wakeUp &&
                  cursor == nowMinutes,
            ),
          );
        }

        if (busyEnd > cursor) {
          cursor = busyEnd;
        }
      }

      if (cursor < sleep) {
        final freeMinutes =
            sleep - cursor;

        entries.add(
          _ScheduleEntry(
            sortMinutes: cursor,
            time:
                '${_formatMinutes(cursor)}'
                '–'
                '${_formatMinutes(sleep)}',
            title:
                '$_freeTimeText · '
                '${_formatDuration(freeMinutes)}',
            icon: Icons.schedule_outlined,
            type:
                _ScheduleEntryType.freeTime,
            isNow:
                nowMinutes >= wakeUp &&
                cursor == nowMinutes,
          ),
        );
      }
    }

    //
    // Miegas
    //
    if (_routine.sleepStartMinutes != null) {
      entries.add(
        _ScheduleEntry(
          sortMinutes:
              _routine.sleepStartMinutes!,
          time: _formatMinutes(
            _routine.sleepStartMinutes!,
          ),
          title: _sleepText,
          icon: Icons.bedtime_outlined,
          type: _ScheduleEntryType.routine,
        ),
      );
    }

    entries.sort(
      (a, b) {
        final compare = a.sortMinutes
            .compareTo(b.sortMinutes);

        if (compare != 0) {
          return compare;
        }

        if (a.type ==
                _ScheduleEntryType.freeTime &&
            b.type !=
                _ScheduleEntryType.freeTime) {
          return 1;
        }

        if (b.type ==
                _ScheduleEntryType.freeTime &&
            a.type !=
                _ScheduleEntryType.freeTime) {
          return -1;
        }

        return 0;
      },
    );

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _createEntries();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _loadSchedule,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadSchedule,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.all(20),
                  children: [
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (entries.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 60,
                        ),
                        child: Center(
                          child: Text(
                            _emptyText,
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      ),

                    ...entries.map(
                      (entry) =>
                          _ScheduleItem(
                        icon: entry.icon,
                        time: entry.time,
                        title: entry.title,
                        type: entry.type,
                        calendarText:
                            _calendarEventText,
                        nowText: _nowText,
                        isNow: entry.isNow,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

enum _ScheduleEntryType {
  routine,
  calendar,
  freeTime,
}

class _ScheduleEntry {
  final int sortMinutes;
  final String time;
  final String title;
  final IconData icon;
  final _ScheduleEntryType type;
  final bool isNow;

  const _ScheduleEntry({
    required this.sortMinutes,
    required this.time,
    required this.title,
    required this.icon,
    required this.type,
    this.isNow = false,
  });
}

class _BusyPeriod {
  final int startMinutes;
  final int endMinutes;

  const _BusyPeriod({
    required this.startMinutes,
    required this.endMinutes,
  });
}

class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String title;
  final _ScheduleEntryType type;
  final String calendarText;
  final String nowText;
  final bool isNow;

  const _ScheduleItem({
    required this.icon,
    required this.time,
    required this.title,
    required this.type,
    required this.calendarText,
    required this.nowText,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context) {
    final isCalendar =
        type == _ScheduleEntryType.calendar;

    final isFreeTime =
        type == _ScheduleEntryType.freeTime;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (isNow) ...[
                    Text(
                      nowText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),

                    const SizedBox(height: 3),
                  ],

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isFreeTime
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),

                  if (isCalendar) ...[
                    const SizedBox(height: 4),

                    Text(
                      calendarText,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}