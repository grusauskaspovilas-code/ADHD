import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import '../l10n/home_strings.dart';
import '../l10n/guardian_strings.dart';

import '../models/task.dart';
import '../models/context_place.dart';

import '../services/language_service.dart';
import '../services/task_service.dart';
import '../services/task_selector_service.dart';
import '../services/unified_task_service.dart';
import '../services/notification_service.dart';
import '../services/context_place_service.dart';
import '../services/location_context_service.dart';
import '../services/task_location_filter_service.dart';

import '../widgets/home/available_time_sheet.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_task_list.dart';
import '../widgets/home/ai_loading_dialog.dart';
import '../widgets/home/current_activity_sheet.dart';

import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'next_task_screen.dart';
import 'stuck_screen.dart';
import '../widgets/home/no_task_fits_sheet.dart';
import '../services/home_task_selection_service.dart';
import '../widgets/home/no_calendar_event_sheet.dart';
import 'routine_screen.dart';
import 'schedule_screen.dart';
import 'context_places_screen.dart';
import '../services/ai_context_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLanguage _selectedLanguage = AppLanguage.automatic;

  List<Task> _tasks = [];
  bool _isLoadingTasks = true;
  ContextPlace? _currentContextPlace;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    NotificationService.onTaskNotificationTapped = _openTaskFromNotification;

    _loadSavedLanguage();

    _loadTasks().then((_) {
      if (!mounted) return;

      TaskService.refreshGuardian();

      final pendingTaskId = NotificationService.pendingTaskId;

      if (pendingTaskId != null) {
        NotificationService.pendingTaskId = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _openTaskFromNotification(pendingTaskId);
        });
      }
    });
  }

  @override
  void dispose() {
    NotificationService.onTaskNotificationTapped = null;

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTasks();
      TaskService.refreshGuardian();
    }
  }

  Future<void> _loadSavedLanguage() async {
    final language = await LanguageService.loadLanguage();

    if (!mounted) return;

    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _loadTasks() async {
    final tasks = await UnifiedTaskService.loadTasks();

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoadingTasks = false;
    });
  }

  List<Task> get _actionableTasks {
    return _tasks.where((task) {
      if (task.isCompleted) {
        return false;
      }

      if (task.source == TaskSource.app) {
        return true;
      }

      return task.source == TaskSource.calendar && task.type == TaskType.task;
    }).toList();
  }

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarScreen(language: _activeLanguage),
      ),
    );

    if (!mounted) return;

    await _loadTasks();
    await TaskService.refreshGuardian();
  }

  Future<void> _openRoutine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineScreen(language: _activeLanguage),
      ),
    );

    if (!mounted) return;

    await _loadTasks();
    await TaskService.refreshGuardian();
  }

  Future<void> _openSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleScreen(language: _activeLanguage),
      ),
    );
  }

  Future<void> _openContextPlaces() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContextPlacesScreen(language: _activeLanguage),
      ),
    );
  }

  Future<void> _openTaskFromNotification(String taskId) async {
    //
    // Užkrauname naujausias užduotis,
    // nes notification gali būti paspaustas
    // po ilgesnio laiko.
    //
    final tasks = await UnifiedTaskService.loadTasks();

    if (!mounted) {
      return;
    }

    Task? task;

    for (final item in tasks) {
      if (item.id == taskId) {
        task = item;
        break;
      }
    }

    if (task == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Užduotis neberasta.')));

      return;
    }

    if (task.isCompleted) {
      return;
    }

    await _openTask(task);
  }

  Future<void> _openAddTask() async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(language: _activeLanguage),
      ),
    );

    if (task == null || !mounted) {
      return;
    }

    await TaskService.addTask(task);
    await _loadTasks();
  }

  Future<void> _openEditTask(Task existingTask) async {
    if (existingTask.source != TaskSource.app) {
      return;
    }

    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          language: _activeLanguage,
          existingTask: existingTask,
        ),
      ),
    );

    if (task == null || !mounted) {
      return;
    }

    await TaskService.addTask(task);
    await _loadTasks();
  }

  Future<void> _saveCalendarTaskAsCompleted(Task task) async {
    final completedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
      estimatedMinutes: task.estimatedMinutes,
      priority: task.priority,
      energyLevel: task.energyLevel,
      isCompleted: true,
      steps: task.steps,
      source: task.source,
      type: task.type,
      placeRequirement: task.placeRequirement,
    );

    await TaskService.addTask(completedTask);
  }

  Future<void> _openTask(Task task) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NextTaskScreen(task: task, language: _activeLanguage),
      ),
    );

    if (completed != true) {
      return;
    }

    if (task.source == TaskSource.app) {
      await TaskService.setCompleted(task.id, true);
    } else if (task.type == TaskType.task) {
      await _saveCalendarTaskAsCompleted(task);
    }

    await _loadTasks();

    if (!mounted) return;

    _showCompletionUndo(task);
  }

  Future<void> _openStuckTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StuckScreen(task: task, language: _activeLanguage),
      ),
    );
  }

  Future<void> _showStuckHelp() async {
    final tasks = _actionableTasks;

    final task = TaskSelectorService.selectNextTask(tasks);

    if (task == null || !mounted) {
      _showNoTasksMessage();
      return;
    }

    await _openStuckTask(task);
  }

  int? _minutesUntilNextBlockingEvent() {
    final now = DateTime.now();

    final events = _tasks.where((task) {
      return task.source == TaskSource.calendar &&
          task.type == TaskType.calendarEvent &&
          task.dueDate != null &&
          task.dueDate!.isAfter(now);
    }).toList();

    if (events.isEmpty) {
      return null;
    }

    events.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return events.first.dueDate!.difference(now).inMinutes;
  }

  Future<void> _selectTaskFromCalendar() async {
    await _loadTasks();

    if (!mounted) return;

    final minutes = _minutesUntilNextBlockingEvent();

    if (minutes == null) {
      final selectAnyway = await showNoCalendarEventSheet(
        context: context,
        title: _homeStrings.noCalendarEventTitle,
        subtitle: _homeStrings.noCalendarEventSubtitle,
        selectTaskText: _homeStrings.selectTaskAnyway,
        cancelText: _homeStrings.cancel,
      );

      if (!mounted) return;

      if (selectAnyway == true) {
        await _selectTaskAnyTime();
      }

      return;
    }

    if (minutes <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_homeStrings.noFreeTime)));

      return;
    }

    await _selectTaskForTime(minutes);
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String get _busyTitle {
    return _homeStrings.busyTitle;
  }

  String _busyUntilText(DateTime date) {
    final time = _formatTime(date);

    return _homeStrings.busyUntil(time);
  }

  String get _suggestAnywayText {
    return _homeStrings.suggestAnyway;
  }

  String get _busyOkText {
    return _homeStrings.busyOk;
  }

  Future<Task?> _selectTaskWithAi({
    required List<Task> tasks,
    int? availableMinutes,
  }) async {
    final locationAwareTasks = await _filterTasksForCurrentPlace(tasks);
    if (locationAwareTasks.isEmpty) return null;

    final aiContext = await AiContextService.build(tasks: locationAwareTasks);

    if (!mounted) {
      return null;
    }

    if (aiContext.currentlyBusy) {
      final suggestAnyway = await showCurrentActivitySheet(
        context: context,
        title: _busyTitle,
        activity: aiContext.currentActivity ?? '',
        untilText: aiContext.nextFreeTime == null
            ? null
            : _busyUntilText(aiContext.nextFreeTime!),
        suggestAnywayText: _suggestAnywayText,
        okText: _busyOkText,
      );

      if (suggestAnyway != true) {
        return null;
      }
    }

    return HomeTaskSelectionService.selectTask(
      context: aiContext,
      ignoreBusyState: true,
      availableMinutesOverride: availableMinutes,
    );
  }

  Future<List<Task>> _filterTasksForCurrentPlace(List<Task> tasks) async {
    try {
      const locationService = LocationContextService();
      if (await locationService.loadStatus() != LocationContextStatus.ready) {
        return tasks;
      }

      final places = await ContextPlaceService.loadPlaces();
      final currentPlace = await locationService.detectCurrentPlace(places);
      if (mounted && currentPlace?.id != _currentContextPlace?.id) {
        setState(() => _currentContextPlace = currentPlace);
      }
      return TaskLocationFilterService.filterForPlace(tasks, currentPlace);
    } catch (_) {
      // Vietos kontekstas yra papildomas. GPS ar geokodavimo klaida neturi
      // sustabdyti pagrindinės užduočių atrankos.
      return tasks;
    }
  }

  Future<void> _selectTaskForTime(int availableMinutes) async {
    final tasks = _actionableTasks;

    if (tasks.isEmpty) {
      _showNoTasksMessage();
      return;
    }

    final fittingTasks = tasks.where((task) {
      final duration = task.estimatedMinutes;

      if (duration == null) {
        return false;
      }

      return duration <= availableMinutes;
    }).toList();

    if (fittingTasks.isNotEmpty) {
      // Parodome loading langą.
      showAiLoadingDialog(
        context: context,
        title: _homeStrings.aiLoadingTitle,
        subtitle: _homeStrings.aiLoadingSubtitle,
      );

      final task = await _selectTaskWithAi(
        tasks: fittingTasks,
        availableMinutes: availableMinutes,
      );

      if (!mounted) return;

      // Uždaro loading langą.
      Navigator.of(context, rootNavigator: true).pop();

      if (task != null) {
        await _openTask(task);
      }

      return;
    }

    // Jei nė viena užduotis netelpa.
    final task = TaskSelectorService.selectNextTask(tasks);

    if (task == null || !mounted) {
      _showNoTasksMessage();
      return;
    }

    await _showNoTaskFits(task, availableMinutes);
  }

  Future<void> _selectTaskAnyTime() async {
    final tasks = _actionableTasks;

    if (tasks.isEmpty) {
      _showNoTasksMessage();
      return;
    }

    showAiLoadingDialog(
      context: context,
      title: _homeStrings.aiLoadingTitle,
      subtitle: _homeStrings.aiLoadingSubtitle,
    );

    final task = await _selectTaskWithAi(tasks: tasks);

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    if (task != null) {
      await _openTask(task);
    }
  }

  Future<void> _askAvailableTime() async {
    if (_actionableTasks.isEmpty) {
      _showNoTasksMessage();
      return;
    }

    final minutes = await showAvailableTimeSheet(
      context: context,
      title: _homeStrings.availableTimeTitle,
      subtitle: _homeStrings.availableTimeSubtitle,
      calendarText: _homeStrings.calendarTime,
      oneHourText: _homeStrings.oneHour,
      anyTimeText: _homeStrings.anyTime,
    );

    if (!mounted || minutes == null) {
      return;
    }

    if (minutes == -2) {
      await _selectTaskFromCalendar();
      return;
    }

    if (minutes == -1) {
      await _selectTaskAnyTime();
      return;
    }

    await _selectTaskForTime(minutes);
  }

  Future<void> _showNoTaskFits(Task task, int availableMinutes) async {
    final startSmall = await showNoTaskFitsSheet(
      context: context,
      title: _homeStrings.nothingFitsTitle(availableMinutes),
      subtitle: _homeStrings.nothingFitsSubtitle,
      taskTitle: task.title,
      helpMeStartText: _homeStrings.helpMeStart,
      notNowText: _homeStrings.notNow,
    );

    if (startSmall == true && mounted) {
      await _openStuckTask(task);
    }
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    final completed = value ?? false;

    if (task.source == TaskSource.app) {
      await TaskService.setCompleted(task.id, completed);
    } else if (task.type == TaskType.task && completed) {
      await _saveCalendarTaskAsCompleted(task);
    }

    await _loadTasks();

    if (completed && mounted) {
      _showCompletionUndo(task);
    }
  }

  void _showCompletionUndo(Task task) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: Text(_strings.taskCompleted(task.title)),
        action: SnackBarAction(
          label: _strings.undo,
          onPressed: () async {
            if (task.source == TaskSource.app) {
              await TaskService.setCompleted(task.id, false);
            } else {
              await TaskService.deleteTask(task.id);
            }

            if (!mounted) return;

            await _loadTasks();
          },
        ),
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    if (task.source != TaskSource.app) {
      return;
    }

    await TaskService.deleteTask(task.id);

    await _loadTasks();

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: Text(_strings.taskDeleted(task.title)),
        action: SnackBarAction(
          label: _strings.undo,
          onPressed: () async {
            await TaskService.addTask(task);

            if (!mounted) return;

            await _loadTasks();
          },
        ),
      ),
    );
  }

  void _showNoTasksMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_homeStrings.noTasks)));
  }

  AppLanguage get _activeLanguage {
    return LanguageService.resolve(_selectedLanguage);
  }

  AppStrings get _strings {
    return AppStrings(_activeLanguage);
  }

  HomeStrings get _homeStrings {
    return HomeStrings(_activeLanguage);
  }

  GuardianStrings get _guardianStrings {
    return GuardianStrings(_activeLanguage);
  }

  String _languageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.automatic:
        return '🌐  Automatic';

      case AppLanguage.english:
        return '🇬🇧  English';

      case AppLanguage.german:
        return '🇩🇪  Deutsch';

      case AppLanguage.lithuanian:
        return '🇱🇹  Lietuvių';
    }
  }

  Future<void> _testGuardian() async {
    final results = await AiContextService.buildGuardian(tasks: _tasks);

    if (!mounted) return;

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_guardianStrings.noMonitoredTasks)),
      );

      return;
    }

    final result = results.first;
    final task = result.task;

    final deadline = task.dueDate!;

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    final deadlineText =
        '${twoDigits(deadline.day)}.'
        '${twoDigits(deadline.month)}.'
        '${deadline.year} '
        '${twoDigits(deadline.hour)}:'
        '${twoDigits(deadline.minute)}';

    String message;

    if (result.isOverdue) {
      message = _guardianStrings.deadlineAlreadyPassed;
    } else if (!result.canStillFit) {
      message = _guardianStrings.noSufficientSlot;
    } else {
      final suggested = result.suggestedStart!;

      final suggestedText =
          '${twoDigits(suggested.day)}.'
          '${twoDigits(suggested.month)} '
          '${twoDigits(suggested.hour)}:'
          '${twoDigits(suggested.minute)}';

      message = _guardianStrings.suggestedTime(suggestedText);
    }

    final duration = task.estimatedMinutes ?? 30;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            result.isUrgent
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
          ),
          title: Text(result.isUrgent ? 'Guardian ⚠️' : 'Guardian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Text(_guardianStrings.deadlineLabel(deadlineText)),

              const SizedBox(height: 6),

              Text(_guardianStrings.durationLabel(duration)),

              const SizedBox(height: 16),

              Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: result.isUrgent
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(_guardianStrings.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;

    final visibleItems = _tasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              HomeHeader(
                addTaskText: strings.addTask,
                languageTooltip: strings.languageLabel,
                selectedLanguage: _selectedLanguage,
                onAddTask: _openAddTask,
                onOpenCalendar: _openCalendar,
                onLanguageSelected: (language) async {
                  setState(() {
                    _selectedLanguage = language;
                  });

                  await LanguageService.saveLanguage(language);
                },
                languageName: _languageName,
              ),

              const SizedBox(height: 12),

              if (_isLoadingTasks) const LinearProgressIndicator(),

              if (_currentContextPlace != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.location_on_outlined, size: 18),
                    label: Text(
                      _homeStrings.locationContext(_currentContextPlace!.name),
                    ),
                  ),
                ),
              ],

              if (!_isLoadingTasks && visibleItems.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: HomeTaskList(
                    tasks: visibleItems,
                    formatDueDate: _homeStrings.formatDueDate,
                    formatDuration: _homeStrings.formatDuration,
                    onToggleTask: _toggleTask,
                    onDeleteTask: _deleteTask,
                    onEditTask: _openEditTask,
                    onOpenTask: _openTask,
                  ),
                ),

              const Spacer(),

              const Icon(Icons.psychology_alt_outlined, size: 64),

              const SizedBox(height: 16),

              Text(
                strings.homeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                strings.homeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _askAvailableTime,
                  child: Text(
                    strings.whatShouldIDo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: _actionableTasks.isEmpty ? null : _showStuckHelp,
                icon: const Icon(Icons.help_outline),
                label: Text(strings.imStuck),
              ),
              TextButton.icon(
                onPressed: _openRoutine,
                icon: const Icon(Icons.calendar_view_week_outlined),
                label: Text(_homeStrings.myRoutine),
              ),

              TextButton.icon(
                onPressed: _openSchedule,
                icon: const Icon(Icons.view_agenda_outlined),
                label: Text(_homeStrings.mySchedule),
              ),

              TextButton.icon(
                onPressed: _openContextPlaces,
                icon: const Icon(Icons.location_on_outlined),
                label: Text(_homeStrings.importantPlaces),
              ),

              TextButton.icon(
                onPressed: _testGuardian,
                icon: const Icon(Icons.shield_outlined),
                label: Text(_homeStrings.guardianTest),
              ),
              TextButton.icon(
                onPressed: () async {
                  await NotificationService.showTestNotification();
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(_homeStrings.notificationTest),
              ),
              TextButton.icon(
                onPressed: () async {
                  await NotificationService.scheduleTestNotification();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_homeStrings.notificationScheduled)),
                  );
                },
                icon: const Icon(Icons.schedule_outlined),
                label: Text(_homeStrings.scheduledNotificationTest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
