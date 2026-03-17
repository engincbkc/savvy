import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
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
  SavingsCategory _category = SavingsCategory.emergency;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
                        colors: [Color(0xFFB45309), Color(0xFFD97706)],
                      ),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(AppIcons.savings,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Birikim Ekle',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Yeni bir birikim kaydi olustur',
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
                  color: AppColors.savingsSurfaceDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                      color: AppColors.savings.withValues(alpha: 0.2)),
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
                    color: AppColors.savingsStrong,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.numericLarge.copyWith(
                      color: AppColors.savings.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: '₺',
                    suffixStyle: AppTypography.numericMedium.copyWith(
                      color: AppColors.savings.withValues(alpha: 0.5),
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

              // Category chips
              Text('Kategori',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: SavingsCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.savings
                            : AppColors.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.savings
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

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: _FieldChip(
                  icon: AppIcons.calendar,
                  label: _formatDate(_date),
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
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.savings,
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
                      : Text('Birikim Ekle',
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
