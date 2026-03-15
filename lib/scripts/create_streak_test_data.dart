import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class StreakTestDataGenerator {
  StreakTestDataGenerator._();

  static final SupabaseClient _supabase = SupabaseService.instance.client;

  static Future<void> createStreakTestData({int days = 7}) async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    if (days <= 0) return;

    final now = DateTime.now();
    final rows = <Map<String, dynamic>>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      rows.add({
        'user_id': user.id,
        'mood_score': 3 + (i % 3),
        'note': 'streak test day ${days - i}',
        'emotion_factors': ['test'],
        'tags': ['test_data', 'streak_debug'],
        'created_at': date.toIso8601String(),
      });
    }

    await _supabase.from('mood_entries').insert(rows);
    await SupabaseService.instance.recalculateStreak(user.id);
    debugPrint('createStreakTestData: inserted $days rows');
  }

  static Future<void> deleteTestData() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _supabase
        .from('mood_entries')
        .delete()
        .eq('user_id', user.id)
        .contains('tags', ['test_data']);

    await SupabaseService.instance.recalculateStreak(user.id);
    debugPrint('deleteTestData: deleted rows tagged test_data');
  }

  static Future<void> deleteAllMoodEntries() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _supabase.from('mood_entries').delete().eq('user_id', user.id);
    await SupabaseService.instance.recalculateStreak(user.id);
    debugPrint('deleteAllMoodEntries: deleted all mood entries');
  }
}
