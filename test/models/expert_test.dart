import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/models/expert.dart';

void main() {
  group('Expert model', () {
    test('creates with required fields', () {
      final expert = Expert(
        expertId: 'exp-1',
        fullName: 'Nguyen Van A',
        title: 'Dr.',
        specialization: 'Anxiety',
        bio: 'Experienced therapist',
        yearsOfExperience: 10,
        pricePerSession: 300000,
      );

      expect(expert.displayName, 'Dr. Nguyen Van A');
      expect(expert.rating, 0.0);
      expect(expert.totalReviews, 0);
      expect(expert.isAvailable, isTrue);
      expect(expert.licenseNumber, isNull);
      expect(expert.avatarUrl, isNull);
      expect(expert.createdAt, isA<DateTime>());
    });

    test('displayName combines title and fullName', () {
      final expert = Expert(
        expertId: 'exp-1',
        fullName: 'Tran Thi B',
        title: 'Ms.',
        specialization: 'Depression',
        bio: 'Bio',
        yearsOfExperience: 5,
        pricePerSession: 200000,
      );

      expect(expert.displayName, 'Ms. Tran Thi B');
    });

    test('toMap produces correct keys for Supabase', () {
      final expert = Expert(
        expertId: 'exp-1',
        fullName: 'Test',
        title: 'Dr.',
        specialization: 'Stress',
        bio: 'Bio',
        yearsOfExperience: 3,
        pricePerSession: 250000,
        rating: 4.5,
      );

      final map = expert.toMap();
      expect(map['id'], 'exp-1');
      expect(map['bio'], 'Bio');
      expect(map['specialization'], 'Stress');
      expect(map['hourly_rate'], 250000);
      expect(map['rating'], 4.5);
    });

    test('fromMap parses Supabase row correctly', () {
      final data = {
        'id': 'exp-123',
        'bio': 'Expert bio',
        'specialization': 'Depression',
        'hourly_rate': 350000,
        'rating': 4.8,
        'total_reviews': 20,
        'years_experience': 8,
        'is_approved': true,
        'license_number': 'LIC-123',
        'created_at': '2024-01-01T00:00:00.000',
        'users': {
          'full_name': 'Dr. Expert',
          'avatar_url': 'https://example.com/avatar.png',
        },
      };

      final expert = Expert.fromMap(data);
      expect(expert.expertId, 'exp-123');
      expect(expert.fullName, 'Dr. Expert');
      expect(expert.specialization, 'Depression');
      expect(expert.pricePerSession, 350000);
      expect(expert.rating, 4.8);
      expect(expert.totalReviews, 20);
      expect(expert.yearsOfExperience, 8);
      expect(expert.isAvailable, isTrue);
      expect(expert.licenseNumber, 'LIC-123');
      expect(expert.avatarUrl, 'https://example.com/avatar.png');
    });

    test('fromMap handles missing user data', () {
      final data = {
        'id': 'exp-1',
        'bio': 'Bio',
        'specialization': 'General',
        'hourly_rate': 200000,
        'rating': 0,
        'total_reviews': 0,
        'years_experience': 0,
        'is_approved': true,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final expert = Expert.fromMap(data);
      expect(expert.fullName, 'Unknown Expert');
    });

    test('fromMap handles string numeric fields', () {
      final data = {
        'id': 'exp-1',
        'bio': 'Bio',
        'specialization': 'Stress',
        'hourly_rate': '250000.0',
        'rating': '4.2',
        'total_reviews': '15',
        'years_experience': '5',
        'is_approved': true,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final expert = Expert.fromMap(data);
      expect(expert.pricePerSession, 250000.0);
      expect(expert.rating, 4.2);
      expect(expert.totalReviews, 15);
      expect(expert.yearsOfExperience, 5);
    });

    test('fromMap handles invalid numeric strings gracefully', () {
      final data = {
        'id': 'exp-1',
        'bio': 'Bio',
        'specialization': 'Stress',
        'hourly_rate': 'invalid',
        'rating': 'invalid',
        'total_reviews': 'invalid',
        'years_experience': 'invalid',
        'is_approved': true,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final expert = Expert.fromMap(data);
      expect(expert.pricePerSession, 0.0);
      expect(expert.rating, 0.0);
      expect(expert.totalReviews, 0);
      expect(expert.yearsOfExperience, 0);
    });

    test('fromMap defaults isAvailable to true when is_approved missing', () {
      final data = {
        'id': 'exp-1',
        'bio': 'Bio',
        'specialization': 'Stress',
        'hourly_rate': 200000,
        'rating': 0,
        'total_reviews': 0,
        'years_experience': 0,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final expert = Expert.fromMap(data);
      expect(expert.isAvailable, isTrue);
    });

    test('createdAt defaults to DateTime.now() when missing', () {
      final data = {
        'id': 'exp-1',
        'bio': 'Bio',
        'specialization': 'Stress',
        'hourly_rate': 200000,
        'rating': 0,
        'total_reviews': 0,
        'years_experience': 0,
        'is_approved': true,
      };

      final expert = Expert.fromMap(data);
      expect(expert.createdAt.difference(DateTime.now()).inSeconds, lessThan(1));
    });

    test('can set custom avatar and license', () {
      final expert = Expert(
        expertId: 'exp-1',
        fullName: 'Test',
        title: 'Dr.',
        specialization: 'Anxiety',
        bio: 'Bio',
        yearsOfExperience: 5,
        pricePerSession: 200000,
        avatarUrl: 'https://example.com/face.jpg',
        licenseNumber: 'LIC-999',
        isAvailable: false,
      );

      expect(expert.avatarUrl, 'https://example.com/face.jpg');
      expect(expert.licenseNumber, 'LIC-999');
      expect(expert.isAvailable, isFalse);
    });
  });
}
