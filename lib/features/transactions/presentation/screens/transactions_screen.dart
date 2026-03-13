import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final incomesAsync = ref.watch(monthIncomesProvider(yearMonth));
    final expensesAsync = ref.watch(monthExpensesProvider(yearMonth));
    final savingsAsync = ref.watch(monthSavingsProvider(yearMonth));

    final isLoading = incomesAsync.isLoading ||
        expensesAsync.isLoading ||
        savingsAsync.isLoading;

    final incomes = incomesAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];
    final savings = savingsAsync.value ?? [];

    // Combine all transactions into a unified list
    final allItems = <_TransactionItem>[
      ...incomes.map((i) => _TransactionItem(
            title: i.category.label,
            note: i.note,
            amount: i.amount,
            type: _TxType.income,
            date: i.date,
          )),
      ...expenses.map((e) => _TransactionItem(
            title: e.category.label,
            note: e.note,
            amount: e.amount,
            type: _TxType.expense,
            date: e.date,
          )),
      ...savings.map((s) => _TransactionItem(
            title: s.category.label,
            note: s.note,
            amount: s.amount,
            type: _TxType.savings,
            date: s.date,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İşlemler',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allItems.isEmpty
              ? EmptyState(
                  icon: AppIcons.analytics,
                  title: 'Henüz işlem yok',
                  subtitle: 'İlk gelir veya giderini ekleyerek başla.',
                  actionLabel: 'İşlem Ekle',
                  onAction: () {},
                )
              : ListView.builder(
                  padding: AppSpacing.screenH,
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return _TransactionCard(item: item);
                  },
                ),
    );
  }
}

enum _TxType { income, expense, savings }

class _TransactionItem {
  final String title;
  final String? note;
  final double amount;
  final _TxType type;
  final DateTime date;

  _TransactionItem({
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.date,
  });
}

class _TransactionCard extends StatelessWidget {
  final _TransactionItem item;

  const _TransactionCard({required this.item});

  Color get _iconBgColor => switch (item.type) {
        _TxType.income => AppColors.income,
        _TxType.expense => AppColors.expense,
        _TxType.savings => AppColors.savings,
      };

  Color get _amountColor => switch (item.type) {
        _TxType.income => AppColors.income,
        _TxType.expense => AppColors.expense,
        _TxType.savings => AppColors.savings,
      };

  IconData get _icon => switch (item.type) {
        _TxType.income => AppIcons.income,
        _TxType.expense => AppIcons.expense,
        _TxType.savings => AppIcons.savings,
      };

  String get _prefix => switch (item.type) {
        _TxType.income => '+',
        _TxType.expense => '-',
        _TxType.savings => '',
      };

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: AppSpacing.listTile,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBgColor,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              _icon,
              color: AppColors.textInverse,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.note != null ? '$dateStr · ${item.note}' : dateStr,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '$_prefix${CurrencyFormatter.formatNoDecimal(item.amount)}',
            style: AppTypography.numericSmall.copyWith(
              color: _amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
