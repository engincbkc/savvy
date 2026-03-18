import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/swipeable_transaction_tile.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class ExpenseTab extends ConsumerWidget {
  final List<Expense> expenses;
  final List<Expense> allExpenses;
  final double total;

  const ExpenseTab({
    super.key,
    required this.expenses,
    required this.allExpenses,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const EmptyState(
        icon: AppIcons.expense,
        title: 'Hen\u00fcz gider yok',
        subtitle: '\u0130lk giderini ekleyerek ba\u015flayabilirsin.',
      );
    }

    final grouped = <ExpenseCategory, List<Expense>>{};
    for (final e in expenses) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, e) => s + e.amount);
        final bT = b.value.fold(0.0, (s, e) => s + e.amount);
        return bT.compareTo(aT);
      });

    final byType = <ExpenseType, double>{};
    for (final e in expenses) {
      byType[e.expenseType] = (byType[e.expenseType] ?? 0) + e.amount;
    }

    final monthlyData = buildMonthlyCategoryData<Expense>(
      allExpenses,
      (e) => e.category.label,
      (e) => expenseIcon(e.category),
      (e) => e.date,
      (e) => e.amount,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        SummaryCard(
          title: 'Toplam Gider',
          total: total,
          color: AppColors.of(context).expense,
          gradient: const [Color(0xFFC81E1E), Color(0xFFEF4444)],
          icon: AppIcons.expense,
          itemCount: expenses.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.base),

        ExpenseTypeRow(byType: byType, total: total),
        const SizedBox(height: AppSpacing.lg),

        // Ayl\u0131k kategori tablosu
        if (monthlyData.months.length > 1)
          MonthlyCategoryTable(
            data: monthlyData,
            color: AppColors.of(context).expense,
            prefix: '-',
          ),
        if (monthlyData.months.length > 1)
          const SizedBox(height: AppSpacing.xl),

        SectionHeader(title: 'T\u00fcm Giderler', count: expenses.length),
        const SizedBox(height: AppSpacing.sm),
        ...expenses.map((e) => SwipeableTransactionTile(
              key: ValueKey(e.id),
              id: e.id,
              title: e.category.label,
              subtitle: e.note,
              amount: e.amount,
              date: e.date,
              color: AppColors.of(context).expense,
              icon: expenseIcon(e.category),
              prefix: '-',
              isRecurring: e.isRecurring,
              person: e.person,
              onDelete: () => _confirmDelete(context, ref, e.id),
              onTap: () => _showDetail(context, e),
            )),

        const SizedBox(height: AppSpacing.lg),

        CategoryAccordion(
          title: 'Kategorilere G\u00f6re',
          count: grouped.length,
          color: AppColors.of(context).expense,
          children: sortedCats.map((entry) {
            final catTotal = entry.value.fold(0.0, (s, e) => s + e.amount);
            return CategoryRow(
              icon: expenseIcon(entry.key),
              label: entry.key.label,
              amount: catTotal,
              percentage: total > 0 ? catTotal / total : 0.0,
              color: AppColors.of(context).expense,
              count: entry.value.length,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Gider Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.of(context).textPrimary)),
        content: Text('Bu gideri silmek istedi\u011fine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('\u0130ptal',
                style: TextStyle(color: AppColors.of(context).textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(transactionFormProvider.notifier).deleteExpense(id);
            },
            child: Text('Sil', style: TextStyle(color: AppColors.of(context).expense)),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: TransactionDetailSheet(
          title: 'Gider',
          categoryLabel: expense.category.label,
          categoryIcon: expenseIcon(expense.category),
          amount: expense.amount,
          date: expense.date,
          color: AppColors.of(context).expense,
          gradient: const [Color(0xFFC81E1E), Color(0xFFEF4444)],
          note: expense.note,
          person: expense.person,
          isRecurring: expense.isRecurring,
          recurringEndDate: expense.recurringEndDate,
          extraLabel: 'Gider Tipi',
          extraValue: expense.expenseType.label,
          onEdit: () => _showEdit(context, expense),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditExpenseSheet(expense: expense),
      ),
    );
  }
}
