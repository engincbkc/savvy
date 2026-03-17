import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

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

    final amount = double.parse(
      _amountController.text.replaceAll(',', '.').replaceAll(' ', ''),
    );

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC81E1E), Color(0xFFEF4444)],
                      ),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(AppIcons.expense,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gider Ekle',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Yeni bir gider kaydi olustur',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.expenseSurfaceDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.expense.withValues(alpha: 0.2)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  textInputAction: TextInputAction.next,
                  style: AppTypography.numericLarge.copyWith(
                    color: AppColors.expenseStrong,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.numericLarge.copyWith(
                      color: AppColors.expense.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: '₺',
                    suffixStyle: AppTypography.numericMedium.copyWith(
                      color: AppColors.expense.withValues(alpha: 0.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tutar giriniz';
                    final parsed = double.tryParse(
                        v.replaceAll(',', '.').replaceAll(' ', ''));
                    if (parsed == null || parsed <= 0) {
                      return 'Geçerli bir tutar giriniz';
                    }
                    if (parsed > 10000000) return 'Maksimum tutar ₺10.000.000';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Expense type
              Text('Gider Tipi',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: ExpenseType.values.map((type) {
                  final isSelected = _expenseType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _expenseType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: type != ExpenseType.values.last
                                ? AppSpacing.xs
                                : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.expense
                              : AppColors.surfaceOverlay,
                          borderRadius: AppRadius.chip,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.expense
                                : AppColors.borderDefault,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type.label,
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.base),

              // Category chips
              Text('Kategori',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.expense
                            : AppColors.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.expense
                              : AppColors.borderDefault,
                        ),
                      ),
                      child: Text(
                        cat.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.base),

              // Date & Person row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: _FieldChip(
                        icon: AppIcons.calendar,
                        label: _formatDate(_date),
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
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
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

              const SizedBox(height: AppSpacing.sm),

              // Recurring toggle
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOverlay,
                  borderRadius: AppRadius.input,
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.recurring,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Periyodik Gider',
                          style: AppTypography.titleSmall
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                    Switch.adaptive(
                      value: _isRecurring,
                      activeTrackColor: AppColors.expense,
                      onChanged: (v) => setState(() {
                        _isRecurring = v;
                        if (!v) _recurringEndDate = null;
                      }),
                    ),
                  ],
                ),
              ),

              if (_isRecurring) ...[
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: _FieldChip(
                    icon: Icons.event_busy_rounded,
                    label: _recurringEndDate != null
                        ? 'Bitis: ${_formatDate(_recurringEndDate!)}'
                        : 'Bitis Tarihi (opsiyonel)',
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input),
                    elevation: 0,
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Gider Ekle',
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FieldChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
