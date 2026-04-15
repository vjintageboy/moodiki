import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/models/streak.dart';
import 'package:n04_app/models/mood_entry.dart';

void main() {
  group('Streak calculation', () {
    // Helper to create mood entries on specific dates
    List<MoodEntry> _entriesForDays(List<DateTime> days) {
      return days
          .map((d) => MoodEntry(
                entryId: 'entry-${d.day}',
                userId: 'user-1',
                moodLevel: 3,
                timestamp: d,
              ))
          .toList();
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    test('returns zero streak for empty entries', () {
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: []);

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastActivityDate, isNull);
    });

    test('current streak = 1 when user logged today', () {
      final entries = _entriesForDays([todayDate]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
    });

    test('current streak = 1 when user logged yesterday but not today', () {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      final entries = _entriesForDays([yesterday]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
    });

    test('current streak = 0 when last activity was 2+ days ago', () {
      final twoDaysAgo = todayDate.subtract(const Duration(days: 2));
      final entries = _entriesForDays([twoDaysAgo]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 1);
    });

    test('current streak = 3 for 3 consecutive days including today', () {
      final day1 = todayDate.subtract(const Duration(days: 2));
      final day2 = todayDate.subtract(const Duration(days: 1));
      final day3 = todayDate;
      final entries = _entriesForDays([day1, day2, day3]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 3);
      expect(streak.longestStreak, 3);
    });

    test('current streak = 5 for 5 consecutive days including today', () {
      final days = List.generate(5, (i) => todayDate.subtract(Duration(days: 4 - i)));
      final entries = _entriesForDays(days);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 5);
    });

    test('current streak resets after a gap, but longest is preserved', () {
      // User logged 5 days in a row last week, then stopped for 3 days
      final fiveDaysAgo = todayDate.subtract(const Duration(days: 5));
      final fourDaysAgo = todayDate.subtract(const Duration(days: 4));
      final threeDaysAgo = todayDate.subtract(const Duration(days: 3));
      final twoDaysAgo = todayDate.subtract(const Duration(days: 2));
      final yesterday = todayDate.subtract(const Duration(days: 1));

      // 5-day streak last week
      final streakDays = [fiveDaysAgo, fourDaysAgo, threeDaysAgo, twoDaysAgo, yesterday];
      final entries = _entriesForDays(streakDays);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 5);
    });

    test('longest streak finds the longest consecutive run ever', () {
      // 2-day streak, gap, 4-day streak, gap, 1-day today
      final entries = _entriesForDays([
        todayDate.subtract(const Duration(days: 10)),
        todayDate.subtract(const Duration(days: 9)),
        // gap of 5 days
        todayDate.subtract(const Duration(days: 4)),
        todayDate.subtract(const Duration(days: 3)),
        todayDate.subtract(const Duration(days: 2)),
        todayDate.subtract(const Duration(days: 1)),
        // today
        todayDate,
      ]);

      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 5); // 4 days + today = 5
      expect(streak.longestStreak, 5); // the 4-day + today run
    });

    test('deduplicates multiple entries on the same day', () {
      // User logged 3 times on the same day
      final sameDay = todayDate;
      final entries = [
        MoodEntry(entryId: '1', userId: 'user-1', moodLevel: 3, timestamp: sameDay),
        MoodEntry(entryId: '2', userId: 'user-1', moodLevel: 4, timestamp: sameDay.add(const Duration(hours: 5))),
        MoodEntry(entryId: '3', userId: 'user-1', moodLevel: 5, timestamp: sameDay.add(const Duration(hours: 10))),
      ];

      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 1); // Only 1 unique day
      expect(streak.longestStreak, 1);
      expect(streak.totalActivities, 3); // But total entries count all
    });

    test('longest streak spans a gap correctly', () {
      // 3-day streak, gap, 1-day today
      final day3 = todayDate.subtract(const Duration(days: 3));
      final day2 = todayDate.subtract(const Duration(days: 2));
      final day1 = todayDate.subtract(const Duration(days: 1));

      final entries = _entriesForDays([day3, day2, day1, todayDate]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 4);
      expect(streak.longestStreak, 4);
    });

    test('current streak is 0 if today and yesterday both have no activity', () {
      final threeDaysAgo = todayDate.subtract(const Duration(days: 3));
      final entries = _entriesForDays([threeDaysAgo]);
      final streak = Streak.fromMoodEntries(userId: 'user-1', entries: entries);

      expect(streak.currentStreak, 0);
      expect(streak.lastActivityDate, threeDaysAgo);
    });
  });
}
