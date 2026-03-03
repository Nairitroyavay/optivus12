// ─── Domain-layer onboarding data models ──────────────────────
//
// ZERO Flutter imports. Platform-agnostic.
// Presentation-layer mappers convert iconKey/colorHex to IconData/Color.

// ─── Typed Enums ──────────────────────────────────────────────

enum ImprovementArea {
  health('Health', 'favorite'),
  career('Career', 'work'),
  skill('Skill', 'code'),
  recovery('Recovery', 'spa'),
  growth('Growth', 'trending_up'),
  focus('Focus', 'center_focus_strong');

  final String label;
  final String iconKey;
  const ImprovementArea(this.label, this.iconKey);
}

enum IdentityGoal {
  financiallyFree('Become financially free', 'account_balance_wallet'),
  strongBody('Build strong body', 'fitness_center'),
  disciplined('Become disciplined', 'shield'),
  newLanguage('Master a new language', 'translate'),
  startBusiness('Start a business', 'rocket_launch'),
  innerPeace('Find inner peace', 'self_improvement'),
  betterPartner('Be a better partner', 'favorite'),
  travelWorld('Travel the world', 'flight'),
  readBooks('Read 20 books', 'menu_book');

  final String label;
  final String iconKey;
  const IdentityGoal(this.label, this.iconKey);
}

enum GoodHabit {
  gym('Gym', 'fitness_center', 'Daily Goal: 45m', 0.65),
  coding('Coding', 'code', null, null),
  reading('Reading', 'menu_book', null, null),
  meditation('Meditation', 'self_improvement', null, null),
  journaling('Journaling', 'edit_note', null, null);

  final String label;
  final String iconKey;
  final String? goal;
  final double? progress;
  const GoodHabit(this.label, this.iconKey, this.goal, this.progress);
}

enum BadHabit {
  cigarettes('Cigarettes', 'smoking_rooms', '#EF4444'),
  doomScrolling('Doom Scrolling', 'phone_android', '#FACC15'),
  junkFood('Junk Food', 'fastfood', '#F59E0B'),
  procrastination('Procrastination', 'timer_off', '#EF4444');

  final String label;
  final String iconKey;
  final String colorHex;
  const BadHabit(this.label, this.iconKey, this.colorHex);
}

enum CoachRelationship {
  father('Father', 'Protective & Wise', 'shield'),
  mother('Mother', 'Nurturing & Kind', 'favorite'),
  uncle('Uncle', 'Casual & Direct', 'handshake'),
  friend('Friend', 'Supportive Peer', 'people'),
  teacher('Teacher', 'Strict & Driven', 'school'),
  custom('Custom', 'Describe your ideal\nrelationship', 'edit');

  final String label;
  final String subtitle;
  final String iconKey;
  const CoachRelationship(this.label, this.subtitle, this.iconKey);
}

enum CoachPersonality {
  supportive(
    'Supportive',
    'Gentle nudges and\npositive reinforcement.',
    'emoji_emotions',
  ),
  challenging(
    'Challenging',
    'Tough love and\nhigh standards.',
    'fitness_center',
  ),
  calm('Calm', 'Mindful guidance\nto reduce stress.', 'self_improvement'),
  strategic('Strategic', 'Data-driven logic\nand efficiency.', 'psychology');

  final String label;
  final String description;
  final String iconKey;
  const CoachPersonality(this.label, this.description, this.iconKey);
}

// ─── Schedule Block ───────────────────────────────────────────

class ScheduleBlock {
  final String label;
  final String iconKey;
  final String colorHex;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool isEnabled;

  const ScheduleBlock({
    required this.label,
    required this.iconKey,
    required this.colorHex,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.isEnabled = true,
  });

  ScheduleBlock copyWith({
    String? label,
    String? iconKey,
    String? colorHex,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? isEnabled,
  }) {
    return ScheduleBlock(
      label: label ?? this.label,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
