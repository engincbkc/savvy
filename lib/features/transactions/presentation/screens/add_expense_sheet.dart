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
import 'package:uuid/uuid.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final double? initialAmount;
  final ExpenseCategory? initialCategory;
  final String? initialNote;

  const AddExpenseSheet({
    super.key,
    this.scrollController,
    this.initialAmount,
    this.initialCategory,
    this.initialNote,
  });

  /// Convenience static method to open AddExpenseSheet as a bottom sheet,
  /// optionally pre-filling values.
  static Future<void> show(
    BuildContext context, {
    double? initialAmount,
    ExpenseCategory? initialCategory,
    String? initialNote,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (sheetCtx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(sheetCtx).surfaceCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddExpenseSheet(
            scrollController: scrollController,
            initialAmount: initialAmount,
            initialCategory: initialCategory,
            initialNote: initialNote,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _personController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.market;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  DateTime? _recurringEndDate;
  bool _amountOk = false;

  @override
  void initState() {
    super.initState();
    // Apply pre-fill values if provided
    if (widget.initialAmount != null) {
      _amountController.text =
          widget.initialAmount!.toStringAsFixed(0).replaceAll('.', ',');
    }
    if (widget.initialCategory != null) {
      _category = widget.initialCategory!;
    }
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }
    _amountController.addListener(_onAmountChanged);
    _amountOk = isAmountValid(_amountController.text);
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
    final picked = await showSavvyDatePicker(
      context: context,
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _pickEndDate() {
    showMonthDurationPicker(
      context: context,
      startDate: _date,
      currentEndDate: _recurringEndDate,
      onSelected: (date) => setState(() => _recurringEndDate = date),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseAmount(_amountController.text);
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      expenseType: ExpenseType.variable, // Varsayılan değer
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
      createdAt: DateTime.now(),
      isSettled: !_date.isAfter(DateTime.now()),
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
    final isLoading = ref.watch(
      transactionFormProvider.select((s) => s.isLoading),
    );
    final c = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Column(
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

                // Başlık
                TextFormField(
                  controller: _personController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Başlık (opsiyonel)',
                    prefixIcon: const Icon(Icons.label_outline_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

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
                          ? 'Bitiş: ${formatDateTR(_recurringEndDate!)}'
                          : 'Bitiş Tarihi (opsiyonel)',
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),

                // Date
                FormSectionLabel(text: 'Başlangıç Tarihi', icon: AppIcons.calendar),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickDate,
                  child: FieldChip(
                    icon: AppIcons.calendar,
                    label: formatDateTR(_date),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Note
                TextFormField(
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Not (opsiyonel)',
                    prefixIcon: const Icon(AppIcons.note, size: 18),
                    counterStyle: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                FormSubmitButton(
                  isLoading: isLoading,
                  label: 'Gider Ekle',
                  color: c.expense,
                  enabled: _amountOk,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
