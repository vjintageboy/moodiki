import 'package:flutter/material.dart';
import '../mood/mood_log_page.dart';
import '../mood/mood_history_page.dart';
import '../meditation/meditation_detail_page.dart';
import '../profile/profile_page.dart';
import '../expert/expert_list_page.dart';
import '../chatbot/chatbot_page.dart';
import '../news/news_feed_page.dart';
import '../../core/services/localization_service.dart';
import '../../services/supabase_service.dart';
import '../../core/constants/app_colors.dart';
import 'new_home_page.dart'; // Import new modern home design

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
  with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _fabAnimationController;
  Animation<double> _fabScale = const AlwaysStoppedAnimation(1.0);
  AnimationController? _fabGlowController;
  bool _shouldGlowAiFab = false;

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fabAnimationController = controller;
    _fabScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );
    controller.forward();

    final glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _fabGlowController = glowController;

    _loadAiFabMoodState();
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    _fabGlowController?.dispose();
    super.dispose();
  }

  Future<void> _loadAiFabMoodState() async {
    try {
      final service = SupabaseService.instance;
      final user = service.currentUser;
      if (user == null) {
        if (!mounted) return;
        if (_shouldGlowAiFab) {
          setState(() {
            _shouldGlowAiFab = false;
          });
        }
        return;
      }

      final moods = await service.getMoodEntries(user.id);
      final latestMood = moods.isNotEmpty ? moods.first.moodLevel : null;
      final shouldGlow = latestMood != null && latestMood <= 2;

      if (!mounted) return;
      if (_shouldGlowAiFab != shouldGlow) {
        setState(() {
          _shouldGlowAiFab = shouldGlow;
        });
      }
    } catch (e) {
      debugPrint('AI FAB mood state error: $e');
      // Keep default visual state if mood lookup fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentTab;

    switch (_selectedIndex) {
      case 0:
        currentTab = const HomeTab();
        break;
      case 1:
        currentTab = const MoodHistoryPage();
        break;
      case 2:
        currentTab = const NewsFeedPage();
        break;
      case 3:
        currentTab = const ExpertListPage();
        break;
      case 4:
        currentTab = const ProfilePage();
        break;
      default:
        currentTab = _buildOtherTab();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: currentTab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          right: 4,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: AnimatedBuilder(
          animation: _fabGlowController ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            final glowT = _fabGlowController?.value ?? 0.0;
            final blur = _shouldGlowAiFab ? 18.0 + (10.0 * glowT) : 8.0;
            final spread = _shouldGlowAiFab ? 1.0 + (1.5 * glowT) : 0.0;
            final opacity = _shouldGlowAiFab ? 0.22 + (0.18 * glowT) : 0.15;

            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: opacity),
                    blurRadius: blur,
                    spreadRadius: spread,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ScaleTransition(
            scale: _fabScale,
            child: FloatingActionButton(
              heroTag: 'ai_assistant_fab',
              onPressed: _openAiAssistant,
              backgroundColor: AppColors.primaryLight,
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    Icons.home_outlined,
                    Icons.home,
                    context.l10n.home,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.mood_outlined,
                    Icons.mood,
                    context.l10n.mood,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    2,
                    Icons.article_outlined,
                    Icons.article,
                    'News',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    3,
                    Icons.spa_outlined,
                    Icons.spa,
                    context.l10n.experts,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    4,
                    Icons.person_outline,
                    Icons.person,
                    context.l10n.profile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAiAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatbotPage()),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _loadAiFabMoodState();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTab() {
    if (_selectedIndex == 4) {
      // Profile tab
      return const ProfilePage();
    }

    return Center(
      child: Text(
        'Tab ${_selectedIndex + 1}',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use new modern home design
    return const NewHomePage();
  }
}
