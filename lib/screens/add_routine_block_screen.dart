import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/user_routine.dart';


class AddRoutineBlockScreen extends StatefulWidget {
  final AppLanguage language;
  final RoutineBlock? existingBlock;

  const AddRoutineBlockScreen({
    super.key,
    required this.language,
    this.existingBlock,
  });

  @override
  State<AddRoutineBlockScreen> createState() =>
      _AddRoutineBlockScreenState();
}

class _AddRoutineBlockScreenState
    extends State<AddRoutineBlockScreen> {
  final _titleController =
      TextEditingController();

  final Set<int> _weekdays = {};

  int _startMinutes = 8 * 60;
  int _endMinutes = 17 * 60;
  
  @override
void initState() {
  super.initState();

  final block = widget.existingBlock;

  if (block != null) {
    _titleController.text = block.title;

    _weekdays.addAll(
      block.weekdays,
    );

    _startMinutes = block.startMinutes;
    _endMinutes = block.endMinutes;
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Pridėti reguliarų laiką';
      case AppLanguage.german:
        return 'Regelmäßige Zeit hinzufügen';
      default:
        return 'Add regular time';
    }
  }

  String get _nameText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Pavadinimas';
      case AppLanguage.german:
        return 'Bezeichnung';
      default:
        return 'Name';
    }
  }

  String get _nameHint {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Pvz. Darbas, sportas, mokslai';
      case AppLanguage.german:
        return 'Z. B. Arbeit, Sport, Studium';
      default:
        return 'E.g. Work, gym, study';
    }
  }

  String get _daysText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kuriomis dienomis?';
      case AppLanguage.german:
        return 'An welchen Tagen?';
      default:
        return 'Which days?';
    }
  }

  String get _timeText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Kada?';
      case AppLanguage.german:
        return 'Wann?';
      default:
        return 'When?';
    }
  }

  String get _startText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Pradžia';
      case AppLanguage.german:
        return 'Beginn';
      default:
        return 'Start';
    }
  }

  String get _endText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Pabaiga';
      case AppLanguage.german:
        return 'Ende';
      default:
        return 'End';
    }
  }

  String get _saveText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'IŠSAUGOTI';
      case AppLanguage.german:
        return 'SPEICHERN';
      default:
        return 'SAVE';
    }
  }

  List<String> get _dayNames {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return [
          'Pr',
          'An',
          'Tr',
          'Kt',
          'Pn',
          'Št',
          'Sk',
        ];
      case AppLanguage.german:
        return [
          'Mo',
          'Di',
          'Mi',
          'Do',
          'Fr',
          'Sa',
          'So',
        ];
      default:
        return [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ];
    }
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  Future<int?> _pickTime(
    int currentMinutes,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
    );

    if (selected == null) {
      return null;
    }

    return selected.hour * 60 +
        selected.minute;
  }

  Future<void> _changeStart() async {
    final minutes =
        await _pickTime(_startMinutes);

    if (minutes == null) return;

    setState(() {
      _startMinutes = minutes;
    });
  }

  Future<void> _changeEnd() async {
    final minutes =
        await _pickTime(_endMinutes);

    if (minutes == null) return;

    setState(() {
      _endMinutes = minutes;
    });
  }

  void _save() {
    final title =
        _titleController.text.trim();

    if (title.isEmpty ||
        _weekdays.isEmpty) {
      return;
    }

    final block = RoutineBlock(
     id: widget.existingBlock?.id ??
    DateTime.now()
        .microsecondsSinceEpoch
        .toString(),
      title: title,
      weekdays: _weekdays.toList()..sort(),
      startMinutes: _startMinutes,
      endMinutes: _endMinutes,
    );

    Navigator.pop(
      context,
      block,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = _dayNames;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: _nameText,
                hintText: _nameHint,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              _daysText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                7,
                (index) {
                  final weekday = index + 1;

                  return FilterChip(
                    label: Text(
                      dayNames[index],
                    ),
                    selected: _weekdays
                        .contains(weekday),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _weekdays.add(
                            weekday,
                          );
                        } else {
                          _weekdays.remove(
                            weekday,
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Text(
              _timeText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.play_arrow,
                ),
                title: Text(_startText),
                trailing: Text(
                  _formatTime(
                    _startMinutes,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _changeStart,
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.stop_outlined,
                ),
                title: Text(_endText),
                trailing: Text(
                  _formatTime(
                    _endMinutes,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _changeEnd,
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  _saveText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}