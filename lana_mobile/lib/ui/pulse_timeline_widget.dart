import 'package:flutter/material.dart';
import 'theme.dart';

class PulseTimelineWidget extends StatelessWidget {
  final String currentStatus; // 'initiated', 'fx_locked', 'breb_sent', 'confirmed'

  const PulseTimelineWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'key': 'initiated', 'label': 'Initiated', 'icon': Icons.play_circle_outline},
      {'key': 'fx_locked', 'label': 'FX Locked', 'icon': Icons.lock_clock},
      {'key': 'breb_sent', 'label': 'Bre-B Sent', 'icon': Icons.send_rounded},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.check_circle},
    ];

    int currentIndex = steps.indexWhere((s) => s['key'] == currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: LanaTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: LanaTheme.goldAccent, size: 20),
              SizedBox(width: 8),
              Text('LanaYa Pulse', style: TextStyle(color: LanaTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            bool isComplete = i <= currentIndex;
            bool isCurrent = i == currentIndex;
            bool isLast = i == steps.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    // Status circle
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isComplete ? LanaTheme.emeraldGreen.withOpacity(0.2) : LanaTheme.darkBackground,
                        border: Border.all(
                          color: isComplete ? LanaTheme.emeraldGreen : LanaTheme.textMuted.withOpacity(0.3),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isComplete ? LanaTheme.emeraldGreen : LanaTheme.textMuted.withOpacity(0.4),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Label
                    Expanded(
                      child: Text(
                        step['label'] as String,
                        style: TextStyle(
                          color: isComplete ? LanaTheme.textColor : LanaTheme.textMuted.withOpacity(0.4),
                          fontSize: 15,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Checkmark
                    if (isComplete && !isCurrent)
                      const Icon(Icons.check, color: LanaTheme.emeraldGreen, size: 18),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: LanaTheme.emeraldGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Active', style: TextStyle(color: LanaTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                // Connector line
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: Container(
                      width: 2, height: 28,
                      color: isComplete ? LanaTheme.emeraldGreen.withOpacity(0.4) : LanaTheme.textMuted.withOpacity(0.15),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
