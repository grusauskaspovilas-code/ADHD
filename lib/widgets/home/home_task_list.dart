import 'package:flutter/material.dart';

import '../../models/task.dart';

class HomeTaskList extends StatelessWidget {
  final List<Task> tasks;
  final String Function(DateTime?) formatDueDate;
  final String Function(int?) formatDuration;
  final Future<void> Function(Task, bool?) onToggleTask;
  final Future<void> Function(Task) onDeleteTask;
  final Future<void> Function(Task) onEditTask;
  final Future<void> Function(Task) onOpenTask;

  const HomeTaskList({
    super.key,
    required this.tasks,
    required this.formatDueDate,
    required this.formatDuration,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
    required this.onOpenTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 6);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];

        final isCalendar = task.source == TaskSource.calendar;

        final isCalendarTask = isCalendar && task.type == TaskType.task;

        return Card(
          child: ListTile(
            onTap: () {
              onOpenTask(task);
            },

            leading: isCalendar
                ? isCalendarTask
                      ? Checkbox(
                          value: false,
                          onChanged: (value) {
                            onToggleTask(task, value);
                          },
                        )
                      : const Icon(Icons.calendar_month_outlined, size: 28)
                : Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      onToggleTask(task, value);
                    },
                  ),

            title: Text(
              task.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(formatDueDate(task.dueDate)),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      Text(formatDuration(task.estimatedMinutes)),
                    ],
                  ),
                ],
              ),
            ),

            trailing: isCalendar
                ? const Icon(Icons.lock_outline, size: 20)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          onEditTask(task);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          onDeleteTask(task);
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
