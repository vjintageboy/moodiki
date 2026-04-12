import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/streak.dart';

/// Displays wellness statistics with Organic Sanctuary tonal layering design
/// Follows the "No-Line" rule: boundaries via background color shifts, not borders
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFF7ED),
                        Color(0xFFFFEDD5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            // Whitespace separation instead of dividers
            const SizedBox(height: 24),
            // Stats row with whitespace separation
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: currentLabel,
                    value: '${streak?.currentStreak ?? 0}',
                    unit: daysUnit,
                    color: AppColors.osPrimary,
                  ),
                ),
                // Whitespace gap for separation
                const SizedBox(width: 20),
                Expanded(
                  child: _StatItem(
                    label: longestLabel,
                    value: '${streak?.longestStreak ?? 0}',
                    unit: daysUnit,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 20),
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
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
