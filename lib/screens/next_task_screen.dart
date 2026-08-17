import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/task.dart';
import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import 'stuck_screen.dart';
class NextTaskScreen extends StatelessWidget {
  final Task task;
  final AppLanguage language;

  const NextTaskScreen({
    super.key,
    required this.task,
    required this.language,
  });

  String get _callText {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'SKAMBINTI';
      case AppLanguage.german:
        return 'ANRUFEN';
      default:
        return 'CALL';
    }
  }

  String get _emailText {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'ATSAKYTI EL. PAŠTU';
      case AppLanguage.german:
        return 'PER E-MAIL ANTWORTEN';
      default:
        return 'REPLY BY EMAIL';
    }
  }

  String get _cannotOpenText {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Nepavyko atidaryti reikiamos programos.';
      case AppLanguage.german:
        return 'Die benötigte App konnte nicht geöffnet werden.';
      default:
        return 'Could not open the required app.';
    }
  }

  Future<void> _openStuckScreen(
    BuildContext context,
  ) async {
    final result =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StuckScreen(
          task: task,
          language: language,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == 'start') {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '2 minute mode coming next',
          ),
        ),
      );
    }

    if (result == 'breakDown') {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Task breakdown coming next',
          ),
        ),
      );
    }
  }

  Future<void> _makePhoneCall(
    BuildContext context,
  ) async {
    final phone =
        task.phoneNumber?.trim();

    if (phone == null ||
        phone.isEmpty) {
      return;
    }

    //
    // tel: atidaro telefono programą
    // su jau įvestu numeriu.
    //
    // Pats skambutis nepradedamas
    // automatiškai.
    //
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened &&
        context.mounted) {
      _showCannotOpen(context);
    }
  }

  Future<void> _sendEmail(
  BuildContext context,
) async {
  final email = task.emailAddress?.trim();

  if (email == null || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Užduotyje nėra el. pašto adreso.',
        ),
      ),
    );
    return;
  }

  final uri = Uri.parse(
    'mailto:$email',
  );

  final opened = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!opened && context.mounted) {
    _showCannotOpen(context);
  }
}
  void _showCannotOpen(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          _cannotOpenText,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
  ) {
    switch (task.actionType) {
      case TaskActionType.phoneCall:
        return SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton.icon(
            onPressed: () {
              _makePhoneCall(context);
            },
            icon: const Icon(
              Icons.phone,
            ),
            label: Text(
              _callText,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        );

      case TaskActionType.email:
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: FilledButton.icon(
      onPressed: () {
        _sendEmail(context);
      },
      icon: const Icon(
        Icons.email_outlined,
      ),
      label: Text(
        _emailText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

      case TaskActionType.none:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        AppStrings(language);

    final hasAction =
        task.actionType !=
            TaskActionType.none;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment:
                    Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                strings.doThisNow,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Icon(
                task.actionType ==
                        TaskActionType
                            .phoneCall
                    ? Icons.phone_outlined
                    : task.actionType ==
                            TaskActionType
                                .email
                        ? Icons
                            .email_outlined
                        : Icons
                            .play_circle_outline,
                size: 80,
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                task.title,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              if (task.description !=
                  null) ...[
                const SizedBox(
                  height: 12,
                ),
                Text(
                  task.description!,
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors
                        .grey.shade700,
                  ),
                ),
              ],

              //
              // Parodome kontaktą.
              //
              if (task.actionType ==
                      TaskActionType
                          .phoneCall &&
                  task.phoneNumber !=
                      null) ...[
                const SizedBox(
                  height: 12,
                ),
                Text(
                  task.phoneNumber!,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],

              if (task.actionType ==
                      TaskActionType
                          .email &&
                  task.emailAddress !=
                      null) ...[
                const SizedBox(
                  height: 12,
                ),
                Text(
                  task.emailAddress!,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(
                height: 20,
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment:
                    WrapAlignment.center,
                children: [
                  Chip(
                    label: Text(
                      '${strings.priority}: '
                      '${strings.priorityName(task.priority.name)}',
                    ),
                  ),

                  if (task
                          .estimatedMinutes !=
                      null)
                    Chip(
                      avatar:
                          const Icon(
                        Icons.schedule,
                        size: 18,
                      ),
                      label: Text(
                        '${task.estimatedMinutes} min',
                      ),
                    ),
                ],
              ),

              const Spacer(),

              //
              // Skambinti / rašyti.
              //
              if (hasAction) ...[
                _buildActionButton(
                  context,
                ),

                const SizedBox(
                  height: 10,
                ),
              ],

              //
              // Atlikta paliekame atskirai.
              //
              // Vien telefono ar email
              // programos atidarymas dar
              // nereiškia, kad užduotis
              // tikrai atlikta.
              //
              SizedBox(
                width:
                    double.infinity,
                height: 58,
                child:
                    FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: Text(
                    strings.done,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    _openStuckScreen(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.help_outline,
                  ),
                  label: Text(
                    strings.cantStart,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}