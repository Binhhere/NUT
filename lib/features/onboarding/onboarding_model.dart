class OnboardingProfile {
  const OnboardingProfile({
    required this.hasSeenOnboarding,
    this.username,
    this.reason,
  });

  final bool hasSeenOnboarding;
  final String? username;
  final String? reason;
}
