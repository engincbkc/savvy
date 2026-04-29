import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/screens/add_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

part 'quick_expense_sheet.g.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
Expense? lastExpense(Ref ref) {
  final expenses = ref.watch(allExpensesProvider).value ?? [];
  final active = expenses.where((e) => !e.isDeleted).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return active.isEmpty ? null : active.first;
}

// ─── Templates ────────────────────────────────────────────────────────────────

class _QuickTemplate {
  final String label;
  final double amount;
  final ExpenseCategory category;
  final ExpenseType expenseType;

  const _QuickTemplate({
    required this.label,
    required this.amount,
    required this.category,
    this.expenseType = ExpenseType.variable,
  });
}

const _kDefaultTemplates = [
  _QuickTemplate(
    label: 'Market',
    amount: 500,
    category: ExpenseCategory.market,
    expenseType: ExpenseType.variable,
  ),
  _QuickTemplate(
    label: 'Benzin',
    amount: 1500,
    category: ExpenseCategory.transport,
    expenseType: ExpenseType.variable,
  ),
  _QuickTemplate(
    label: 'Yemek',
    amount: 250,
    category: ExpenseCategory.food,
    expenseType: ExpenseType.discretionary,
  ),
  _QuickTemplate(
    label: 'Fatura',
    amount: 2000,
    category: ExpenseCategory.bills,
    expenseType: ExpenseType.fixed,
  ),
  _QuickTemplate(
    label: 'Kafe',
    amount: 150,
    category: ExpenseCategory.entertainment,
    expenseType: ExpenseType.discretionary,
  ),
];

// ─── Sheet ────────────────────────────────────────────────────────────────────

class QuickExpenseSheet extends ConsumerStatefulWidget {
  const QuickExpenseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (sheetCtx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(sheetCtx).surfaceCard,
            borderRadius: AppRadius.bottomSheet,
          ),
          child: const QuickExpenseSheet(),
        ),
      ),
    );
  }

  @override
  ConsumerState<QuickExpenseSheet> createState() => _QuickExpenseSheetState();
}

class _QuickExpenseSheetState extends ConsumerState<QuickExpenseSheet> {
  // Tracks which recent expenses are being saved (to show loading state)
  final Set<String> _saving = {};

  Future<void> _repeatExpense(Expense original) async {
    if (_saving.contains(original.id)) return;
    setState(() => _saving.add(original.id));
    HapticFeedback.mediumImpact();

    final newExpense = original.copyWith(
      id: const Uuid().v4(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    try {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.add(newExpense);
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gider eklendi: ${CurrencyFormatter.formatNoDecimal(newExpense.amount)}',
          AppColors.of(context).expense,
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata olustu, tekrar deneyin.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(original.id));
    }
  }

  void _openTemplate(_QuickTemplate template) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    AddExpenseSheet.show(
      context,
      initialAmount: template.amount,
      initialCategory: template.category,
      initialNote: template.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final recentExpenses = (allExpensesAsync.value ?? [])
        .where((e) => !e.isDeleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = recentExpenses.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SheetHandle(),
          const SizedBox(height: AppSpacing.base),

          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.expenseSurfaceDim,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(LucideIcons.zap, size: 18, color: c.expense),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Hızlı Gider',
                style: AppTypography.titleLarge
                    .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Sık Kullanılanlar ──────────────────────────────────────
          Text(
            'Sık Kullanılanlar',
            style: AppTypography.labelMedium
                .copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kDefaultTemplates.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final template = _kDefaultTemplates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () => _openTemplate(template),
                );
              },
            ),
          ),

          // ── Son İşlemler ──────────────────────────────────────────
          if (recent.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Son İşlemler',
              style: AppTypography.labelMedium.copyWith(
                  color: c.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recent.map(
              (expense) => _RecentExpenseTile(
                expense: expense,
                isSaving: _saving.contains(expense.id),
                onRepeat: () => _repeatExpense(expense),
              ),
            ),
          ] else if (allExpensesAsync.isLoading) ...[
            const SizedBox(height: AppSpacing.xl),
            const Center(child: CircularProgressIndicator()),
          ],

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}

// ─── Template Card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final _QuickTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 88,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.surfaceOverlay,
          borderRadius: AppRadius.card,
          border: Border.all(color: c.borderDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(template.category.icon, size: 20, color: c.expense),
            const SizedBox(height: 4),
            Text(
              template.label,
              style: AppTypography.caption.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              CurrencyFormatter.formatNoDecimal(template.amount),
              style: AppTypography.caption
                  .copyWith(color: c.textSecondary, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Expense Tile ──────────────────────────────────────────────────────

class _RecentExpenseTile extends StatelessWidget {
  final Expense expense;
  final bool isSaving;
  final VoidCallback onRepeat;

  const _RecentExpenseTile({
    required this.expense,
    required this.isSaving,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        borderRadius: AppRadius.card,
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.expenseSurfaceDim,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(expense.category.icon, size: 16, color: c.expense),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Label & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.note?.isNotEmpty == true
                      ? expense.note!
                      : expense.category.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.category.label,
                  style:
                      AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            CurrencyFormatter.formatNoDecimal(expense.amount),
            style: AppTypography.bodySmall.copyWith(
              color: c.expense,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Repeat button
          SizedBox(
            width: 72,
            height: 32,
            child: TextButton(
              onPressed: isSaving ? null : onRepeat,
              style: TextButton.styleFrom(
                backgroundColor: c.expenseSurfaceDim,
                foregroundColor: c.expense,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.chip),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isSaving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.expense,
                      ),
                    )
                  : Text(
                      'Tekrarla',
                      style: AppTypography.caption.copyWith(
                        color: c.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
