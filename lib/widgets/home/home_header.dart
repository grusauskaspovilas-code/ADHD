import 'package:flutter/material.dart';

import '../../l10n/app_language.dart';

class HomeHeader extends StatelessWidget {
  final String addTaskText;
  final String languageTooltip;
  final AppLanguage selectedLanguage;
  final VoidCallback onAddTask;
  final VoidCallback onOpenCalendar;
  final Future<void> Function(AppLanguage)
      onLanguageSelected;
  final String Function(AppLanguage)
      languageName;

  const HomeHeader({
    super.key,
    required this.addTaskText,
    required this.languageTooltip,
    required this.selectedLanguage,
    required this.onAddTask,
    required this.onOpenCalendar,
    required this.onLanguageSelected,
    required this.languageName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: onAddTask,
          icon: const Icon(
            Icons.add,
            size: 24,
          ),
          label: Text(
            addTaskText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(
              160,
              52,
            ),
          ),
        ),

        const Spacer(),

        IconButton(
          onPressed: onOpenCalendar,
          icon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),

        const SizedBox(width: 4),

        PopupMenuButton<AppLanguage>(
          icon: const Icon(
            Icons.language,
          ),
          tooltip: languageTooltip,
          initialValue: selectedLanguage,
          onSelected: onLanguageSelected,
          itemBuilder: (context) {
            return AppLanguage.values.map(
              (language) {
                return PopupMenuItem<AppLanguage>(
                  value: language,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          languageName(language),
                        ),
                      ),
                      if (selectedLanguage ==
                          language)
                        const Icon(
                          Icons.check,
                          size: 20,
                        ),
                    ],
                  ),
                );
              },
            ).toList();
          },
        ),
      ],
    );
  }
}