class Task {
  final String id;

  String title;
  String? description;

  DateTime createdAt;
  DateTime? dueDate;

  int? estimatedMinutes;

  TaskPriority priority;
  EnergyLevel energyLevel;

  bool isCompleted;

  //
  // Ar tai būtina užduotis, kurios
  // termino Guardian neturėtų leisti
  // pražiopsoti.
  //
  bool isRequired;

  //
  // Koks konkretus veiksmas reikalingas
  // šiai užduočiai atlikti.
  //
  TaskActionType actionType;

  //
  // Naudojamas, kai actionType ==
  // TaskActionType.phoneCall.
  //
  String? phoneNumber;

  //
  // Naudojamas, kai actionType ==
  // TaskActionType.email.
  //
  String? emailAddress;

  List<String> steps;

  TaskSource source;
  TaskType type;
  TaskPlaceRequirement placeRequirement;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.estimatedMinutes,
    this.priority = TaskPriority.normal,
    this.energyLevel = EnergyLevel.medium,
    this.isCompleted = false,
    this.isRequired = false,
    this.actionType = TaskActionType.none,
    this.phoneNumber,
    this.emailAddress,
    this.steps = const [],
    this.source = TaskSource.app,
    this.type = TaskType.task,
    this.placeRequirement = TaskPlaceRequirement.anywhere,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'priority': priority.name,
      'energyLevel': energyLevel.name,
      'isCompleted': isCompleted,
      'isRequired': isRequired,

      //
      // Veiksmo informacija.
      //
      'actionType': actionType.name,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,

      'steps': steps,
      'source': source.name,
      'type': type.name,
      'placeRequirement': placeRequirement.name,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      estimatedMinutes: json['estimatedMinutes'] as int?,

      priority: TaskPriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => TaskPriority.normal,
      ),

      energyLevel: EnergyLevel.values.firstWhere(
        (value) => value.name == json['energyLevel'],
        orElse: () => EnergyLevel.medium,
      ),

      isCompleted: json['isCompleted'] as bool? ?? false,

      //
      // Senos užduotys šio lauko
      // neturėjo.
      //
      isRequired: json['isRequired'] as bool? ?? false,

      //
      // Senos užduotys neturėjo
      // actionType, todėl jos lieka
      // paprastomis užduotimis.
      //
      actionType: TaskActionType.values.firstWhere(
        (value) => value.name == json['actionType'],
        orElse: () => TaskActionType.none,
      ),

      phoneNumber: json['phoneNumber'] as String?,

      emailAddress: json['emailAddress'] as String?,

      steps: List<String>.from(json['steps'] ?? []),

      source: TaskSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => TaskSource.app,
      ),

      type: TaskType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => TaskType.task,
      ),

      placeRequirement: TaskPlaceRequirement.values.firstWhere(
        (value) => value.name == json['placeRequirement'],
        orElse: () => TaskPlaceRequirement.anywhere,
      ),
    );
  }
}

enum TaskPriority { low, normal, high, urgent }

enum EnergyLevel { low, medium, high }

enum TaskSource { app, calendar }

enum TaskType { task, calendarEvent }

//
// Ką vartotojas turi padaryti,
// kad atliktų užduotį.
//
enum TaskActionType {
  //
  // Paprasta užduotis.
  //
  none,

  //
  // Reikia paskambinti.
  //
  phoneCall,

  //
  // Reikia parašyti / atsakyti
  // el. paštu.
  //
  email,
}

enum TaskPlaceRequirement { anywhere, home, work, school, childcare, other }
