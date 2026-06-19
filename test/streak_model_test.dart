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

    test('Day 1 is growing', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 14, 23, 45);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 1);
      expect(streak.ripplePhaseAt(now), RipplePhase.growing);
    });

    test('Day 2 is growing', () {
      final start = DateTime(2026, 6, 14, 23, 30);
      final now = DateTime(2026, 6, 15, 0, 15);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 2);
      expect(streak.ripplePhaseAt(now), RipplePhase.growing);
    });

    test('Day 7 is breakthrough', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 20, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 7);
      expect(streak.ripplePhaseAt(now), RipplePhase.breakthrough);
    });

    test('Day 8 is ascending', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 6, 21, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 8);
      expect(streak.ripplePhaseAt(now), RipplePhase.ascending);
    });

    test('Day 30 is rising', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 7, 13, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 30);
      expect(streak.ripplePhaseAt(now), RipplePhase.rising);
    });

    test('Day 90 is orbit', () {
      final start = DateTime(2026, 6, 14, 10, 30);
      final now = DateTime(2026, 9, 11, 9, 0);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 90);
      expect(streak.ripplePhaseAt(now), RipplePhase.orbit);
    });
  });
}
