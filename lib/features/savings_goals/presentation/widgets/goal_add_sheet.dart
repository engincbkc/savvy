import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';
import 'package:savvy/features/savings_goals/presentation/providers/goals_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class GoalAddSheet extends ConsumerStatefulWidget {
  final SavingsGoal? existing;
  const GoalAddSheet({super.key, this.existing});

  @override
  ConsumerState<GoalAddSheet> createState() => _GoalAddSheetState();
}

class _GoalAddSheetState extends ConsumerState<GoalAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _targetDate;
  SavingsCategory _category = SavingsCategory.goal;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final g = widget.existing!;
      _titleController.text = g.title;
      _targetController.text = g.targetAmount.toStringAsFixed(0);
      _currentController.text = g.currentAmount.toStringAsFixed(0);
      _targetDate = g.targetDate;
      _category = g.category;
    }
    // Rebuild chip when target amount changes
    _targetController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final target = parseAmount(_targetController.text);
    final current = _currentController.text.trim().isEmpty
        ? 0.0
        : parseAmount(_currentController.text);

    final goal = _isEdit
        ? widget.existing!.copyWith(
            title: _titleController.text.trim(),
            targetAmount: target,
            currentAmount: current,
            targetDate: _targetDate,
            category: _category,
          )
        : SavingsGoal(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            targetAmount: target,
            currentAmount: current,
            targetDate: _targetDate,
            category: _category,
            createdAt: DateTime.now(),
          );

    final notifier = ref.read(goalsProvider.notifier);
    final success =
        _isEdit ? await notifier.updateGoal(goal) : await notifier.addGoal(goal);

    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.base,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SheetHandle(),
                      const SizedBox(height: AppSpacing.lg),
                      SheetHeader(
                        icon: LucideIcons.target,
                        gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
                        title: _isEdit ? 'Hedef Düzenle' : 'Hedef Ekle',
                        subtitle: _isEdit
                            ? 'Mevcut hedefini güncelle'
                            : 'Yeni bir finansal hedef oluştur',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Hedef adı (ör: Ev alma)',
                          prefixIcon:
                              Icon(LucideIcons.tag, size: 18, color: c.textTertiary),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Hedef adı giriniz' : null,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      AmountInputField(
                        controller: _targetController,
                        color: c.savings,
                        strongColor: c.savingsStrong,
                        bgColor: c.savingsSurfaceDim,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Mevcut Birikim', icon: LucideIcons.piggyBank),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _currentController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                          ThousandFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: '₺',
                          prefixIcon:
                              Icon(LucideIcons.coins, size: 18, color: c.textTertiary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Hedef Tarihi (opsiyonel)',
                          icon: LucideIcons.calendar),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _targetDate ??
                                DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) setState(() => _targetDate = picked);
                        },
                        child: FieldChip(
                          icon: LucideIcons.calendar,
                          label: _targetDate != null
                              ? formatDateTR(_targetDate!)
                              : 'Tarih seç',
                        ),
                      ),
                      // Smart suggestion chip — reactive to target amount & net income
                      _SmartSuggestionChip(
                        targetText: _targetController.text,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Kategori', icon: LucideIcons.layoutGrid),
                      const SizedBox(height: AppSpacing.sm),
                      CategoryChipSelector<SavingsCategory>(
                        values: SavingsCategory.values,
                        selected: _category,
                        labelOf: (c) => c.label,
                        iconOf: (c) => c.icon,
                        activeColor: c.savings,
                        onSelected: (cat) => setState(() => _category = cat),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              // Sabit buton — her zaman altta görünür
              FormSubmitButton(
                isLoading: ref.watch(goalsProvider).isLoading,
                label: _isEdit ? 'Kaydet' : 'Hedef Oluştur',
                color: c.savings,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Smart Suggestion Chip ─────────────────────────────────────────

class _SmartSuggestionChip extends ConsumerWidget {
  final String targetText;
  const _SmartSuggestionChip({required this.targetText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final summaries = ref.watch(allMonthSummariesProvider);
    final monthlyNet = summaries.isNotEmpty
        ? summaries.first.totalIncome - summaries.first.totalExpense
        : 0.0;

    final targetAmount = parseAmount(targetText);
    if (monthlyNet <= 0 || targetAmount <= 0) return const SizedBox.shrink();

    final suggested = FinancialCalculator.suggestedMonthlySaving(monthlyNet);
    if (suggested <= 0) return const SizedBox.shrink();

    final months = FinancialCalculator.monthsToGoal(
      targetAmount: targetAmount,
      currentAmount: 0,
      monthlySavings: suggested,
    );
    if (months <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.savings.withValues(alpha: 0.07),
          borderRadius: AppRadius.input,
          border: Border.all(color: c.savings.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 15, color: c.savings),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Aylık gelirinizin %20\'siyle '
                '(~${CurrencyFormatter.formatNoDecimal(suggested)}) '
                'yaklaşık $months ay içinde ulaşabilirsiniz',
                style: AppTypography.caption.copyWith(
                  color: c.savings,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
