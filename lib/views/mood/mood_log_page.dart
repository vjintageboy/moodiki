import 'package:flutter/material.dart';
import '../../models/mood_entry.dart';
import '../../core/services/localization_service.dart';
import '../../core/constants/app_colors.dart';
import '../../services/supabase_service.dart';

class MoodLogPage extends StatefulWidget {
  final int? initialMoodLevel;

  const MoodLogPage({super.key, this.initialMoodLevel});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final TextEditingController _noteController = TextEditingController();

  late int _selectedMoodLevel;
  final Set<String> _selectedFactors = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMoodLevel = widget.initialMoodLevel ?? 3;
  }

  // Mood levels with Material Symbols icons and colors
  List<Map<String, dynamic>> get _moodLevels => [
    {
      'level': 1,
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'labelKey': 'moodVeryBad',
      'color': const Color(0xFF6366F1), // Indigo
    },
    {
      'level': 2,
      'icon': Icons.sentiment_dissatisfied_rounded,
      'labelKey': 'moodBad',
      'color': const Color(0xFF60A5FA), // Soft Blue
    },
    {
      'level': 3,
      'icon': Icons.sentiment_neutral_rounded,
      'labelKey': 'moodNeutral',
      'color': const Color(0xFF94A3B8), // Slate
    },
    {
      'level': 4,
      'icon': Icons.sentiment_satisfied_rounded,
      'labelKey': 'good',
      'color': const Color(0xFFFBBF24), // Gentle Yellow
    },
    {
      'level': 5,
      'icon': Icons.sentiment_very_satisfied_rounded,
      'labelKey': 'moodExcellent',
      'color': const Color(0xFFFCA5A1), // Warm Peach
    },
  ];

  // Emotion factors with Material Symbols icons
  List<Map<String, dynamic>> get _emotionFactors => [
    {'key': 'work', 'icon': Icons.work_outline_rounded, 'labelKey': 'work'},
    {'key': 'family', 'icon': Icons.family_restroom_rounded, 'labelKey': 'family'},
    {'key': 'health', 'icon': Icons.favorite_rounded, 'labelKey': 'health'},
    {'key': 'relationships', 'icon': Icons.groups_outlined, 'labelKey': 'relationships'},
    {'key': 'sleep', 'icon': Icons.bedtime_outlined, 'labelKey': 'sleep'},
    {'key': 'food', 'icon': Icons.restaurant_outlined, 'labelKey': 'food'},
    {'key': 'exercise', 'icon': Icons.fitness_center_outlined, 'labelKey': 'exercise'},
    {'key': 'social', 'icon': Icons.public_outlined, 'labelKey': 'social'},
    {'key': 'money', 'icon': Icons.payments_outlined, 'labelKey': 'money'},
    {'key': 'weather', 'icon': Icons.cloud_outlined, 'labelKey': 'weather'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodEntry() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final moodEntry = MoodEntry(
        entryId: '',
        userId: user.id,
        moodLevel: _selectedMoodLevel,
        note: _noteController.text.trim(),
        emotionFactors: _selectedFactors.toList(),
        tags: [],
        timestamp: DateTime.now(),
      );

      await _supabaseService.createMoodEntry(moodEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.moodLoggedSuccess),
            backgroundColor: AppColors.osPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorSavingMood(e.toString())),
            backgroundColor: AppColors.osError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 32),
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildMoodSelectorGlassCard(),
          const SizedBox(height: 24),
          _buildContextualFactors(),
          const SizedBox(height: 24),
          _buildNotesSection(),
          const SizedBox(height: 40),
          _buildQuoteCard(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.grey.shade700,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.moodTrackerTitle,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Color(0xFF0F172A),
        ),
      ),
      centerTitle: false,
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.osPrimary,
                strokeWidth: 2.5,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _saveMoodEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.osPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppColors.osPrimary.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.howAreYouFeelingHero,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.moodHeroSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelectorGlassCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.osPrimary.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: _moodLevels.map((mood) {
              final isSelected = _selectedMoodLevel == mood['level'];
              final Color moodColor = mood['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedMoodLevel = mood['level']),
                  child: _MoodSelectorItem(
                    icon: mood['icon'] as IconData,
                    label: _getLocalizedMoodLabel(context, mood['labelKey']),
                    isSelected: isSelected,
                    moodColor: moodColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualFactors() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.factorsWhatAffect,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _emotionFactors.map((factor) {
            final key = factor['key']!;
            final icon = factor['icon']! as IconData;
            final labelKey = factor['labelKey']!;
            final isSelected = _selectedFactors.contains(key);
            return _FactorChip(
              icon: icon,
              label: _getLocalizedFactorLabel(context, labelKey),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFactors.remove(key);
                  } else {
                    _selectedFactors.add(key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notesToday,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            // Glow behind textarea
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.osPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
            TextField(
              controller: _noteController,
              maxLines: null,
              minLines: 5,
              cursorColor: AppColors.osPrimary,
              decoration: InputDecoration(
                hintText: l10n.notesPlaceholder,
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(
                    color: Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(
                    color: Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(
                    color: AppColors.osPrimary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            // Floating action buttons
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                children: [
                  _buildNoteActionButton(Icons.image_outlined),
                  const SizedBox(width: 8),
                  _buildNoteActionButton(Icons.mic_outlined),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteActionButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image/mic actions
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.osPrimary, AppColors.osPrimaryDim],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.osPrimary.withValues(alpha: 0.3),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blur circles
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned(
            left: -40,
            top: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFFBBF7D0).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.dailyInspirationQuote,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 2,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.quoteInspirationLabel,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedMoodLabel(BuildContext context, String labelKey) {
    final l10n = context.l10n;
    switch (labelKey) {
      case 'moodVeryBad':
        return l10n.moodVeryBad;
      case 'moodBad':
        return l10n.moodBad;
      case 'moodNeutral':
        return l10n.moodNeutral;
      case 'good':
        return l10n.good;
      case 'moodExcellent':
        return l10n.moodExcellent;
      default:
        return '';
    }
  }

  String _getLocalizedFactorLabel(BuildContext context, String labelKey) {
    final l10n = context.l10n;
    switch (labelKey) {
      case 'work':
        return l10n.work;
      case 'family':
        return l10n.family;
      case 'health':
        return l10n.health;
      case 'relationships':
        return l10n.relationships;
      case 'sleep':
        return l10n.sleep;
      case 'food':
        return l10n.food;
      case 'exercise':
        return l10n.exercise;
      case 'social':
        return l10n.social;
      case 'money':
        return l10n.money;
      case 'weather':
        return l10n.weather;
      default:
        return labelKey;
    }
  }
}

/// Individual mood selector item with glass effect
class _MoodSelectorItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color moodColor;

  const _MoodSelectorItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.moodColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect for selected
            if (isSelected)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isSelected ? 64 : 56,
              height: isSelected ? 64 : 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? moodColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(9999),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 4)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: moodColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: isSelected ? 32 : 28,
                opticalSize: 40,
                fill: isSelected ? 1 : 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? moodColor : Colors.grey.shade400,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

/// Factor selection chip with gradient selected state
class _FactorChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FactorChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFF0FDF4),
                    Color(0xFFECFDF5),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.osPrimary
                : Colors.grey.shade100,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.osPrimary.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.osPrimary
                  : Colors.grey.shade500,
              fill: isSelected ? 1 : 0,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.osPrimary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
