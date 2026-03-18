import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';

part 'goals_provider.g.dart';

@riverpod
Stream<List<SavingsGoal>> allGoals(Ref ref) {
  return ref.watch(savingsGoalRepositoryProvider).watchAll();
}

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addGoal(SavingsGoal goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).add(goal);
    });
    return !state.hasError;
  }

  Future<bool> updateGoal(SavingsGoal goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).update(goal);
    });
    return !state.hasError;
  }

  Future<bool> deleteGoal(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).delete(id);
    });
    return !state.hasError;
  }
}
