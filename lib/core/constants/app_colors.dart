import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF8BC34A);
  static const Color primaryPurple = Color(0xFF7B2BB0);
  static const Color splashBackground = Color(0xFFFFF5F6);
  static const Color quoteBackground1 = Color(0xFFF2C6D8);
  static const Color quoteBackground2 = Color(0xFFBFD9FF);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundGrey = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);

  // Status colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Mood colors
  static const Color moodVeryPoor = Color(0xFFEF5350); // Red
  static const Color moodPoor = Color(0xFFFF9800); // Orange
  static const Color moodOkay = Color(0xFFFFEB3B); // Yellow
  static const Color moodGood = Color(0xFF8BC34A); // Light Green
  static const Color moodExcellent = Color(0xFF4CAF50); // Green

  // Category colors
  static const Color categoryStress = Color(0xFFE8F5E9);
  static const Color categoryAnxiety = Color(0xFFE3F2FD);
  static const Color categorySleep = Color(0xFFD1F2EB);
  static const Color categoryFocus = Color(0xFFFFF3E0);

  // Organic Sanctuary Theme Colors (Green editorial design system)
  static const Color osSurface = Color(0xFFDDFFE2);
  static const Color osPrimary = Color(0xFF006B1B);
  static const Color osPrimaryDim = Color(0xFF005D16);
  static const Color osPrimaryFixed = Color(0xFF76FB7A);
  static const Color osPrimaryFixedDim = Color(0xFF68EC6E);
  static const Color osOnPrimary = Color(0xFFD1FFC8);
  static const Color osOnPrimaryFixed = Color(0xFF00480F);
  static const Color osOnPrimaryFixedVariant = Color(0xFF00691A);
  static const Color osPrimaryContainer = Color(0xFF76FB7A);
  static const Color osOnPrimaryContainer = Color(0xFF005E17);
  static const Color osOnSurface = Color(0xFF0B361D);
  static const Color osOnSurfaceVariant = Color(0xFF3B6447);
  static const Color osSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color osSurfaceContainerLow = Color(0xFFCAFDD4);
  static const Color osSurfaceContainer = Color(0xFFBEF5CA);
  static const Color osSurfaceContainerHigh = Color(0xFFB5F0C2);
  static const Color osSurfaceContainerHighest = Color(0xFFACECBB);
  static const Color osSurfaceBright = Color(0xFFDDFFE2);
  static const Color osSurfaceDim = Color(0xFFA0E4B1);
  static const Color osInverseSurface = Color(0xFF001206);
  static const Color osInverseOnSurface = Color(0xFF7BA785);
  static const Color osInversePrimary = Color(0xFF76FB7A);
  static const Color osOutline = Color(0xFF568061);
  static const Color osOutlineVariant = Color(0xFF8BB795);
  static const Color osSecondary = Color(0xFF006A38);
  static const Color osSecondaryDim = Color(0xFF005C30);
  static const Color osSecondaryFixed = Color(0xFF86FAAC);
  static const Color osSecondaryFixedDim = Color(0xFF77EB9F);
  static const Color osOnSecondary = Color(0xFFCCFFD6);
  static const Color osOnSecondaryFixed = Color(0xFF004A26);
  static const Color osOnSecondaryFixedVariant = Color(0xFF006A38);
  static const Color osSecondaryContainer = Color(0xFF86FAAC);
  static const Color osOnSecondaryContainer = Color(0xFF005F32);
  static const Color osTertiary = Color(0xFF00656F);
  static const Color osTertiaryDim = Color(0xFF005861);
  static const Color osTertiaryFixed = Color(0xFF11EAFF);
  static const Color osTertiaryFixedDim = Color(0xFF00DBEE);
  static const Color osOnTertiary = Color(0xFFD4F9FF);
  static const Color osOnTertiaryFixed = Color(0xFF003D43);
  static const Color osOnTertiaryFixedVariant = Color(0xFF005C64);
  static const Color osTertiaryContainer = Color(0xFF11EAFF);
  static const Color osOnTertiaryContainer = Color(0xFF005159);
  static const Color osError = Color(0xFFB02500);
  static const Color osErrorDim = Color(0xFFB92902);
  static const Color osOnError = Color(0xFFFFEFEC);
  static const Color osOnErrorContainer = Color(0xFF520C00);
  static const Color osErrorContainer = Color(0xFFF95630);
  static const Color osBackground = Color(0xFFDDFFE2);
  static const Color osOnBackground = Color(0xFF0B361D);
  static const Color osSurfaceTint = Color(0xFF006B1B);

  // Helper methods
  static Color getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return moodVeryPoor;
      case 2:
        return moodPoor;
      case 3:
        return moodOkay;
      case 4:
        return moodGood;
      case 5:
        return moodExcellent;
      default:
        return textSecondary;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'stress':
        return categoryStress;
      case 'anxiety':
        return categoryAnxiety;
      case 'sleep':
        return categorySleep;
      case 'focus':
        return categoryFocus;
      default:
        return backgroundLight;
    }
  }
}
