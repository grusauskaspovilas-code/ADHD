import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_routine.dart';

class UserRoutineService {
  static const String _storageKey =
      'user_routine';

  static Future<UserRoutine> loadRoutine() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return const UserRoutine();
    }

    try {
      final data = jsonDecode(raw);

      if (data is! Map<String, dynamic>) {
        return const UserRoutine();
      }

      return UserRoutine.fromJson(data);
    } catch (_) {
      return const UserRoutine();
    }
  }

  static Future<void> saveRoutine(
    UserRoutine routine,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(
        routine.toJson(),
      ),
    );
  }

  static Future<void> clearRoutine() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}