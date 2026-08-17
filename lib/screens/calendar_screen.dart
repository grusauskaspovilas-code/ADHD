import 'package:flutter/material.dart';
import 'package:device_calendar_plus/device_calendar_plus.dart';

import '../l10n/app_language.dart';
import '../models/task.dart';
import '../services/calendar_service.dart';
import '../services/calendar_entry_type_service.dart';

class CalendarScreen extends StatefulWidget {
  final AppLanguage language;

  const CalendarScreen({
    super.key,
    required this.language,
  });

  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends State<CalendarScreen>
    with WidgetsBindingObserver {
  List<Event> _events = [];
  bool _isLoading = true;

  final Map<String, TaskType> _types = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final events =
        await CalendarService.getUpcomingEvents();

    final types = <String, TaskType>{};

    for (final event in events) {
      final id = _eventId(event);

      types[id] =
          await CalendarEntryTypeService.getType(id);
    }

    if (!mounted) return;

    setState(() {
      _events = events;

      _types
        ..clear()
        ..addAll(types);

      _isLoading = false;
    });
  }

  String _eventId(Event event) {
    return CalendarEntryTypeService.createCalendarId(
      title: event.title.trim(),
      startDate: event.startDate,
    );
  }

  Future<void> _changeType(
    Event event,
    TaskType type,
  ) async {
    final id = _eventId(event);

    await CalendarEntryTypeService.setType(
      id,
      type,
    );

    if (!mounted) return;

    setState(() {
      _types[id] = type;
    });
  }

  String get _title {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kalendorius';

      case AppLanguage.german:
        return 'Kalender';

      default:
        return 'Calendar';
    }
  }

  String get _today {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Šiandien';

      case AppLanguage.german:
        return 'Heute';

      default:
        return 'Today';
    }
  }

  String get _tomorrow {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Rytoj';

      case AppLanguage.german:
        return 'Morgen';

      default:
        return 'Tomorrow';
    }
  }

  String get _noEvents {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Artimiausių įvykių nerasta.';

      case AppLanguage.german:
        return 'Keine kommenden Termine gefunden.';

      default:
        return 'No upcoming events found.';
    }
  }

  String get _taskText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Užduotis';

      case AppLanguage.german:
        return 'Aufgabe';

      default:
        return 'Task';
    }
  }

  String get _eventText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Įvykis';

      case AppLanguage.german:
        return 'Termin';

      default:
        return 'Event';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final eventDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        eventDate.difference(today).inDays;

    if (difference == 0) {
      return _today;
    }

    if (difference == 1) {
      return _tomorrow;
    }

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _loadEvents,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _events.isEmpty
                ? Center(
                    child: Text(
                      _noEvents,
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.all(20),
                      itemCount: _events.length,
                      separatorBuilder:
                          (context, index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemBuilder:
                          (context, index) {
                        final event =
                            _events[index];

                        final id =
                            _eventId(event);

                        final type =
                            _types[id] ??
                                TaskType.calendarEvent;

                        final isTask =
                            type == TaskType.task;

                        return Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              14,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isTask
                                          ? Icons
                                              .check_box_outlined
                                          : Icons
                                              .event_outlined,
                                      size: 30,
                                    ),

                                    const SizedBox(
                                      width: 14,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            event.title
                                                    .trim()
                                                    .isEmpty
                                                ? _title
                                                : event
                                                    .title,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 4,
                                          ),

                                          Text(
                                            '${_formatDate(event.startDate)} · '
                                            '${_formatTime(event.startDate)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 14,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          ChoiceChip(
                                        label: Text(
                                          _eventText,
                                        ),
                                        avatar:
                                            const Icon(
                                          Icons
                                              .event_outlined,
                                          size: 18,
                                        ),
                                        selected:
                                            !isTask,
                                        onSelected:
                                            (selected) {
                                          if (!selected) {
                                            return;
                                          }

                                          _changeType(
                                            event,
                                            TaskType
                                                .calendarEvent,
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),

                                    Expanded(
                                      child:
                                          ChoiceChip(
                                        label: Text(
                                          _taskText,
                                        ),
                                        avatar:
                                            const Icon(
                                          Icons
                                              .check_outlined,
                                          size: 18,
                                        ),
                                        selected:
                                            isTask,
                                        onSelected:
                                            (selected) {
                                          if (!selected) {
                                            return;
                                          }

                                          _changeType(
                                            event,
                                            TaskType
                                                .task,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}