import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';

class UserPreferencesState {
  final List<ImprovementArea> improvementAreas;
  final List<IdentityGoal> identityGoals;
  final String? customGoal;
  final List<GoodHabit> goodHabits;
  final List<BadHabit> badHabits;
  final List<String> customBadHabits;
  final List<ScheduleBlock> schedule;
  final CoachRelationship? coachRelationship;
  final CoachPersonality? coachPersonality;
  final String? coachName;
  final int cachedStep;

  const UserPreferencesState({
    this.improvementAreas = const [],
    this.identityGoals = const [],
    this.customGoal,
    this.goodHabits = const [],
    this.badHabits = const [],
    this.customBadHabits = const [],
    this.schedule = const [],
    this.coachRelationship,
    this.coachPersonality,
    this.coachName,
    this.cachedStep = 0,
  });

  /// The default schedule payload exactly as in the original model
  static List<ScheduleBlock> defaultSchedule() {
    return [
      ScheduleBlock(
        label: 'Sleep',
        icon: Icons.bedtime_rounded,
        color: const Color(0xFF6B7280),
        startTime: const TimeOfDay(hour: 22, minute: 0),
        endTime: const TimeOfDay(hour: 6, minute: 30),
      ),
      ScheduleBlock(
        label: 'Classes',
        icon: Icons.school_rounded,
        color: const Color(0xFFFACC15),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      ),
      ScheduleBlock(
        label: 'Work',
        icon: Icons.work_rounded,
        color: const Color(0xFFEF4444),
        startTime: const TimeOfDay(hour: 13, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
      ScheduleBlock(
        label: 'Gym',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF10B981),
        startTime: const TimeOfDay(hour: 17, minute: 30),
        endTime: const TimeOfDay(hour: 19, minute: 0),
      ),
    ];
  }

  UserPreferencesState copyWith({
    List<ImprovementArea>? improvementAreas,
    List<IdentityGoal>? identityGoals,
    String? customGoal,
    bool clearCustomGoal = false,
    List<GoodHabit>? goodHabits,
    List<BadHabit>? badHabits,
    List<String>? customBadHabits,
    List<ScheduleBlock>? schedule,
    CoachRelationship? coachRelationship,
    CoachPersonality? coachPersonality,
    String? coachName,
    bool clearCoachName = false,
    int? cachedStep,
  }) {
    return UserPreferencesState(
      improvementAreas: improvementAreas ?? this.improvementAreas,
      identityGoals: identityGoals ?? this.identityGoals,
      customGoal: clearCustomGoal ? null : (customGoal ?? this.customGoal),
      goodHabits: goodHabits ?? this.goodHabits,
      badHabits: badHabits ?? this.badHabits,
      customBadHabits: customBadHabits ?? this.customBadHabits,
      schedule: schedule ?? this.schedule,
      coachRelationship: coachRelationship ?? this.coachRelationship,
      coachPersonality: coachPersonality ?? this.coachPersonality,
      coachName: clearCoachName ? null : (coachName ?? this.coachName),
      cachedStep: cachedStep ?? this.cachedStep,
    );
  }

  /// Convert to Map for Supabase `user_preferences` table and SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'improvement_areas': improvementAreas.map((e) => e.name).toList(),
      'identity_goals': [
        ...identityGoals.map((e) => e.name),
        if (customGoal != null && customGoal!.isNotEmpty) 'custom:$customGoal',
      ],
      'good_habits': goodHabits.map((e) => e.name).toList(),
      'bad_habits': [
        ...badHabits.map((e) => e.name),
        ...customBadHabits.map((e) => 'custom:$e'),
      ],
      'schedule': schedule
          .where((b) => b.isEnabled)
          .map(
            (b) => {
              'label': b.label,
              'start':
                  '${b.startTime.hour}:${b.startTime.minute.toString().padLeft(2, '0')}',
              'end':
                  '${b.endTime.hour}:${b.endTime.minute.toString().padLeft(2, '0')}',
              'icon_code': b.icon.codePoint,
              'color_value': b.color.toARGB32(),
            },
          )
          .toList(),
      'coach_relationship': coachRelationship?.name,
      'coach_personality': coachPersonality?.name,
      'coach_name': coachName,
      'cached_step': cachedStep,
    };
  }

  /// Factory from JSON (for cache hydration)
  factory UserPreferencesState.fromJson(Map<String, dynamic> json) {
    try {
      // Parse improvement areas
      final iaList = (json['improvement_areas'] as List?)?.cast<String>() ?? [];
      final parsedIa = iaList
          .map(
            (e) => ImprovementArea.values.firstWhere(
              (v) => v.name == e,
              orElse: () => ImprovementArea.health,
            ),
          )
          .toList();

      // Parse identity goals + custom
      final igList = (json['identity_goals'] as List?)?.cast<String>() ?? [];
      final parsedIg = <IdentityGoal>[];
      String? parsedCustomGoal;
      for (final g in igList) {
        if (g.startsWith('custom:')) {
          parsedCustomGoal = g.replaceFirst('custom:', '');
        } else {
          try {
            parsedIg.add(IdentityGoal.values.firstWhere((v) => v.name == g));
          } catch (_) {}
        }
      }

      // Parse good habits
      final ghList = (json['good_habits'] as List?)?.cast<String>() ?? [];
      final parsedGh = ghList
          .map(
            (e) => GoodHabit.values.firstWhere(
              (v) => v.name == e,
              orElse: () => GoodHabit.coding,
            ),
          )
          .toList();

      // Parse bad habits + custom
      final bhList = (json['bad_habits'] as List?)?.cast<String>() ?? [];
      final parsedBh = <BadHabit>[];
      final parsedCustomBad = <String>[];
      for (final h in bhList) {
        if (h.startsWith('custom:')) {
          parsedCustomBad.add(h.replaceFirst('custom:', ''));
        } else {
          try {
            parsedBh.add(BadHabit.values.firstWhere((v) => v.name == h));
          } catch (_) {}
        }
      }

      // Parse schedule
      final schedList =
          (json['schedule'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final parsedSchedule = schedList.map((s) {
        final startParts = (s['start'] as String).split(':');
        final endParts = (s['end'] as String).split(':');
        return ScheduleBlock(
          label: s['label'] ?? 'Unknown',
          icon: IconData(
            s['icon_code'] ?? Icons.event.codePoint,
            fontFamily: 'MaterialIcons',
          ),
          color: Color(s['color_value'] ?? 0xFF6B7280),
          startTime: TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          ),
          endTime: TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          ),
          isEnabled: true,
        );
      }).toList();

      // Parse Enums
      final cr = json['coach_relationship'] as String?;
      CoachRelationship? parsedCr;
      if (cr != null) {
        parsedCr = CoachRelationship.values.firstWhere(
          (v) => v.name == cr,
          orElse: () => CoachRelationship.custom,
        );
      }

      final cp = json['coach_personality'] as String?;
      CoachPersonality? parsedCp;
      if (cp != null) {
        parsedCp = CoachPersonality.values.firstWhere(
          (v) => v.name == cp,
          orElse: () => CoachPersonality.supportive,
        );
      }

      return UserPreferencesState(
        improvementAreas: parsedIa,
        identityGoals: parsedIg,
        customGoal: parsedCustomGoal,
        goodHabits: parsedGh,
        badHabits: parsedBh,
        customBadHabits: parsedCustomBad,
        schedule: parsedSchedule.isEmpty ? defaultSchedule() : parsedSchedule,
        coachRelationship: parsedCr,
        coachPersonality: parsedCp,
        coachName: json['coach_name'] as String?,
        cachedStep: json['cached_step'] as int? ?? 0,
      );
    } catch (e) {
      // On any parse error (e.g. enum changed), fallback to blank state
      return UserPreferencesState(schedule: defaultSchedule());
    }
  }
}

