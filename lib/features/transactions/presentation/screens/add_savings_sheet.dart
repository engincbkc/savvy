import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddSavingsSheet extends ConsumerStatefulWidget {
  const AddSavingsSheet({super.key});

  @override
  ConsumerState<AddSavingsSheet> createState() => _AddSavingsSheetState();
}

class _AddSavingsSheetState extends ConsumerState<AddSavingsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  SavingsCategory _category = SavingsCategory.emergency;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseAmount(_amountController.text);
    final savings = Savings(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: DateTime.now(),
    );

    final success =
        await ref.read(transactionFormProvider.notifier).addSavings(savings);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Birikim eklendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).savings,
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
                icon: AppIcons.savings,
                gradient: [Color(0xFFB45309), Color(0xFFD97706)],
                title: 'Birikim Ekle',
                subtitle: 'Yeni bir birikim kaydı oluştur',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              AmountInputField(
                controller: _amountController,
                color: c.savings,
                strongColor: c.savingsStrong,
                bgColor: c.savingsSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category
              FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
              const SizedBox(height: AppSpacing.sm),
              CategoryChipSelector<SavingsCategory>(
                values: SavingsCategory.values,
                selected: _category,
                labelOf: (cat) => cat.label,
                iconOf: (cat) => cat.icon,
                activeColor: c.savings,
                onSelected: (cat) => setState(() => _category = cat),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Date
              FormSectionLabel(text: 'Tarih', icon: AppIcons.calendar),
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
                decoration: const InputDecoration(
                  hintText: 'Not (opsiyonel)',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit

                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              FormSubmitButton(
                isLoading: formState.isLoading,
                label: 'Birikim Ekle',
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
