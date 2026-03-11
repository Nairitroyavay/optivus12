import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  bool _isChecking = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent! Check your inbox.'),
            ),
          );
          _startCountdown();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send email. Please try again later.'),
          ),
        );
      }
    }
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _checkVerified() async {
    setState(() => _isChecking = true);
    try {
      // Reload the user from Firebase to get the latest emailVerified status.
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Verified — go to login so the auth flow re-hydrates cleanly.
        if (mounted) context.go('/login');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email not verified yet. Please check your inbox.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not check status. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Glass envelope icon
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 48,
                      color: OptivusTheme.primaryText,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Check Your Inbox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: OptivusTheme.primaryText,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to your email address.\nOpen it to activate your Optivus account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: 48),

              // Primary CTA — check verification status
              LiquidGlassButton(
                text: 'I\'ve Verified My Email',
                onPressed: _isChecking ? () {} : _checkVerified,
                isLoading: _isChecking,
                loadingText: 'Checking…',
                icon: Icons.check_circle_outline_rounded,
              ),

              const SizedBox(height: 20),

              // Resend email button with cooldown
              GestureDetector(
                onTap: _resendCountdown > 0 ? null : _resendEmail,
                child: AnimatedOpacity(
                  opacity: _resendCountdown > 0 ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend email in ${_resendCountdown}s'
                          : 'Didn\'t receive it? Resend email',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OptivusTheme.accentGold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Back to Login
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  'Back to Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
