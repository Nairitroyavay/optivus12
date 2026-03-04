import 'package:meta/meta.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final bool isOnboardingComplete;

  const AuthAuthenticated({required this.isOnboardingComplete});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthAuthenticated &&
        other.isOnboardingComplete == isOnboardingComplete;
  }

  @override
  int get hashCode => isOnboardingComplete.hashCode;
}
