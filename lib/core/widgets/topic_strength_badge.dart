import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../models/topic_progress.dart';

class TopicStrengthBadge extends StatelessWidget {
  final TopicStrength strength;

  const TopicStrengthBadge({
    super.key,
    required this.strength,
  });

  _BadgeStyle get _style {
    switch (strength) {
      case TopicStrength.untested:
        return _BadgeStyle(
          color: const Color(0xFF5A7185),
          label: 'Untested',
        );
      case TopicStrength.weak:
        return _BadgeStyle(
          color: const Color(0xFFE74C3C),
          label: 'Weak',
        );
      case TopicStrength.average:
        return _BadgeStyle(
          color: const Color(0xFFF39C12),
          label: 'Average',
        );
      case TopicStrength.strong:
        return _BadgeStyle(
          color: const Color(0xFF2ECC71),
          label: 'Strong',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color, width: 1),
      ),
      child: Text(
        style.label,
        style: AppTypography.labelMedium.copyWith(
          color: style.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color color;
  final String label;

  const _BadgeStyle({required this.color, required this.label});
}
