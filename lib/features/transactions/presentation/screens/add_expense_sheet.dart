import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:savvy/shared/widgets/info_tooltip.dart';
import 'package:uuid/uuid.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _personController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.market;
  ExpenseType _expenseType = ExpenseType.variable;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  DateTime? _recurringEndDate;
  bool _amountOk = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final ok = isAmountValid(_amountController.text);
    if (ok != _amountOk) setState(() => _amountOk = ok);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurringEndDate ?? _date.add(const Duration(days: 365)),
      firstDate: _date,
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (picked != null) setState(() => _recurringEndDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseAmount(_amountController.text);
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      expenseType: _expenseType,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
      createdAt: DateTime.now(),
    );

    final success =
        await ref.read(transactionFormProvider.notifier).addExpense(expense);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gider eklendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).expense,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final c = AppColors.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),

              // Header
              const SheetHeader(
                icon: AppIcons.expense,
                gradient: [Color(0xFFC81E1E), Color(0xFFEF4444)],
                title: 'Gider Ekle',
                subtitle: 'Yeni bir gider kaydı oluştur',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              AmountInputField(
                controller: _amountController,
                color: c.expense,
                strongColor: c.expenseStrong,
                bgColor: c.expenseSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category
              FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
              const SizedBox(height: AppSpacing.sm),
              CategoryChipSelector<ExpenseCategory>(
                values: ExpenseCategory.values,
                selected: _category,
                labelOf: (cat) => cat.label,
                iconOf: (cat) => cat.icon,
                activeColor: c.expense,
                onSelected: (cat) => setState(() => _category = cat),
              ),
              const SizedBox(height: AppSpacing.base),

              // Recurring (moved below category)
              RecurringToggle(
                label: 'Periyodik Gider',
                value: _isRecurring,
                activeColor: c.expense,
                onChanged: (v) => setState(() {
                  _isRecurring = v;
                  if (!v) _recurringEndDate = null;
                }),
              ),
              if (_isRecurring) ...[
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: FieldChip(
                    icon: Icons.event_busy_rounded,
                    label: _recurringEndDate != null
                        ? 'Bitis: ${formatDateTR(_recurringEndDate!)}'
                        : 'Bitis Tarihi (opsiyonel)',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              // Expense type with InfoTooltips
              Row(
                children: [
                  FormSectionLabel(text: 'Gider Tipi', icon: Icons.tune_rounded),
                  const Spacer(),
                  InfoTooltip(
                    title: 'Gider Tipleri',
                    description:
                        'Sabit: Her ay düzenli tekrarlayan giderler (kira, fatura).\n\n'
                        'Değişken: Aydan aya miktarı değişen giderler (market, ulaşım).\n\n'
                        'İsteğe Bağlı: Zorunlu olmayan, kısılabilir harcamalar (eğlence, yeme-içme).\n\n'
                        'İş/Yatırım: İş veya yatırım amaçlı yapılan giderler.',
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: ExpenseType.values.map((type) {
                  final isSelected = _expenseType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _expenseType = type);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: type != ExpenseType.values.last
                                ? AppSpacing.xs
                                : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? c.expense
                              : c.surfaceOverlay,
                          borderRadius: AppRadius.chip,
                          border: Border.all(
                            color: isSelected ? c.expense : c.borderDefault,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: c.expense.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type.label,
                          style: AppTypography.caption.copyWith(
                            color: isSelected ? Colors.white : c.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Date & Person
              FormSectionLabel(text: 'Detaylar', icon: AppIcons.info),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: FieldChip(
                        icon: AppIcons.calendar,
                        label: formatDateTR(_date),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Kisi (opsiyonel)',
                        prefixIcon: const Icon(AppIcons.person, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Note
              TextFormField(
                controller: _noteController,
                textInputAction: TextInputAction.done,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not (opsiyonel)',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              FormSubmitButton(
                isLoading: formState.isLoading,
                label: 'Gider Ekle',
                color: c.expense,
                enabled: _amountOk,
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
