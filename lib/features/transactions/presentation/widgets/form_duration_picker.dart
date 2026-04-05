import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart'
    show formatDateTR;

/// Duration picker with 3 modes: Aylık, Yıllık, Tam Tarih.
void showMonthDurationPicker({
  required BuildContext context,
  required DateTime startDate,
  required DateTime? currentEndDate,
  required ValueChanged<DateTime> onSelected,
}) {
  showModalBottomSheet(useRootNavigator: true,
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _DurationPickerSheet(
      startDate: startDate,
      currentEndDate: currentEndDate,
      onSelected: (date) {
        Navigator.pop(ctx);
        onSelected(date);
      },
    ),
  );
}

class _DurationPickerSheet extends StatefulWidget {
  final DateTime startDate;
  final DateTime? currentEndDate;
  final ValueChanged<DateTime> onSelected;

  const _DurationPickerSheet({
    required this.startDate,
    required this.currentEndDate,
    required this.onSelected,
  });

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  int _mode = 0; // 0=aylık, 1=yıllık, 2=tam tarih
  final _customController = TextEditingController();

  static const _monthPresets = [3, 6, 12, 18, 24];
  static const _yearPresets = [2, 3, 5, 10, 15];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Süre Seç',
            style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Periyodik işlem ne kadar sürecek?',
            style: AppTypography.caption.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: AppSpacing.base),

          // Mode tabs
          Padding(
            padding: AppSpacing.screenH,
            child: Row(
              children: [
                _ModeTab(label: 'Aylık', isActive: _mode == 0, onTap: () => setState(() => _mode = 0)),
                const SizedBox(width: AppSpacing.sm),
                _ModeTab(label: 'Yıllık', isActive: _mode == 1, onTap: () => setState(() => _mode = 1)),
                const SizedBox(width: AppSpacing.sm),
                _ModeTab(label: 'Tam Tarih', isActive: _mode == 2, onTap: () => setState(() => _mode = 2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Content
          if (_mode == 0) ...[
            _buildGrid(c, _monthPresets, (n) => '$n ay', (n) => DateTime(
              widget.startDate.year, widget.startDate.month + n, widget.startDate.day,
            )),
            const SizedBox(height: AppSpacing.base),
            _buildCustomInput(c, 'ay', (n) => DateTime(
              widget.startDate.year, widget.startDate.month + n, widget.startDate.day,
            )),
          ],
          if (_mode == 1) ...[
            _buildGrid(c, _yearPresets, (n) => '$n yıl', (n) => DateTime(
              widget.startDate.year + n, widget.startDate.month, widget.startDate.day,
            )),
            const SizedBox(height: AppSpacing.base),
            _buildCustomInput(c, 'yıl', (n) => DateTime(
              widget.startDate.year + n, widget.startDate.month, widget.startDate.day,
            )),
          ],
          if (_mode == 2) _buildDateButton(c),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildGrid(SavvyColors c, List<int> presets, String Function(int) labelOf, DateTime Function(int) dateOf) {
    return Padding(
      padding: AppSpacing.screenH,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: presets.map((n) {
          final endDate = dateOf(n);
          final isSelected = widget.currentEndDate != null &&
              widget.currentEndDate!.year == endDate.year &&
              widget.currentEndDate!.month == endDate.month;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSelected(endDate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? c.brandPrimary : c.surfaceOverlay,
                borderRadius: AppRadius.chip,
                border: Border.all(color: isSelected ? c.brandPrimary : c.borderDefault),
              ),
              child: Text(
                labelOf(n),
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : c.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomInput(SavvyColors c, String unit, DateTime Function(int) dateOf) {
    return Padding(
      padding: AppSpacing.screenH,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Örn: 48',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
              onSubmitted: (val) {
                final n = int.tryParse(val);
                if (n != null && n > 0) {
                  widget.onSelected(dateOf(n));
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(unit, style: AppTypography.labelMedium.copyWith(color: c.textSecondary)),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              final n = int.tryParse(_customController.text);
              if (n != null && n > 0) {
                HapticFeedback.selectionClick();
                widget.onSelected(dateOf(n));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.brandPrimary,
                borderRadius: AppRadius.chip,
              ),
              child: Text('Uygula', style: AppTypography.labelSmall.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(SavvyColors c) {
    return Padding(
      padding: AppSpacing.screenH,
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.currentEndDate ?? widget.startDate.add(const Duration(days: 365)),
            firstDate: widget.startDate,
            lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
          );
          if (picked != null) widget.onSelected(picked);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceOverlay,
            borderRadius: AppRadius.input,
            border: Border.all(color: c.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.currentEndDate != null
                    ? formatDateTR(widget.currentEndDate!)
                    : 'Takvimden tarih seç',
                style: AppTypography.labelMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? c.brandPrimary : c.surfaceOverlay,
            borderRadius: AppRadius.chip,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isActive ? Colors.white : c.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
