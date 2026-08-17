import 'package:flutter/material.dart';

import '../models/task.dart';
import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import '../services/ai_task_estimate_service.dart';

class AddTaskScreen extends StatefulWidget {
  final AppLanguage language;

  const AddTaskScreen({
    super.key,
    required this.language,
  });

  @override
  State<AddTaskScreen> createState() =>
      _AddTaskScreenState();
}

class _AddTaskScreenState
    extends State<AddTaskScreen> {
  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();
	  
	  final _phoneController =
    TextEditingController();

final _emailController =
    TextEditingController();

TaskActionType _actionType =
    TaskActionType.none;
    

  DateTime? _dueDate;
  int? _estimatedMinutes;

  bool _isRequired = false;
  bool _isEstimatingDuration = false;

 @override
void dispose() {
  _titleController.dispose();
  _descriptionController.dispose();
  _phoneController.dispose();
  _emailController.dispose();
  super.dispose();
}

  Future<void> _estimateDurationWithAi() async {
    final title =
        _titleController.text.trim();

    if (title.isEmpty) {
      final strings =
          AppStrings(widget.language);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            strings.enterTask,
          ),
        ),
      );

      return;
    }

    setState(() {
      _isEstimatingDuration = true;
    });

    final description =
        _descriptionController.text.trim();
		
		

    final minutes =
        await AiTaskEstimateService
            .estimateDuration(
      title: title,
      description: description.isEmpty
          ? null
          : description,
      language: widget.language,
    );

    if (!mounted) return;

    setState(() {
      _isEstimatingDuration = false;

      if (minutes != null) {
        _estimatedMinutes = minutes;
      }
    });
  }

  String get _importanceTitle {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kokia tai užduotis?';

      case AppLanguage.german:
        return 'Was für eine Aufgabe ist das?';

      default:
        return 'What kind of task is this?';
    }
  }

  String get _flexibleTaskText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kai turėsiu laiko';

      case AppLanguage.german:
        return 'Wenn ich Zeit habe';

      default:
        return 'When I have time';
    }
  }

  String get _flexibleTaskDescription {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'AI pasiūlys, kai paprašysi.';

      case AppLanguage.german:
        return 'KI schlägt sie vor, wenn du fragst.';

      default:
        return 'AI will suggest it when you ask.';
    }
  }

  String get _requiredTaskText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Būtina padaryti';

      case AppLanguage.german:
        return 'Muss erledigt werden';

      default:
        return 'Must be done';
    }
  }

  String get _requiredTaskDescription {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Svarbus terminas. Neleisk jo pražiopsoti.';

      case AppLanguage.german:
        return 'Wichtige Frist. Nicht verpassen.';

      default:
        return 'Important deadline. Do not let me miss it.';
    }
  }

  String get _requiredDeadlineMessage {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Būtinai užduočiai pasirink terminą.';

      case AppLanguage.german:
        return 'Für eine notwendige Aufgabe muss eine Frist festgelegt werden.';

      default:
        return 'Choose a deadline for a required task.';
    }
  }

  String get _whenTitle {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Wann muss es erledigt sein?';

      case AppLanguage.lithuanian:
        return 'Kada reikia padaryti?';

      default:
        return 'When does it need to be done?';
    }
  }

  String get _todayText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Heute';

      case AppLanguage.lithuanian:
        return 'Šiandien';

      default:
        return 'Today';
    }
  }

  String get _tomorrowText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Morgen';

      case AppLanguage.lithuanian:
        return 'Rytoj';

      default:
        return 'Tomorrow';
    }
  }

  String get _pickDateText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Datum wählen';

      case AppLanguage.lithuanian:
        return 'Pasirinkti datą';

      default:
        return 'Pick date';
    }
  }

  String get _noDeadlineText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Kein Termin';

      case AppLanguage.lithuanian:
        return 'Nėra termino';

      default:
        return 'No deadline';
    }
  }

  String get _suggestWithAiText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Mit KI vorschlagen';

      case AppLanguage.lithuanian:
        return 'Pasiūlyti su AI';

      default:
        return 'Suggest with AI';
    }
  }

  String get _aiThinkingText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'KI...';

      case AppLanguage.lithuanian:
        return 'AI...';

      default:
        return 'AI...';
    }
  }

  String get _durationTitle {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Wie lange könnte es dauern?';

      case AppLanguage.lithuanian:
        return 'Kiek maždaug užtruks?';

      default:
        return 'How long might it take?';
    }
  }

  String get _notSureText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Weiß nicht';

      case AppLanguage.lithuanian:
        return 'Nežinau';

      default:
        return 'Not sure';
    }
  }

  String get _oneHourText {
    switch (widget.language) {
      case AppLanguage.german:
        return '1 Std.';

      case AppLanguage.lithuanian:
        return '1 val.';

      default:
        return '1 hour';
    }
  }
  
  String get _pickTimeText {
  switch (widget.language) {
    case AppLanguage.german:
      return 'Uhrzeit wählen';
    case AppLanguage.lithuanian:
      return 'Pasirinkti laiką';
    default:
      return 'Pick time';
  }
}

  String get _addText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'AUFGABE HINZUFÜGEN';

      case AppLanguage.lithuanian:
        return 'PRIDĖTI UŽDUOTĮ';

      default:
        return 'ADD TASK';
    }
  }
  
  String get _actionTitle {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Ką reikės padaryti?';
    case AppLanguage.german:
      return 'Was musst du tun?';
    default:
      return 'What do you need to do?';
  }
}

