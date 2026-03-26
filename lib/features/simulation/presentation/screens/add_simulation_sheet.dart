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
import 'package:uuid/uuid.dart';

/// Full-screen simulation creation page with type selection,
/// interactive sliders, and live preview.
class AddSimulationSheet extends ConsumerStatefulWidget {
  const AddSimulationSheet({super.key});

  @override
  ConsumerState<AddSimulationSheet> createState() =>
      _AddSimulationSheetState();
}

class _AddSimulationSheetState extends ConsumerState<AddSimulationSheet> {
  // Step 0: type, Step 1: parameters
  int _step = 0;
  SimulationType _type = SimulationType.car;
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  // Parameters
  double _price = 1000000;
  double _downPaymentPercent = 20;
  double _annualRate = 2.5;
  int _termMonths = 48;

  static const _termOptions = [1, 3, 6, 9, 12, 24, 36, 48, 60, 120, 180, 240];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
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
        colorHex: _type.color.toARGB32().toRadixString(16).substring(2).toUpperCase(),
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
          icon: Icon(
            _step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded,
            color: c.textPrimary,
          ),
          onPressed: () {
            if (_step == 0) {
              Navigator.of(context).pop();
            } else {
              setState(() => _step = 0);
            }
          },
        ),
        title: Text(
          _step == 0 ? 'Yeni Simülasyon' : _type.label,
          style: AppTypography.titleLarge.copyWith(color: c.textPrimary),
        ),
      ),
      body: _step == 0 ? _buildTypeSelection(c) : _buildParameters(c),
    );
  }

  // ─── Step 0: Type Selection ─────────────────────────────────
  Widget _buildTypeSelection(SavvyColors c) {
    final types = SimulationType.values;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ne simüle etmek istiyorsun?',
                  style: AppTypography.headlineSmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Bir senaryo tipi seç',
                  style: AppTypography.bodyMedium
                      .copyWith(color: c.textTertiary),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...types.map((type) {
                  final isSelected = type == _type;
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GestureDetector(
                      onTap: !isSelected
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _type = type);
                            }
                          : null,
                      child: _AnimatedTypeCard(
                        type: type,
                        isSelected: isSelected,
                        onSelected: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _type = type;
                            _step = 1;
                          });
                        },
                      ),
                    ),
                  );
                }),
                SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xl2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Parameters with Sliders + Live Preview ─────────
  Widget _buildParameters(SavvyColors c) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name input
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

                // ── Price ────────────────────────────────────
                _SliderSection(
                  label: _type == SimulationType.car
                      ? 'Araç Fiyatı'
                      : _type == SimulationType.housing
                          ? 'Ev Fiyatı'
                          : 'Kredi Tutarı',
                  valueText:
                      CurrencyFormatter.formatNoDecimal(_price),
                  child: Slider(
                    value: _price,
                    min: 100000,
                    max: 20000000,
                    divisions: 199,
                    activeColor: _type.color,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _price = (v / 50000).round() * 50000);
                    },
                  ),
                ),

                // ── Down Payment ─────────────────────────────
                _SliderSection(
                  label: 'Peşinat',
                  valueText:
                      '%${_downPaymentPercent.toInt()} · ${CurrencyFormatter.formatNoDecimal(_downPayment)}',
                  child: Slider(
                    value: _downPaymentPercent,
                    min: 0,
                    max: 80,
                    divisions: 80,
                    activeColor: _type.color,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _downPaymentPercent = v.roundToDouble());
                    },
                  ),
                ),
                // ── Use Savings as Down Payment ─────────────
                Builder(
                  builder: (context) {
                    final totalSavings = ref.watch(totalSavingsAmountProvider);
                    if (totalSavings <= 0) return const SizedBox.shrink();
                    final savingsPercent = _price > 0
                        ? (totalSavings / _price * 100).clamp(0.0, 80.0)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _downPaymentPercent = savingsPercent.roundToDouble());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: _type.color.withValues(alpha: 0.08),
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: _type.color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.landmark, size: 14, color: _type.color),
                              const SizedBox(width: 6),
                              Text(
                                'Birikimimi kullan: ${CurrencyFormatter.formatNoDecimal(totalSavings)}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: _type.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ── Annual Rate ──────────────────────────────
                _SliderSection(
                  label: 'Yıllık Faiz',
                  valueText: '%${_annualRate.toStringAsFixed(1)}',
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

                // ── Term ─────────────────────────────────────
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vade',
                  style: AppTypography.labelMedium
                      .copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _termOptions.map((m) {
                    final isSelected = m == _termMonths;
                    final label =
                        m >= 12 ? '${m ~/ 12} yıl' : '$m ay';
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _termMonths = m);
                      },
                      child: AnimatedContainer(
                        duration: AppDuration.fast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _type.color
                              : c.surfaceCard,
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                            color: isSelected
                                ? _type.color
                                : c.borderDefault,
                          ),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : c.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl2),

                // ── Live Preview ──────────────────────────────
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
                              value: CurrencyFormatter.formatNoDecimal(
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
                              value: CurrencyFormatter.formatNoDecimal(
                                  _totalPayment),
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _PreviewItem(
                              label: 'Toplam Faiz',
                              value: CurrencyFormatter.formatNoDecimal(
                                  _totalInterest),
                              color: c.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                  : Icon(LucideIcons.calculator, size: 18,
                      color: Colors.white),
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
    );
  }
}

// ─── Slider Section ──────────────────────────────────────────
class _SliderSection extends StatelessWidget {
  final String label;
  final String valueText;
  final Color? valueColor;
  final Widget child;

