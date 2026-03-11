import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepCoachName extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepCoachName({super.key, required this.onNext});

  @override
  ConsumerState<StepCoachName> createState() => _StepCoachNameState();
}

class _StepCoachNameState extends ConsumerState<StepCoachName> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(userPreferencesProvider).coachName ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectSuggestion(String name) {
    _controller.text = name;
    ref.read(userPreferencesProvider.notifier).setCoachName(name);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userPreferencesProvider);
    final suggestions = ['Dad', 'Maa', 'Sensei', 'Bro', 'Chief'];

    // SingleChildScrollView allows the page to scroll up when the keyboard
    // appears — this is the fix for the critical 274px keyboard overflow.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'What Should We\nCall Your Coach?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your AI an identity that resonates with you.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Glass Input Field — BackdropFilter for consistent glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLength: 50,
                  onChanged: (val) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .setCoachName(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g., Marcus, Athena, Coach...',
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: OptivusTheme.secondaryText,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    hintStyle: TextStyle(
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick name suggestions
          Text(
            'SUGGESTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: suggestions.map((name) {
              return GestureDetector(
                onTap: () => _selectSuggestion(name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OptivusTheme.primaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Preview Card — no Spacer, just natural vertical flow
          if (state.coachName != null && state.coachName!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Opacity(
              opacity: 0.85,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFDF6E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: OptivusTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: OptivusTheme.accentGold,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: OptivusTheme.primaryText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '"Good morning, let\'s execute today\'s blueprint."\n— ${state.coachName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: OptivusTheme.primaryText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Next Button
          LiquidGlassButton(
            text: 'Create My Coach',
            onPressed: widget.onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
