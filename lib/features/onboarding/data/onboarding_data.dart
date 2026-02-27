import 'package:flutter/material.dart';

// ─── Typed Enums ──────────────────────────────────────────────

enum ImprovementArea {
  health('Health', Icons.favorite_rounded),
  career('Career', Icons.work_rounded),
  skill('Skill', Icons.code_rounded),
  recovery('Recovery', Icons.spa_rounded),
  growth('Growth', Icons.trending_up_rounded),
  focus('Focus', Icons.center_focus_strong_rounded);

  final String label;
  final IconData icon;
  const ImprovementArea(this.label, this.icon);
}

enum IdentityGoal {
  financiallyFree(
    'Become financially free',
    Icons.account_balance_wallet_rounded,
  ),
  strongBody('Build strong body', Icons.fitness_center_rounded),
  disciplined('Become disciplined', Icons.shield_rounded),
  newLanguage('Master a new language', Icons.translate_rounded),
  startBusiness('Start a business', Icons.rocket_launch_rounded),
  innerPeace('Find inner peace', Icons.self_improvement_rounded),
  betterPartner('Be a better partner', Icons.favorite_rounded),
  travelWorld('Travel the world', Icons.flight_rounded),
  readBooks('Read 20 books', Icons.menu_book_rounded);

  final String label;
  final IconData icon;
  const IdentityGoal(this.label, this.icon);
}

enum GoodHabit {
  gym('Gym', Icons.fitness_center_rounded, 'Daily Goal: 45m', 0.65),
  coding('Coding', Icons.code_rounded, null, null),
  reading('Reading', Icons.menu_book_rounded, null, null),
  meditation('Meditation', Icons.self_improvement_rounded, null, null),
  journaling('Journaling', Icons.edit_note_rounded, null, null);

  final String label;
  final IconData icon;
  final String? goal;
  final double? progress;
  const GoodHabit(this.label, this.icon, this.goal, this.progress);
}

enum BadHabit {
  cigarettes('Cigarettes', Icons.smoking_rooms_rounded, Color(0xFFEF4444)),
  doomScrolling(
    'Doom Scrolling',
    Icons.phone_android_rounded,
    Color(0xFFFACC15),
  ),
  junkFood('Junk Food', Icons.fastfood_rounded, Color(0xFFF59E0B)),
  procrastination(
    'Procrastination',
    Icons.timer_off_rounded,
    Color(0xFFEF4444),
  );

  final String label;
  final IconData icon;
  final Color color;
  const BadHabit(this.label, this.icon, this.color);
}

enum CoachRelationship {
  father('Father', 'Protective & Wise', Icons.shield_rounded),
  mother('Mother', 'Nurturing & Kind', Icons.favorite_rounded),
  uncle('Uncle', 'Casual & Direct', Icons.handshake_rounded),
  friend('Friend', 'Supportive Peer', Icons.people_rounded),
  teacher('Teacher', 'Strict & Driven', Icons.school_rounded),
  custom('Custom', 'Describe your ideal\nrelationship', Icons.edit_rounded);

  final String label;
  final String subtitle;
  final IconData icon;
  const CoachRelationship(this.label, this.subtitle, this.icon);
}

enum CoachPersonality {
  supportive(
    'Supportive',
    'Gentle nudges and\npositive reinforcement.',
    Icons.emoji_emotions_rounded,
  ),
  challenging(
    'Challenging',
    'Tough love and\nhigh standards.',
    Icons.fitness_center_rounded,
  ),
  calm(
    'Calm',
    'Mindful guidance\nto reduce stress.',
    Icons.self_improvement_rounded,
  ),
  strategic(
    'Strategic',
    'Data-driven logic\nand efficiency.',
    Icons.psychology_rounded,
  );

  final String label;
  final String description;
  final IconData icon;
  const CoachPersonality(this.label, this.description, this.icon);
}

// ─── Schedule Block ───────────────────────────────────────────

class ScheduleBlock {
  final String label;
  final IconData icon;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  bool isEnabled;

  ScheduleBlock({
    required this.label,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
    this.isEnabled = true,
  });
}