  const _SliderSection({
    required this.label,
    required this.valueText,
    this.valueColor,
    required this.child,
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

// ─── Drag-to-Select Type Card ────────────────────────────────
// Each type has a draggable icon on the left and a target on the right.
// Drag the icon to the target to select!
class _AnimatedTypeCard extends StatefulWidget {
  final SimulationType type;
  final bool isSelected;
  final VoidCallback onSelected;

  const _AnimatedTypeCard({
    required this.type,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_AnimatedTypeCard> createState() => _AnimatedTypeCardState();
}

class _AnimatedTypeCardState extends State<_AnimatedTypeCard>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _dragging = false;
  late final AnimationController _bounceCtrl;

  // Track width for drag limit
  static const double _trackWidth = 220;
  static const double _thumbSize = 40;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dragX = 0;
  }

  @override
  void didUpdateWidget(covariant _AnimatedTypeCard old) {
    super.didUpdateWidget(old);
    // Always reset thumb to left
    if (widget.isSelected != old.isSelected) {
      setState(() => _dragX = 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  // Get drag icon & target icon per type
  IconData get _dragIcon => switch (widget.type) {
        SimulationType.car => LucideIcons.car,
        SimulationType.housing => LucideIcons.key,
        SimulationType.credit => LucideIcons.banknote,
        SimulationType.vacation => LucideIcons.plane,
        SimulationType.tech => LucideIcons.shoppingCart,
        SimulationType.custom => LucideIcons.sparkles,
      };

  IconData get _targetIcon => switch (widget.type) {
        SimulationType.car => LucideIcons.parkingCircle,
        SimulationType.housing => LucideIcons.home,
        SimulationType.credit => LucideIcons.landmark,
        SimulationType.vacation => LucideIcons.palmtree,
        SimulationType.tech => LucideIcons.gift,
        SimulationType.custom => LucideIcons.target,
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final type = widget.type;
    final isSelected = widget.isSelected;
    final progress = (_dragX / (_trackWidth - _thumbSize)).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: AppDuration.normal,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelected
            ? type.color.withValues(alpha: 0.08)
            : c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        border: Border.all(
          color: isSelected
              ? type.color.withValues(alpha: 0.5)
              : c.borderDefault.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: type.color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0,
            ),
            child: Row(
              children: [
                Text(
                  type.label,
                  style: AppTypography.titleMedium.copyWith(
                    color: isSelected ? type.color : c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  type.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      color: type.color, size: 18),
              ],
            ),
          ),

          // Drag track
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.base,
            ),
            child: SizedBox(
              height: _thumbSize + 8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final maxDrag = maxWidth - _thumbSize;

                  return Stack(
                    children: [
                      // Track background
                      Positioned(
                        left: 4,
                        right: 4,
                        top: (_thumbSize + 8 - 36) / 2,
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: type.color.withValues(alpha: 0.06),
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: type.color.withValues(
                                alpha: 0.1 + progress * 0.2,
                              ),
                            ),
                          ),
                          child: !isSelected
                              ? Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 12,
                                          color: type.color
                                              .withValues(alpha: 0.3)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'kaydır',
                                        style:
                                            AppTypography.caption.copyWith(
                                          color: type.color
                                              .withValues(alpha: 0.3),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),

                      // Progress fill
                      Positioned(
                        left: 4,
                        top: (_thumbSize + 8 - 36) / 2,
                        child: Container(
                          width: (_dragX + _thumbSize / 2)
                              .clamp(0.0, maxWidth - 8),
                          height: 36,
                          decoration: BoxDecoration(
                            color: type.color.withValues(
                              alpha: 0.08 + progress * 0.12,
                            ),
                            borderRadius: AppRadius.pill,
                          ),
                        ),
                      ),

                      // Target icon (right side)
                      Positioned(
                        right: 10,
                        top: (_thumbSize + 8 - 28) / 2,
                        child: AnimatedOpacity(
                          duration: AppDuration.fast,
                          opacity: isSelected ? 1.0 : 0.3,
                          child: Icon(
                            _targetIcon,
                            size: 22,
                            color: type.color,
                          ),
                        ),
                      ),

                      // Draggable thumb
                      Positioned(
                        left: _dragX.clamp(0.0, maxDrag),
                        top: 4,
                        child: GestureDetector(
                          onHorizontalDragStart: isSelected ? (_) {
                            setState(() {
                              _dragging = true;
                              _dragX = 0;
                            });
                          } : null,
                          onHorizontalDragUpdate: isSelected
                              ? (d) {
                                  if (!_dragging) return;
                                  setState(() {
                                    _dragX = (_dragX + d.delta.dx)
                                        .clamp(0.0, maxDrag);
                                  });
                                  final pct = _dragX / maxDrag;
                                  if (pct > 0.5 && pct < 0.52) {
                                    HapticFeedback.selectionClick();
                                  }
                                }
                              : null,
                          onHorizontalDragEnd: isSelected
                              ? (_) {
                                  if (!_dragging) return;
                                  _dragging = false;
                                  if (_dragX > maxDrag * 0.85) {
                                    HapticFeedback.heavyImpact();
                                    setState(() => _dragX = maxDrag);
                                    Future.delayed(
                                      const Duration(milliseconds: 200),
                                      widget.onSelected,
                                    );
                                  } else {
                                    HapticFeedback.lightImpact();
                                    setState(() => _dragX = 0);
                                  }
                                }
                              : null,
                          child: Container(
                            width: _thumbSize,
                            height: _thumbSize,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? type.color
                                  : type.color.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: type.color
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _dragIcon,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
