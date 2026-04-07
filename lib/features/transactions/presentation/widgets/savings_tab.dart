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
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_savings_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/collapsible_section.dart';
import 'package:savvy/shared/widgets/empty_state.dart';
import 'package:savvy/shared/widgets/portfolio_table.dart';

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
        title: 'Henüz birikim yok',
        subtitle: 'İlk birikimini ekleyerek başlayabilirsin.',
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

    // Build portfolio rows — birikim portföy gibi gösterilir
    final rows = savings.map((s) {
      final dateStr =
          '${s.date.day.toString().padLeft(2, '0')}.${s.date.month.toString().padLeft(2, '0')}.${s.date.year}';
      // Yüzde hesapla (toplam içindeki payı)
      final pct = total > 0 ? (s.amount / total * 100) : 0.0;

      return PortfolioRow(
        id: s.id,
        title: s.category.label,
        subtitle: s.note?.isNotEmpty == true ? '${s.note} · $dateStr' : dateStr,
        amount: s.amount,
        date: s.date,
        icon: savingsIcon(s.category),
        accentColor: AppColors.of(context).savings,
        extraColumns: {
          'PAY': '%${pct.toStringAsFixed(1)}',
        },
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        // Özet — collapsible
        CollapsibleSection(
          title: 'Özet',
          icon: AppIcons.savings,
          color: AppColors.of(context).savings,
          child: SummaryCard(
            title: 'Toplam Birikim',
            total: total,
            color: AppColors.of(context).savings,
            gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
            icon: AppIcons.savings,
            itemCount: savings.length,
            categoryCount: grouped.length,
            insights: _buildSavingsInsights(savings, grouped, total),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Aylık dağılım — collapsible
        if (monthlyData.months.length > 1) ...[
          CollapsibleSection(
            title: 'Aylık Dağılım',
            icon: Icons.calendar_view_month_rounded,
            color: AppColors.of(context).savings,
            initiallyExpanded: false,
            child: MonthlyCategoryTable(
              data: monthlyData,
              color: AppColors.of(context).savings,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Portföy tablosu (kendi aç/kapat başlığı var)
        PortfolioTable(
          title: 'Birikim Portföyü',
          titleIcon: AppIcons.savings,
          color: AppColors.of(context).savings,
          rows: rows,
          columnHeaders: const ['TUTAR', 'PAY%'],
          buildColumns: (row) {
            final s = savings.firstWhere((s) => s.id == row.id);
            final pct = total > 0 ? (s.amount / total * 100) : 0.0;
            return [
              CurrencyFormatter.formatNoDecimal(row.amount),
              '%${pct.toStringAsFixed(1)}',
            ];
          },
          buildActions: (row) => [
            PortfolioAction(
              icon: Icons.info_outline_rounded,
              label: 'Detay',
              onTap: () => _showDetail(
                  context, savings.firstWhere((s) => s.id == row.id)),
            ),
            PortfolioAction(
              icon: Icons.edit_rounded,
              label: 'Düzenle',
              onTap: () => _showEdit(
                  context, savings.firstWhere((s) => s.id == row.id)),
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
          color: AppColors.of(context).savings,
          initiallyExpanded: false,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.of(context).savings.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '${sortedCats.length}',
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).savings,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          child: Column(
            children: sortedCats.map((entry) {
              final catTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
              return CategoryRow(
                icon: savingsIcon(entry.key),
                label: entry.key.label,
                amount: catTotal,
                percentage: total > 0 ? catTotal / total : 0.0,
                color: AppColors.of(context).savings,
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
      type: 'Birikim',
      onConfirm: () => ref.read(transactionFormProvider.notifier).deleteSavings(id),
    );
  }

  void _showDetail(BuildContext context, Savings s) {
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
          title: 'Birikim',
          categoryLabel: s.category.label,
          categoryIcon: savingsIcon(s.category),
          amount: s.amount,
          date: s.date,
          color: AppColors.of(context).savings,
          gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
          note: s.note,
          onEdit: () => _showEdit(context, s),
        ),
      ),
    );
  }

  List<SummaryInsight> _buildSavingsInsights(
    List<Savings> savings,
    Map<SavingsCategory, List<Savings>> grouped,
    double total,
  ) {
    // En büyük kategori
    final topCat = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });
    final topCatName = topCat.isNotEmpty ? topCat.first.key.label : '-';
    final topCatAmount = topCat.isNotEmpty
        ? topCat.first.value.fold(0.0, (s, i) => s + i.amount)
        : 0.0;
    final topCatPct = total > 0 ? (topCatAmount / total * 100) : 0.0;

    // En büyük tek birikim
    final maxSaving = savings.isNotEmpty
        ? savings.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    // Ortalama
    final avg = savings.isNotEmpty ? total / savings.length : 0.0;

    return [
      SummaryInsight(
        label: 'En Büyük Kategori',
        value: '$topCatName (%${topCatPct.toStringAsFixed(0)})',
        icon: Icons.emoji_events_rounded,
      ),
      SummaryInsight(
        label: 'Ortalama Birikim',
        value: CurrencyFormatter.formatNoDecimal(avg),
        icon: Icons.functions_rounded,
      ),
      if (maxSaving != null)
        SummaryInsight(
          label: 'En Büyük İşlem',
          value: CurrencyFormatter.formatNoDecimal(maxSaving.amount),
          icon: Icons.star_outline_rounded,
          isPositive: true,
        ),
    ];
  }

  void _showEdit(BuildContext context, Savings s) {
    showModalBottomSheet(useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditSavingsSheet(savings: s),
      ),
    );
  }
}
