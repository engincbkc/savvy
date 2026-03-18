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

class EditExpenseSheet extends ConsumerStatefulWidget {
  final Expense expense;
  const EditExpenseSheet({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<EditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _personController;
  late ExpenseCategory _category;
  late ExpenseType _expenseType;
  late DateTime _date;
  late bool _isRecurring;
  DateTime? _recurringEndDate;

  // Original values for change detection
  late final String _origAmount;
  late final String _origNote;
  late final String _origPerson;
  late final ExpenseCategory _origCategory;
  late final ExpenseType _origExpenseType;
  late final DateTime _origDate;
  late final bool _origIsRecurring;
  late final DateTime? _origRecurringEndDate;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController = TextEditingController(text: e.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: e.note ?? '');
    _personController = TextEditingController(text: e.person ?? '');
    _category = e.category;
    _expenseType = e.expenseType;
    _date = e.date;
    _isRecurring = e.isRecurring;
    _recurringEndDate = e.recurringEndDate;

    _origAmount = _amountController.text;
    _origNote = _noteController.text;
    _origPerson = _personController.text;
    _origCategory = e.category;
    _origExpenseType = e.expenseType;
    _origDate = e.date;
    _origIsRecurring = e.isRecurring;
    _origRecurringEndDate = e.recurringEndDate;

    _amountController.addListener(_checkChanges);
    _noteController.addListener(_checkChanges);
    _personController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _amountController.text != _origAmount ||
        _noteController.text != _origNote ||
        _personController.text != _origPerson ||
        _category != _origCategory ||
        _expenseType != _origExpenseType ||
        _date != _origDate ||
        _isRecurring != _origIsRecurring ||
        _recurringEndDate != _origRecurringEndDate;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text);

    final updated = widget.expense.copyWith(
      amount: amount,
      category: _category,
      expenseType: _expenseType,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateExpense(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gider güncellendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
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

              const SheetHeader(
                icon: AppIcons.edit,
                gradient: [Color(0xFFC81E1E), Color(0xFFEF4444)],
                title: 'Gider Düzenle',
                subtitle: 'Mevcut gider kaydını güncelle',
              ),
              const SizedBox(height: AppSpacing.xl),

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
                onSelected: (cat) {
                  setState(() => _category = cat);
                  _checkChanges();
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // Recurring
              RecurringToggle(
                label: 'Periyodik Gider',
                value: _isRecurring,
                activeColor: c.expense,
                onChanged: (v) {
                  setState(() {
                    _isRecurring = v;
                    if (!v) _recurringEndDate = null;
                  });
                  _checkChanges();
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _recurringEndDate ?? _date.add(const Duration(days: 365)),
                      firstDate: _date,
                      lastDate: DateTime.now().add(const Duration(days: 1825)),
                    );
                    if (picked != null) {
                      setState(() => _recurringEndDate = picked);
                      _checkChanges();
                    }
                  },
                  child: FieldChip(
                    icon: Icons.event_busy_rounded,
                    label: _recurringEndDate != null
                        ? 'Bitiş: ${formatDateTR(_recurringEndDate!)}'
                        : 'Bitiş Tarihi (opsiyonel)',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              // Expense type
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
                        _checkChanges();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: type != ExpenseType.values.last ? AppSpacing.xs : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? c.expense : c.surfaceOverlay,
                          borderRadius: AppRadius.chip,
                          border: Border.all(
                            color: isSelected ? c.expense : c.borderDefault,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type.label,
                          style: AppTypography.caption.copyWith(
                            color: isSelected ? Colors.white : c.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 366)),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                          _checkChanges();
                        }
                      },
                      child: FieldChip(icon: AppIcons.calendar, label: formatDateTR(_date)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      decoration: InputDecoration(
                        hintText: 'Kişi',
                        prefixIcon: const Icon(AppIcons.person, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _noteController,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

                    ],
                  ),
                ),
              ),
              if (_hasChanges) ...[
                const SizedBox(height: AppSpacing.base),
                FormSubmitButton(
                  isLoading: formState.isLoading,
                  label: 'Kaydet',
                  color: c.expense,
                  onPressed: _submit,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
