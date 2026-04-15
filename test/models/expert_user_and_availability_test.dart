import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/models/expert_user.dart';
import 'package:n04_app/models/availability.dart';

void main() {
  group('ExpertCredentials', () {
    test('creates with optional fields', () {
      final creds = ExpertCredentials();

      expect(creds.licenseNumber, isNull);
      expect(creds.licenseUrl, isNull);
      expect(creds.certificateUrls, isEmpty);
      expect(creds.education, isNull);
      expect(creds.university, isNull);
      expect(creds.graduationYear, isNull);
      expect(creds.specialization, isNull);
      expect(creds.bio, isNull);
    });

    test('creates with all fields', () {
      final creds = ExpertCredentials(
        licenseNumber: 'LIC-123',
        licenseUrl: 'https://example.com/license.pdf',
        certificateUrls: ['https://example.com/cert1.pdf', 'https://example.com/cert2.pdf'],
        education: 'PhD Psychology',
        university: 'Hanoi University',
        graduationYear: 2015,
        specialization: 'Cognitive Behavioral Therapy',
        bio: 'Experienced therapist',
      );

      expect(creds.licenseNumber, 'LIC-123');
      expect(creds.certificateUrls.length, 2);
      expect(creds.graduationYear, 2015);
      expect(creds.bio, 'Experienced therapist');
    });

    test('toMap produces correct keys', () {
      final creds = ExpertCredentials(
        licenseNumber: 'LIC-456',
        specialization: 'Anxiety',
        bio: 'Bio',
        certificateUrls: ['url1', 'url2'],
      );

      final map = creds.toMap();
      expect(map['license_number'], 'LIC-456');
      expect(map['specialization'], 'Anxiety');
      expect(map['bio'], 'Bio');
      expect(map['certificate_urls'], ['url1', 'url2']);
    });

    test('fromMap parses Supabase row', () {
      final data = {
        'license_number': 'LIC-789',
        'license_url': 'https://example.com/license.pdf',
        'certificate_urls': ['cert1.pdf', 'cert2.pdf'],
        'education': 'MD Psychiatry',
        'university': 'Medical University',
        'graduation_year': 2010,
        'specialization': 'Depression',
        'bio': '10 years experience',
      };

      final creds = ExpertCredentials.fromMap(data);
      expect(creds.licenseNumber, 'LIC-789');
      expect(creds.licenseUrl, 'https://example.com/license.pdf');
      expect(creds.certificateUrls, ['cert1.pdf', 'cert2.pdf']);
      expect(creds.education, 'MD Psychiatry');
      expect(creds.university, 'Medical University');
      expect(creds.graduationYear, 2010);
      expect(creds.specialization, 'Depression');
      expect(creds.bio, '10 years experience');
    });

    test('fromMap handles null fields', () {
      final data = <String, dynamic>{
        'license_number': null,
        'certificate_urls': null,
      };

      final creds = ExpertCredentials.fromMap(data);
      expect(creds.licenseNumber, isNull);
      expect(creds.certificateUrls, isEmpty);
    });

    test('fromMap handles string conversion for graduation_year', () {
      final data = {
        'license_number': 'LIC-1',
        'graduation_year': '2020',
      };

      final creds = ExpertCredentials.fromMap(data);
      expect(creds.graduationYear, 2020);
    });

    test('fromMap handles invalid graduation_year', () {
      final data = {
        'license_number': 'LIC-1',
        'graduation_year': 'not-a-number',
      };

      final creds = ExpertCredentials.fromMap(data);
      expect(creds.graduationYear, isNull);
    });

    test('_parseList handles various input types', () {
      // Already tested via fromMap, but verify edge cases:
      final emptyData = <String, dynamic>{};
      final emptyCreds = ExpertCredentials.fromMap(emptyData);
      expect(emptyCreds.certificateUrls, isEmpty);
    });
  });

  group('ExpertUser status helpers', () {
    test('isPending returns true for pending status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.pending,
        credentials: ExpertCredentials(),
      );

      expect(user.isPending, isTrue);
      expect(user.isApproved, isFalse);
      expect(user.isActive, isFalse);
      expect(user.isRejected, isFalse);
      expect(user.isSuspended, isFalse);
      expect(user.canLogin, isFalse);
    });

    test('isApproved returns true for approved status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.approved,
        credentials: ExpertCredentials(),
      );

      expect(user.isApproved, isTrue);
      expect(user.isActive, isFalse);
      expect(user.isPending, isFalse);
      expect(user.canLogin, isTrue);
    });

    test('isActive returns true for active status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.active,
        credentials: ExpertCredentials(),
      );

      expect(user.isActive, isTrue);
      expect(user.isApproved, isTrue);
      expect(user.canLogin, isTrue);
    });

    test('isRejected returns true for rejected status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.rejected,
        credentials: ExpertCredentials(),
      );

      expect(user.isRejected, isTrue);
      expect(user.canLogin, isFalse);
    });

    test('isSuspended returns true for suspended status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.suspended,
        credentials: ExpertCredentials(),
      );

      expect(user.isSuspended, isTrue);
      expect(user.canLogin, isFalse);
    });

    test('canLogin is false for inactive status', () {
      final user = ExpertUser(
        uid: 'u1',
        email: 'e@test.com',
        displayName: 'Expert',
        status: ExpertStatus.inactive,
        credentials: ExpertCredentials(),
      );

      expect(user.canLogin, isFalse);
    });

    test('statusLabel returns correct string for each status', () {
      final statusLabels = {
        ExpertStatus.pending: 'Pending Approval',
        ExpertStatus.approved: 'Approved',
        ExpertStatus.active: 'Active',
        ExpertStatus.inactive: 'Inactive',
        ExpertStatus.rejected: 'Rejected',
        ExpertStatus.suspended: 'Suspended',
      };

      for (final entry in statusLabels.entries) {
        final user = ExpertUser(
          uid: 'u1',
          email: 'e@test.com',
          displayName: 'Expert',
          status: entry.key,
          credentials: ExpertCredentials(),
        );
        expect(user.statusLabel, entry.value);
      }
    });
  });

  group('ExpertUser fromMap', () {
    test('parses expert data with approved status', () {
      final data = {
        'id': 'expert-123',
        'is_approved': true,
        'created_at': '2024-01-01T00:00:00.000',
        'approved_at': '2024-01-02T00:00:00.000',
        'approved_by': 'admin-1',
        'users': {
          'email': 'expert@test.com',
          'full_name': 'Dr. Expert',
          'avatar_url': 'https://example.com/avatar.png',
        },
        'license_number': 'LIC-123',
        'specialization': 'CBT',
        'bio': 'Expert bio',
      };

      final user = ExpertUser.fromMap(data, 'u1');
      expect(user.uid, 'u1');
      expect(user.expertId, 'expert-123');
      expect(user.email, 'expert@test.com');
      expect(user.displayName, 'Dr. Expert');
      expect(user.photoUrl, 'https://example.com/avatar.png');
      expect(user.isActive, isTrue);
      expect(user.approvedAt, isA<DateTime>());
      expect(user.approvedBy, 'admin-1');
      expect(user.credentials.licenseNumber, 'LIC-123');
    });

    test('parses expert data with pending status', () {
      final data = {
        'id': 'expert-456',
        'is_approved': false,
        'created_at': '2024-01-01T00:00:00.000',
        'users': {
          'email': 'pending@test.com',
          'full_name': 'Pending Expert',
        },
      };

      final user = ExpertUser.fromMap(data, 'u2');
      expect(user.isPending, isTrue);
      expect(user.email, 'pending@test.com');
    });

    test('handles missing user data gracefully', () {
      final data = {
        'id': 'expert-789',
        'is_approved': true,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final user = ExpertUser.fromMap(data, 'u3');
      expect(user.email, '');
      expect(user.displayName, '');
    });
  });

  group('ExpertStatus enum', () {
    test('has all expected values', () {
      expect(ExpertStatus.values.length, 6);
      expect(ExpertStatus.values, contains(ExpertStatus.pending));
      expect(ExpertStatus.values, contains(ExpertStatus.approved));
      expect(ExpertStatus.values, contains(ExpertStatus.active));
      expect(ExpertStatus.values, contains(ExpertStatus.inactive));
      expect(ExpertStatus.values, contains(ExpertStatus.rejected));
      expect(ExpertStatus.values, contains(ExpertStatus.suspended));
    });
  });

  group('ExpertAvailability model', () {
    test('creates with required fields', () {
      final slot = ExpertAvailability(
        id: 'slot-1',
        expertId: 'expert-1',
        dayOfWeek: 1,
        startTime: '09:00',
        endTime: '17:00',
      );

      expect(slot.id, 'slot-1');
      expect(slot.expertId, 'expert-1');
      expect(slot.dayOfWeek, 1);
      expect(slot.startTime, '09:00');
      expect(slot.endTime, '17:00');
    });

    test('dartWeekday returns correct Dart weekday', () {
      final slot = ExpertAvailability(
        id: 'slot-1',
        expertId: 'expert-1',
        dayOfWeek: 1, // Monday in DB
        startTime: '09:00',
        endTime: '17:00',
      );

      expect(slot.dartWeekday, 1); // Monday in Dart is also 1
    });
  });
}
