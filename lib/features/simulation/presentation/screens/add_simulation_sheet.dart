import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddSimulationSheet extends ConsumerStatefulWidget {
  const AddSimulationSheet({super.key});

  @override
  ConsumerState<AddSimulationSheet> createState() => _AddSimulationSheetState();
}

class _AddSimulationSheetState extends ConsumerState<AddSimulationSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  SimulationType _selectedType = SimulationType.credit;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    final entry = SimulationEntry(
      id: const Uuid().v4(),
      title: title,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      type: _selectedType,
      colorHex: _selectedType.color.toARGB32()
          .toRadixString(16)
          .substring(2)
          .toUpperCase(),
      createdAt: DateTime.now(),
    );

    final ok = await ref
        .read(simulationProvider.notifier)
        .addSimulation(entry);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.of(context).pop(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          const SizedBox(height: AppSpacing.lg),

          // Header
          SheetHeader(
            icon: Icons.auto_awesome_rounded,
            gradient: [
              c.brandPrimary,
              c.brandAccent,
            ],
            title: 'Yeni Simülasyon',
            subtitle: 'Finansal senaryonuzu oluşturun',
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title field
          Text(
            'Simülasyon Adı',
            style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.bodyLarge.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'Örn: İlk Evim, Yatırım Planı...',
              hintStyle:
                  AppTypography.bodyMedium.copyWith(color: c.textTertiary),
              filled: true,
              fillColor: c.surfaceInput,
              border: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: c.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: c.brandPrimary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Description field
          Text(
            'Açıklama (opsiyonel)',
            style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            style: AppTypography.bodyMedium.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'Kısa bir not...',
              hintStyle:
                  AppTypography.bodySmall.copyWith(color: c.textTertiary),
              filled: true,
              fillColor: c.surfaceInput,
              border: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: c.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: c.brandPrimary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Type selector
          Text(
            'Simülasyon Tipi',
            style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...SimulationType.values.map((type) {
            final isSelected = type == _selectedType;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedType = type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color.withValues(alpha: 0.08)
                        : c.surfaceInput,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.5)
                          : c.borderDefault,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (isSelected ? type.color : c.textTertiary)
                              .withValues(alpha: 0.1),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Icon(
                          type.icon,
                          size: 18,
                          color: isSelected ? type.color : c.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: AppTypography.titleSmall.copyWith(
                                color: isSelected
                                    ? type.color
                                    : c.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              type.subtitle,
                              style: AppTypography.caption.copyWith(
                                color: c.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            size: 20, color: type.color),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),

          // Save button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.minTouchTarget,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Oluştur',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
