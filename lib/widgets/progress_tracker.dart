import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressTracker extends StatefulWidget {
  final double percent; // value between 0 and 1

  const ProgressTracker({super.key, required this.percent});

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  // store last milestone we hit so we don't trigger animations repeatedly
  double lastMilestone = 0;
  String message = '';

  // these are the percentage milestones (as decimal form)
  static final milestones = [0.25, 0.50, 0.75, 1.0];

  // friendly messages shown to the user based on progress
  static final milestoneMessages = {
    0.25: 'Great start! 🎯',
    0.50: 'Halfway there! 🏃‍♂️',
    0.75: 'Almost done! 💪',
    1.00: 'Ready for adventure! 🥳',
  };

  @override
  void didUpdateWidget(covariant ProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // check if we crossed a milestone and trigger animations/haptics
    for (final m in milestones) {
      if (oldWidget.percent < m && widget.percent >= m && lastMilestone < m) {
        lastMilestone = m;
        message = milestoneMessages[m]!;
        HapticFeedback.lightImpact(); // quick vibration feedback
        SystemSound.play(SystemSoundType.click); // optional click sound
        _pulse.forward(from: 0); // animate the percentage bump
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // converting to a cleaner display (0-100%)
    final pct = (widget.percent.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // actual progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: widget.percent,
            backgroundColor: cs.surfaceVariant.withOpacity(.25),
          ),
        ),
        const SizedBox(height: 8),

        // percentage text with pulse animation
        ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.1,
          ).animate(CurvedAnimation(parent: _pulse, curve: Curves.elasticOut)),
          child: Text(
            '$pct%',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary),
          ),
        ),

        // milestone message fade-in
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: message.isEmpty ? 0 : 1,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, color: cs.primary),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }
}
