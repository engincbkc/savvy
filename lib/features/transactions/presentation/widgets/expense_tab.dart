import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/transactions/presentation/widgets/delete_dialog.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/collapsible_section.dart';
import 'package:savvy/shared/widgets/empty_state.dart';
import 'package:savvy/shared/widgets/portfolio_table.dart';

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
        title: 'Henüz gider yok',
        subtitle: 'İlk giderini ekleyerek başlayabilirsin.',
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
      (e) => e.person != null && e.person!.isNotEmpty
          ? '${e.person} ${e.category.label}'
          : e.category.label,
      (e) => expenseIcon(e.category),
      (e) => e.date,
      (e) => e.amount,
      isRecurring: (e) => e.isRecurring,
      getRecurringEndDate: (e) => e.recurringEndDate,
      getMonthlyOverrides: (e) => e.monthlyOverrides,
    );

    // Build portfolio rows
    final rows = expenses.map((e) {
      final dateStr =
          '${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}';
      final sub = [
        e.person ?? '',
        e.expenseType.label,
      ].where((s) => s.isNotEmpty).join(' · ');

      return PortfolioRow(
        id: e.id,
        title: e.category.label,
        subtitle: sub.isNotEmpty ? '$sub · $dateStr' : dateStr,
        amount: e.amount,
        date: e.date,
        icon: expenseIcon(e.category),
        accentColor: AppColors.of(context).expense,
        isRecurring: e.isRecurring,
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        // Özet kart — collapsible
        CollapsibleSection(
          title: 'Özet',
          icon: AppIcons.expense,
          color: AppColors.of(context).expense,
          child: Column(
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
              const SizedBox(height: AppSpacing.md),
              ExpenseTypeRow(byType: byType, total: total),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Aylık kategori tablosu — collapsible
        if (monthlyData.months.length > 1) ...[
          CollapsibleSection(
            title: 'Aylık Dağılım',
            icon: Icons.calendar_view_month_rounded,
            color: AppColors.of(context).expense,
            initiallyExpanded: false,
            child: MonthlyCategoryTable(
              data: monthlyData,
              color: AppColors.of(context).expense,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Portfolio-style table — collapsible (already has its own header)
        PortfolioTable(
          title: 'Tüm Giderler',
          titleIcon: AppIcons.expense,
          color: AppColors.of(context).expense,
          rows: rows,
          columnHeaders: const ['TUTAR', 'TİP'],
          buildColumns: (row) {
            final expense = expenses.firstWhere((e) => e.id == row.id);
            return [
              CurrencyFormatter.formatNoDecimal(row.amount),
              expense.expenseType.label,
            ];
          },
          buildActions: (row) => [
            PortfolioAction(
              icon: Icons.info_outline_rounded,
              label: 'Detay',
              onTap: () => _showDetail(
                  context, expenses.firstWhere((e) => e.id == row.id)),
            ),
            PortfolioAction(
              icon: Icons.edit_rounded,
              label: 'Düzenle',
              onTap: () => _showEdit(
                  context, expenses.firstWhere((e) => e.id == row.id)),
            ),
            PortfolioAction(
              icon: Icons.delete_outline_rounded,
              label: 'Sil',
              color: AppColors.of(context).expense,
              onTap: () => _confirmDelete(context, ref, row.id),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Kategoriler — collapsible
        CollapsibleSection(
          title: 'Kategorilere Göre',
          icon: Icons.pie_chart_outline_rounded,
          color: AppColors.of(context).expense,
          initiallyExpanded: false,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.of(context).expense.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '${grouped.length}',
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).expense,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          child: Column(
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
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDeleteConfirmation(
      context: context,
      type: 'Gider',
      onConfirm: () => ref.read(transactionFormProvider.notifier).deleteExpense(id),
    );
  }

  void _showDetail(BuildContext context, Expense expense) {
    showModalBottomSheet(useRootNavigator: true,
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
    showModalBottomSheet(useRootNavigator: true,
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
