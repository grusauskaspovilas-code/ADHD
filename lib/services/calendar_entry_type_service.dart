import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class CalendarEntryTypeService {
  static const String _key = 'calendar_entry_types';

  static Future<Map<String, TaskType>> _loadAll() async {
    final preferences =
        await SharedPreferences.getInstance();

    final saved = preferences.getString(_key);

    if (saved == null || saved.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(
        jsonDecode(saved),
      );

      final result = <String, TaskType>{};

      decoded.forEach((id, value) {
        result[id] = TaskType.values.firstWhere(
          (type) => type.name == value,
          orElse: () => TaskType.calendarEvent,
        );
      });

      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<TaskType> getType(
    String id,
  ) async {
    final types = await _loadAll();

    return types[id] ??
        TaskType.calendarEvent;
  }

  static Future<void> setType(
    String id,
    TaskType type,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final types = await _loadAll();

    types[id] = type;

    final encoded = jsonEncode(
      types.map(
        (key, value) => MapEntry(
          key,
          value.name,
        ),
      ),
    );

    await preferences.setString(
      _key,
      encoded,
    );
  }

  static String createCalendarId({
    required String title,
    required DateTime startDate,
  }) {
    final normalizedTitle = title
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    return 'calendar_'
        '${startDate.millisecondsSinceEpoch}_'
        '${normalizedTitle.hashCode}';
  }
}