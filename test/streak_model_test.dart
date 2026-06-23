import 'package:flutter_test/flutter_test.dart';
import 'package:nut_mvp/features/streak/streak_model.dart';

void main() {
  group('StreakModel.currentStreakDays', () {
    test('returns 0 when startDate is null', () {
      const streak = StreakModel.empty;

      expect(streak.currentStreakDays(DateTime(2026, 6, 20)), 0);
    });

    test('same calendar day as startDate is Day 1', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 14, 23, 45);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 1);
    });

    test('next calendar day is Day 2', () {
      final start = DateTime(2026, 6, 14, 23, 30);
      final now = DateTime(2026, 6, 15, 0, 15);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 2);
    });

    test('six calendar days after startDate is Day 7', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 20, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 7);
    });
  });

  group('StreakModel.ripplePhaseAt', () {
    test('not started is seed', () {
      const streak = StreakModel.empty;

      expect(streak.ripplePhaseAt(DateTime(2026, 6, 20)), RipplePhase.seed);
    });

    test('Day 1 is breathing', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 14, 23, 45);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 1);
      expect(streak.ripplePhaseAt(now), RipplePhase.breathing);
      expect(streak.breathingProgressAt(now), closeTo(1 / 3, 0.001));
    });

    test('Day 3 is breathing at full seed growth', () {
      final start = DateTime(2026, 6, 14, 23, 30);
      final now = DateTime(2026, 6, 16, 0, 15);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 3);
      expect(streak.ripplePhaseAt(now), RipplePhase.breathing);
      expect(streak.breathingProgressAt(now), 1.0);
    });

    test('Day 4 starts piercing with the first ring opened', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 17, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 4);
      expect(streak.ripplePhaseAt(now), RipplePhase.piercing);
      expect(streak.piercedRingCountAt(now), 1);
    });

    test('Day 10 has seven pierced rings and about 20 percent decay', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 23, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 10);
      expect(streak.ripplePhaseAt(now), RipplePhase.piercing);
      expect(streak.piercedRingCountAt(now), 7);
      expect(streak.ringDecayProgressAt(now), closeTo(0.20, 0.001));
    });

    test('Day 20 has seventeen pierced rings and about 80 percent decay', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 7, 3, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 20);
      expect(streak.ripplePhaseAt(now), RipplePhase.piercing);
      expect(streak.piercedRingCountAt(now), 17);
      expect(streak.ringDecayProgressAt(now), closeTo(0.80, 0.001));
    });

    test('Day 21 is breakthrough with all rings pierced', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 7, 4, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 21);
      expect(streak.ripplePhaseAt(now), RipplePhase.breakthrough);
      expect(streak.piercedRingCountAt(now), StreakModel.totalRingLayers);
      expect(streak.ringDecayProgressAt(now), 1.0);
    });

    test('Day 22 and later use the sprout phase', () {
      final start = DateTime(2026, 1, 1, 10, 30);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.ripplePhaseAt(DateTime(2026, 1, 22)), RipplePhase.pet);
      expect(streak.ripplePhaseAt(DateTime(2026, 4, 10)), RipplePhase.pet);
      expect(streak.ripplePhaseAt(DateTime(2026, 7, 19)), RipplePhase.pet);
      expect(streak.ripplePhaseAt(DateTime(2026, 12, 31)), RipplePhase.pet);
    });
  });
}
