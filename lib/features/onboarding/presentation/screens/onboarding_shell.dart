import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/theme/app_gradients.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';
import 'package:optivus/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_welcome.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_improvement_areas.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_identity_goals.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_good_habits.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_bad_habits.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_daily_schedule.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_coach_relationship.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_coach_selection.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_coach_name.dart';
import 'package:optivus/features/onboarding/presentation/steps/step_blueprint_summary.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalPages = 10;
  bool _isHydrating = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _hydrateCache();
  }

  Future<void> _hydrateCache() async {
    // Wait for the async hydration from shared_preferences to finish
    await ref.read(userPreferencesProvider.notifier).hydrate();

    // Jump to the cached step if any
    final savedStep = ref.read(userPreferencesProvider).cachedStep;
    if (savedStep > 0 && savedStep < _totalPages && mounted) {
      _pageController = PageController(
        initialPage: savedStep,
        viewportFraction: 1.0,
      );
      _currentPage = savedStep;
    }

    if (mounted) {
      setState(() {
        _isHydrating = false;
      });
    }
  }

  void _goToNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    context.go('/home/feed');
  }

  void _finish() async {
    // TODO: Save final selection data to Supabase user_preferences table
    // (This should be done inside userPreferencesProvider in the next phase)

    // Clear the local step cache so if they restart, they don't jump to step 10
    await ref.read(userPreferencesProvider.notifier).clearCache();

    // Mark onboarding complete in AuthSessionProvider
    // This updates SharedPreferences, the Supabase profiles table, AND triggers AppRouter redirect
    await ref.read(authSessionProvider.notifier).completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isHydrating) {
      return const Scaffold(
        backgroundColor: OptivusTheme.backgroundTop,
        body: Center(
          child: CircularProgressIndicator(color: OptivusTheme.accentGold),
        ),
      );
    }

    final progress = (_currentPage + 1) / _totalPages;

    return Container(
      decoration: BoxDecoration(gradient: AppGradients.gradientForIndex(0)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Progress Bar ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return Container(
                      height: 4,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  OptivusTheme.accentGold,
                                  Color(0xFFD4A10A),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ─── Header ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OnboardingHeader(
                  currentStep: _currentPage + 1,
                  totalSteps: _totalPages,
                  onBack: _currentPage > 0 ? _goBack : null,
                  onSkip: _skip,
                ),
              ),

              // ─── Page Content ───────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    // Save the step progress so users don't lose their place if the OS kills the app
                    ref
                        .read(userPreferencesProvider.notifier)
                        .setCachedStep(index);
                  },
                  children: [
                    StepWelcome(onNext: _goToNext),
                    StepImprovementAreas(onNext: _goToNext),
                    StepIdentityGoals(onNext: _goToNext),
                    StepGoodHabits(onNext: _goToNext),
                    StepBadHabits(onNext: _goToNext),
                    StepDailySchedule(onNext: _goToNext),
                    StepCoachRelationship(onNext: _goToNext),
                    StepCoachSelection(onNext: _goToNext),
                    StepCoachName(onNext: _goToNext),
                    StepBlueprintSummary(onFinish: _finish),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
