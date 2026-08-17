import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/task.dart';
import '../services/breakdown_service.dart';
import '../services/ai_breakdown_service.dart';

class BreakdownScreen extends StatefulWidget {
  final Task task;
  final AppLanguage language;

  const BreakdownScreen({
    super.key,
    required this.task,
    required this.language,
  });

  @override
  State<BreakdownScreen> createState() =>
      _BreakdownScreenState();
}

class _BreakdownScreenState
    extends State<BreakdownScreen> {
List<String> _steps = [];
bool _isLoading = true;

int _currentStep = 0;

@override
void initState() {
  super.initState();

  _loadSteps();
}

Future<void> _loadSteps() async {
  final aiSteps =
      await AiBreakdownService.generateSteps(
    task: widget.task,
    language: widget.language,
  );

  if (!mounted) return;

  // Jei AI nepavyko, naudojame seną
  // vietinį BreakdownService.
  final steps = aiSteps ??
      BreakdownService.createSteps(
        widget.task,
        widget.language,
      );

  setState(() {
    _steps = steps;
    _currentStep = 0;
    _isLoading = false;
  });
}

  String get _title {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Tik vienas mažas žingsnis';
      case AppLanguage.german:
        return 'Nur ein kleiner Schritt';
      default:
        return 'Just one small step';
    }
  }

  String get _dontThink {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Negalvok apie visą užduotį.';
      case AppLanguage.german:
        return 'Denk nicht an die ganze Aufgabe.';
      default:
        return "Don't think about the whole task.";
    }
  }

  String get _done {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'PADARIAU ŠĮ ŽINGSNĮ';
      case AppLanguage.german:
        return 'SCHRITT ERLEDIGT';
      default:
        return 'I DID THIS STEP';
    }
  }

  String get _allDone {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'Puiku. Tu jau pradėjai.';
      case AppLanguage.german:
        return 'Super. Du hast angefangen.';
      default:
        return 'Nice. You already started.';
    }
  }

  String get _backToTask {
    switch (widget.language) {
      case AppLanguage.lithuanian:
        return 'GRĮŽTI PRIE UŽDUOTIES';
      case AppLanguage.german:
        return 'ZURÜCK ZUR AUFGABE';
      default:
        return 'BACK TO TASK';
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });

      return;
    }

    setState(() {
      _currentStep = _steps.length;
    });
  }

 @override
Widget build(BuildContext context) {
  if (_isLoading) {
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

              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              ),

              const SizedBox(height: 24),

              Text(
                widget.language ==
                        AppLanguage.lithuanian
                    ? 'Skaidau užduotį į mažus žingsnius...'
                    : widget.language ==
                            AppLanguage.german
                        ? 'Ich teile die Aufgabe in kleine Schritte...'
                        : 'Breaking the task into small steps...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  final finished =
      _currentStep >= _steps.length;

  

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

              if (!finished) ...[
                Text(
                  _dontThink,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  '${_currentStep + 1}/${_steps.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Text(
                    _steps[_currentStep],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                ),

                const SizedBox(height: 24),

                Text(
                  _allDone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: finished
                      ? () {
                          Navigator.pop(context);
                        }
                      : _nextStep,
                  icon: Icon(
                    finished
                        ? Icons.arrow_back
                        : Icons.check,
                  ),
                  label: Text(
                    finished ? _backToTask : _done,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}