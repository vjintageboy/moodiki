# Home View - Design Documentation

## Overview

This directory contains the modernized home view for the Mental Wellness App, designed according to the **Neumorphism** design system with a focus on calm aesthetics, accessibility, and user wellness.

## Design System

### Style: Neumorphism (Soft UI)
- **Keywords**: Soft shadows, embossed/debossed effects, subtle depth, rounded corners
- **Best For**: Health/wellness apps, meditation platforms, calming interfaces
- **Performance**: ⚡ Good
- **Accessibility**: ⚠ Enhanced with proper contrast ratios

### Colors
| Role | Hex | Usage |
|------|-----|-------|
| Primary | #2563EB | Accent elements, CTAs |
| Secondary | #3B82F6 | Secondary actions |
| Primary Light | #4CAF50 | Main brand color, mood positive |
| Background | #F8FAFC | Main background, neumorphic surface |
| Text Primary | #1E293B | Headings, important text |
| Text Secondary | #757575 | Supporting text, labels |

### Typography
- **Heading Font**: Lora (Serif - calm, wellness aesthetic)
- **Body Font**: Raleway (Sans-serif - clean, readable)
- **Scale**: 12px / 14px / 16px / 18px / 20px / 24px / 28px
- **Line Height**: 1.4 - 1.5 for body text

### Effects
- **Soft Shadows**: Multiple box-shadows for depth
  - Light: `-5px -5px 15px rgba(255,255,255,0.9)`
  - Dark: `5px 5px 15px rgba(0,0,0,0.08)`
- **Border Radius**: 12-16px standard, 20px for pills
- **Animation Timing**: 150-300ms for micro-interactions
- **Easing**: `ease-out` for entering, `ease-in` for exiting

## File Structure

```
lib/views/home/
├── home_page.dart              # Original home page (preserved as backup)
├── home_page_backup.dart       # Backup copy
├── new_home_page.dart          # ✨ New modern home design
├── README.md                   # This file
└── widgets/
    ├── neumorphic_card.dart           # Reusable neumorphic card component
    ├── mood_quick_check.dart          # Quick mood selector widget
    ├── wellness_stats_card.dart       # Streak statistics display
    ├── featured_meditation_card.dart  # Featured meditation showcase
    └── quick_action_grid.dart         # Grid of quick action buttons
```

## Components

### 1. NeumorphicCard (`widgets/neumorphic_card.dart`)
**Purpose**: Base component for all card-style elements

