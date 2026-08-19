import 'package:flutter/material.dart';

import 'models/task.dart';

import 'screens/home_screen.dart';
import 'screens/next_task_screen.dart';

import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FocusAssistantApp extends StatefulWidget {
  const FocusAssistantApp({super.key});

  @override
  State<FocusAssistantApp> createState() => _FocusAssistantAppState();
}

class _FocusAssistantAppState extends State<FocusAssistantApp> {
  @override
  void initState() {
    super.initState();

    //
    // Notification paspaudimas,
    // kai aplikacija jau veikia.
    //
    NotificationService.onTaskNotificationTapped = _openTaskFromNotification;

    //
    // Kai aplikacija paleidžiama
    // iš visiškai uždarytos būsenos,
    // navigatoriaus dar nėra.
    //
    // Todėl palaukiame pirmo frame.
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPendingNotification();
    });
  }

  @override
  void dispose() {
    NotificationService.onTaskNotificationTapped = null;

    super.dispose();
  }

  Future<void> _openPendingNotification() async {
    final taskId = NotificationService.pendingTaskId;

    if (taskId == null || taskId.isEmpty) {
      return;
    }

    NotificationService.pendingTaskId = null;

    await _openTaskFromNotification(taskId);
  }

  Future<void> _openTaskFromNotification(String taskId) async {
    //
    // Surandame konkrečią užduotį.
    //
    final tasks = await TaskService.loadTasks();

    Task? selectedTask;

    for (final task in tasks) {
      if (task.id == taskId) {
        selectedTask = task;
        break;
      }
    }

    if (selectedTask == null || selectedTask.isCompleted) {
      return;
    }

    //
    // Pasiimame vartotojo kalbą.
    //
    final savedLanguage = await LanguageService.loadLanguage();

    final language = LanguageService.resolve(savedLanguage);

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      //
      // Jei navigatorius dėl kokios nors
      // priežasties dar neparuoštas,
      // neprarandame taskId.
      //
      NotificationService.pendingTaskId = taskId;

      return;
    }

    final completed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            NextTaskScreen(task: selectedTask!, language: language),
      ),
    );

    //
    // Jei žmogus užduotį pažymėjo
    // atlikta tiesiai iš notification
    // atidaryto ekrano.
    //
    if (completed == true) {
      await TaskService.setCompleted(selectedTask.id, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Focus Assistant',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const HomeScreen(),
    );
  }
}
