import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/simulation/presentation/widgets/affordability_gauge.dart';
import 'package:savvy/features/simulation/presentation/widgets/amortization_table.dart';
import 'package:savvy/features/simulation/presentation/widgets/before_after_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/breakdown_cards.dart';
import 'package:savvy/features/simulation/presentation/widgets/budget_snapshot_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/hero_result_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/section_header.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_form_field.dart';

class SimulationDetailScreen extends ConsumerStatefulWidget {
  final String simulationId;

  const SimulationDetailScreen({super.key, required this.simulationId});

  @override
  ConsumerState<SimulationDetailScreen> createState() =>
      _SimulationDetailScreenState();
}

class _SimulationDetailScreenState
    extends ConsumerState<SimulationDetailScreen> {
  SimulationEntry? _entry;
  bool _loaded = false;
  bool _showAmortization = false;

  // Form controllers
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _downPaymentCtrl = TextEditingController();
  final _monthlyCostCtrl = TextEditingController();
  final _currentRentCtrl = TextEditingController();
  final _increaseCtrl = TextEditingController();

  // Auto-calculate debounce
  bool _debouncing = false;

  // Results
  CreditSimulationResult? _creditResult;
  CarSimulationResult? _carResult;
  RentSimulationResult? _rentResult;

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    _downPaymentCtrl.dispose();
    _monthlyCostCtrl.dispose();
    _currentRentCtrl.dispose();
    _increaseCtrl.dispose();
    super.dispose();
  }

  void _loadParameters(SimulationEntry entry) {
    if (_loaded) return;
    _loaded = true;
    _entry = entry;
    final p = entry.parameters;
    _principalCtrl.text = _cleanDefault(p['principal']);
    _rateCtrl.text = _cleanDefault(p['annualRate']);
    _termCtrl.text = _cleanDefault(p['termMonths']);
    _downPaymentCtrl.text = _cleanDefault(p['downPayment']);
    _monthlyCostCtrl.text = _cleanDefault(p['monthlyCost']);
    _currentRentCtrl.text = _cleanDefault(p['currentRent']);
    _increaseCtrl.text = _cleanDefault(p['increasePercent']);

    // Attach listeners for auto-calculate
    for (final ctrl in [
      _principalCtrl,
      _rateCtrl,
      _termCtrl,
      _downPaymentCtrl,
      _monthlyCostCtrl,
      _currentRentCtrl,
      _increaseCtrl,
    ]) {
      ctrl.addListener(_autoCalculate);
    }

    // Auto-calculate if parameters already filled
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCalculate());
  }

  String _cleanDefault(dynamic val) {
    if (val == null) return '';
    final s = val.toString();
    return (s == '0' || s == '0.0') ? '' : s;
  }

  MonthSummary? get _currentBudget {
    final summaries = ref.read(allMonthSummariesProvider);
    return summaries.isNotEmpty ? summaries.first : null;
  }

  void _autoCalculate() {
    if (_debouncing) return;
    _debouncing = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      _debouncing = false;
      if (mounted) _runCalculation(save: false);
    });
  }

  void _calculate() {
    HapticFeedback.mediumImpact();
    _runCalculation(save: true);
  }

  void _runCalculation({required bool save}) {
    final entry = _entry;
    final budget = _currentBudget;
    if (entry == null || budget == null) return;

    setState(() {
      _creditResult = null;
      _carResult = null;
      _rentResult = null;
      _showAmortization = false;
    });

    switch (entry.type) {
      case SimulationType.credit:
      case SimulationType.investment:
      case SimulationType.custom:
        final principal = double.tryParse(_principalCtrl.text) ?? 0;
        final rate = double.tryParse(_rateCtrl.text) ?? 0;
        final term = int.tryParse(_termCtrl.text) ?? 0;
        if (principal <= 0 || rate <= 0 || term <= 0) return;
        setState(() {
          _creditResult = SimulationCalculator.credit(
            principal: principal,
            annualRate: rate / 100,
            termMonths: term,
            currentBudget: budget,
          );
        });
        if (save) {
          _saveParameters(
              {'principal': principal, 'annualRate': rate, 'termMonths': term});
        }

      case SimulationType.housing:
        final price = double.tryParse(_principalCtrl.text) ?? 0;
        final dp = double.tryParse(_downPaymentCtrl.text) ?? 0;
        final rate = double.tryParse(_rateCtrl.text) ?? 0;
        final term = int.tryParse(_termCtrl.text) ?? 0;
        if (price <= 0 || rate <= 0 || term <= 0) return;
        final loanAmount = price - dp;
        if (loanAmount <= 0) return;
        setState(() {
          _creditResult = SimulationCalculator.credit(
            principal: loanAmount,
            annualRate: rate / 100,
            termMonths: term,
            currentBudget: budget,
          );
        });
        if (save) {
          _saveParameters({
            'principal': price,
            'downPayment': dp,
            'annualRate': rate,
            'termMonths': term,
          });
        }

      case SimulationType.car:
        final price = double.tryParse(_principalCtrl.text) ?? 0;
        final dp = double.tryParse(_downPaymentCtrl.text) ?? 0;
        final rate = double.tryParse(_rateCtrl.text) ?? 0;
        final term = int.tryParse(_termCtrl.text) ?? 0;
        final mc = double.tryParse(_monthlyCostCtrl.text) ?? 0;
        if (price <= 0 || rate <= 0 || term <= 0) return;
        setState(() {
          _carResult = SimulationCalculator.car(
            vehiclePrice: price,
            downPayment: dp,
            annualRate: rate / 100,
            termMonths: term,
            estimatedMonthlyCosts: mc,
            currentBudget: budget,
          );
        });
        if (save) {
          _saveParameters({
            'principal': price,
            'downPayment': dp,
            'annualRate': rate,
            'termMonths': term,
            'monthlyCost': mc,
          });
        }

      case SimulationType.rent:
        final rent = double.tryParse(_currentRentCtrl.text) ?? 0;
        final inc = double.tryParse(_increaseCtrl.text) ?? 0;
        if (rent <= 0) return;
        setState(() {
          _rentResult = SimulationCalculator.rentChange(
            currentRent: rent,
            increasePercent: inc,
            currentBudget: budget,
          );
        });
        if (save) {
          _saveParameters({'currentRent': rent, 'increasePercent': inc});
        }
    }
  }

  Future<void> _saveParameters(Map<String, dynamic> params) async {
    final entry = _entry;
    if (entry == null) return;
    await ref.read(simulationProvider.notifier).updateSimulation(
          entry.copyWith(parameters: params, updatedAt: DateTime.now()),
        );
  }

  bool get _hasResults =>
      _creditResult != null || _carResult != null || _rentResult != null;

  double get _monthlyImpact {
    if (_creditResult != null) return _creditResult!.monthlyPayment;
    if (_carResult != null) return _carResult!.totalMonthlyImpact;
    if (_rentResult != null) return _rentResult!.monthlyDiff;
    return 0;
  }

  double get _newNetBalance {
    if (_creditResult != null) return _creditResult!.newNetBalance;
    if (_carResult != null) return _carResult!.newNetBalance;
    if (_rentResult != null) return _rentResult!.newNetBalance;
    return 0;
  }

  AffordabilityStatus? get _affordability {
    if (_creditResult != null) return _creditResult!.affordability;
    if (_carResult != null) return _carResult!.affordability;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final simulationsAsync = ref.watch(allSimulationsProvider);

    return simulationsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Hata: $e',
              style: AppTypography.bodyMedium.copyWith(color: c.expense)),
        ),
      ),
      data: (simulations) {
        final entry =
            simulations.where((s) => s.id == widget.simulationId).firstOrNull;
        if (entry == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.alertTriangle,
                      size: 48, color: c.textTertiary),
                  const SizedBox(height: AppSpacing.base),
                  Text('Simülasyon bulunamadı',
                      style: AppTypography.titleMedium
                          .copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          );
        }

        _loadParameters(entry);
        final typeColor = _parseColor(entry);
        final budget = _currentBudget;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  leading: IconButton(
                    icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
                    onPressed: () => context.go('/simulate'),
                  ),
                  title: Text(entry.title,
                      style: AppTypography.headlineSmall
                          .copyWith(color: c.textPrimary)),
                  centerTitle: false,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: AppSpacing.base),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(entry.type.icon, size: 14, color: typeColor),
                          const SizedBox(width: 4),
                          Text(entry.type.label,
                              style: AppTypography.caption.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: AppSpacing.screenH,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),

                      // Description
                      if (entry.description != null &&
                          entry.description!.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.base),
                          child: Text(entry.description!,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: c.textSecondary)),
                        ),

                      // Current Budget Snapshot
                      if (budget != null) ...[
                        BudgetSnapshotCard(budget: budget),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Section: Parametreler
                      SectionHeader(
                        icon: LucideIcons.settings2,
                        title: 'Parametreler',
                        color: typeColor,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildForm(context, entry.type, typeColor),

                      const SizedBox(height: AppSpacing.lg),

                      // Calculate & Save button
                      SizedBox(
                        width: double.infinity,
                        height: AppSpacing.minTouchTarget,
                        child: ElevatedButton.icon(
                          onPressed: _calculate,
                          icon: const Icon(LucideIcons.save, size: 18),
                          label: Text('Hesapla ve Kaydet',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: typeColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.card),
                            elevation: 0,
                          ),
                        ),
                      ),

                      // Results
                      if (_hasResults && budget != null) ...[
                        const SizedBox(height: AppSpacing.xl),

                        HeroResultCard(
                          monthlyImpact: _monthlyImpact,
                          color: typeColor,
                          isRent: entry.type == SimulationType.rent,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        BeforeAfterCard(
                          budget: budget,
                          monthlyImpact: _monthlyImpact,
                          newNetBalance: _newNetBalance,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        if (_affordability != null)
                          AffordabilityGauge(
                            status: _affordability!,
                            ratio: _creditResult?.incomeRatio ??
                                (_carResult != null
                                    ? _carResult!.totalMonthlyImpact /
                                        (budget.totalIncome == 0
                                            ? 1
                                            : budget.totalIncome)
                                    : 0),
                          ),

                        if (_affordability != null)
                          const SizedBox(height: AppSpacing.base),

                        if (_creditResult != null)
                          CreditBreakdownCard(
                              result: _creditResult!, color: typeColor),
                        if (_carResult != null)
                          CarBreakdownCard(
                              result: _carResult!, color: typeColor),
                        if (_rentResult != null)
                          RentBreakdownCard(
                              result: _rentResult!, color: typeColor),

                        // Amortization schedule
                        if (_creditResult != null &&
                            _creditResult!
                                .amortizationSchedule.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.base),
                          _buildAmortizationToggle(context, typeColor),
                          if (_showAmortization)
                            AmortizationTable(
                              schedule:
                                  _creditResult!.amortizationSchedule,
                              color: typeColor,
                            ),
                        ],
                        if (_carResult != null &&
                            _carResult!.creditResult.amortizationSchedule
                                .isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.base),
                          _buildAmortizationToggle(context, typeColor),
                          if (_showAmortization)
                            AmortizationTable(
                              schedule: _carResult!
                                  .creditResult.amortizationSchedule,
                              color: typeColor,
                            ),
                        ],
                      ],

                      const SizedBox(height: AppSpacing.xl5 + AppSpacing.xl2),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmortizationToggle(BuildContext context, Color color) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _showAmortization = !_showAmortization);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: _showAmortization ? AppRadius.topOnly : AppRadius.card,
          border: Border.all(color: c.borderDefault),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.table2, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text('Ödeme Planı',
                style: AppTypography.titleMedium
                    .copyWith(color: c.textPrimary)),
            const Spacer(),
            AnimatedRotation(
              turns: _showAmortization ? 0.5 : 0,
              duration: AppDuration.normal,
              child:
                  Icon(LucideIcons.chevronDown, size: 18, color: c.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(SimulationEntry entry) {
    try {
      final hex = entry.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return entry.type.color;
    }
  }

  // ─── Form builders ───────────────────────────────────────────────

  Widget _buildForm(BuildContext context, SimulationType type, Color color) {
    return switch (type) {
      SimulationType.rent => _buildRentForm(context, color),
      SimulationType.car => _buildCarForm(context, color),
      SimulationType.housing => _buildHousingForm(context, color),
      _ => _buildCreditForm(context, color),
    };
  }

  Widget _buildCreditForm(BuildContext context, Color color) {
    return Column(
      children: [
        SimFormField(
            label: 'Kredi Tutarı',
            suffix: '₺',
            controller: _principalCtrl,
            icon: LucideIcons.banknote,
            color: color),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
              child: SimFormField(
                  label: 'Yıllık Faiz',
                  suffix: '%',
                  controller: _rateCtrl,
                  icon: LucideIcons.percent,
                  color: color,
                  decimal: true)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: SimFormField(
                  label: 'Vade',
                  suffix: 'ay',
                  controller: _termCtrl,
                  icon: LucideIcons.calendar,
                  color: color)),
        ]),
      ],
    );
  }

  Widget _buildHousingForm(BuildContext context, Color color) {
    return Column(
      children: [
        SimFormField(
            label: 'Konut Fiyatı',
            suffix: '₺',
            controller: _principalCtrl,
            icon: LucideIcons.home,
            color: color),
        const SizedBox(height: AppSpacing.md),
        SimFormField(
            label: 'Peşinat',
            suffix: '₺',
            controller: _downPaymentCtrl,
            icon: LucideIcons.wallet,
            color: color,
            hint: 'FuzulEv / EminEvim birikimi dahil'),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
              child: SimFormField(
                  label: 'Yıllık Faiz',
                  suffix: '%',
                  controller: _rateCtrl,
                  icon: LucideIcons.percent,
                  color: color,
                  decimal: true)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: SimFormField(
                  label: 'Vade',
                  suffix: 'ay',
                  controller: _termCtrl,
                  icon: LucideIcons.calendar,
                  color: color)),
        ]),
      ],
    );
  }

  Widget _buildCarForm(BuildContext context, Color color) {
    return Column(
      children: [
        SimFormField(
            label: 'Araç Fiyatı',
            suffix: '₺',
            controller: _principalCtrl,
            icon: LucideIcons.car,
            color: color),
        const SizedBox(height: AppSpacing.md),
        SimFormField(
            label: 'Peşinat',
            suffix: '₺',
            controller: _downPaymentCtrl,
            icon: LucideIcons.wallet,
            color: color),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
              child: SimFormField(
                  label: 'Yıllık Faiz',
                  suffix: '%',
                  controller: _rateCtrl,
                  icon: LucideIcons.percent,
                  color: color,
                  decimal: true)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: SimFormField(
                  label: 'Vade',
                  suffix: 'ay',
                  controller: _termCtrl,
                  icon: LucideIcons.calendar,
                  color: color)),
        ]),
        const SizedBox(height: AppSpacing.md),
        SimFormField(
            label: 'Aylık Giderler',
            suffix: '₺',
            controller: _monthlyCostCtrl,
            icon: LucideIcons.fuel,
            color: color,
            hint: 'Yakıt, sigorta, bakım...'),
      ],
    );
  }

  Widget _buildRentForm(BuildContext context, Color color) {
    return Column(
      children: [
        SimFormField(
            label: 'Mevcut Kira',
            suffix: '₺',
            controller: _currentRentCtrl,
            icon: LucideIcons.building2,
            color: color),
        const SizedBox(height: AppSpacing.md),
        SimFormField(
            label: 'Artış Oranı',
            suffix: '%',
            controller: _increaseCtrl,
            icon: LucideIcons.trendingUp,
            color: color,
            decimal: true),
      ],
    );
  }
}
