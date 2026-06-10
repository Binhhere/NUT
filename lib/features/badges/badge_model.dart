class BadgeModel {
  const BadgeModel({
    required this.title,
    required this.requiredDays,
    required this.description,
  });

  final String title;
  final int requiredDays;
  final String description;

  bool isUnlocked(int currentDays) => currentDays >= requiredDays;
}
