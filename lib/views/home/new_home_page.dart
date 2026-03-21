import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/localization_service.dart';
import '../../core/providers/mood_provider.dart';
import '../../models/streak.dart';
import '../../models/meditation.dart';
import '../../services/supabase_service.dart';
import '../../services/notification_service.dart';
import '../../scripts/migrate_existing_users.dart';
import '../mood/mood_log_page.dart';
import '../meditation/meditation_library_page.dart';
import '../meditation/meditation_detail_page.dart';
import '../expert/expert_list_page.dart';
import '../streak/streak_history_page.dart';
import '../chatbot/chatbot_page.dart';
import '../notification/notifications_page.dart';
import '../chat/chat_list_page.dart';
import 'widgets/neumorphic_card.dart';
import 'widgets/mood_quick_check.dart';
import 'widgets/wellness_stats_card.dart';
import 'widgets/featured_meditation_card.dart';
import 'widgets/quick_action_grid.dart';

/// Modern home page with neumorphic design
/// Follows Mental Wellness App design system
class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  Streak? _streak;
  List<Meditation> _meditations = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _migrateUser();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  Future<void> _migrateUser() async {
    await migrateCurrentUser();
  }

  Future<void> _loadData() async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Load streak
      await _supabaseService.recalculateStreak(user.id);
      final streak = await _supabaseService.getStreak(user.id);

      // Load featured meditations (take first one)
      final meditationsData = await _supabaseService.getMeditations();
      final meditations = meditationsData
          .take(1)
          .map((m) => Meditation.fromMap(m))
          .toList();

      if (mounted) {
        setState(() {
          _streak = streak;
          _meditations = meditations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.l10n.unableToLoadData;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 18) return context.l10n.goodAfternoon;
    return context.l10n.goodEvening;
  }

  String _getUserName() {
    final user = _supabaseService.currentUser;
    if (user?.userMetadata?['full_name'] != null) {
      return user!.userMetadata!['full_name'];
    }
    return user?.email?.split('@').first ?? 'User';
  }

  void _handleMoodSelection(int mood) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodLogPage(initialMoodLevel: mood),
      ),
    ).then((saved) {
      // Nếu MoodLogPage trả về true (đã lưu thành công) → refresh streak
      if (saved == true && mounted) {
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: const Color(0xFFF8FAFC),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryLight,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                MoodQuickCheck(
                  onMoodSelected: _handleMoodSelection,
                  title: context.l10n.howAreYouFeelingShort,
                ),
                const SizedBox(height: 20),
                WellnessStatsCard(
                  streak: _streak,
                  titleText: context.l10n.yourWellnessStreak,
                  currentLabel: context.l10n.currentDays,
                  longestLabel: context.l10n.longestDays,
                  totalLabel: context.l10n.totalLogs,
                  daysUnit: context.l10n.daysUnit,
                  logsUnit: context.l10n.logsUnit,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StreakHistoryPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context.l10n.quickActions),
                const SizedBox(height: 12),
                QuickActionGrid(
                  actions: [
                    QuickActionItem(
                      title: context.l10n.expertConsultation,
                      icon: Icons.psychology_outlined,
                      color: AppColors.primaryLight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpertListPage(),
                          ),
                        );
                      },
                    ),
                    QuickActionItem(
                      title: context.l10n.aiAssistant,
                      icon: Icons.smart_toy_outlined,
                      color: AppColors.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatbotPage(),
                          ),
                        );
                      },
                    ),
                    QuickActionItem(
                      title: context.l10n.moodHistory,
                      icon: Icons.insights_outlined,
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MoodLogPage(),
                          ),
                        );
                      },
                    ),
                    QuickActionItem(
                      title: context.l10n.allMeditations,
                      icon: Icons.self_improvement_outlined,
                      color: AppColors.primaryPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MeditationLibraryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (_meditations.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader(context.l10n.featuredMeditation),
                  const SizedBox(height: 12),
                  FeaturedMeditationCard(
                    meditation: _meditations.first,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MeditationDetailPage(
                            meditation: _meditations.first,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                _buildMotivationalQuote(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getUserName(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildHeaderAction(
          icon: Icons.message_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatListPage(),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: NotificationService().streamNotifications(
            _supabaseService.currentUser?.id ?? '',
          ),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final unreadCount =
                notifications.where((n) => n['isRead'] == false).length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeaderAction(
                  icon: Icons.notifications_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    return NeumorphicCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.primaryLight.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.dailyInspiration,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.wellnessQuote,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${context.l10n.wellnessQuoteAttribution}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.tryAgain,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
