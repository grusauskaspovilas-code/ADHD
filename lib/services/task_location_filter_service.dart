import '../models/context_place.dart';
import '../models/task.dart';

class TaskLocationFilterService {
  static List<Task> filterForPlace(
    List<Task> tasks,
    ContextPlace? currentPlace,
  ) {
    if (currentPlace == null) return tasks;

    final currentRequirement = _requirementFor(currentPlace.type);
    return tasks.where((task) {
      return task.isRequired ||
          task.placeRequirement == TaskPlaceRequirement.anywhere ||
          task.placeRequirement == currentRequirement;
    }).toList();
  }

  static TaskPlaceRequirement _requirementFor(ContextPlaceType type) {
    return switch (type) {
      ContextPlaceType.home => TaskPlaceRequirement.home,
      ContextPlaceType.work => TaskPlaceRequirement.work,
      ContextPlaceType.school => TaskPlaceRequirement.school,
      ContextPlaceType.childcare => TaskPlaceRequirement.childcare,
      ContextPlaceType.other => TaskPlaceRequirement.other,
    };
  }
}
