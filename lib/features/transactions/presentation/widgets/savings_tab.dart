import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_savings_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/swipeable_transaction_tile.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class SavingsTab extends ConsumerWidget {
  final List<Savings> savings;
  final List<Savings> allSavings;
  final double total;

  const SavingsTab({
    super.key,
    required this.savings,
    required this.allSavings,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (savings.isEmpty) {
      return const EmptyState(
        icon: AppIcons.savings,
        title: 'Hen\u00fcz birikim yok',
        subtitle: '\u0130lk birikimini ekleyerek ba\u015flayabilirsin.',
      );
    }

    final grouped = <SavingsCategory, List<Savings>>{};
    for (final s in savings) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });

    final monthlyData = buildMonthlyCategoryData<Savings>(
      allSavings,
      (s) => s.category.label,
      (s) => savingsIcon(s.category),
      (s) => s.date,
      (s) => s.amount,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        SummaryCard(
          title: 'Toplam Birikim',
          total: total,
          color: AppColors.savings,
          gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
          icon: AppIcons.savings,
          itemCount: savings.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Ayl\u0131k kategori tablosu
        if (monthlyData.months.length > 1)
          MonthlyCategoryTable(
            data: monthlyData,
            color: AppColors.savings,
            prefix: '',
          ),
        if (monthlyData.months.length > 1)
          const SizedBox(height: AppSpacing.xl),

        SectionHeader(title: 'T\u00fcm Birikimler', count: savings.length),
        const SizedBox(height: AppSpacing.sm),
        ...savings.map((s) => SwipeableTransactionTile(
              key: ValueKey(s.id),
              id: s.id,
              title: s.category.label,
              subtitle: s.note,
              amount: s.amount,
              date: s.date,
              color: AppColors.savings,
              icon: savingsIcon(s.category),
              prefix: '',
              isRecurring: false,
              person: null,
              onDelete: () => _confirmDelete(context, ref, s.id),
              onTap: () => _showEditSavings(context, s),
            )),

        const SizedBox(height: AppSpacing.lg),

        CategoryAccordion(
          title: 'Kategorilere G\u00f6re',
          count: sortedCats.length,
          color: AppColors.savings,
          children: sortedCats.map((entry) {
            final catTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
            return CategoryRow(
              icon: savingsIcon(entry.key),
              label: entry.key.label,
              amount: catTotal,
              percentage: total > 0 ? catTotal / total : 0.0,
              color: AppColors.savings,
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
        title: Text('Birikim Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.textPrimary)),
        content: Text('Bu birikimi silmek istedi\u011fine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('\u0130ptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(transactionFormProvider.notifier).deleteSavings(id);
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showEditSavings(BuildContext context, Savings s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditSavingsSheet(savings: s),
      ),
    );
  }
}
