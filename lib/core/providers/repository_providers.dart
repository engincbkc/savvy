import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/firebase_providers.dart';
import 'package:savvy/features/transactions/data/expense_repository.dart';
import 'package:savvy/features/transactions/data/income_repository.dart';
import 'package:savvy/features/savings/data/savings_repository.dart';

part 'repository_providers.g.dart';

@riverpod
IncomeRepository incomeRepository(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) throw StateError('User not authenticated');
  return IncomeRepository(
    firestore: ref.watch(firestoreProvider),
    uid: uid,
  );
}

@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) throw StateError('User not authenticated');
  return ExpenseRepository(
    firestore: ref.watch(firestoreProvider),
    uid: uid,
  );
}

@riverpod
SavingsRepository savingsRepository(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) throw StateError('User not authenticated');
  return SavingsRepository(
    firestore: ref.watch(firestoreProvider),
    uid: uid,
  );
}