String get _normalActionText {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Paprasta užduotis';
    case AppLanguage.german:
      return 'Normale Aufgabe';
    default:
      return 'Regular task';
  }
}

String get _callActionText {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Paskambinti';
    case AppLanguage.german:
      return 'Anrufen';
    default:
      return 'Make a call';
  }
}

String get _emailActionText {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Parašyti / atsakyti el. paštu';
    case AppLanguage.german:
      return 'E-Mail schreiben / beantworten';
    default:
      return 'Write / reply by email';
  }
}

String get _phoneLabel {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Telefono numeris';
    case AppLanguage.german:
      return 'Telefonnummer';
    default:
      return 'Phone number';
  }
}

String get _emailLabel {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'El. pašto adresas';
    case AppLanguage.german:
      return 'E-Mail-Adresse';
    default:
      return 'Email address';
  }
}

String get _phoneRequiredMessage {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Įvesk telefono numerį.';
    case AppLanguage.german:
      return 'Bitte Telefonnummer eingeben.';
    default:
      return 'Enter a phone number.';
  }
}

String get _emailRequiredMessage {
  switch (widget.language) {
    case AppLanguage.lithuanian:
      return 'Įvesk el. pašto adresą.';
    case AppLanguage.german:
      return 'Bitte E-Mail-Adresse eingeben.';
    default:
      return 'Enter an email address.';
  }
}
  
  Future<void> _pickDueTime() async {
  if (_dueDate == null) {
    await _pickDate();

    if (_dueDate == null) {
      return;
    }
  }

  if (!mounted) return;

  final currentDueDate = _dueDate!;

  final selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: currentDueDate.hour,
      minute: currentDueDate.minute,
    ),
  );

  if (selectedTime == null) {
    return;
  }

  setState(() {
    _dueDate = DateTime(
      currentDueDate.year,
      currentDueDate.month,
      currentDueDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  });
}

