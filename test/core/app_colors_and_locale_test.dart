import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/core/constants/app_colors.dart';
import 'package:n04_app/core/services/localization_service.dart';

void main() {
  group('AppColors', () {
    test('all primary colors are defined', () {
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.primaryLight, isA<Color>());
      expect(AppColors.accent, isA<Color>());
      expect(AppColors.primaryPurple, isA<Color>());
    });

    test('all mood colors are defined', () {
      expect(AppColors.moodVeryPoor, isA<Color>());
      expect(AppColors.moodPoor, isA<Color>());
      expect(AppColors.moodOkay, isA<Color>());
      expect(AppColors.moodGood, isA<Color>());
      expect(AppColors.moodExcellent, isA<Color>());
    });

    test('getMoodColor returns correct color for each level', () {
      expect(AppColors.getMoodColor(1), AppColors.moodVeryPoor);
      expect(AppColors.getMoodColor(2), AppColors.moodPoor);
      expect(AppColors.getMoodColor(3), AppColors.moodOkay);
      expect(AppColors.getMoodColor(4), AppColors.moodGood);
      expect(AppColors.getMoodColor(5), AppColors.moodExcellent);
    });

    test('getMoodColor returns textSecondary for invalid level', () {
      expect(AppColors.getMoodColor(0), AppColors.textSecondary);
      expect(AppColors.getMoodColor(6), AppColors.textSecondary);
      expect(AppColors.getMoodColor(-1), AppColors.textSecondary);
    });

    test('getCategoryColor returns correct color for each category', () {
      expect(AppColors.getCategoryColor('stress'), AppColors.categoryStress);
      expect(AppColors.getCategoryColor('anxiety'), AppColors.categoryAnxiety);
      expect(AppColors.getCategoryColor('sleep'), AppColors.categorySleep);
      expect(AppColors.getCategoryColor('focus'), AppColors.categoryFocus);
    });

    test('getCategoryColor is case-insensitive', () {
      expect(AppColors.getCategoryColor('STRESS'), AppColors.categoryStress);
      expect(AppColors.getCategoryColor('Anxiety'), AppColors.categoryAnxiety);
      expect(AppColors.getCategoryColor('Sleep'), AppColors.categorySleep);
    });

    test('getCategoryColor returns backgroundLight for unknown category', () {
      expect(AppColors.getCategoryColor('unknown'), AppColors.backgroundLight);
      expect(AppColors.getCategoryColor(''), AppColors.backgroundLight);
    });

    test('all category colors are different', () {
      final colors = {
        AppColors.categoryStress,
        AppColors.categoryAnxiety,
        AppColors.categorySleep,
        AppColors.categoryFocus,
      };
      expect(colors.length, 4); // all unique
    });
  });

  group('LocaleProvider', () {
    test('defaults to Vietnamese', () {
      final provider = LocaleProvider();
      expect(provider.locale.languageCode, 'vi');
    });

    test('setLocale changes to English', () {
      final provider = LocaleProvider();
      provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, 'en');
    });

    test('setLocale rejects unsupported language', () {
      final provider = LocaleProvider();
      provider.setLocale(const Locale('fr')); // French not supported
      expect(provider.locale.languageCode, 'vi'); // stays Vietnamese
    });

    test('toggleLocale switches between vi and en', () {
      final provider = LocaleProvider();

      // Start: vi
      expect(provider.locale.languageCode, 'vi');

      // Toggle to en
      provider.toggleLocale();
      expect(provider.locale.languageCode, 'en');

      // Toggle back to vi
      provider.toggleLocale();
      expect(provider.locale.languageCode, 'vi');

      // Toggle again to en
      provider.toggleLocale();
      expect(provider.locale.languageCode, 'en');
    });

    test('setLocale accepts both supported languages', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, 'en');

      provider.setLocale(const Locale('vi'));
      expect(provider.locale.languageCode, 'vi');
    });
  });
}
