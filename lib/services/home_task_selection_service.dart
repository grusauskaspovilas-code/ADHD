import '../models/ai_context.dart';
import '../models/task.dart';
import 'ai_service.dart';
import 'task_selector_service.dart';

class HomeTaskSelectionService {
  static Future<Task?> selectTask({
    required AiContext context,
    bool ignoreBusyState = false,
    int? availableMinutesOverride,
  }) async {
    if (context.tasks.isEmpty) {
      return null;
    }

    if (context.currentlyBusy &&
        !ignoreBusyState) {
      return null;
    }

    final availableMinutes =
        availableMinutesOverride ??
            context.freeMinutesNow;

    try {
      final aiTask =
          await AIService.selectBestTask(
        tasks: context.tasks,
        availableMinutes: availableMinutes,
      );

      if (aiTask != null) {
        return aiTask;
      }
    } catch (_) {
      // Jei AI, internetas ar serveris
      // neveikia, naudojame vietinę logiką.
    }

    return TaskSelectorService.selectNextTask(
      context.tasks,
      availableMinutes: availableMinutes,
    );
  }
}