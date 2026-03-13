import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
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
  final _dateController = TextEditingController();
  SavingsCategory _category = SavingsCategory.emergency;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateText();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _updateDateText() {
    _dateController.text =
        '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _updateDateText();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.replaceAll(',', '.').replaceAll(' ', ''),
    );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Birikim başarıyla kaydedildi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
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
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
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

              // Title
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.savings,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(AppIcons.savings,
                        color: AppColors.textInverse, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Birikim Ekle',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Tutar (₺)',
                  prefixIcon: Icon(AppIcons.savings, size: 20),
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
              const SizedBox(height: AppSpacing.base),

              // Category
              DropdownButtonFormField<SavingsCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  hintText: 'Kategori',
                  prefixIcon: Icon(AppIcons.category, size: 20),
                ),
                items: SavingsCategory.values
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      hintText: 'Tarih',
                      prefixIcon: Icon(AppIcons.calendar, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Note
              TextFormField(
                controller: _noteController,
                textInputAction: TextInputAction.done,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not (opsiyonel)',
                  prefixIcon: Icon(AppIcons.note, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit
              ElevatedButton(
                onPressed: formState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.savings,
                ),
                child: formState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textInverse,
                        ),
                      )
                    : const Text('Birikim Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
