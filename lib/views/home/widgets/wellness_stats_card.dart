import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/streak.dart';
import 'neumorphic_card.dart';

/// Displays wellness statistics with neumorphic design
class WellnessStatsCard extends StatelessWidget {
  final Streak? streak;
  final VoidCallback? onTap;
  final String titleText;
  final String currentLabel;
  final String longestLabel;
  final String totalLabel;
  final String daysUnit;
  final String logsUnit;

  const WellnessStatsCard({
    super.key,
    this.streak,
    this.onTap,
    required this.titleText,
    required this.currentLabel,
    required this.longestLabel,
    required this.totalLabel,
    required this.daysUnit,
    required this.logsUnit,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: currentLabel,
                  value: '${streak?.currentStreak ?? 0}',
                  unit: daysUnit,
                  color: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderLight,
              ),
              Expanded(
                child: _StatItem(
                  label: longestLabel,
                  value: '${streak?.longestStreak ?? 0}',
                  unit: daysUnit,
                  color: AppColors.warning,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderLight,
              ),
              Expanded(
                child: _StatItem(
                  label: totalLabel,
                  value: '${streak?.totalActivities ?? 0}',
                  unit: logsUnit,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
