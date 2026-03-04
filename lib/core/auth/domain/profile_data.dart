/// Domain entity for a user profile.
/// No Firebase imports — this lives in the domain layer.
class ProfileData {
  final bool isOnboardingComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileData({
    required this.isOnboardingComplete,
    this.createdAt,
    this.updatedAt,
  });
}
