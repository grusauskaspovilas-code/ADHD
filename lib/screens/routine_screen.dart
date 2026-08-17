import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/user_routine.dart';
import '../services/user_routine_service.dart';
import 'add_routine_block_screen.dart';

class RoutineScreen extends StatefulWidget {
  final AppLanguage language;

  const RoutineScreen({
    super.key,
    required this.language,
  });

  @override
  State<RoutineScreen> createState() =>
      _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  UserRoutine _routine = const UserRoutine();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    final routine =
        await UserRoutineService.loadRoutine();

    if (!mounted) return;

    setState(() {
      _routine = routine;
      _isLoading = false;
    });
  }

  String get _title {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Mano rutina';
      case AppLanguage.german:
        return 'Meine Routine';
      default:
        return 'My routine';
    }
  }

  String get _subtitle {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Padėk programėlei suprasti tavo įprastą dieną.';
      case AppLanguage.german:
        return 'Hilf der App, deinen normalen Tagesablauf zu verstehen.';
      default:
        return 'Help the app understand your usual day.';
    }
  }

  String get _wakeUpText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Keliuosi';
      case AppLanguage.german:
        return 'Aufstehen';
      default:
        return 'Wake up';
    }
  }

  String get _sleepText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Einu miegoti';
      case AppLanguage.german:
        return 'Schlafenszeit';
      default:
        return 'Bedtime';
    }
  }

  String get _notSetText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Nenustatyta';
      case AppLanguage.german:
        return 'Nicht festgelegt';
      default:
        return 'Not set';
    }
  }

  String get _addRegularTimeText {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'PRIDĖTI REGULIARŲ LAIKĄ';
      case AppLanguage.german:
        return 'REGELMÄSSIGE ZEIT HINZUFÜGEN';
      default:
        return 'ADD REGULAR TIME';
    }
  }

  String _formatMinutes(int? minutes) {
    if (minutes == null) {
      return _notSetText;
    }

    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String _formatWeekdays(
    List<int> weekdays,
  ) {
    final names = switch (widget.language) {
      AppLanguage.lithuanian => [
          'Pr',
          'An',
          'Tr',
          'Kt',
          'Pn',
          'Št',
          'Sk',
        ],
      AppLanguage.german => [
          'Mo',
          'Di',
          'Mi',
          'Do',
          'Fr',
          'Sa',
          'So',
        ],
      _ => [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ],
    };

    return weekdays
        .where(
          (day) => day >= 1 && day <= 7,
        )
        .map(
          (day) => names[day - 1],
        )
        .join(', ');
  }

  Future<int?> _pickTime(
    int? currentMinutes,
  ) async {
    final initialTime = currentMinutes == null
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: currentMinutes ~/ 60,
            minute: currentMinutes % 60,
          );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time == null) {
      return null;
    }

    return time.hour * 60 + time.minute;
  }

  Future<void> _changeWakeUp() async {
    final minutes = await _pickTime(
      _routine.wakeUpMinutes,
    );

    if (minutes == null) return;

    final updated = UserRoutine(
      wakeUpMinutes: minutes,
      sleepStartMinutes:
          _routine.sleepStartMinutes,
      blocks: _routine.blocks,
    );

    await UserRoutineService.saveRoutine(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _routine = updated;
    });
  }

  Future<void> _changeSleep() async {
    final minutes = await _pickTime(
      _routine.sleepStartMinutes,
    );

    if (minutes == null) return;

    final updated = UserRoutine(
      wakeUpMinutes:
          _routine.wakeUpMinutes,
      sleepStartMinutes: minutes,
      blocks: _routine.blocks,
    );

    await UserRoutineService.saveRoutine(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _routine = updated;
    });
  }

  Future<void> _addRoutineBlock() async {
    final block =
        await Navigator.push<RoutineBlock>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRoutineBlockScreen(
          language: widget.language,
        ),
      ),
    );

    if (block == null || !mounted) {
      return;
    }

    final updated = UserRoutine(
      wakeUpMinutes:
          _routine.wakeUpMinutes,
      sleepStartMinutes:
          _routine.sleepStartMinutes,
      blocks: [
        ..._routine.blocks,
        block,
      ],
    );

    await UserRoutineService.saveRoutine(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _routine = updated;
    });
  }

  Future<void> _editRoutineBlock(
    RoutineBlock block,
  ) async {
    final updatedBlock =
        await Navigator.push<RoutineBlock>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRoutineBlockScreen(
          language: widget.language,
          existingBlock: block,
        ),
      ),
    );

    if (updatedBlock == null || !mounted) {
      return;
    }

    final updatedBlocks = _routine.blocks
        .map(
          (item) =>
              item.id == updatedBlock.id
                  ? updatedBlock
                  : item,
        )
        .toList();

    final updatedRoutine = UserRoutine(
      wakeUpMinutes:
          _routine.wakeUpMinutes,
      sleepStartMinutes:
          _routine.sleepStartMinutes,
      blocks: updatedBlocks,
    );

    await UserRoutineService.saveRoutine(
      updatedRoutine,
    );

    if (!mounted) return;

    setState(() {
      _routine = updatedRoutine;
    });
  }

  Future<void> _deleteRoutineBlock(
    RoutineBlock block,
  ) async {
    final updatedBlocks = _routine.blocks
        .where(
          (item) => item.id != block.id,
        )
        .toList();

    final updatedRoutine = UserRoutine(
      wakeUpMinutes:
          _routine.wakeUpMinutes,
      sleepStartMinutes:
          _routine.sleepStartMinutes,
      blocks: updatedBlocks,
    );

    await UserRoutineService.saveRoutine(
      updatedRoutine,
    );

    if (!mounted) return;

    setState(() {
      _routine = updatedRoutine;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : ListView(
                padding:
                    const EdgeInsets.all(24),
                children: [
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Kėlimosi laikas
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.wb_sunny_outlined,
                      ),
                      title: Text(
                        _wakeUpText,
                      ),
                      subtitle: Text(
                        _formatMinutes(
                          _routine
                              .wakeUpMinutes,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: _changeWakeUp,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Miego laikas
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.bedtime_outlined,
                      ),
                      title: Text(
                        _sleepText,
                      ),
                      subtitle: Text(
                        _formatMinutes(
                          _routine
                              .sleepStartMinutes,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: _changeSleep,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Pridėti reguliarų laiką
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed:
                          _addRoutineBlock,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: Text(
                        _addRegularTimeText,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Rutinos blokai
                  if (_routine
                      .blocks.isNotEmpty) ...[
                    const SizedBox(height: 28),

                    ..._routine.blocks.map(
                      (block) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons
                                .event_repeat_outlined,
                          ),
                          title: Text(
                            block.title,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatWeekdays(block.weekdays)}'
                            ' · '
                            '${_formatMinutes(block.startMinutes)}'
                            '–'
                            '${_formatMinutes(block.endMinutes)}',
                          ),

                          // Paspaudus kortelę –
                          // redaguojame.
                          onTap: () {
                            _editRoutineBlock(
                              block,
                            );
                          },

                          // Šiukšliadėžė –
                          // ištriname bloką.
                          trailing: IconButton(
                            icon: const Icon(
                              Icons
                                  .delete_outline,
                            ),
                            onPressed: () {
                              _deleteRoutineBlock(
                                block,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}