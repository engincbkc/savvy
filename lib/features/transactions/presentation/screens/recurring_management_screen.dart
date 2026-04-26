import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/planned_changes/presentation/widgets/planned_change_sheet.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_income_sheet.dart';
import 'package:savvy/shared/widgets/empty_state.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

// ─── Yardimci veri sinifi ───────────────────────────────────────────────

enum _ItemType { income, expense }

class _RecurringItem {
  final String id;
  final String title;
  final String categoryLabel;
  final IconData icon;
  final double amount; // net tutar
  final bool isGross;
  final DateTime startDate;
  final DateTime? endDate;
  final _ItemType type;
  final Income? income;
  final Expense? expense;

  const _RecurringItem({
    required this.id,
    required this.title,
    required this.categoryLabel,
    required this.icon,
    required this.amount,
    required this.isGross,
    required this.startDate,
    this.endDate,
    required this.type,
    this.income,
    this.expense,
  });

  bool get isExpiringSoon {
    if (endDate == null) return false;
    final daysLeft = endDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 60;
  }

  bool get isExpired {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  int? get monthsRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (endDate!.isBefore(now)) return 0;
    return (endDate!.year - now.year) * 12 + endDate!.month - now.month;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Ana Ekran
// ═══════════════════════════════════════════════════════════════════════

class RecurringManagementScreen extends ConsumerWidget {
  const RecurringManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);

    final loading = allIncomesAsync.isLoading || allExpensesAsync.isLoading;

    if (loading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              ShimmerBox(height: 100),
              SizedBox(height: AppSpacing.base),
              ShimmerBox(height: 60),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 60),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 60),
            ],
          ),
        ),
      );
    }

    final allIncomes = allIncomesAsync.value ?? [];
    final allExpenses = allExpensesAsync.value ?? [];
    final now = DateTime.now();

    // Periyodik gelirler — aktif olanlar
    final recurringIncomes = allIncomes
        .where((i) =>
            i.isRecurring &&
            (i.recurringEndDate == null ||
                i.recurringEndDate!.isAfter(now)))
        .map((i) => _RecurringItem(
              id: i.id,
              title: i.category.label,
              categoryLabel: i.person?.isNotEmpty == true
                  ? i.person!
                  : (i.note?.isNotEmpty == true ? i.note! : i.category.label),
              icon: i.category.icon,
              amount: FinancialCalculator.resolveNetForMonth(
                amount: i.amount,
                isGross: i.isGross,
                month: now.month,
              ),
              isGross: i.isGross,
              startDate: i.date,
              endDate: i.recurringEndDate,
              type: _ItemType.income,
              income: i,
            ))
        .toList();

    // Periyodik giderler — aktif olanlar
    final recurringExpenses = allExpenses
        .where((e) =>
            e.isRecurring &&
            (e.recurringEndDate == null ||
                e.recurringEndDate!.isAfter(now)))
        .map((e) => _RecurringItem(
              id: e.id,
              title: e.category.label,
              categoryLabel: e.note?.isNotEmpty == true
                  ? e.note!
                  : e.category.label,
              icon: e.category.icon,
              amount: e.amount,
              isGross: false,
              startDate: e.date,
              endDate: e.recurringEndDate,
              type: _ItemType.expense,
              expense: e,
            ))
        .toList();

    // Tum liste
    final allItems = [...recurringIncomes, ...recurringExpenses];

    // Yakinda bitiyor vs normal aktif
    final expiringSoon =
        allItems.where((i) => i.isExpiringSoon).toList()
          ..sort((a, b) => a.endDate!.compareTo(b.endDate!));
    final active = allItems
        .where((i) => !i.isExpiringSoon)
        .toList()
      ..sort((a, b) {
        // Gelirler once, sonra giderler; her grupta tutara gore azalan
        if (a.type != b.type) {
          return a.type == _ItemType.income ? -1 : 1;
        }
        return b.amount.compareTo(a.amount);
      });

    // Ozet hesaplama
    final totalIncome = recurringIncomes.fold(0.0, (s, i) => s + i.amount);
    final totalExpense = recurringExpenses.fold(0.0, (s, i) => s + i.amount);
    final net = totalIncome - totalExpense;

    if (allItems.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const EmptyState(
          icon: AppIcons.recurring,
          title: 'Periyodik işlem yok',
          subtitle:
              'Gelir veya gider eklerken "Periyodik" seçeneğini açarak\notomatik projeksiyon oluşturabilirsin.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).surfaceBackground,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // Ozet kart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
              child: _SummaryCard(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                net: net,
                count: allItems.length,
              ),
            ),
          ),

          // Borc ozeti banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
              child: _DebtSummaryBanner(
                onTap: () => context.push('/debt'),
              ),
            ),
          ),

          // Yakinda bitiyor bolumu
          if (expiringSoon.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: AppIcons.warning,
                label: 'Yakında Bitiyor',
                color: AppColors.of(context).warning,
                count: expiringSoon.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RecurringTile(
                    item: expiringSoon[index],
                    onEdit: () => _openEdit(context, ref, expiringSoon[index]),
                    onStop: () => _confirmStop(context, ref, expiringSoon[index]),
                    onAddChange: () =>
                        _openPlannedChange(context, expiringSoon[index]),
                  ),
                  childCount: expiringSoon.length,
                ),
              ),
            ),
          ],

          // Aktif bolumu
          if (active.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: AppIcons.recurring,
                label: 'Aktif',
                color: AppColors.of(context).textSecondary,
                count: active.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RecurringTile(
                    item: active[index],
                    onEdit: () => _openEdit(context, ref, active[index]),
                    onStop: () => _confirmStop(context, ref, active[index]),
                    onAddChange: () =>
                        _openPlannedChange(context, active[index]),
                  ),
                  childCount: active.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl3)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.of(context).surfaceBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(AppIcons.back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Periyodik İşlemler',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.of(context).textPrimary,
        ),
      ),
    );
  }

  void _openEdit(
      BuildContext context, WidgetRef ref, _RecurringItem item) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: item.type == _ItemType.income
              ? EditIncomeSheet(
                  income: item.income!,
                  scrollController: scrollController,
                )
              : EditExpenseSheet(
                  expense: item.expense!,
                  scrollController: scrollController,
                ),
        ),
      ),
    );
  }

  void _confirmStop(
      BuildContext context, WidgetRef ref, _RecurringItem item) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.close, color: c.warning, size: 24),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Periyodik tekrarı durdur',
                style: AppTypography.headlineSmall
                    .copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: AppSpacing.screenH,
                child: Text(
                  '"${item.categoryLabel}" kalemi için periyodik tekrarı durdurmak istiyor musun?\nMevcut kayıt korunur, gelecek aya yansımaz.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenH,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: c.surfaceOverlay,
                            borderRadius: AppRadius.input,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Vazgeç',
                            style: AppTypography.labelMedium.copyWith(
                              color: c.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _stopRecurring(context, ref, item);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: c.warning,
                            borderRadius: AppRadius.input,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Durdur',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _openPlannedChange(BuildContext context, _RecurringItem item) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlannedChangeSheet(
        parentId: item.id,
        parentType: item.type == _ItemType.income ? 'income' : 'expense',
        currentAmount: item.amount,
        isGross: item.isGross,
      ),
    );
  }

  Future<void> _stopRecurring(
      BuildContext context, WidgetRef ref, _RecurringItem item) async {
    final now = DateTime.now();
    if (item.type == _ItemType.income && item.income != null) {
      await ref
          .read(transactionFormProvider.notifier)
          .updateIncome(item.income!.copyWith(recurringEndDate: now));
    } else if (item.type == _ItemType.expense && item.expense != null) {
      await ref
          .read(transactionFormProvider.notifier)
          .updateExpense(item.expense!.copyWith(recurringEndDate: now));
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.categoryLabel} periyodik tekrarı durduruldu'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.of(context).textPrimary,
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Ozet Kart
// ═══════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final int count;

  const _SummaryCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: colors.borderDefault.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.brandLight,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(AppIcons.recurring,
                    size: 16, color: colors.brandPrimary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Aylık Periyodik Özet',
                style: AppTypography.labelMedium
                    .copyWith(color: colors.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceOverlay,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '$count kalem',
                  style: AppTypography.caption
                      .copyWith(color: colors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              _SummaryCol(
                label: 'Gelir',
                amount: totalIncome,
                color: colors.income,
              ),
              _Divider(),
              _SummaryCol(
                label: 'Gider',
                amount: totalExpense,
                color: colors.expense,
              ),
              _Divider(),
              _SummaryCol(
                label: 'Net',
                amount: net,
                color: net >= 0 ? colors.income : colors.expense,
                showSign: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool showSign;

  const _SummaryCol({
    required this.label,
    required this.amount,
    required this.color,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.of(context).textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            showSign
                ? CurrencyFormatter.withSign(amount)
                : CurrencyFormatter.compact(amount),
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.of(context).borderDefault.withValues(alpha: 0.4),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Bolum Basligi
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '$count',
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Periyodik Kalem Tile
// ═══════════════════════════════════════════════════════════════════════

class _RecurringTile extends StatelessWidget {
  final _RecurringItem item;
  final VoidCallback onEdit;
  final VoidCallback onStop;
  final VoidCallback? onAddChange;

  const _RecurringTile({
    required this.item,
    required this.onEdit,
    required this.onStop,
    this.onAddChange,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isIncome = item.type == _ItemType.income;
    final color = isIncome ? colors.income : colors.expense;
    final bgColor =
        isIncome ? colors.incomeSurface : colors.expenseSurface;

    return Dismissible(
      key: ValueKey('recurring_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onStop();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.warning,
          borderRadius: AppRadius.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.close, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text(
              'Durdur',
              style: AppTypography.caption
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: item.isExpiringSoon
                  ? colors.warning.withValues(alpha: 0.4)
                  : colors.borderDefault.withValues(alpha: 0.3),
            ),
            boxShadow: AppShadow.xs,
          ),
          child: Row(
            children: [
              // Ikon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(item.icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),

              // Bilgi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.categoryLabel,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isGross) ...[
                          const SizedBox(width: 4),
                          _Badge(
                            label: 'Brüt',
                            color: colors.income,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          isIncome ? 'Gelir' : item.expense?.expenseType.label ?? 'Gider',
                          style: AppTypography.caption.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        if (item.endDate != null) ...[
                          Text(
                            ' · ',
                            style: AppTypography.caption
                                .copyWith(color: colors.textTertiary),
                          ),
                          _EndDateBadge(item: item),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Tutar + ay bilgisi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.compact(item.amount),
                    style: AppTypography.numericSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/ay',
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(AppIcons.forward,
                  size: 16, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kucuk yardimci widgetlar ──────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Borc Ozeti Banner
// ═══════════════════════════════════════════════════════════════════════

class _DebtSummaryBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _DebtSummaryBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.expenseSurfaceDim,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.expenseMuted.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.expenseSurface,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  LucideIcons.creditCard,
                  size: 18,
                  color: colors.expense,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Borç Özeti',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.expenseStrong,
                      ),
                    ),
                    Text(
                      'Taksit takviminizi ve borçsuz tarihinizi görün',
                      style: AppTypography.caption.copyWith(
                        color: colors.expense,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: colors.expense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndDateBadge extends StatelessWidget {
  final _RecurringItem item;

  const _EndDateBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final months = item.monthsRemaining;

    if (months == null) return const SizedBox.shrink();

    final isExpiring = item.isExpiringSoon;
    final color = isExpiring ? colors.warning : colors.textTertiary;

    final label = months == 0
        ? 'Bu ay bitiyor'
        : months == 1
            ? '1 ay kaldı'
            : '$months ay kaldı';

    return Text(
      label,
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: isExpiring ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
