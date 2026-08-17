import '../models/task.dart';

class TaskSelectorService {
  static Task? selectNextTask(
    List<Task> tasks, {
    int? availableMinutes,
  }) {
    var candidates = tasks
        .where((task) => !task.isCompleted)
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    // Jei nurodytas turimas laikas,
    // ieškome užduočių, kurios telpa.
    if (availableMinutes != null) {
      final fittingTasks = candidates.where((task) {
        final minutes = task.estimatedMinutes;

        if (minutes == null) {
          return false;
        }

        return minutes <= availableMinutes;
      }).toList();

      if (fittingTasks.isNotEmpty) {
        // Pirmiausia geriau išnaudojame turimą laiką.
        fittingTasks.sort((a, b) {
          final aMinutes =
              a.estimatedMinutes ?? 0;
          final bMinutes =
              b.estimatedMinutes ?? 0;

          final durationComparison =
              bMinutes.compareTo(aMinutes);

          if (durationComparison != 0) {
            return durationComparison;
          }

          // Jei trukmė vienoda,
          // renkamės svarbesnę.
          return _priorityScore(b.priority)
              .compareTo(
            _priorityScore(a.priority),
          );
        });

        return fittingTasks.first;
      }
    }

    // Jei laikas nenurodytas,
    // pirmiausia žiūrime prioritetą.
    candidates.sort((a, b) {
      final priorityComparison =
          _priorityScore(b.priority).compareTo(
        _priorityScore(a.priority),
      );

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // Jei prioritetas vienodas,
      // pirmiau užduotis su artimesniu terminu.
      final aDue = a.dueDate;
      final bDue = b.dueDate;

      if (aDue != null && bDue != null) {
        return aDue.compareTo(bDue);
      }

      if (aDue != null) {
        return -1;
      }

      if (bDue != null) {
        return 1;
      }

      return 0;
    });

    return candidates.first;
  }

  static int _priorityScore(
    TaskPriority priority,
  ) {
    switch (priority) {
      case TaskPriority.low:
        return 1;

      case TaskPriority.normal:
        return 2;

      case TaskPriority.high:
        return 3;

      case TaskPriority.urgent:
        return 4;
    }
  }
}