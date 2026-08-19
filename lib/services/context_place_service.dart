import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/context_place.dart';
import 'location_context_service.dart';

class ContextPlaceService {
  static const String _storageKey = 'context_places';

  static Future<List<ContextPlace>> loadPlaces() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      final places = <ContextPlace>[];
      for (final item in decoded) {
        try {
          places.add(
            ContextPlace.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        } catch (_) {
          // One damaged entry must not hide the remaining saved places.
        }
      }
      return places;
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePlaces(List<ContextPlace> places) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(places.map((place) => place.toJson()).toList()),
    );
    LocationContextService.clearDetectionCache();
  }
}
