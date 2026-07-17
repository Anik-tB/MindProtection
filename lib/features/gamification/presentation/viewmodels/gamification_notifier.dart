import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../../core/db/isar_service.dart';
import '../../data/models/gamification_model.dart';

part 'gamification_notifier.g.dart';

class GamificationState {
  final int level;
  final int xp;
  final int coins;
  final int focusStreak;
  final int habitStreak;

  GamificationState({
    required this.level,
    required this.xp,
    required this.coins,
    required this.focusStreak,
    required this.habitStreak,
  });

  GamificationState copyWith({
    int? level,
    int? xp,
    int? coins,
    int? focusStreak,
    int? habitStreak,
  }) {
    return GamificationState(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      focusStreak: focusStreak ?? this.focusStreak,
      habitStreak: habitStreak ?? this.habitStreak,
    );
  }
}

@riverpod
class Gamification extends _$Gamification {
  late final Isar _isar;

  @override
  GamificationState build() {
    _isar = IsarService.instance;
    _loadState();
    
    return GamificationState(
      level: 1,
      xp: 0,
      coins: 0,
      focusStreak: 0,
      habitStreak: 0,
    );
  }

  Future<void> _loadState() async {
    final stats = await _isar.gamificationModels.get(1);
    if (stats != null) {
      state = GamificationState(
        level: stats.level,
        xp: stats.xp,
        coins: stats.coins,
        focusStreak: stats.focusStreak,
        habitStreak: stats.habitStreak,
      );
    } else {
      // Initialize if empty
      await _saveState(
        level: 1,
        xp: 0,
        coins: 0,
        focusStreak: 0,
        habitStreak: 0,
      );
    }
  }

  Future<void> _saveState({
    required int level,
    required int xp,
    required int coins,
    required int focusStreak,
    required int habitStreak,
  }) async {
    final model = GamificationModel()
      ..id = 1
      ..level = level
      ..xp = xp
      ..coins = coins
      ..focusStreak = focusStreak
      ..habitStreak = habitStreak;

    await _isar.writeTxn(() async {
      await _isar.gamificationModels.put(model);
    });
  }

  Future<void> addXp(int amount) async {
    int newXp = state.xp + amount;
    int newLevel = state.level;
    int newCoins = state.coins;

    // 100 XP per level scaling
    int xpNeeded = newLevel * 100;

    while (newXp >= xpNeeded) {
      newXp -= xpNeeded;
      newLevel += 1;
      newCoins += newLevel * 20; // 20 coins reward per level up
      xpNeeded = newLevel * 100;
    }

    state = state.copyWith(xp: newXp, level: newLevel, coins: newCoins);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }

  Future<void> addCoins(int amount) async {
    state = state.copyWith(coins: state.coins + amount);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) {
      return false;
    }
    state = state.copyWith(coins: state.coins - amount);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
    return true;
  }

  Future<void> incrementFocusStreak() async {
    state = state.copyWith(focusStreak: state.focusStreak + 1);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }

  Future<void> resetFocusStreak() async {
    state = state.copyWith(focusStreak: 0);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }

  Future<void> incrementHabitStreak() async {
    state = state.copyWith(habitStreak: state.habitStreak + 1);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }

  Future<void> resetHabitStreak() async {
    state = state.copyWith(habitStreak: 0);
    await _saveState(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      focusStreak: state.focusStreak,
      habitStreak: state.habitStreak,
    );
  }
}
