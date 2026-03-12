import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addIncome(Income income) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).add(income);
    });
    return !state.hasError;
  }

  Future<bool> addExpense(Expense expense) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).add(expense);
    });
    return !state.hasError;
  }

  Future<bool> addSavings(Savings savings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).add(savings);
    });
    return !state.hasError;
  }

  Future<bool> deleteIncome(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }

  Future<bool> deleteExpense(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }

  Future<bool> deleteSavings(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }
}
