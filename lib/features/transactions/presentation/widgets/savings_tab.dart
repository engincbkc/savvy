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
        // Özet — sade
        _SimpleSavingsSummary(
          savings: savings,
          grouped: grouped,
          total: total,
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

// ═══════════════════════════════════════════════════════════════════
// Sade birikim özeti
// ═══════════════════════════════════════════════════════════════════

class _SimpleSavingsSummary extends StatelessWidget {
  final List<Savings> savings;
  final Map<SavingsCategory, List<Savings>> grouped;
  final double total;

  const _SimpleSavingsSummary({
    required this.savings,
    required this.grouped,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    // En büyük birikim
    final maxSaving = savings.isNotEmpty
        ? savings.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    // En büyük kategori
    final topCat = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });
    final topCatName = topCat.isNotEmpty ? topCat.first.key.label : '-';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = c.savings;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.04)]
              : [accent.withValues(alpha: 0.06), accent.withValues(alpha: 0.02)],
        ),
        borderRadius: AppRadius.cardLg,
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.2 : 0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SavRow(
            icon: Icons.emoji_events_rounded,
            iconColor: accent,
            label: 'En büyük birikim',
            value: maxSaving != null
                ? CurrencyFormatter.formatNoDecimal(maxSaving.amount)
                : '-',
            detail: maxSaving != null ? maxSaving.category.label : '',
          ),
          _thinDivider(accent),
          _SavRow(
            icon: Icons.category_rounded,
            iconColor: accent.withValues(alpha: 0.6),
            label: 'Ağırlıklı kategori',
            value: topCatName,
            detail: '${grouped.length} kategori',
          ),
          _thinDivider(accent),
          _SavRow(
            icon: Icons.receipt_long_rounded,
            iconColor: accent.withValues(alpha: 0.6),
            label: '${savings.length} işlem',
            value: '',
            detail: 'Ort. ${CurrencyFormatter.formatNoDecimal(savings.isNotEmpty ? total / savings.length : 0)}',
          ),
        ],
      ),
    );
  }

  Widget _thinDivider(Color accent) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0),
                accent.withValues(alpha: 0.15),
                accent.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      );
}

class _SavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String detail;

  const _SavRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.bodySmall.copyWith(color: c.textSecondary)),
        const Spacer(),
        if (value.isNotEmpty)
          Text(value, style: AppTypography.labelMedium.copyWith(
            color: c.textPrimary, fontWeight: FontWeight.w600)),
        if (detail.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(detail, style: AppTypography.caption.copyWith(
            color: c.textTertiary, fontSize: 11)),
        ],
      ],
    );
  }
}
