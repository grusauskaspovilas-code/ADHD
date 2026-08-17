import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'guardian_notification_service.dart';

class TaskService {
  static const String _tasksKey = 'tasks';

  static Future<List<Task>> loadTasks() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedTasks =
        preferences.getString(_tasksKey);

    if (savedTasks == null ||
        savedTasks.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded =
          jsonDecode(savedTasks);

      return decoded
          .map(
            (item) => Task.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(
    List<Task> tasks,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      tasks
          .map(
            (task) => task.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _tasksKey,
      encoded,
    );
  }

  static Future<void> addTask(
    Task task,
  ) async {
    final tasks = await loadTasks();

    //
    // Jei užduotis tokiu ID jau yra,
    // pakeičiame ją.
    //
    // Tai bus naudinga ir vėliau,
    // kai leisime redaguoti užduotis.
    //
    final existingIndex =
        tasks.indexWhere(
      (existingTask) =>
          existingTask.id == task.id,
    );

    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }

    await saveTasks(tasks);

    await _refreshGuardian(tasks);
  }

  static Future<void> deleteTask(
    String taskId,
  ) async {
    final tasks = await loadTasks();

    Task? deletedTask;

    for (final task in tasks) {
      if (task.id == taskId) {
        deletedTask = task;
        break;
      }
    }

    tasks.removeWhere(
      (task) => task.id == taskId,
    );

    await saveTasks(tasks);

    //
    // Ištrintos užduoties nebebus tasks
    // sąraše, todėl jos notification
    // atšaukiame atskirai.
    //
    if (deletedTask != null) {
      await GuardianNotificationService
          .cancelForTask(
        deletedTask,
      );
    }

    await _refreshGuardian(tasks);
  }

  static Future<void> setCompleted(
    String taskId,
    bool completed,
  ) async {
    final tasks = await loadTasks();

    for (final task in tasks) {
      if (task.id == taskId) {
        task.isCompleted = completed;
        break;
      }
    }

    await saveTasks(tasks);

    //
    // Guardian iš naujo įvertina visas
    // būtinas užduotis.
    //
    // Jei ši užduotis atlikta,
    // jos priminimas bus panaikintas.
    //
    await _refreshGuardian(tasks);
  }

  static Future<void> _refreshGuardian(
    List<Task> tasks,
  ) async {
    try {
      await GuardianNotificationService
          .refresh(
        tasks: tasks,
      );
    } catch (_) {
      //
      // Guardian klaida neturi sutrukdyti
      // išsaugoti / atlikti / ištrinti
      // užduoties.
      //
      // Tai svarbu: pagrindinė programėlė
      // turi veikti net jei kalendoriaus ar
      // notification sistema laikinai
      // nepavyksta.
      //
    }
  }
}