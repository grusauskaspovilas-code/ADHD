import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/task.dart';
import '../services/ai_stuck_service.dart';

import 'focus_timer_screen.dart';
import 'breakdown_screen.dart';

class StuckScreen extends StatefulWidget {
  final Task task;
  final AppLanguage language;

  const StuckScreen({
    super.key,
    required this.task,
    required this.language,
  });

  @override
  State<StuckScreen> createState() =>
      _StuckScreenState();
}

class _StuckScreenState extends State<StuckScreen> {
  String? _aiStep;
  bool _isLoadingStep = true;

  Task get task => widget.task;
  AppLanguage get language => widget.language;

  @override
  void initState() {
    super.initState();
    _loadAiStep();
  }

  Future<void> _loadAiStep() async {
    final step =
        await AiStuckService.generateFirstStep(
      task: task,
      language: language,
    );

    if (!mounted) return;

    setState(() {
      _aiStep = step;
      _isLoadingStep = false;
    });
  }

  String get _title {
    switch (language) {
      case AppLanguage.german:
        return 'Okay. Machen wir es kleiner.';
      case AppLanguage.lithuanian:
        return 'Gerai. Supaprastinkime.';
      default:
        return "Okay. Let's make it smaller.";
    }
  }

  String get _subtitle {
    switch (language) {
      case AppLanguage.german:
        return 'Du musst nicht die ganze Aufgabe erledigen.';
      case AppLanguage.lithuanian:
        return 'Tau nereikia dabar atlikti visos užduoties.';
      default:
        return "You don't need to finish the whole task right now.";
    }
  }

  String get _question {
    switch (language) {
      case AppLanguage.german:
        return 'Mach nur einen winzigen Schritt:';
      case AppLanguage.lithuanian:
        return 'Padaryk tik vieną mažą žingsnį:';
      default:
        return 'Do just one tiny step:';
    }
  }

  String get _fallbackStep {
    switch (language) {
      case AppLanguage.german:
        return 'Öffne einfach das, was du für diese Aufgabe brauchst.';
      case AppLanguage.lithuanian:
        return 'Tiesiog atsidaryk tai, ko reikia šiai užduočiai pradėti.';
      default:
        return 'Just open what you need to begin this task.';
    }
  }

  String get _thinkingText {
    switch (language) {
      case AppLanguage.german:
        return 'Ich suche einen kleinen ersten Schritt...';
      case AppLanguage.lithuanian:
        return 'Ieškau mažo pirmo žingsnio...';
      default:
        return 'Finding a small first step...';
    }
  }

  String get _twoMinutes {
    switch (language) {
      case AppLanguage.german:
        return 'NUR 2 MINUTEN STARTEN';
      case AppLanguage.lithuanian:
        return 'PRADĖTI TIK 2 MINUTĖMS';
      default:
        return 'START FOR JUST 2 MINUTES';
    }
  }

  String get _breakDown {
    switch (language) {
      case AppLanguage.german:
        return 'AUFGABE WEITER AUFTEILEN';
      case AppLanguage.lithuanian:
        return 'DAR LABIAU SUSKAIDYTI';
      default:
        return 'BREAK IT DOWN MORE';
    }
  }

  String get _notNow {
    switch (language) {
      case AppLanguage.german:
        return 'Nicht jetzt';
      case AppLanguage.lithuanian:
        return 'Ne dabar';
      default:
        return 'Not now';
    }
  }

  Future<void> _startTwoMinutes() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FocusTimerScreen(
          task: task,
          language: language,
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'finished') {
      Navigator.pop(
        context,
        'timerFinished',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedStep =
        _aiStep ?? _fallbackStep;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.spa_outlined,
                size: 72,
              ),

              const SizedBox(height: 24),

              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      task.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_isLoadingStep) ...[
                      const SizedBox(height: 6),

                      const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _thinkingText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ] else
                      Text(
                        displayedStep,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: _isLoadingStep
                      ? null
                      : _startTwoMinutes,
                  icon: const Icon(
                    Icons.timer_outlined,
                  ),
                  label: Text(
                    _twoMinutes,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BreakdownScreen(
                          task: task,
                          language: language,
                        ),
                      ),
                    );
                  },
                  child: Text(_breakDown),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(_notNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}