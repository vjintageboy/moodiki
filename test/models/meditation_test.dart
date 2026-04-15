import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/models/meditation.dart';

void main() {
  group('Meditation model', () {
    // ── Construction ──────────────────────────────────────────────────────
    test('creates with required fields', () {
      final m = Meditation(
        meditationId: 'med-1',
        title: 'Morning Meditation',
        description: 'Start your day fresh',
        duration: 10,
        category: MeditationCategory.stress,
      );

      expect(m.meditationId, 'med-1');
      expect(m.title, 'Morning Meditation');
      expect(m.duration, 10);
      expect(m.category, MeditationCategory.stress);
      expect(m.level, MeditationLevel.beginner); // default
      expect(m.rating, 0.0);
      expect(m.totalReviews, 0);
      expect(m.audioUrl, isNull);
      expect(m.thumbnailUrl, isNull);
      expect(m.embedding, isNull);
    });

    // ── toMap ─────────────────────────────────────────────────────────────
    test('toMap produces correct keys for Supabase insert', () {
      final m = Meditation(
        meditationId: 'med-1',
        title: 'Sleep Well',
        description: 'Drift off peacefully',
        duration: 20,
        category: MeditationCategory.sleep,
      );

      final map = m.toMap();
      expect(map['title'], 'Sleep Well');
      expect(map['description'], 'Drift off peacefully');
      expect(map['duration_minutes'], 20);
      expect(map['category'], 'sleep');
      expect(map.containsKey('id'), isFalse); // toMap doesn't include id
    });

    // ── fromMap ───────────────────────────────────────────────────────────
    test('fromMap parses Supabase row correctly', () {
      final data = {
        'id': 'med-123',
        'title': 'Focus Time',
        'description': 'Concentrate better',
        'duration_minutes': 15,
        'category': 'focus',
        'audio_url': 'https://example.com/audio.mp3',
        'thumbnail_url': 'https://example.com/thumb.png',
        'rating': 4.5,
        'total_reviews': 10,
      };

      final m = Meditation.fromMap(data);
      expect(m.meditationId, 'med-123');
      expect(m.title, 'Focus Time');
      expect(m.duration, 15);
      expect(m.category, MeditationCategory.focus);
      expect(m.audioUrl, 'https://example.com/audio.mp3');
      expect(m.thumbnailUrl, 'https://example.com/thumb.png');
      expect(m.rating, 4.5);
      expect(m.totalReviews, 10);
    });

    test('fromMap handles missing category gracefully', () {
      final data = {
        'id': 'med-1',
        'title': 'Test',
        'description': 'Test',
        'duration_minutes': 10,
        'category': 'unknown_category',
      };

      final m = Meditation.fromMap(data);
      expect(m.category, MeditationCategory.stress); // orElse fallback
    });

    test('fromMap handles camelCase legacy keys', () {
      final data = {
        'meditationId': 'med-legacy',
        'title': 'Legacy',
        'description': 'Legacy',
        'duration': 5,
        'category': 'anxiety',
        'audioUrl': 'https://legacy.com/audio.mp3',
        'thumbnailUrl': 'https://legacy.com/thumb.png',
        'totalReviews': 3,
      };

      final m = Meditation.fromMap(data);
      expect(m.meditationId, 'med-legacy');
      expect(m.duration, 5);
      expect(m.audioUrl, 'https://legacy.com/audio.mp3');
      expect(m.totalReviews, 3);
    });

    // ── Embedding parsing ─────────────────────────────────────────────────
    test('fromMap parses embedding from List<dynamic>', () {
      final data = {
        'id': 'med-1',
        'title': 'Test',
        'description': 'Test',
        'duration_minutes': 10,
        'category': 'stress',
        'embedding': [0.1, 0.2, 0.3],
      };

      final m = Meditation.fromMap(data);
      expect(m.embedding, isNotNull);
      expect(m.embedding!.length, 3);
      expect(m.embedding![0], 0.1);
      expect(m.embedding![1], 0.2);
    });

    test('fromMap parses embedding from JSON string', () {
      final data = {
        'id': 'med-1',
        'title': 'Test',
        'description': 'Test',
        'duration_minutes': 10,
        'category': 'stress',
        'embedding': '[0.5, 0.6, 0.7]',
      };

      final m = Meditation.fromMap(data);
      expect(m.embedding, isNotNull);
      expect(m.embedding![0], 0.5);
      expect(m.embedding![2], 0.7);
    });

    test('fromMap returns null for invalid embedding string', () {
      final data = {
        'id': 'med-1',
        'title': 'Test',
        'description': 'Test',
        'duration_minutes': 10,
        'category': 'stress',
        'embedding': 'not a valid list',
      };

      final m = Meditation.fromMap(data);
      expect(m.embedding, isNull);
    });

    // ── copyWith ──────────────────────────────────────────────────────────
    test('copyWith updates specified fields only', () {
      final original = Meditation(
        meditationId: 'med-1',
        title: 'Original',
        description: 'Original desc',
        duration: 10,
        category: MeditationCategory.stress,
      );

      final copied = original.copyWith(
        title: 'Updated',
        duration: 20,
        rating: 4.0,
      );

      expect(copied.title, 'Updated');
      expect(copied.duration, 20);
      expect(copied.rating, 4.0);
      expect(copied.meditationId, 'med-1'); // unchanged
      expect(copied.description, 'Original desc'); // unchanged
      expect(copied.category, MeditationCategory.stress); // unchanged
    });

    // ── updateRating ─────────────────────────────────────────────────────
    test('updateRating calculates new average correctly', () {
      final m = Meditation(
        meditationId: 'med-1',
        title: 'Test',
        description: 'Test',
        duration: 10,
        category: MeditationCategory.stress,
        rating: 4.0,
        totalReviews: 2,
      );

      // Total rating sum = 4.0 * 2 = 8.0
      // New rating = 5.0 → new sum = 13.0, new count = 3
      // Average = 13.0 / 3 ≈ 4.333
      final updated = m.updateRating(5.0);

      expect(updated.totalReviews, 3);
      expect(updated.rating, closeTo(4.333, 0.01));
    });

    test('updateRating does not modify original', () {
      final original = Meditation(
        meditationId: 'med-1',
        title: 'Test',
        description: 'Test',
        duration: 10,
        category: MeditationCategory.stress,
        rating: 3.0,
        totalReviews: 1,
      );

      original.updateRating(4.0);

      expect(original.rating, 3.0);
      expect(original.totalReviews, 1);
    });

    // ── Enum coverage ─────────────────────────────────────────────────────
    test('all meditation categories exist', () {
      expect(MeditationCategory.values.length, 4);
      expect(MeditationCategory.values, contains(MeditationCategory.stress));
      expect(MeditationCategory.values, contains(MeditationCategory.anxiety));
      expect(MeditationCategory.values, contains(MeditationCategory.sleep));
      expect(MeditationCategory.values, contains(MeditationCategory.focus));
    });

    test('all meditation levels exist', () {
      expect(MeditationLevel.values.length, 3);
      expect(MeditationLevel.values, contains(MeditationLevel.beginner));
      expect(MeditationLevel.values, contains(MeditationLevel.intermediate));
      expect(MeditationLevel.values, contains(MeditationLevel.advanced));
    });
  });
}
