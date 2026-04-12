

enum MeditationCategory { stress, anxiety, sleep, focus }

// MeditationLevel không có trong DB nhưng giữ lại cho UI
enum MeditationLevel { beginner, intermediate, advanced }

class Meditation {
  final String meditationId;
  final String title;
  final String description;
  final int duration; // DB: duration_minutes
  final MeditationCategory category;
  final MeditationLevel level; // Không có trong DB, dùng mặc định
  final String? audioUrl;     // DB: audio_url
  final String? thumbnailUrl; // DB: thumbnail_url
  final double rating;        // Không có trong DB, mặc định 0
  final int totalReviews;     // Không có trong DB, mặc định 0
  final List<double>? embedding; // DB: embedding (pgvector 3072-dim)

  Meditation({
    required this.meditationId,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    this.level = MeditationLevel.beginner,
    this.audioUrl,
    this.thumbnailUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.embedding,
  });

  /// Convert sang Map để INSERT vào Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration_minutes': duration,
      'category': category.toString().split('.').last,
      'audio_url': audioUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }

  /// Parse từ row Supabase (hỗ trợ cả camelCase cũ)
  factory Meditation.fromMap(Map<String, dynamic> map) {
    return Meditation(
      meditationId: map['id'] ?? map['meditationId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration_minutes'] ?? map['duration'] ?? 0,
      category: MeditationCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => MeditationCategory.stress,
      ),
      level: MeditationLevel.values.firstWhere(
        (e) => e.toString().split('.').last == (map['level'] ?? ''),
        orElse: () => MeditationLevel.beginner,
      ),
      audioUrl: map['audio_url'] ?? map['audioUrl'],
      thumbnailUrl: map['thumbnail_url'] ?? map['thumbnailUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['total_reviews'] ?? map['totalReviews'] ?? 0,
      embedding: _parseEmbedding(map['embedding']),
    );
  }

  /// Parse embedding from Supabase response (can be `List<dynamic>` or JSON string)
  static List<double>? _parseEmbedding(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => (e as num).toDouble()).toList();
    }
    if (data is String) {
      // Handle string representation like "[0.1, 0.2, ...]"
      try {
        final trimmed = data.trim();
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          final inner = trimmed.substring(1, trimmed.length - 1);
          return inner.split(',').map((s) => double.parse(s.trim())).toList();
        }
      } catch (e) {
        // Fall through to null
      }
    }
    return null;
  }



  /// Update rating (dùng trong UI)
  Meditation updateRating(double newRating) {
    final totalRating = rating * totalReviews + newRating;
    final newTotalReviews = totalReviews + 1;
    return copyWith(
      rating: totalRating / newTotalReviews,
      totalReviews: newTotalReviews,
    );
  }

  Meditation copyWith({
    String? meditationId,
    String? title,
    String? description,
    int? duration,
    MeditationCategory? category,
    MeditationLevel? level,
    String? audioUrl,
    String? thumbnailUrl,
    double? rating,
    int? totalReviews,
    List<double>? embedding,
  }) {
    return Meditation(
      meditationId: meditationId ?? this.meditationId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      level: level ?? this.level,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      embedding: embedding ?? this.embedding,
    );
  }
}