**Props**:
- `child`: Widget - Content to display
- `padding`: EdgeInsets - Internal padding (default: 16px)
- `onTap`: Function - Tap callback
- `color`: Color - Background color (default: #F8FAFC)
- `borderRadius`: double - Corner radius (default: 16px)
- `isPressed`: bool - Pressed state for interaction feedback

**Usage**:
```dart
NeumorphicCard(
  onTap: () => print('Tapped'),
  child: Text('Hello World'),
)
```

### 2. MoodQuickCheck (`widgets/mood_quick_check.dart`)
**Purpose**: Quick mood logging interface

**Features**:
- 5-point mood scale with emoji indicators
- Visual feedback on selection (color, size, animation)
- Smooth animations (200ms, ease-out-back curve)
- Accessible touch targets (min 60px height)

**Props**:
- `onMoodSelected`: Function(int) - Callback when mood selected
- `currentMood`: int? - Pre-selected mood value

**Mood Scale**:
1. 😢 Very Poor (Red)
2. 😕 Poor (Orange)
3. 😐 Okay (Yellow)
4. 🙂 Good (Light Green)
5. 😄 Excellent (Green)

### 3. WellnessStatsCard (`widgets/wellness_stats_card.dart`)
**Purpose**: Display streak and wellness statistics

**Features**:
- Three stat columns: Current / Longest / Total
- Color-coded values for visual hierarchy
- Tap to navigate to detailed streak history
- Semantic icon (fire for streak)

**Props**:
- `streak`: Streak? - Streak data model
- `onTap`: Function - Tap callback

### 4. FeaturedMeditationCard (`widgets/featured_meditation_card.dart`)
**Purpose**: Showcase featured meditation session

**Features**:
- Gradient header with duration badge
- Category tag with semantic colors
- Truncated title and description (max 2 lines)
- Play icon affordance

**Props**:
- `meditation`: Meditation - Meditation data model
- `onTap`: Function - Tap callback

### 5. QuickActionGrid (`widgets/quick_action_grid.dart`)
**Purpose**: Grid of quick access actions

**Features**:
- 2-column responsive grid
- Press state feedback (neumorphic pressed effect)
- Icon + label combination
- Color-coded by action type

**Props**:
- `actions`: List<QuickActionItem> - List of action items

**QuickActionItem**:
- `title`: String
- `icon`: IconData
- `color`: Color
- `onTap`: Function

## New Home Page (`new_home_page.dart`)

### Layout Structure

```
┌─────────────────────────────────────┐
│ Header (Greeting + Actions)         │
├─────────────────────────────────────┤
│ Mood Quick Check Card               │
├─────────────────────────────────────┤
│ Wellness Stats Card                 │
├─────────────────────────────────────┤
│ Quick Actions Grid (2x2)            │
│ ┌──────────┬──────────┐            │
│ │  Expert  │    AI    │            │
│ ├──────────┼──────────┤            │
│ │   Mood   │ Meditate │            │
│ └──────────┴──────────┘            │
├─────────────────────────────────────┤
│ Featured Meditation Card            │
├─────────────────────────────────────┤
│ Motivational Quote Card             │
└─────────────────────────────────────┘
```

### Key Features

#### 1. **Header**
- Personalized greeting (Good Morning/Afternoon/Evening)
- User name display
- Chat access button
- Notification bell with unread badge

#### 2. **Mood Quick Check**
- One-tap mood logging
- Instant visual feedback
- Integrates with MoodProvider
- Success/error toast notifications

#### 3. **Wellness Stats**
- Real-time streak display
- Tap to view detailed history
- Visual separation with dividers
- Color-coded values for emphasis

#### 4. **Quick Actions**
- Expert Consultation (Green)
- AI Assistant (Blue)
- Mood History (Light Green)
- All Meditations (Purple)

#### 5. **Featured Meditation**
- Dynamically loaded from Supabase
- Gradient visual treatment
- Duration and category display
- Direct navigation to detail page

#### 6. **Motivational Quote**
- Daily inspiration section
- Soft background tint
- Quote icon with semantic meaning

### State Management

**Loading States**:
- Centered spinner during data fetch
- Branded color (#4CAF50)
- Fade-in animation on content ready

**Error States**:
- Friendly error icon
- Clear error message
- Retry button
- Maintains app color scheme

**Empty States**:
- Gracefully handles missing data
- Shows 0 values for stats
- Conditional rendering for meditation

### Animations

1. **Initial Load**: 800ms fade-in (ease-out curve)
2. **Mood Selection**: 200ms scale + color change (ease-out-back)
3. **Button Press**: 150ms shadow reduction
4. **Page Transition**: Standard Material motion

### Accessibility

✅ **Touch Targets**: All interactive elements ≥44x44pt
✅ **Contrast**: Text contrast ≥4.5:1 (WCAG AA)
✅ **Focus States**: Visible keyboard navigation support
✅ **Screen Readers**: Semantic widget structure
✅ **Reduced Motion**: Respects system preferences
✅ **Color Independence**: Icons + text, not color alone

### Performance

- **Lazy Loading**: Featured meditation only (limit: 1)
- **Efficient Streams**: StreamBuilder for notifications only
- **Minimal Rebuilds**: Stateful widgets isolate state
- **Image Optimization**: Uses gradient instead of images where possible

## Integration Guide

### Option 1: Replace Current Home (Recommended)

1. **Backup current implementation**:
```bash
cp lib/views/home/home_page.dart lib/views/home/home_page_old.dart
```

2. **Update import in parent widget** (wherever HomePage is used):
```dart
// Old
import 'views/home/home_page.dart';

// New
import 'views/home/new_home_page.dart';

// Usage
NewHomePage() // instead of HomePage()
```

### Option 2: Gradual Migration

1. Keep both implementations
2. Add a feature flag or user preference
3. A/B test with different user groups
4. Gather feedback before full rollout

### Option 3: Integrate Widgets Separately

Use the new widgets in the existing home page:

```dart
import 'views/home/widgets/neumorphic_card.dart';
import 'views/home/widgets/mood_quick_check.dart';
// ... etc

// In build method:
MoodQuickCheck(
  onMoodSelected: (mood) => _handleMoodLog(mood),
)
```

## Testing Checklist

### Visual Testing
- [ ] Neumorphic shadows render correctly
- [ ] Colors match design system
- [ ] Typography scales properly
- [ ] Spacing is consistent (16/20/24px rhythm)
- [ ] Border radius is uniform (12-16px)

### Interaction Testing
- [ ] Mood selection provides immediate feedback
- [ ] All cards respond to taps
- [ ] Buttons show pressed states
- [ ] Navigation works to all destinations
- [ ] Pull-to-refresh updates data

### Responsive Testing
- [ ] Works on small phones (375px width)
- [ ] Works on tablets
- [ ] Portrait and landscape orientations
- [ ] Safe area insets respected

### Accessibility Testing
- [ ] Screen reader announces all elements
- [ ] Tab navigation works
- [ ] Touch targets are adequate (≥44pt)
- [ ] Color contrast passes WCAG AA
- [ ] Reduced motion is respected

### Performance Testing
- [ ] Initial load time <1s
- [ ] Smooth animations (60fps)
- [ ] No memory leaks
- [ ] Efficient data fetching

## Customization

### Changing Colors

Edit `lib/core/constants/app_colors.dart`:
```dart
static const Color primaryLight = Color(0xFF4CAF50); // Change to your brand
```

### Adjusting Neumorphic Effect

Edit `lib/views/home/widgets/neumorphic_card.dart`:
```dart
// Softer shadows
BoxShadow(
  color: Colors.white.withOpacity(0.7), // Reduce from 0.9
  offset: const Offset(-3, -3),          // Reduce from -5
  blurRadius: 10,                         // Reduce from 15
),
```

### Modifying Animation Speed

In components:
```dart
duration: const Duration(milliseconds: 150), // Change from 200/300
```

## Browser/Device Support

✅ iOS 12+
✅ Android 5.0+ (API 21+)
✅ Flutter 3.9.2+
✅ Dart 3.0+

## Dependencies

**Required**:
- `flutter/material.dart` - UI framework
- `provider` - State management
- `supabase_flutter` - Backend integration

**Widget Dependencies**:
- Custom: All widgets in `widgets/` directory
- Models: `Streak`, `Meditation`
- Services: `SupabaseService`, `NotificationService`
- Constants: `AppColors`

## Future Enhancements

### Phase 2 (Recommended)
- [ ] Dark mode support
- [ ] Animated statistics charts
- [ ] Personalized meditation recommendations
- [ ] Mood trend mini-graph
- [ ] Haptic feedback on interactions

### Phase 3 (Nice to Have)
- [ ] Custom quote rotation
- [ ] Achievement badges display
- [ ] Social features preview
- [ ] Weekly wellness report card

## Support & Maintenance

**For Questions**: Reference this documentation
**For Bugs**: Check widget isolation first
**For Design Changes**: Update design system docs first

## References

- [Design System Docs](/.claude/skills/ui-ux-pro-max/design-system/mental-wellness-app/)
- [Material Design Guidelines](https://m3.material.io/)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Last Updated**: 2026-03-21
**Design Version**: 1.0
**Flutter Version**: 3.9.2
