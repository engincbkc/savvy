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

class EditSavingsSheet extends ConsumerStatefulWidget {
  final Savings savings;
  const EditSavingsSheet({super.key, required this.savings});

  @override
  ConsumerState<EditSavingsSheet> createState() => _EditSavingsSheetState();
}

class _EditSavingsSheetState extends ConsumerState<EditSavingsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late SavingsCategory _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final s = widget.savings;
    _amountController = TextEditingController(text: s.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: s.note ?? '');
    _category = s.category;
    _date = s.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text);

    final updated = widget.savings.copyWith(
      amount: amount,
      category: _category,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateSavings(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Birikim guncellendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
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

              const SheetHeader(
                icon: AppIcons.edit,
                gradient: [Color(0xFFB45309), Color(0xFFD97706)],
                title: 'Birikim Duzenle',
                subtitle: 'Mevcut birikim kaydini guncelle',
              ),
              const SizedBox(height: AppSpacing.xl),

              AmountInputField(
                controller: _amountController,
                color: c.savings,
                strongColor: c.savingsStrong,
                bgColor: c.savingsSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xl),

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

              FormSectionLabel(text: 'Tarih', icon: AppIcons.calendar),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 366)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: FieldChip(icon: AppIcons.calendar, label: formatDateTR(_date)),
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
              const SizedBox(height: AppSpacing.base),
              FormSubmitButton(
                isLoading: formState.isLoading,
                label: 'Kaydet',
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