Future<void> _showDurationPicker() async {
  final selected =
      await showModalBottomSheet<int?>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _durationTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DurationButton(
                    text: '5 min',
                    minutes: 5,
                  ),
                  _DurationButton(
                    text: '15 min',
                    minutes: 15,
                  ),
                  _DurationButton(
                    text: '30 min',
                    minutes: 30,
                  ),
                  _DurationButton(
                    text: _oneHourText,
                    minutes: 60,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      -1,
                    );
                  },
                  icon: const Icon(
                    Icons.auto_awesome,
                  ),
                  label: Text(
                    _suggestWithAiText,
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      0,
                    );
                  },
                  child: Text(
                    _notSureText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!mounted || selected == null) {
    return;
  }

  //
  // AI pats įvertina trukmę.
  //
  if (selected == -1) {
    await _estimateDurationWithAi();
    return;
  }

  setState(() {
    if (selected == 0) {
      _estimatedMinutes = null;
    } else {
      _estimatedMinutes = selected;
    }
  });
}

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final selectedDate =
        await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(
        now.year + 5,
        12,
        31,
      ),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      //
      // Kol kas pasirinktos dienos
      // terminas = tos dienos pabaiga.
      //
      _dueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
      );
    });
  }

  void _selectToday() {
    final now = DateTime.now();

    setState(() {
      _dueDate = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
      );
    });
  }

  void _selectTomorrow() {
    final tomorrow = DateTime.now().add(
      const Duration(days: 1),
    );

    setState(() {
      _dueDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        23,
        59,
      );
    });
  }

  void _removeDeadline() {
    //
    // Būtinai užduočiai termino
    // nuimti neleidžiame.
    //
    if (_isRequired) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _requiredDeadlineMessage,
          ),
        ),
      );

      return;
    }

    setState(() {
      _dueDate = null;
    });
  }
  
  Future<void> _selectRequired(
  bool required,
) async {
  setState(() {
    _isRequired = required;
  });

  if (!required) {
    return;
  }

  //
  // 1. Pasirenkame termino datą.
  //
  if (_dueDate == null) {
    await _pickDate();

    if (_dueDate == null || !mounted) {
      return;
    }
  }

  //
  // 2. Pasirenkame tikslų termino laiką.
  //
  await _pickDueTime();

  if (!mounted) {
    return;
  }

  //
  // 3. Pasirenkame, kiek maždaug
  // užduotis užtruks.
  //
  await _showDurationPicker();
}

  TaskPriority _calculatePriority() {
    if (_dueDate == null) {
      return TaskPriority.normal;
    }

    final difference =
        _dueDate!.difference(
      DateTime.now(),
    );

    if (difference.inHours <= 24) {
      return TaskPriority.urgent;
    }

    if (difference.inDays <= 3) {
      return TaskPriority.high;
    }

    return TaskPriority.normal;
  }

  void _saveTask() {
    final strings =
        AppStrings(widget.language);

    final title =
        _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            strings.enterTask,
          ),
        ),
      );

      return;
    }
	
	  final phoneNumber =
      _phoneController.text.trim();

  final emailAddress =
      _emailController.text.trim();

  if (_actionType ==
          TaskActionType.phoneCall &&
      phoneNumber.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          _phoneRequiredMessage,
        ),
      ),
    );

    return;
  }

  if (_actionType ==
          TaskActionType.email &&
      emailAddress.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          _emailRequiredMessage,
        ),
      ),
    );

    return;
  }

    //
    // Guardian ateityje galės saugoti
    // tik užduotį su konkrečiu terminu.
    //
    if (_isRequired &&
        _dueDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _requiredDeadlineMessage,
          ),
        ),
      );

      return;
    }

    final description =
        _descriptionController.text.trim();

    final task = Task(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      title: title,
      description: description.isEmpty
          ? null
          : description,
      createdAt: DateTime.now(),
      dueDate: _dueDate,
      estimatedMinutes:
          _estimatedMinutes,
      priority: _calculatePriority(),
      energyLevel:
          EnergyLevel.medium,
      isRequired: _isRequired,
	  actionType: _actionType,

phoneNumber:
    _actionType ==
            TaskActionType.phoneCall
        ? phoneNumber
        : null,

emailAddress:
    _actionType ==
            TaskActionType.email
        ? emailAddress
        : null,
    );

    Navigator.pop(
      context,
      task,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        AppStrings(widget.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.addTask,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(24),
          children: [
            Text(
              strings.whatDoYouNeedToDo,
              style: const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  _titleController,
              autofocus: true,
              textInputAction:
                  TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.task,
                hintText:
                    strings.taskExample,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller:
                  _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: strings.notes,
                hintText:
                    strings.optional,
                border:
                    const OutlineInputBorder(),
              ),
            ),
const SizedBox(height: 28),

Text(
  _actionTitle,
  style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    ChoiceChip(
      avatar: const Icon(
        Icons.check_circle_outline,
        size: 18,
      ),
      label: Text(
        _normalActionText,
      ),
      selected:
          _actionType ==
              TaskActionType.none,
      onSelected: (_) {
        setState(() {
          _actionType =
              TaskActionType.none;
        });
      },
    ),

    ChoiceChip(
      avatar: const Icon(
        Icons.phone_outlined,
        size: 18,
      ),
      label: Text(
        _callActionText,
      ),
      selected:
          _actionType ==
              TaskActionType.phoneCall,
      onSelected: (_) {
        setState(() {
          _actionType =
              TaskActionType.phoneCall;
        });
      },
    ),

    ChoiceChip(
      avatar: const Icon(
        Icons.email_outlined,
        size: 18,
      ),
      label: Text(
        _emailActionText,
      ),
      selected:
          _actionType ==
              TaskActionType.email,
      onSelected: (_) {
        setState(() {
          _actionType =
              TaskActionType.email;
        });
      },
    ),
  ],
),

//
// Telefono numeris rodomas tik
// skambučio užduočiai.
//
if (_actionType ==
    TaskActionType.phoneCall) ...[
  const SizedBox(height: 16),

  TextField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    textInputAction:
        TextInputAction.next,
    autofillHints: const [
      AutofillHints.telephoneNumber,
    ],
    decoration: InputDecoration(
      labelText: _phoneLabel,
      prefixIcon: const Icon(
        Icons.phone_outlined,
      ),
      border:
          const OutlineInputBorder(),
    ),
  ),
],

