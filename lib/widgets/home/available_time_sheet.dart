import 'package:flutter/material.dart';

Future<int?> showAvailableTimeSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String calendarText,
  required String oneHourText,
  required String anyTimeText,
}) {
  return showModalBottomSheet<int?>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      -2,
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                  ),
                  label: Text(
                    calendarText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      text: '5 min',
                      minutes: 5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TimeButton(
                      text: '15 min',
                      minutes: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      text: '30 min',
                      minutes: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TimeButton(
                      text: oneHourText,
                      minutes: 60,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      -1,
                    );
                  },
                  child: Text(
                    anyTimeText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TimeButton extends StatelessWidget {
  final String text;
  final int minutes;

  const _TimeButton({
    required this.text,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.tonal(
        onPressed: () {
          Navigator.pop(
            context,
            minutes,
          );
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}