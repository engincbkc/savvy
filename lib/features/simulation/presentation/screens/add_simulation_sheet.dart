import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddSimulationSheet extends ConsumerStatefulWidget {
  const AddSimulationSheet({super.key});

  @override
  ConsumerState<AddSimulationSheet> createState() =>
      _AddSimulationSheetState();
}

class _AddSimulationSheetState extends ConsumerState<AddSimulationSheet> {
  SimulationType _type = SimulationType.car;
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '1.000.000');
  final _downPaymentCtrl = TextEditingController();
  bool _saving = false;

  // Parameters
  double _price = 1000000;
  double _downPaymentPercent = 20;
  double _annualRate = 2.5;
  int _termMonths = 48;

  @override
  void initState() {
    super.initState();
    _syncDownPaymentText();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _downPaymentCtrl.dispose();
    super.dispose();
  }

  void _syncDownPaymentText() {
    final dp = _price * _downPaymentPercent / 100;
    _downPaymentCtrl.text = _formatNumber(dp);
  }

  String _formatNumber(double v) {
    return CurrencyFormatter.formatNoDecimal(v).replaceAll('₺', '').trim();
  }

  // ─── Calculations ───────────────────────────────────────────
  double get _downPayment => _price * _downPaymentPercent / 100;
  double get _loanAmount => _price - _downPayment;

  double get _monthlyPayment {
    if (_loanAmount <= 0 || _termMonths <= 0) return 0;
    final r = _annualRate / 100 / 12;
    if (r == 0) return _loanAmount / _termMonths;
    final pow = math.pow(1 + r, _termMonths);
    return _loanAmount * (r * pow) / (pow - 1);
  }

  double get _totalPayment => _monthlyPayment * _termMonths;
  double get _totalInterest => _totalPayment - _loanAmount;

  // ─── Duration Picker ────────────────────────────────────────
  void _openDurationPicker() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    showMonthDurationPicker(
      context: context,
      startDate: now,
      currentEndDate: DateTime(now.year, now.month + _termMonths, now.day),
      onSelected: (endDate) {
        final months = (endDate.year - now.year) * 12 +
            endDate.month -
            now.month;
        if (months > 0) {
          setState(() => _termMonths = months);
        }
      },
    );
  }

  // ─── Save ───────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Simülasyon adı gerekli'),
          backgroundColor: AppColors.of(context).expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final entry = SimulationEntry(
        id: const Uuid().v4(),
        title: name,
        type: _type,
        colorHex: _type.color
            .toARGB32()
            .toRadixString(16)
            .substring(2)
            .toUpperCase(),
        parameters: {
          'principal': _price,
          'downPayment': _downPayment,
          'downPaymentPercent': _downPaymentPercent,
          'annualRate': _annualRate,
          'termMonths': _termMonths,
          'loanAmount': _loanAmount,
          'monthlyPayment': _monthlyPayment,
          'totalPayment': _totalPayment,
          'totalInterest': _totalInterest,
        },
        createdAt: DateTime.now(),
      );

      await ref.read(simulationRepositoryProvider).add(entry);

      if (mounted) {
        setState(() => _saving = false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Yeni Simülasyon',
          style: AppTypography.titleLarge.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name Input ─────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    style: AppTypography.headlineSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Simülasyon adı...',
                      hintStyle: AppTypography.headlineSmall.copyWith(
                        color: c.textTertiary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Divider(color: c.borderDefault.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Total Price (Slider + TextBox) ─────────
                  _buildSliderWithInput(
                    c: c,
                    label: 'Toplam Tutar',
                    controller: _priceCtrl,
                    suffix: '₺',
                    sliderValue: _price,
                    sliderMin: 100000,
                    sliderMax: 100000000,
                    divisions: 999,
                    onSliderChanged: (v) {
                      final rounded =
                          (v / 50000).round() * 50000;
                      setState(() {
                        _price = rounded.toDouble();
                        _priceCtrl.text = _formatNumber(_price);
                        _syncDownPaymentText();
                      });
                    },
                    onTextSubmitted: (text) {
                      final parsed = parseAmount(text);
                      if (parsed > 0) {
                        setState(() {
                          _price = parsed;
                          _priceCtrl.text = _formatNumber(_price);
                          _syncDownPaymentText();
                        });
                      }
                    },
                  ),

                  // ── Down Payment (Slider + TextBox) ────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peşinat',
                        style: AppTypography.labelMedium
                            .copyWith(color: c.textSecondary),
                      ),
                      Text(
                        '%${_downPaymentPercent.toInt()}',
                        style: AppTypography.numericSmall.copyWith(
                          color: c.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // TextBox for down payment amount
                  TextFormField(
                    controller: _downPaymentCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandFormatter()],
                    style: AppTypography.numericMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      suffixText: '₺',
                      suffixStyle: AppTypography.numericMedium.copyWith(
                        color: c.textTertiary,
                      ),
                      filled: true,
                      fillColor: c.surfaceInput,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.input,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    onFieldSubmitted: (text) {
                      final parsed = parseAmount(text);
                      if (parsed >= 0 && _price > 0) {
                        final pct =
                            (parsed / _price * 100).clamp(0.0, 100.0);
                        setState(() {
                          _downPaymentPercent = pct.roundToDouble();
                          _syncDownPaymentText();
                        });
                      }
                    },
                    onTapOutside: (_) {
                      final parsed =
                          parseAmount(_downPaymentCtrl.text);
                      if (parsed >= 0 && _price > 0) {
                        final pct =
                            (parsed / _price * 100).clamp(0.0, 100.0);
                        setState(() {
                          _downPaymentPercent = pct.roundToDouble();
                          _syncDownPaymentText();
                        });
                      }
                    },
                  ),
                  Slider(
                    value: _downPaymentPercent,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: _type.color,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _downPaymentPercent = v.roundToDouble();
                        _syncDownPaymentText();
                      });
                    },
                  ),

                  // ── Use Savings as Down Payment ────────────
                  Builder(
                    builder: (context) {
                      final totalSavings =
                          ref.watch(totalSavingsAmountProvider);
                      if (totalSavings <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final pct = _price > 0
                                ? (totalSavings / _price * 100)
                                    .clamp(0.0, 100.0)
                                : 0.0;
                            setState(() {
                              _downPaymentPercent =
                                  pct.roundToDouble();
                              _syncDownPaymentText();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: c.savings.withValues(alpha: 0.06),
                              borderRadius: AppRadius.card,
                              border: Border.all(
                                color:
                                    c.savings.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.landmark,
                                    size: 16, color: c.savings),
                                const SizedBox(width: AppSpacing.sm),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mevcut Birikiminiz',
                                      style: AppTypography.caption
                                          .copyWith(
                                        color: c.textTertiary,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter
                                          .formatNoDecimal(
                                              totalSavings),
                                      style: AppTypography.numericSmall
                                          .copyWith(
                                        color: c.savings,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Annual Rate ────────────────────────────
                  _SliderSection(
                    label: 'Yıllık Faiz',
                    valueText: '%${_annualRate.toStringAsFixed(1)}',
                    minLabel: '%0',
                    maxLabel: '%5',
                    valueColor: _annualRate < 2
                        ? c.income
                        : _annualRate < 3.5
                            ? c.savings
                            : c.expense,
                    child: Slider(
                      value: _annualRate,
                      min: 0,
                      max: 5,
                      divisions: 50,
                      activeColor: _annualRate < 2
                          ? c.income
                          : _annualRate < 3.5
                              ? c.savings
                              : c.expense,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(
                            () => _annualRate = (v * 10).round() / 10);
                      },
                    ),
                  ),

                  // ── Term / Vade ─────────────────────────────
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Vade',
                        style: AppTypography.labelMedium
                            .copyWith(color: c.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        _termMonths >= 12
                            ? '${_termMonths ~/ 12} yıl${_termMonths % 12 > 0 ? ' ${_termMonths % 12} ay' : ''}'
                            : '$_termMonths ay',
                        style: AppTypography.numericSmall.copyWith(
                          color: _type.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Duration picker button (opens the Aylık/Yıllık/Tam Tarih sheet)
                  GestureDetector(
                    onTap: _openDurationPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceInput,
                        borderRadius: AppRadius.input,
                        border: Border.all(
                          color: _type.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.calendar,
                              size: 18, color: _type.color),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            _termMonths >= 12
                                ? '${_termMonths ~/ 12} yıl${_termMonths % 12 > 0 ? ' ${_termMonths % 12} ay' : ''}'
                                : '$_termMonths ay',
                            style: AppTypography.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Değiştir',
                            style: AppTypography.labelSmall.copyWith(
                              color: _type.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.chevronRight,
                              size: 14, color: _type.color),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Category Selection ─────────────────────
                  Text(
                    'Kategori',
                    style: AppTypography.labelMedium
                        .copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: SimulationType.values.map((type) {
                      final isSelected = type == _type;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _type = type);
                        },
                        child: AnimatedContainer(
                          duration: AppDuration.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? type.color.withValues(alpha: 0.15)
                                : c.surfaceCard,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: isSelected
                                  ? type.color
                                  : c.borderDefault,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon,
                                  size: 18,
                                  color: isSelected
                                      ? type.color
                                      : c.textTertiary),
                              const SizedBox(width: 6),
                              Text(
                                type.label,
                                style:
                                    AppTypography.labelSmall.copyWith(
                                  color: isSelected
                                      ? type.color
                                      : c.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl2),

                  // ── Live Preview ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _type.color.withValues(alpha: 0.06),
                      borderRadius: AppRadius.cardLg,
                      border: Border.all(
                        color: _type.color.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Canlı Önizleme',
                          style: AppTypography.labelMedium.copyWith(
                            color: _type.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          children: [
                            Expanded(
                              child: _PreviewItem(
                                label: 'Aylık Taksit',
                                value:
                                    CurrencyFormatter.formatNoDecimal(
                                        _monthlyPayment),
                                color: _type.color,
                                large: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _PreviewItem(
                                label: 'Toplam Ödeme',
                                value:
                                    CurrencyFormatter.formatNoDecimal(
                                        _totalPayment),
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _PreviewItem(
                                label: 'Toplam Faiz',
                                value:
                                    CurrencyFormatter.formatNoDecimal(
                                        _totalInterest),
                                color: c.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl5),
                ],
              ),
            ),
          ),

          // ── Sticky Save Button ─────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: c.surfaceBackground,
              border: Border(
                top: BorderSide(
                  color: c.borderDefault.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(LucideIcons.calculator,
                        size: 18, color: Colors.white),
                label: Text(
                  _saving ? 'Kaydediliyor...' : 'Hesapla ve Kaydet',
                  style: AppTypography.labelLarge
                      .copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Slider + TextBox Combined ────────────────────────────
  Widget _buildSliderWithInput({
    required SavvyColors c,
    required String label,
    required TextEditingController controller,
    required String suffix,
    required double sliderValue,
    required double sliderMin,
    required double sliderMax,
    required int divisions,
    required ValueChanged<double> onSliderChanged,
    required ValueChanged<String> onTextSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium
              .copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandFormatter()],
          style: AppTypography.numericMedium.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: AppTypography.numericMedium.copyWith(
              color: c.textTertiary,
            ),
            filled: true,
            fillColor: c.surfaceInput,
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          onFieldSubmitted: onTextSubmitted,
          onTapOutside: (_) => onTextSubmitted(controller.text),
        ),
        // Slider only shown when value is within range;
        // if user typed a value beyond slider max, slider adapts
        Builder(builder: (context) {
          final effectiveMax =
              sliderValue > sliderMax ? sliderValue : sliderMax;
          return Slider(
            value: sliderValue.clamp(sliderMin, effectiveMax),
            min: sliderMin,
            max: effectiveMax,
            divisions: effectiveMax > sliderMax
                ? ((effectiveMax - sliderMin) / 50000).round().clamp(10, 2000)
                : divisions,
            activeColor: _type.color,
            onChanged: onSliderChanged,
          );
        }),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─── Slider Section ──────────────────────────────────────────
class _SliderSection extends StatelessWidget {
  final String label;
  final String valueText;
  final Color? valueColor;
  final Widget child;
  final String? minLabel;
  final String? maxLabel;

  const _SliderSection({
    required this.label,
    required this.valueText,
    this.valueColor,
    required this.child,
    this.minLabel,
    this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium
                  .copyWith(color: c.textSecondary),
            ),
            Text(
              valueText,
              style: AppTypography.numericMedium.copyWith(
                color: valueColor ?? c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        child,
        if (minLabel != null || maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel ?? '',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                    fontSize: 9,
                  ),
                ),
                Text(
                  maxLabel ?? '',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─── Preview Item ────────────────────────────────────────────
class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

  const _PreviewItem({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.of(context).textTertiary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: (large
                    ? AppTypography.numericLarge
                    : AppTypography.numericMedium)
                .copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
