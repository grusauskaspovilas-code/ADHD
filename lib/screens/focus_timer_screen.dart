import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/task.dart';

class FocusTimerScreen extends StatefulWidget {
  final Task task;
  final AppLanguage language;

  const FocusTimerScreen({
    super.key,
    required this.task,
    required this.language,
  });

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const int _initialSeconds = 120;

  int _secondsLeft = _initialSeconds;
  Timer? _timer;
  bool _isPaused = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _title {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Fang einfach an.';
      case AppLanguage.lithuanian:
        return 'Dabar tik pradėk.';
      default:
        return 'Just start.';
    }
  }

  String get _subtitle {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Du musst es nicht fertig machen.';
      case AppLanguage.lithuanian:
        return 'Tau nereikia užbaigti.';
      default:
        return "You don't need to finish it.";
    }
  }

  String get _pause {
    switch (widget.language) {
      case AppLanguage.german:
        return 'PAUSE';
      case AppLanguage.lithuanian:
        return 'PAUZĖ';
      default:
        return 'PAUSE';
    }
  }

  String get _continueText {
    switch (widget.language) {
      case AppLanguage.german:
        return 'WEITER';
      case AppLanguage.lithuanian:
        return 'TĘSTI';
      default:
        return 'CONTINUE';
    }
  }

  String get _finishedEarly {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Ich bin früher fertig';
      case AppLanguage.lithuanian:
        return 'Baigiau anksčiau';
      default:
        return 'I finished early';
    }
  }

  String get _timeUpTitle {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Geschafft. Du hast angefangen.';
      case AppLanguage.lithuanian:
        return 'Puiku. Tu pradėjai.';
      default:
        return 'Nice. You started.';
    }
  }

  String get _timeUpSubtitle {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Möchtest du noch 5 Minuten weitermachen?';
      case AppLanguage.lithuanian:
        return 'Ar nori tęsti dar 5 minutes?';
      default:
        return 'Want to continue for another 5 minutes?';
    }
  }

  String get _fiveMinutes {
    switch (widget.language) {
      case AppLanguage.german:
        return 'NOCH 5 MINUTEN';
      case AppLanguage.lithuanian:
        return 'TĘSTI DAR 5 MIN.';
      default:
        return 'CONTINUE 5 MIN';
    }
  }

  String get _enough {
    switch (widget.language) {
      case AppLanguage.german:
        return 'Für jetzt reicht es';
      case AppLanguage.lithuanian:
        return 'Užtenka dabar';
      default:
        return "That's enough for now";
    }
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || _isPaused) return;

        if (_secondsLeft <= 1) {
          timer.cancel();

          setState(() {
            _secondsLeft = 0;
            _isFinished = true;
          });

          return;
        }

        setState(() {
          _secondsLeft--;
        });
      },
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _startFiveMinutes() {
    _timer?.cancel();

    setState(() {
      _secondsLeft = 5 * 60;
      _isPaused = false;
      _isFinished = false;
    });

    _startTimer();
  }

  void _finish() {
    _timer?.cancel();

    Navigator.pop(
      context,
      'finished',
    );
  }

  @override
  Widget build(BuildContext context) {
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

              if (!_isFinished) ...[
                Text(
                  widget.task.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade700,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                ),

                const SizedBox(height: 24),

                Text(
                  _timeUpTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _timeUpSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],

              const Spacer(),

              if (!_isFinished) ...[
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(
                      _isPaused
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                    label: Text(
                      _isPaused
                          ? _continueText
                          : _pause,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: _finish,
                  child: Text(_finishedEarly),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _startFiveMinutes,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _fiveMinutes,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: _finish,
                  child: Text(_enough),
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}