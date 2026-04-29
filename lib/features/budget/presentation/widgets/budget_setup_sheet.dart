import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/budget/domain/models/budget_limit.dart';
import 'package:savvy/features/budget/presentation/providers/budget_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:savvy/shared/widgets/savvy_snackbar.dart';
import 'package:uuid/uuid.dart';

class BudgetSetupSheet extends ConsumerStatefulWidget {
  /// Pass existing limit to edit, null to create new.
  final BudgetLimit? existing;

  const BudgetSetupSheet({super.key, this.existing});

  @override
  ConsumerState<BudgetSetupSheet> createState() => _BudgetSetupSheetState();
}

class _BudgetSetupSheetState extends ConsumerState<BudgetSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.market;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _category = widget.existing!.category;
      _amountController.text =
          widget.existing!.monthlyLimit.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseAmount(_amountController.text);
    final limit = _isEdit
        ? widget.existing!.copyWith(
            category: _category,
            monthlyLimit: amount,
          )
        : BudgetLimit(
            id: const Uuid().v4(),
            category: _category,
            monthlyLimit: amount,
            createdAt: DateTime.now(),
          );

    final success =
        await ref.read(budgetLimitProvider.notifier).upsert(limit);
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        SavvySnackbar.error(context, 'Bir hata oluştu, tekrar deneyin.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              const SizedBox(height: AppSpacing.base),
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                      ),
                      borderRadius: AppRadius.chip,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.wallet,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEdit ? 'Limiti Düzenle' : 'Bütçe Limiti Ekle',
                        style: AppTypography.headlineSmall
                            .copyWith(color: colors.textPrimary),
                      ),
                      Text(
                        'Aylık harcama sınırı belirle',
                        style: AppTypography.bodySmall
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category selector
              Text(
                'Kategori',
                style: AppTypography.labelLarge
                    .copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CategoryChipSelector(
                selected: _category,
                onSelected: (cat) => setState(() => _category = cat),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount field
              Text(
                'Aylık Limit',
                style: AppTypography.labelLarge
                    .copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: AppTypography.numericMedium
                    .copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '₺ ',
                  prefixStyle: AppTypography.numericMedium
                      .copyWith(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.surfaceInput,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(color: colors.borderDefault),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(color: colors.borderDefault),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide:
                        BorderSide(color: colors.borderFocus, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tutar girin';
                  final parsed = parseAmount(v);
                  if (parsed <= 0) return 'Geçerli bir tutar girin';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.input,
                    ),
                  ),
                  child: Text(
                    _isEdit ? 'Güncelle' : 'Limit Ekle',
                    style: AppTypography.labelLarge
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChipSelector extends StatelessWidget {
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelected;

  const _CategoryChipSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ExpenseCategory.values.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(cat);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.brandPrimary
                  : colors.surfaceOverlay,
              borderRadius: AppRadius.pill,
              border: Border.all(
                color: isSelected
                    ? colors.brandPrimary
                    : colors.borderDefault,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 14,
                  color: isSelected ? Colors.white : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  cat.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
