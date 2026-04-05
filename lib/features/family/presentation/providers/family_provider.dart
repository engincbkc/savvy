import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';

part 'family_provider.g.dart';

/// Tüm işlemleri person alanına göre gruplar.
/// person == null olanlar "Ortak" grubuna girer.
@riverpod
Map<String, ({double income, double expense})> personContributions(Ref ref) {
  final incomes = ref.watch(allIncomesProvider).value ?? [];
  final expenses = ref.watch(allExpensesProvider).value ?? [];

  final result = <String, ({double income, double expense})>{};

  for (final i in incomes) {
    final key = i.person?.trim().isNotEmpty == true ? i.person! : 'Ortak';
    final cur = result[key] ?? (income: 0, expense: 0);
    result[key] = (income: cur.income + i.amount, expense: cur.expense);
  }
  for (final e in expenses) {
    final key = e.person?.trim().isNotEmpty == true ? e.person! : 'Ortak';
    final cur = result[key] ?? (income: 0, expense: 0);
    result[key] = (income: cur.income, expense: cur.expense + e.amount);
  }

  return result;
}