// ─── Riverpod Notifier ───────────────────────────────────────

class UserPreferencesNotifier extends Notifier<UserPreferencesState> {
  static const _cacheKey = 'onboarding_cache';

  @override
  UserPreferencesState build() {
    // Return default initially, hydration is explicit
    return UserPreferencesState(
      schedule: UserPreferencesState.defaultSchedule(),
    );
  }

  /// Load from local SharedPreferences cache
  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = prefs.getString(_cacheKey);
      if (cache != null) {
        final Map<String, dynamic> json = jsonDecode(cache);
        state = UserPreferencesState.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to hydrate cache: $e');
    }
  }

  /// Save to local cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Failed to save root cache: $e');
    }
  }

  /// Update the current step in cache (so if OS kills app, they remain on the tab)
  void setCachedStep(int step) {
    state = state.copyWith(cachedStep: step);
    _saveToCache();
  }

  // --- Step 2 Mutations ---
  void toggleImprovementArea(ImprovementArea area) {
    if (state.improvementAreas.contains(area)) {
      state = state.copyWith(
        improvementAreas: state.improvementAreas
            .where((a) => a != area)
            .toList(),
      );
    } else {
      state = state.copyWith(
        improvementAreas: [...state.improvementAreas, area],
      );
    }
    _saveToCache();
  }

  // --- Step 3 Mutations ---
  void toggleIdentityGoal(IdentityGoal goal) {
    if (state.identityGoals.contains(goal)) {
      state = state.copyWith(
        identityGoals: state.identityGoals.where((g) => g != goal).toList(),
      );
    } else {
      state = state.copyWith(identityGoals: [...state.identityGoals, goal]);
    }
    _saveToCache();
  }

  void setCustomGoal(String? goal) {
    state = state.copyWith(
      customGoal: goal,
      clearCustomGoal: goal == null || goal.isEmpty,
    );
    _saveToCache();
  }

  // --- Step 4 Mutations ---
  void toggleGoodHabit(GoodHabit habit) {
    if (state.goodHabits.contains(habit)) {
      state = state.copyWith(
        goodHabits: state.goodHabits.where((h) => h != habit).toList(),
      );
    } else {
      state = state.copyWith(goodHabits: [...state.goodHabits, habit]);
    }
    _saveToCache();
  }

  // --- Step 5 Mutations ---
  void toggleBadHabit(BadHabit habit) {
    if (state.badHabits.contains(habit)) {
      state = state.copyWith(
        badHabits: state.badHabits.where((h) => h != habit).toList(),
      );
    } else {
      state = state.copyWith(badHabits: [...state.badHabits, habit]);
    }
    _saveToCache();
  }

  void addCustomBadHabit(String habit) {
    if (!state.customBadHabits.contains(habit)) {
      state = state.copyWith(
        customBadHabits: [...state.customBadHabits, habit],
      );
      _saveToCache();
    }
  }

  void removeCustomBadHabit(String habit) {
    state = state.copyWith(
      customBadHabits: state.customBadHabits.where((h) => h != habit).toList(),
    );
    _saveToCache();
  }

  // --- Step 6 Mutations ---
  void updateScheduleBlock(int index, ScheduleBlock block) {
    final newSchedule = List<ScheduleBlock>.from(state.schedule);
    newSchedule[index] = block;
    state = state.copyWith(schedule: newSchedule);
    _saveToCache();
  }

  // --- Step 7 Mutations ---
  void setCoachRelationship(CoachRelationship relation) {
    state = state.copyWith(coachRelationship: relation);
    _saveToCache();
  }

  // --- Step 8 Mutations ---
  void setCoachPersonality(CoachPersonality personality) {
    state = state.copyWith(coachPersonality: personality);
    _saveToCache();
  }

  // --- Step 9 Mutations ---
  void setCoachName(String? name) {
    state = state.copyWith(
      coachName: name,
      clearCoachName: name == null || name.isEmpty,
    );
    _saveToCache();
  }

  /// Call this when finishing onboarding
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}

// ─── Global Provider ──────────────────────────────────────────

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferencesState>(() {
      return UserPreferencesNotifier();
    });
