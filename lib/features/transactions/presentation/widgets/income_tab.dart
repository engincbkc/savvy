import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_income_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/swipeable_transaction_tile.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class IncomeTab extends ConsumerWidget {
  final List<Income> incomes;
  final List<Income> allIncomes;
  final double total;

  const IncomeTab({
    super.key,
    required this.incomes,
    required this.allIncomes,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incomes.isEmpty) {
      return const EmptyState(
        icon: AppIcons.income,
        title: 'Hen\u00fcz gelir yok',
        subtitle: '\u0130lk gelirini ekleyerek ba\u015flayabilirsin.',
      );
    }

    // Kategori gruplama
    final grouped = <IncomeCategory, List<Income>>{};
    for (final i in incomes) {
      grouped.putIfAbsent(i.category, () => []).add(i);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });

    // Monthly breakdown data
    final monthlyData = buildMonthlyCategoryData<Income>(
      allIncomes,
      (i) => i.category.label,
      (i) => incomeIcon(i.category),
      (i) => i.date,
      (i) => i.amount,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        SummaryCard(
          title: 'Toplam Gelir',
          total: total,
          color: AppColors.of(context).income,
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          icon: AppIcons.income,
          itemCount: incomes.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Ayl\u0131k kategori tablosu
        if (monthlyData.months.length > 1)
          MonthlyCategoryTable(
            data: monthlyData,
            color: AppColors.of(context).income,
            prefix: '+',
          ),
        if (monthlyData.months.length > 1)
          const SizedBox(height: AppSpacing.xl),

        SectionHeader(title: 'T\u00fcm Gelirler', count: incomes.length),
        const SizedBox(height: AppSpacing.sm),
        ...incomes.map((i) => SwipeableTransactionTile(
              key: ValueKey(i.id),
              id: i.id,
              title: i.category.label,
              subtitle: i.note,
              amount: i.amount,
              date: i.date,
              color: AppColors.of(context).income,
              icon: incomeIcon(i.category),
              prefix: '+',
              isRecurring: i.isRecurring,
              person: i.person,
              onDelete: () => _confirmDelete(context, ref, i.id, 'gelir'),
              onTap: () => _showDetail(context, i),
            )),

        const SizedBox(height: AppSpacing.lg),

        // Kategoriler — Akordiyon
        CategoryAccordion(
          title: 'Kategorilere G\u00f6re',
          count: grouped.length,
          color: AppColors.of(context).income,
          children: sortedCats.map((entry) {
            final catTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
            return CategoryRow(
              icon: incomeIcon(entry.key),
              label: entry.key.label,
              amount: catTotal,
              percentage: total > 0 ? catTotal / total : 0.0,
              color: AppColors.of(context).income,
              count: entry.value.length,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('$type Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.of(context).textPrimary)),
        content: Text('Bu ${type}i silmek istedi\u011fine emin misin?',
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
              ref.read(transactionFormProvider.notifier).deleteIncome(id);
            },
            child:
                Text('Sil', style: TextStyle(color: AppColors.of(context).expense)),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Income income) {
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
          title: 'Gelir',
          categoryLabel: income.category.label,
          categoryIcon: incomeIcon(income.category),
          amount: income.amount,
          date: income.date,
          color: AppColors.of(context).income,
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          note: income.note,
          person: income.person,
          isRecurring: income.isRecurring,
          recurringEndDate: income.recurringEndDate,
          onEdit: () => _showEdit(context, income),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, Income income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditIncomeSheet(income: income),
      ),
    );
  }
}
