import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/planned_changes/domain/models/planned_change.dart';
import 'package:savvy/features/planned_changes/presentation/providers/planned_change_provider.dart';
import 'package:uuid/uuid.dart';

class PlannedChangeSheet extends ConsumerStatefulWidget {
  final String parentId;
  final String parentType; // 'income' or 'expense'
  final double currentAmount;
  final bool isGross;

  const PlannedChangeSheet({
    super.key,
    required this.parentId,
    required this.parentType,
    required this.currentAmount,
    this.isGross = false,
  });

  @override
  ConsumerState<PlannedChangeSheet> createState() => _PlannedChangeSheetState();
}

class _PlannedChangeSheetState extends ConsumerState<PlannedChangeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _effectiveDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    1,
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDate,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _effectiveDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final rawInput = _amountController.text;
    final amount = CurrencyFormatter.parse(rawInput) ??
        double.tryParse(rawInput.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _showError('Geçerli bir tutar girin.');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    try {
      final change = PlannedChange(
        id: const Uuid().v4(),
        parentId: widget.parentId,
        parentType: widget.parentType,
        newAmount: amount,
        effectiveDate: _effectiveDate,
        isGross: widget.isGross,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await ref.read(plannedChangeRepositoryProvider).save(change);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Planlı değişiklik kaydedildi'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.of(context).textPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.of(context).expense,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isIncome = widget.parentType == 'income';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: (isIncome
                                    ? colors.income
                                    : colors.expense)
                                .withValues(alpha: 0.12),
                            borderRadius: AppRadius.chip,
                          ),
                          child: Icon(
                            AppIcons.recurring,
                            size: 18,
                            color: isIncome ? colors.income : colors.expense,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Planlı Değişiklik',
                                style: AppTypography.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                'Mevcut: ${CurrencyFormatter.formatNoDecimal(widget.currentAmount)}'
                                '${widget.isGross ? ' (Brüt)' : ''}',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Yeni Tutar
                    Text(
                      'Yeni Tutar${widget.isGross ? ' (Brüt)' : ''}',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: AppTypography.numericMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₺ ',
                        prefixStyle: AppTypography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        hintText: '0',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                        filled: true,
                        fillColor: colors.surfaceOverlay,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Tutar gerekli';
                        }
                        final parsed = CurrencyFormatter.parse(v) ??
                            double.tryParse(v.replaceAll(',', '.'));
                        if (parsed == null || parsed <= 0) {
                          return 'Geçerli bir tutar girin';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Gecerlilik Tarihi
                    Text(
                      'Geçerlilik Tarihi',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceOverlay,
                          borderRadius: AppRadius.input,
                        ),
                        child: Row(
                          children: [
                            Icon(AppIcons.calendar,
                                size: 16, color: colors.textSecondary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _formatDate(_effectiveDate),
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Icon(AppIcons.forward,
                                size: 16, color: colors.textTertiary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Not (opsiyonel)
                    Text(
                      'Not (opsiyonel)',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: Maaş zammı, kira artışı...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                        filled: true,
                        fillColor: colors.surfaceOverlay,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Kaydet butonu
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _save,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: _isSaving
                                ? colors.textTertiary
                                : (isIncome ? colors.income : colors.expense),
                            borderRadius: AppRadius.input,
                          ),
                          alignment: Alignment.center,
                          child: _isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.surfaceCard,
                                  ),
                                )
                              : Text(
                                  'Kaydet',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
