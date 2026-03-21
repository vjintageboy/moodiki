import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/localization_service.dart';
import 'neumorphic_card.dart';

/// Quick mood check widget with visual mood selector
class MoodQuickCheck extends StatefulWidget {
  final Function(int) onMoodSelected;
  final int? currentMood;
  final String title;

  const MoodQuickCheck({
    super.key,
    required this.onMoodSelected,
    required this.title,
    this.currentMood,
  });

  @override
  State<MoodQuickCheck> createState() => _MoodQuickCheckState();
}

class _MoodQuickCheckState extends State<MoodQuickCheck> {
  int? _selectedMood;
  int? _hoveredMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.currentMood;
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mood_outlined,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final moodLevel = index + 1;
              final isSelected = _selectedMood == moodLevel;
              final isHovered = _hoveredMood == moodLevel;
              final moodColor = AppColors.getMoodColor(moodLevel);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = moodLevel;
                    });
                    // Chỉ cập nhật local state, KHÔNG lưu DB ngay
                  },
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredMood = moodLevel),
                    onExit: (_) => setState(() => _hoveredMood = null),
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: isSelected ? 68 : (isHovered ? 64 : 60),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? moodColor
                            : (isHovered
                                ? moodColor.withValues(alpha: 0.15)
                                : moodColor.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? moodColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 24,
                              height: 1.0,
                            ),
                            child: Text(_getMoodEmoji(moodLevel)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moodLevel.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          // Hiển thị label và nút "Ghi lại" khi đã chọn mood
          if (_selectedMood != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getMoodLabel(_selectedMood!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getMoodColor(_selectedMood!),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onMoodSelected(_selectedMood!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getMoodColor(_selectedMood!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.logMood,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return context.l10n.veryPoor;
      case 2:
        return context.l10n.poor;
      case 3:
        return context.l10n.okay;
      case 4:
        return context.l10n.good;
      case 5:
        return context.l10n.excellent;
      default:
        return '';
    }
  }
}
