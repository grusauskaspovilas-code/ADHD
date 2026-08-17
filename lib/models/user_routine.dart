class RoutineBlock {
  final String id;
  final String title;

  // 1 = pirmadienis, 7 = sekmadienis.
  final List<int> weekdays;

  // Minutės nuo vidurnakčio.
  // Pvz. 08:30 = 510.
  final int startMinutes;
  final int endMinutes;

  const RoutineBlock({
    required this.id,
    required this.title,
    required this.weekdays,
    required this.startMinutes,
    required this.endMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    };
  }

  factory RoutineBlock.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoutineBlock(
      id: json['id'] as String,
      title: json['title'] as String,
      weekdays: List<int>.from(
        json['weekdays'] as List,
      ),
      startMinutes:
          json['startMinutes'] as int,
      endMinutes:
          json['endMinutes'] as int,
    );
  }
}

class UserRoutine {
  final int? sleepStartMinutes;
  final int? wakeUpMinutes;

  final List<RoutineBlock> blocks;

  const UserRoutine({
    this.sleepStartMinutes,
    this.wakeUpMinutes,
    this.blocks = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'sleepStartMinutes':
          sleepStartMinutes,
      'wakeUpMinutes':
          wakeUpMinutes,
      'blocks': blocks
          .map((block) => block.toJson())
          .toList(),
    };
  }

  factory UserRoutine.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawBlocks =
        json['blocks'] as List? ?? [];

    return UserRoutine(
      sleepStartMinutes:
          json['sleepStartMinutes'] as int?,
      wakeUpMinutes:
          json['wakeUpMinutes'] as int?,
      blocks: rawBlocks
          .map(
            (item) => RoutineBlock.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList(),
    );
  }
}