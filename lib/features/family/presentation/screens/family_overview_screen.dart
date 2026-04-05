import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/family/presentation/providers/family_provider.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class FamilyOverviewScreen extends ConsumerWidget {
  const FamilyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(allIncomesProvider);
    final expensesAsync = ref.watch(allExpensesProvider);

    final isLoading = incomesAsync.isLoading || expensesAsync.isLoading;

    if (isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: AppColors.of(context).surfaceBackground,
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              ShimmerBox(height: 120),
              SizedBox(height: AppSpacing.base),
              ShimmerBox(height: 100),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 100),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 100),
            ],
          ),
        ),
      );
    }

    final contributions = ref.watch(personContributionsProvider);
    final allIncomes = incomesAsync.value ?? [];
    final allExpenses = expensesAsync.value ?? [];

    final totalIncome = contributions.values.fold(0.0, (s, v) => s + v.income);
    final totalExpense = contributions.values.fold(0.0, (s, v) => s + v.expense);
    final totalNet = totalIncome - totalExpense;

    // Sort: named persons first (alphabetical), then "Ortak" last
    final sortedKeys = contributions.keys.toList()
      ..sort((a, b) {
        if (a == 'Ortak') return 1;
        if (b == 'Ortak') return -1;
        return a.compareTo(b);
      });

    return Scaffold(
      backgroundColor: AppColors.of(context).surfaceBackground,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Ev Bütçesi Özet Kartı ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
              ),
              child: _HouseholdSummaryCard(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                totalNet: totalNet,
              ),
            ),
          ),

          // ─── Section başlık ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
              child: Text(
                'Kişi Katkıları',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ─── Kişi Katkı Kartları ──────────────────────────────
          if (contributions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Henüz işlem kaydı yok.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.of(context).textTertiary,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final key = sortedKeys[index];
                  final data = contributions[key]!;
                  final net = data.income - data.expense;
                  final shareRatio = totalIncome > 0
                      ? (data.income / totalIncome).clamp(0.0, 1.0)
                      : 0.0;

                  final personIncomes = allIncomes
                      .where((i) => _personKey(i.person) == key)
                      .toList();
                  final personExpenses = allExpenses
                      .where((e) => _personKey(e.person) == key)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm,
                    ),
                    child: _PersonContributionCard(
                      name: key,
                      income: data.income,
                      expense: data.expense,
                      net: net,
                      shareRatio: shareRatio,
                      incomes: personIncomes,
                      expenses: personExpenses,
                    ),
                  );
                },
                childCount: sortedKeys.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _personKey(String? person) =>
      person?.trim().isNotEmpty == true ? person! : 'Ortak';

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.of(context).surfaceCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: AppColors.of(context).textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Aile Bütçesi',
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.of(context).textPrimary,
        ),
      ),
      centerTitle: false,
    );
  }
}

// ─── Ev Bütçesi Özet Kartı ────────────────────────────────────────────────────

class _HouseholdSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalNet;

  const _HouseholdSummaryCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalNet,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = totalNet >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.chip,
                ),
                child: const Icon(
                  LucideIcons.users,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ev Bütçesi',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            CurrencyFormatter.format(totalNet),
            style: AppTypography.numericLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isPositive ? 'Net Pozitif Bakiye' : 'Net Negatif Bakiye',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryStatItem(
                  label: 'Toplam Gelir',
                  value: CurrencyFormatter.format(totalIncome),
                  color: Colors.white.withValues(alpha: 0.9),
                  icon: LucideIcons.trendingUp,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: _SummaryStatItem(
                  label: 'Toplam Gider',
                  value: CurrencyFormatter.format(totalExpense),
                  color: Colors.white.withValues(alpha: 0.9),
                  icon: LucideIcons.trendingDown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 13),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.numericSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Kişi Katkı Kartı ─────────────────────────────────────────────────────────

class _PersonContributionCard extends StatefulWidget {
  final String name;
  final double income;
  final double expense;
  final double net;
  final double shareRatio;
  final List<Income> incomes;
  final List<Expense> expenses;

  const _PersonContributionCard({
    required this.name,
    required this.income,
    required this.expense,
    required this.net,
    required this.shareRatio,
    required this.incomes,
    required this.expenses,
  });

  @override
  State<_PersonContributionCard> createState() =>
      _PersonContributionCardState();
}

class _PersonContributionCardState extends State<_PersonContributionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isPositive = widget.net >= 0;
    final netColor = isPositive ? c.income : c.expense;
    final isOrtak = widget.name == 'Ortak';

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: c.borderDefault.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            // ─── Kart başlığı ──────────────────────────────────
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: _expanded
                  ? const BorderRadius.vertical(top: Radius.circular(AppRadius.lg))
                  : AppRadius.card,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isOrtak
                                ? c.brandPrimary.withValues(alpha: 0.1)
                                : c.income.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isOrtak
                                ? Icon(
                                    LucideIcons.home,
                                    size: 18,
                                    color: c.brandPrimary,
                                  )
                                : Text(
                                    widget.name[0].toUpperCase(),
                                    style: AppTypography.titleLarge.copyWith(
                                      color: c.income,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isOrtak
                                    ? 'Kişi atanmamış işlemler'
                                    : 'Gelir payı: ${CurrencyFormatter.percent(widget.shareRatio)}',
                                style: AppTypography.caption.copyWith(
                                  color: c.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Net bakiye
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.withSign(widget.net),
                              style: AppTypography.numericSmall.copyWith(
                                color: netColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'net',
                              style: AppTypography.caption.copyWith(
                                color: c.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 280),
                          child: Icon(
                            LucideIcons.chevronDown,
                            size: 16,
                            color: c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Gelir/Gider satırı
                    Row(
                      children: [
                        _MiniStat(
                          label: 'Gelir',
                          value: CurrencyFormatter.format(widget.income),
                          color: c.income,
                        ),
                        const SizedBox(width: AppSpacing.base),
                        _MiniStat(
                          label: 'Gider',
                          value: CurrencyFormatter.format(widget.expense),
                          color: c.expense,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress bar
                    if (widget.shareRatio > 0 && !isOrtak) ...[
                      ClipRRect(
                        borderRadius: AppRadius.pill,
                        child: LinearProgressIndicator(
                          value: widget.shareRatio,
                          minHeight: 4,
                          backgroundColor: c.borderDefault.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(c.income),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ─── Expandable: işlem listesi ─────────────────────
            if (_expanded) ...[
              Divider(
                height: 1,
                color: c.borderDefault.withValues(alpha: 0.4),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.incomes.isNotEmpty) ...[
                      _TransactionSectionHeader(
                        label: 'Gelirler',
                        icon: LucideIcons.trendingUp,
                        color: c.income,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...widget.incomes.map(
                        (i) => _TransactionRow(
                          label: i.source ?? i.category.name,
                          amount: i.amount,
                          isIncome: true,
                        ),
                      ),
                    ],
                    if (widget.incomes.isNotEmpty && widget.expenses.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),
                    if (widget.expenses.isNotEmpty) ...[
                      _TransactionSectionHeader(
                        label: 'Giderler',
                        icon: LucideIcons.trendingDown,
                        color: c.expense,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...widget.expenses.map(
                        (e) => _TransactionRow(
                          label: e.subcategory ?? e.category.name,
                          amount: e.amount,
                          isIncome: false,
                        ),
                      ),
                    ],
                    if (widget.incomes.isEmpty && widget.expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.base,
                          ),
                          child: Text(
                            'İşlem bulunamadı.',
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textTertiary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.chip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                value,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TransactionSectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _TransactionRow({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = isIncome ? c.income : c.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: c.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
