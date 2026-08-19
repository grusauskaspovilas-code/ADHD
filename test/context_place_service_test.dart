import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_assistant/models/context_place.dart';
import 'package:focus_assistant/services/context_place_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads context places', () async {
    const place = ContextPlace(
      id: 'work-1',
      type: ContextPlaceType.work,
      name: 'Office',
      address: 'Main Street 1',
    );

    await ContextPlaceService.savePlaces([place]);
    final loaded = await ContextPlaceService.loadPlaces();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, place.id);
    expect(loaded.single.type, ContextPlaceType.work);
    expect(loaded.single.address, place.address);
  });

  test('keeps valid places when one saved entry is damaged', () async {
    SharedPreferences.setMockInitialValues({
      'context_places':
          '[{"id":"home-1","type":"home","name":"Home","address":"A 1"},{"bad":true}]',
    });

    final loaded = await ContextPlaceService.loadPlaces();

    expect(loaded, hasLength(1));
    expect(loaded.single.type, ContextPlaceType.home);
  });

  test('editing a place preserves its identity', () {
    const place = ContextPlace(
      id: 'work-1',
      type: ContextPlaceType.work,
      name: 'Old office',
      address: 'Old address',
    );

    final edited = place.copyWith(
      type: ContextPlaceType.other,
      name: 'New office',
      address: 'New address',
    );

    expect(edited.id, place.id);
    expect(edited.type, ContextPlaceType.other);
    expect(edited.name, 'New office');
    expect(edited.address, 'New address');
  });
}
