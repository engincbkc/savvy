import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddIncomeSheet extends ConsumerStatefulWidget {
  const AddIncomeSheet({super.key});

  @override
  ConsumerState<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _personController = TextEditingController();
  IncomeCategory _category = IncomeCategory.salary;
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
    final income = Income(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
      createdAt: DateTime.now(),
    );

    final success =
        await ref.read(transactionFormProvider.notifier).addIncome(income);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gelir eklendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).income,
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
                icon: AppIcons.income,
                gradient: [Color(0xFF059669), Color(0xFF10B981)],
                title: 'Gelir Ekle',
                subtitle: 'Yeni bir gelir kaydı oluştur',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              AmountInputField(
                controller: _amountController,
                color: c.income,
                strongColor: c.incomeStrong,
                bgColor: c.incomeSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category
              FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
              const SizedBox(height: AppSpacing.sm),
              CategoryChipSelector<IncomeCategory>(
                values: IncomeCategory.values,
                selected: _category,
                labelOf: (cat) => cat.label,
                iconOf: (cat) => cat.icon,
                activeColor: c.income,
                onSelected: (cat) => setState(() => _category = cat),
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
              const SizedBox(height: AppSpacing.base),

              // Recurring
              RecurringToggle(
                label: 'Periyodik Gelir',
                value: _isRecurring,
                activeColor: c.income,
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

              // Submit

                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              FormSubmitButton(
                isLoading: formState.isLoading,
                label: 'Gelir Ekle',
                color: c.income,
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
