import 'package:flutter_test/flutter_test.dart';
import 'package:nut_mvp/features/streak/streak_model.dart';

void main() {
  group('StreakModel currentStreakDays', () {
    test('no startDate returns 0', () {
      const streak = StreakModel.empty;
      expect(streak.currentStreakDays(), 0);
    });

    test('same calendar day returns Day 1', () {
      final start = DateTime(2026, 6, 14, 10);
      final now = DateTime(2026, 6, 14, 23);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 1);
    });

    test('next calendar day returns Day 2', () {
      final start = DateTime(2026, 6, 14, 23);
      final now = DateTime(2026, 6, 15, 1);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 2);
    });

    test('after 6 calendar days returns Day 7', () {
      final start = DateTime(2026, 6, 14, 10);
      final now = DateTime(2026, 6, 20, 10);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

      expect(streak.currentStreakDays(now), 7);
    });
  });

  group('StreakModel ripplePhaseAt', () {
    test('not started returns RipplePhase.seed', () {
      const streak = StreakModel.empty;
      expect(streak.ripplePhaseAt(), RipplePhase.seed);
    });

    test('Day 1 returns RipplePhase.growing', () {
      final start = DateTime(2026, 6, 14, 10);
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.ripplePhaseAt(start), RipplePhase.growing);
    });

    test('Day 6 returns RipplePhase.growing', () {
      final start = DateTime(2026, 6, 14, 10);
      final d6 = start.add(const Duration(days: 5));
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.currentStreakDays(d6), 6);
      expect(streak.ripplePhaseAt(d6), RipplePhase.growing);
    });

    test('Day 7 returns RipplePhase.breakthrough', () {
      final start = DateTime(2026, 6, 14, 10);
      final d7 = start.add(const Duration(days: 6));
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.currentStreakDays(d7), 7);
      expect(streak.ripplePhaseAt(d7), RipplePhase.breakthrough);
    });

    test('Day 8 returns RipplePhase.ascending', () {
      final start = DateTime(2026, 6, 14, 10);
      final d8 = start.add(const Duration(days: 7));
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.currentStreakDays(d8), 8);
      expect(streak.ripplePhaseAt(d8), RipplePhase.ascending);
    });

    test('Day 30 returns RipplePhase.rising', () {
      final start = DateTime(2026, 6, 14, 10);
      final d30 = start.add(const Duration(days: 29));
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.currentStreakDays(d30), 30);
      expect(streak.ripplePhaseAt(d30), RipplePhase.rising);
    });

    test('Day 90 returns RipplePhase.orbit', () {
      final start = DateTime(2026, 6, 14, 10);
      final d90 = start.add(const Duration(days: 89));
      final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);
      expect(streak.currentStreakDays(d90), 90);
      expect(streak.ripplePhaseAt(d90), RipplePhase.orbit);
    });
  });
}
