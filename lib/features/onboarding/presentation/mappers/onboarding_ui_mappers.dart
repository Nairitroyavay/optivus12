import 'package:flutter/material.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';

/// Presentation-layer mappers that convert domain string keys to Flutter UI types.
/// This is the ONLY place where domain enums touch Flutter IconData/Color.
class OnboardingUiMappers {
  OnboardingUiMappers._();

  // ─── Icon Mappings ──────────────────────────────────────────

  static const Map<String, IconData> _iconKeyMap = {
    'favorite': Icons.favorite_rounded,
    'work': Icons.work_rounded,
    'code': Icons.code_rounded,
    'spa': Icons.spa_rounded,
    'trending_up': Icons.trending_up_rounded,
    'center_focus_strong': Icons.center_focus_strong_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'shield': Icons.shield_rounded,
    'translate': Icons.translate_rounded,
    'rocket_launch': Icons.rocket_launch_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'flight': Icons.flight_rounded,
    'menu_book': Icons.menu_book_rounded,
    'edit_note': Icons.edit_note_rounded,
    'smoking_rooms': Icons.smoking_rooms_rounded,
    'phone_android': Icons.phone_android_rounded,
    'fastfood': Icons.fastfood_rounded,
    'timer_off': Icons.timer_off_rounded,
    'handshake': Icons.handshake_rounded,
    'people': Icons.people_rounded,
    'school': Icons.school_rounded,
    'edit': Icons.edit_rounded,
    'emoji_emotions': Icons.emoji_emotions_rounded,
    'psychology': Icons.psychology_rounded,
    'bedtime': Icons.bedtime_rounded,
    'event': Icons.event_rounded,
  };

  /// Resolve an iconKey string to a Flutter IconData.
  static IconData iconFromKey(String key) {
    return _iconKeyMap[key] ?? Icons.help_outline_rounded;
  }

  // ─── Typed Enum Accessors ───────────────────────────────────

  static IconData improvementAreaIcon(ImprovementArea area) =>
      iconFromKey(area.iconKey);

  static IconData identityGoalIcon(IdentityGoal goal) =>
      iconFromKey(goal.iconKey);

  static IconData goodHabitIcon(GoodHabit habit) => iconFromKey(habit.iconKey);

  static IconData badHabitIcon(BadHabit habit) => iconFromKey(habit.iconKey);

  static IconData coachRelationshipIcon(CoachRelationship rel) =>
      iconFromKey(rel.iconKey);

  static IconData coachPersonalityIcon(CoachPersonality pers) =>
      iconFromKey(pers.iconKey);

  // ─── Color Mapping ──────────────────────────────────────────

  /// Convert a hex color string (e.g., "#EF4444") to a Flutter Color.
  static Color colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF'); // Add full opacity
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color badHabitColor(BadHabit habit) => colorFromHex(habit.colorHex);

  static Color scheduleBlockColor(ScheduleBlock block) =>
      colorFromHex(block.colorHex);

  // ─── TimeOfDay Mapping ──────────────────────────────────────

  static TimeOfDay scheduleBlockStartTime(ScheduleBlock block) =>
      TimeOfDay(hour: block.startHour, minute: block.startMinute);

  static TimeOfDay scheduleBlockEndTime(ScheduleBlock block) =>
      TimeOfDay(hour: block.endHour, minute: block.endMinute);
}