//
// El. paštas rodomas tik
// email užduočiai.
//
if (_actionType ==
    TaskActionType.email) ...[
  const SizedBox(height: 16),

  TextField(
    controller: _emailController,
    keyboardType:
        TextInputType.emailAddress,
    textInputAction:
        TextInputAction.next,
    autofillHints: const [
      AutofillHints.email,
    ],
    decoration: InputDecoration(
      labelText: _emailLabel,
      prefixIcon: const Icon(
        Icons.email_outlined,
      ),
      border:
          const OutlineInputBorder(),
    ),
  ),
],

const SizedBox(height: 28),

//
// Užduoties svarbos tipas.
//
Text(
  _importanceTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: RadioListTile<bool>(
                value: false,
                groupValue: _isRequired,
                onChanged: (value) {
                  if (value != null) {
                    _selectRequired(
                      value,
                    );
                  }
                },
                secondary: const Icon(
                  Icons
                      .lightbulb_outline,
                ),
                title: Text(
                  _flexibleTaskText,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _flexibleTaskDescription,
                ),
              ),
            ),

            Card(
              child: RadioListTile<bool>(
                value: true,
                groupValue: _isRequired,
                onChanged: (value) {
                  if (value != null) {
                    _selectRequired(
                      value,
                    );
                  }
                },
                secondary: const Icon(
                  Icons
                      .notification_important_outlined,
                ),
                title: Text(
                  _requiredTaskText,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _requiredTaskDescription,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              _whenTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(
                    Icons.today,
                    size: 18,
                  ),
                  label:
                      Text(_todayText),
                  onPressed:
                      _selectToday,
                ),

                ActionChip(
                  label:
                      Text(_tomorrowText),
                  onPressed:
                      _selectTomorrow,
                ),

                ActionChip(
                  avatar: const Icon(
                    Icons.calendar_month,
                    size: 18,
                  ),
                  label: Text(
                    _pickDateText,
                  ),
                  onPressed:
                      _pickDate,
                ),

                ActionChip(
                  label: Text(
                    _noDeadlineText,
                  ),
                  onPressed:
                      _removeDeadline,
                ),
              ],
            ),
if (_dueDate != null) ...[
  const SizedBox(height: 12),

  Row(
    children: [
      const Icon(
        Icons.event_available,
        size: 20,
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          '${_dueDate!.day.toString().padLeft(2, '0')}.'
          '${_dueDate!.month.toString().padLeft(2, '0')}.'
          '${_dueDate!.year} · '
          '${_dueDate!.hour.toString().padLeft(2, '0')}:'
          '${_dueDate!.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      TextButton.icon(
        onPressed: _pickDueTime,
        icon: const Icon(
          Icons.schedule,
          size: 18,
        ),
        label: Text(
          _pickTimeText,
        ),
      ),

      if (_isRequired)
        const Icon(
          Icons.notification_important_outlined,
          size: 18,
        ),
    ],
  ),
],

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _durationTitle,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed:
                      _isEstimatingDuration
                          ? null
                          : _estimateDurationWithAi,
                  icon:
                      _isEstimatingDuration
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .auto_awesome,
                              size: 18,
                            ),
                  label: Text(
                    _isEstimatingDuration
                        ? _aiThinkingText
                        : _suggestWithAiText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label:
                      const Text('5 min'),
                  selected:
                      _estimatedMinutes ==
                          5,
                  onSelected: (_) {
                    setState(() {
                      _estimatedMinutes =
                          5;
                    });
                  },
                ),

                ChoiceChip(
                  label:
                      const Text('15 min'),
                  selected:
                      _estimatedMinutes ==
                          15,
                  onSelected: (_) {
                    setState(() {
                      _estimatedMinutes =
                          15;
                    });
                  },
                ),

                ChoiceChip(
                  label:
                      const Text('30 min'),
                  selected:
                      _estimatedMinutes ==
                          30,
                  onSelected: (_) {
                    setState(() {
                      _estimatedMinutes =
                          30;
                    });
                  },
                ),

                ChoiceChip(
                  label:
                      Text(_oneHourText),
                  selected:
                      _estimatedMinutes ==
                          60,
                  onSelected: (_) {
                    setState(() {
                      _estimatedMinutes =
                          60;
                    });
                  },
                ),

                ChoiceChip(
                  label:
                      Text(_notSureText),
                  selected:
                      _estimatedMinutes ==
                          null,
                  onSelected: (_) {
                    setState(() {
                      _estimatedMinutes =
                          null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: _saveTask,
                icon: const Icon(
                  Icons.add_task,
                ),
                label: Text(
                  _addText,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  
}
class _DurationButton extends StatelessWidget {
  final String text;
  final int minutes;

  const _DurationButton({
    required this.text,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        Navigator.pop(
          context,
          minutes,
        );
      },
    );
  }
}