import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_slider.dart';

// ─── Change Type Picker ──────────────────────────────────────────

/// Bottom sheet that lets user pick a change type.
/// Returns a [ChangeType] — the caller should then open [ChangeEditorSheet].
class ChangeTypePicker extends StatelessWidget {
  const ChangeTypePicker({super.key});

  static const _types = ChangeType.values;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceBackground,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.borderDefault,
              borderRadius: AppRadius.pill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Değişiklik Türü',
                style: AppTypography.titleLarge
                    .copyWith(color: c.textPrimary)),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              itemCount: _types.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final opt = _types[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(opt);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: c.surfaceCard,
                      borderRadius: AppRadius.card,
                      border: Border.all(
                          color: c.borderDefault.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: opt.color.withValues(alpha: 0.1),
                            borderRadius: AppRadius.chip,
                          ),
                          child:
                              Icon(opt.icon, size: 20, color: opt.color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.label,
                                  style: AppTypography.labelLarge.copyWith(
                                      color: c.textPrimary)),
                              Text(opt.subtitle,
                                  style: AppTypography.caption.copyWith(
                                      color: c.textTertiary)),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.chevronRight,
                            size: 16, color: c.textTertiary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Unified Change Editor Sheet ─────────────────────────────────

enum ChangeType {
  credit(LucideIcons.creditCard, 'Kredi', 'İhtiyaç, konut veya ticari kredi', Color(0xFFF59E0B)),
  housing(LucideIcons.home, 'Ev Alımı', 'Konut kredisi + peşinat', Color(0xFF3B82F6)),
  car(LucideIcons.car, 'Araç Alımı', 'Taşıt kredisi + aylık giderler', Color(0xFF8B5CF6)),
  rent(LucideIcons.building2, 'Kira Değişimi', 'Kira artışı veya yeni eve taşınma', Color(0xFFEF4444)),
  salary(LucideIcons.briefcase, 'Maaş Değişikliği', 'Zam, terfi veya iş değişikliği', Color(0xFF10B981)),
  income(LucideIcons.trendingUp, 'Gelir Ekle', 'Ek gelir, freelance, kira geliri...', Color(0xFF22C55E)),
  expense(LucideIcons.trendingDown, 'Gider Ekle', 'Sabit veya değişken gider', Color(0xFFEF4444)),
  investment(LucideIcons.lineChart, 'Yatırım', 'Vadeli mevduat, fon, hisse...', Color(0xFF6366F1));

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const ChangeType(this.icon, this.label, this.subtitle, this.color);
}

class ChangeEditorSheet extends StatefulWidget {
  final SimulationChange? change;
  final ChangeType? changeType;

  const ChangeEditorSheet({super.key, this.change, this.changeType});

  @override
  State<ChangeEditorSheet> createState() => _ChangeEditorSheetState();
}

class _ChangeEditorSheetState extends State<ChangeEditorSheet> {
  late ChangeType _type;
  final _labelCtrl = TextEditingController();

  // Shared controllers
  final _amountCtrl = TextEditingController();
  final _amount2Ctrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _extrasCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _annualIncreaseCtrl = TextEditingController();
  bool _isRecurring = true;
  bool _isCompound = true;
  bool _includeTaxes = false;

  // Slider state mirrors for rate and term
  double _rateSlider = 20.0;
  double _termSlider = 24.0;

  @override
  void initState() {
    super.initState();
    if (widget.change != null) {
      _initFromChange(widget.change!);
    } else {
      _type = widget.changeType ?? ChangeType.credit;
    }
    // Keep sliders in sync when text fields are edited manually
    _rateCtrl.addListener(_syncRateSlider);
    _termCtrl.addListener(_syncTermSlider);
  }

  void _syncRateSlider() {
    final v = double.tryParse(_rateCtrl.text);
    if (v != null && v >= 10 && v <= 80) {
      setState(() => _rateSlider = v);
    }
  }

  void _syncTermSlider() {
    final v = double.tryParse(_termCtrl.text);
    if (v != null && v >= 6 && v <= 120) {
      setState(() => _termSlider = v.roundToDouble());
    }
  }

  void _initFromChange(SimulationChange change) {
    switch (change) {
      case CreditChange c:
        _type = ChangeType.credit;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.principal);
        _rateCtrl.text = _fmt(c.annualRate);
        _termCtrl.text = c.termMonths.toString();
        _rateSlider = c.annualRate.clamp(10, 80);
        _termSlider = c.termMonths.toDouble().clamp(6, 120);
      case HousingChange c:
        _type = ChangeType.housing;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.price);
        _amount2Ctrl.text = _fmt(c.downPayment);
        _rateCtrl.text = _fmt(c.annualRate);
        _termCtrl.text = c.termMonths.toString();
        _extrasCtrl.text = _fmt(c.monthlyExtras);
        _rateSlider = c.annualRate.clamp(10, 80);
        _termSlider = c.termMonths.toDouble().clamp(6, 120);
      case CarChange c:
        _type = ChangeType.car;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.price);
        _amount2Ctrl.text = _fmt(c.downPayment);
        _rateCtrl.text = _fmt(c.annualRate);
        _termCtrl.text = c.termMonths.toString();
        _extrasCtrl.text = _fmt(c.monthlyRunningCosts);
        _rateSlider = c.annualRate.clamp(10, 80);
        _termSlider = c.termMonths.toDouble().clamp(6, 120);
      case RentChangeChange c:
        _type = ChangeType.rent;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.currentRent);
        _amount2Ctrl.text = _fmt(c.newRent);
        _annualIncreaseCtrl.text = _fmt(c.annualIncreaseRate);
      case SalaryChangeChange c:
        _type = ChangeType.salary;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.currentGross);
        _amount2Ctrl.text = _fmt(c.newGross);
      case IncomeChange c:
        _type = ChangeType.income;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.amount);
        _descCtrl.text = c.description;
        _isRecurring = c.isRecurring;
      case ExpenseChange c:
        _type = ChangeType.expense;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.amount);
        _descCtrl.text = c.description;
        _isRecurring = c.isRecurring;
      case InvestmentChange c:
        _type = ChangeType.investment;
        _labelCtrl.text = c.label;
        _amountCtrl.text = _fmt(c.principal);
        _rateCtrl.text = _fmt(c.annualReturnRate);
        _termCtrl.text = c.termMonths.toString();
        _isCompound = c.isCompound;
    }
  }

  String _fmt(double v) => v == 0 ? '' : v.toString();

  @override
  void dispose() {
    _rateCtrl.removeListener(_syncRateSlider);
    _termCtrl.removeListener(_syncTermSlider);
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    _amount2Ctrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    _extrasCtrl.dispose();
    _descCtrl.dispose();
    _annualIncreaseCtrl.dispose();
    super.dispose();
  }

  double _parseAmount(String s) => double.tryParse(s.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  int _parseInt(String s) => int.tryParse(s.replaceAll('.', '')) ?? 0;

  SimulationChange? _buildChange() {
    final label = _labelCtrl.text.trim();
    return switch (_type) {
      ChangeType.credit => SimulationChange.credit(
          principal: _parseAmount(_amountCtrl.text),
          annualRate: _parseAmount(_rateCtrl.text),
          termMonths: _parseInt(_termCtrl.text),
          label: label.isEmpty ? 'Kredi' : label,
        ),
      ChangeType.housing => SimulationChange.housing(
          price: _parseAmount(_amountCtrl.text),
          downPayment: _parseAmount(_amount2Ctrl.text),
          annualRate: _parseAmount(_rateCtrl.text),
          termMonths: _parseInt(_termCtrl.text),
          monthlyExtras: _parseAmount(_extrasCtrl.text),
          label: label.isEmpty ? 'Ev Alımı' : label,
        ),
      ChangeType.car => SimulationChange.car(
          price: _parseAmount(_amountCtrl.text),
          downPayment: _parseAmount(_amount2Ctrl.text),
          annualRate: _parseAmount(_rateCtrl.text),
          termMonths: _parseInt(_termCtrl.text),
          monthlyRunningCosts: _parseAmount(_extrasCtrl.text),
          label: label.isEmpty ? 'Araç Alımı' : label,
        ),
      ChangeType.rent => SimulationChange.rentChange(
          currentRent: _parseAmount(_amountCtrl.text),
          newRent: _parseAmount(_amount2Ctrl.text),
          annualIncreaseRate: _parseAmount(_annualIncreaseCtrl.text),
          label: label.isEmpty ? 'Kira Değişimi' : label,
        ),
      ChangeType.salary => SimulationChange.salaryChange(
          currentGross: _parseAmount(_amountCtrl.text),
          newGross: _parseAmount(_amount2Ctrl.text),
          label: label.isEmpty ? 'Maaş Değişikliği' : label,
        ),
      ChangeType.income => SimulationChange.income(
          amount: _parseAmount(_amountCtrl.text),
          description: _descCtrl.text.trim(),
          isRecurring: _isRecurring,
          label: label.isEmpty ? 'Gelir' : label,
        ),
      ChangeType.expense => SimulationChange.expense(
          amount: _parseAmount(_amountCtrl.text),
          description: _descCtrl.text.trim(),
          isRecurring: _isRecurring,
          label: label.isEmpty ? 'Gider' : label,
        ),
      ChangeType.investment => SimulationChange.investment(
          principal: _parseAmount(_amountCtrl.text),
          annualReturnRate: _parseAmount(_rateCtrl.text),
          termMonths: _parseInt(_termCtrl.text),
          isCompound: _isCompound,
          label: label.isEmpty ? 'Yatırım' : label,
        ),
    };
  }

  void _save() {
    final change = _buildChange();
    if (change != null) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(change);
    }
  }

  String get _title => _type.label;

  Color get _color => _type.color;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = _color;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: c.surfaceBackground,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.borderDefault,
              borderRadius: AppRadius.pill,
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(_title,
                    style: AppTypography.titleLarge
                        .copyWith(color: c.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded, color: c.textTertiary),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  _Field(
                    label: 'Etiket (opsiyonel)',
                    controller: _labelCtrl,
                    color: color,
                    icon: LucideIcons.tag,
                    hint: _title,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Type-specific fields
                  ..._buildFields(color),

                  const SizedBox(height: AppSpacing.xl),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.minTouchTarget,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(
                        widget.change != null
                            ? LucideIcons.check
                            : LucideIcons.plus,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        widget.change != null ? 'Güncelle' : 'Ekle',
                        style: AppTypography.labelLarge
                            .copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.card),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(Color color) {
    return switch (_type) {
      ChangeType.credit => [
          _Field(
              label: 'Kredi Tutarı',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.banknote,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Yıllık Faiz',
                    controller: _rateCtrl,
                    color: color,
                    icon: LucideIcons.percent,
                    suffix: '%',
                    numeric: true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _Field(
                    label: 'Vade',
                    controller: _termCtrl,
                    color: color,
                    icon: LucideIcons.calendar,
                    suffix: 'ay',
                    numeric: true)),
          ]),
          const SizedBox(height: AppSpacing.md),
          SimSlider(
            label: 'Yıllık Faiz Oranı',
            value: _rateSlider,
            min: 10,
            max: 80,
            step: 0.5,
            format: (v) => '%${v.toStringAsFixed(1)}',
            color: color,
            onChanged: (v) {
              setState(() {
                _rateSlider = v;
                _rateCtrl.text = v.toStringAsFixed(1);
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SimSlider(
            label: 'Vade',
            value: _termSlider,
            min: 6,
            max: 120,
            step: 6,
            format: (v) => '${v.toInt()} ay',
            color: color,
            onChanged: (v) {
              setState(() {
                _termSlider = v;
                _termCtrl.text = v.toInt().toString();
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _TaxToggle(
            value: _includeTaxes,
            color: color,
            onChanged: (v) => setState(() => _includeTaxes = v),
          ),
        ],
      ChangeType.housing => [
          _Field(
              label: 'Konut Fiyatı',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.home,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Peşinat',
              controller: _amount2Ctrl,
              color: color,
              icon: LucideIcons.wallet,
              suffix: '₺',
              numeric: true,
              hint: 'FuzulEv / EminEvim birikimi dahil'),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Yıllık Faiz',
                    controller: _rateCtrl,
                    color: color,
                    icon: LucideIcons.percent,
                    suffix: '%',
                    numeric: true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _Field(
                    label: 'Vade',
                    controller: _termCtrl,
                    color: color,
                    icon: LucideIcons.calendar,
                    suffix: 'ay',
                    numeric: true)),
          ]),
          const SizedBox(height: AppSpacing.md),
          SimSlider(
            label: 'Yıllık Faiz Oranı',
            value: _rateSlider,
            min: 10,
            max: 80,
            step: 0.5,
            format: (v) => '%${v.toStringAsFixed(1)}',
            color: color,
            onChanged: (v) {
              setState(() {
                _rateSlider = v;
                _rateCtrl.text = v.toStringAsFixed(1);
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SimSlider(
            label: 'Vade',
            value: _termSlider,
            min: 6,
            max: 120,
            step: 6,
            format: (v) => '${v.toInt()} ay',
            color: color,
            onChanged: (v) {
              setState(() {
                _termSlider = v;
                _termCtrl.text = v.toInt().toString();
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Aylık Ek Giderler',
              controller: _extrasCtrl,
              color: color,
              icon: LucideIcons.receipt,
              suffix: '₺',
              numeric: true,
              hint: 'Aidat, sigorta...'),
          const SizedBox(height: AppSpacing.md),
          _TaxToggle(
            value: _includeTaxes,
            color: color,
            onChanged: (v) => setState(() => _includeTaxes = v),
          ),
        ],
      ChangeType.car => [
          _Field(
              label: 'Araç Fiyatı',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.car,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Peşinat',
              controller: _amount2Ctrl,
              color: color,
              icon: LucideIcons.wallet,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Yıllık Faiz',
                    controller: _rateCtrl,
                    color: color,
                    icon: LucideIcons.percent,
                    suffix: '%',
                    numeric: true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _Field(
                    label: 'Vade',
                    controller: _termCtrl,
                    color: color,
                    icon: LucideIcons.calendar,
                    suffix: 'ay',
                    numeric: true)),
          ]),
          const SizedBox(height: AppSpacing.md),
          SimSlider(
            label: 'Yıllık Faiz Oranı',
            value: _rateSlider,
            min: 10,
            max: 80,
            step: 0.5,
            format: (v) => '%${v.toStringAsFixed(1)}',
            color: color,
            onChanged: (v) {
              setState(() {
                _rateSlider = v;
                _rateCtrl.text = v.toStringAsFixed(1);
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SimSlider(
            label: 'Vade',
            value: _termSlider,
            min: 6,
            max: 120,
            step: 6,
            format: (v) => '${v.toInt()} ay',
            color: color,
            onChanged: (v) {
              setState(() {
                _termSlider = v;
                _termCtrl.text = v.toInt().toString();
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Aylık Giderler',
              controller: _extrasCtrl,
              color: color,
              icon: LucideIcons.fuel,
              suffix: '₺',
              numeric: true,
              hint: 'Yakıt, sigorta, bakım...'),
          const SizedBox(height: AppSpacing.md),
          _TaxToggle(
            value: _includeTaxes,
            color: color,
            onChanged: (v) => setState(() => _includeTaxes = v),
          ),
        ],
      ChangeType.rent => [
          _Field(
              label: 'Mevcut Kira',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.building2,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Yeni Kira',
              controller: _amount2Ctrl,
              color: color,
              icon: LucideIcons.arrowRight,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Yıllık Artış Oranı (opsiyonel)',
              controller: _annualIncreaseCtrl,
              color: color,
              icon: LucideIcons.trendingUp,
              suffix: '%',
              numeric: true,
              hint: 'Her yıl kira artış oranı'),
        ],
      ChangeType.salary => [
          _Field(
              label: 'Mevcut Brüt Maaş',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.briefcase,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Yeni Brüt Maaş',
              controller: _amount2Ctrl,
              color: color,
              icon: LucideIcons.trendingUp,
              suffix: '₺',
              numeric: true),
        ],
      ChangeType.income => [
          _Field(
              label: 'Tutar',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.trendingUp,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Açıklama',
              controller: _descCtrl,
              color: color,
              icon: LucideIcons.fileText,
              hint: 'Opsiyonel'),
          const SizedBox(height: AppSpacing.md),
          _RecurringToggle(
            value: _isRecurring,
            color: color,
            onChanged: (v) => setState(() => _isRecurring = v),
          ),
        ],
      ChangeType.expense => [
          _Field(
              label: 'Tutar',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.trendingDown,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Açıklama',
              controller: _descCtrl,
              color: color,
              icon: LucideIcons.fileText,
              hint: 'Opsiyonel'),
          const SizedBox(height: AppSpacing.md),
          _RecurringToggle(
            value: _isRecurring,
            color: color,
            onChanged: (v) => setState(() => _isRecurring = v),
          ),
        ],
      ChangeType.investment => [
          _Field(
              label: 'Yatırım Tutarı',
              controller: _amountCtrl,
              color: color,
              icon: LucideIcons.lineChart,
              suffix: '₺',
              numeric: true),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: _Field(
                    label: 'Yıllık Getiri',
                    controller: _rateCtrl,
                    color: color,
                    icon: LucideIcons.percent,
                    suffix: '%',
                    numeric: true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _Field(
                    label: 'Vade',
                    controller: _termCtrl,
                    color: color,
                    icon: LucideIcons.calendar,
                    suffix: 'ay',
                    numeric: true)),
          ]),
          const SizedBox(height: AppSpacing.md),
          _CompoundToggle(
            value: _isCompound,
            color: color,
            onChanged: (v) => setState(() => _isCompound = v),
          ),
        ],
    };
  }
}

// ─── Currency Input Formatter ───────────────────────────────────

/// Formats numeric input with Turkish thousand separators (1.000.000)
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakam ve virgül/nokta bırak
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Binlik ayracı ekle
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── Reusable Field ──────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final IconData icon;
  final String? suffix;
  final String? hint;
  final bool numeric;

  const _Field({
    required this.label,
    required this.controller,
    required this.color,
    required this.icon,
    this.suffix,
    this.hint,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Yüzde ve ay alanları maskeleme yapmasın
    final isPercentOrMonth = suffix == '%' || suffix == 'ay';
    final useMask = numeric && !isPercentOrMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: useMask ? [_CurrencyInputFormatter()] : null,
          style: AppTypography.bodyMedium.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: color),
            prefixText: useMask ? '₺ ' : null,
            prefixStyle: AppTypography.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            suffixText: suffix,
            suffixStyle:
                AppTypography.bodyMedium.copyWith(color: c.textTertiary),
            hintText: hint,
            hintStyle: AppTypography.bodyMedium
                .copyWith(color: c.textTertiary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: c.surfaceInput,
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }
}

// ─── Toggle Widgets ──────────────────────────────────────────────

class _RecurringToggle extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _RecurringToggle({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: c.borderDefault.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(value ? LucideIcons.repeat : LucideIcons.zap,
                size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(value ? 'Tekrarlayan (aylık)' : 'Tek seferlik',
                  style: AppTypography.bodyMedium
                      .copyWith(color: c.textPrimary)),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: color.withValues(alpha: 0.5),
              activeThumbColor: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxToggle extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _TaxToggle({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: value
                  ? color.withValues(alpha: 0.4)
                  : c.borderDefault.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.landmark, size: 18, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'KKDF + BSMV dahil et',
                    style: AppTypography.bodyMedium
                        .copyWith(color: c.textPrimary),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: color.withValues(alpha: 0.5),
                  activeThumbColor: color,
                ),
              ],
            ),
            if (value) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: AppRadius.chip,
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.info,
                        size: 12, color: color),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Faiz üzerine %25 ek vergi uygulanır (KKDF %15 + BSMV %10)',
                        style: AppTypography.caption.copyWith(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompoundToggle extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _CompoundToggle({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: c.borderDefault.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.trendingUp, size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value ? 'Bileşik Faiz' : 'Basit Faiz',
                      style: AppTypography.bodyMedium
                          .copyWith(color: c.textPrimary)),
                  Text(
                      value
                          ? 'Faiz üstüne faiz hesaplanır'
                          : 'Sadece ana para üzerinden hesaplanır',
                      style: AppTypography.caption
                          .copyWith(color: c.textTertiary)),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: color.withValues(alpha: 0.5),
              activeThumbColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
