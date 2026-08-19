import 'package:flutter_test/flutter_test.dart';

import 'package:focus_assistant/models/context_place.dart';
import 'package:focus_assistant/models/task.dart';
import 'package:focus_assistant/services/task_location_filter_service.dart';

void main() {
  Task task(String id, TaskPlaceRequirement place, {bool isRequired = false}) {
    return Task(
      id: id,
      title: id,
      createdAt: DateTime(2026, 8, 19),
      placeRequirement: place,
      isRequired: isRequired,
    );
  }

  const work = ContextPlace(
    id: 'work',
    type: ContextPlaceType.work,
    name: 'Office',
    address: 'Main Street 1',
  );

  test('keeps anywhere and work tasks while at work', () {
    final tasks = [
      task('anywhere', TaskPlaceRequirement.anywhere),
      task('work-task', TaskPlaceRequirement.work),
      task('home-task', TaskPlaceRequirement.home),
    ];

    final filtered = TaskLocationFilterService.filterForPlace(tasks, work);

    expect(filtered.map((task) => task.id), ['anywhere', 'work-task']);
  });

  test('required task bypasses a location mismatch', () {
    final tasks = [
      task('required-home', TaskPlaceRequirement.home, isRequired: true),
    ];

    final filtered = TaskLocationFilterService.filterForPlace(tasks, work);

    expect(filtered.single.id, 'required-home');
  });

  test('does not filter when current place is unknown', () {
    final tasks = [task('home-task', TaskPlaceRequirement.home)];

    final filtered = TaskLocationFilterService.filterForPlace(tasks, null);

    expect(filtered, same(tasks));
  });
}
