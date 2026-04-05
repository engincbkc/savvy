import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucide_icons/lucide_icons.dart';

part 'simulation_change.freezed.dart';
part 'simulation_change.g.dart';

/// Composable financial change unit.
/// A simulation can contain multiple changes to model complex scenarios.
@Freezed(unionKey: 'changeType')
sealed class SimulationChange with _$SimulationChange {
  /// Kredi cekimi — ihtiyac, konut, ticari
  const factory SimulationChange.credit({
    required double principal,
    required double annualRate,
    required int termMonths,
    @Default('Kredi') String label,
  }) = CreditChange;

  /// Ev alimi — konut kredisi + pesinat
  const factory SimulationChange.housing({
    required double price,
    @Default(0) double downPayment,
    required double annualRate,
    required int termMonths,
    @Default(0) double monthlyExtras,
    @Default('Ev Alımı') String label,
  }) = HousingChange;

  /// Arac alimi — taşıt kredisi + aylık giderler
  const factory SimulationChange.car({
    required double price,
    @Default(0) double downPayment,
    required double annualRate,
    required int termMonths,
    @Default(0) double monthlyRunningCosts,
    @Default('Araç Alımı') String label,
  }) = CarChange;

  /// Kira degisimi
  const factory SimulationChange.rentChange({
    required double currentRent,
    required double newRent,
    @Default(0.0) double annualIncreaseRate, // e.g. 25.0 = %25 per year
    @Default('Kira Değişimi') String label,
  }) = RentChangeChange;

  /// Is degisikligi / zam — brut maas degisikligi
  const factory SimulationChange.salaryChange({
    required double currentGross,
    required double newGross,
    @Default('Maaş Değişikliği') String label,
  }) = SalaryChangeChange;

  /// Gelir ekleme
  const factory SimulationChange.income({
    required double amount,
    @Default('') String description,
    @Default(true) bool isRecurring,
    @Default('Gelir') String label,
  }) = IncomeChange;

  /// Gider ekleme
  const factory SimulationChange.expense({
    required double amount,
    @Default('') String description,
    @Default(true) bool isRecurring,
    @Default('Gider') String label,
  }) = ExpenseChange;

  /// Yatirim
  const factory SimulationChange.investment({
    required double principal,
    required double annualReturnRate,
    required int termMonths,
    @Default(true) bool isCompound,
    @Default('Yatırım') String label,
  }) = InvestmentChange;

  factory SimulationChange.fromJson(Map<String, dynamic> json) =>
      _$SimulationChangeFromJson(json);
}

/// Reusable UI helpers — use these in cards, sheets, list tiles etc.
/// Keeps presentation logic out of widgets and centralised in one place.
extension SimulationChangeUI on SimulationChange {
  /// Display icon per change type.
  IconData get icon => switch (this) {
        CreditChange() => LucideIcons.creditCard,
        HousingChange() => LucideIcons.home,
        CarChange() => LucideIcons.car,
        RentChangeChange() => LucideIcons.building2,
        SalaryChangeChange() => LucideIcons.briefcase,
        IncomeChange() => LucideIcons.trendingUp,
        ExpenseChange() => LucideIcons.trendingDown,
        InvestmentChange() => LucideIcons.lineChart,
      };

  /// Accent color per change type.
  Color get color => switch (this) {
        CreditChange() => const Color(0xFFF59E0B),
        HousingChange() => const Color(0xFF3B82F6),
        CarChange() => const Color(0xFF8B5CF6),
        RentChangeChange() => const Color(0xFFEF4444),
        SalaryChangeChange() => const Color(0xFF10B981),
        IncomeChange() => const Color(0xFF22C55E),
        ExpenseChange() => const Color(0xFFEF4444),
        InvestmentChange() => const Color(0xFF6366F1),
      };

  /// Whether this change involves a loan (has amortization schedule).
  bool get hasLoan => switch (this) {
        CreditChange() => true,
        HousingChange(:final price, :final downPayment) =>
          price - downPayment > 0,
        CarChange(:final price, :final downPayment) =>
          price - downPayment > 0,
        _ => false,
      };

  /// Loan principal amount (0 if not loan-based).
  double get loanPrincipal => switch (this) {
        CreditChange(:final principal) => principal,
        HousingChange(:final price, :final downPayment) =>
          (price - downPayment).clamp(0, double.infinity),
        CarChange(:final price, :final downPayment) =>
          (price - downPayment).clamp(0, double.infinity),
        _ => 0,
      };

  /// Term in months (null if not applicable).
  int? get termMonths => switch (this) {
        CreditChange(:final termMonths) => termMonths,
        HousingChange(:final termMonths) => termMonths,
        CarChange(:final termMonths) => termMonths,
        InvestmentChange(:final termMonths) => termMonths,
        _ => null,
      };

  /// Annual rate (null if not applicable).
  double? get annualRate => switch (this) {
        CreditChange(:final annualRate) => annualRate,
        HousingChange(:final annualRate) => annualRate,
        CarChange(:final annualRate) => annualRate,
        InvestmentChange(:final annualReturnRate) => annualReturnRate,
        _ => null,
      };

  /// Short one-line summary for card previews.
  String get shortSummary => switch (this) {
        CreditChange(:final principal, :final termMonths) =>
          '₺${_compactNum(principal)} · $termMonths ay',
        HousingChange(:final price, :final termMonths) =>
          '₺${_compactNum(price)} · $termMonths ay',
        CarChange(:final price, :final termMonths) =>
          '₺${_compactNum(price)} · $termMonths ay',
        RentChangeChange(:final currentRent, :final newRent) =>
          '₺${_compactNum(currentRent)} → ₺${_compactNum(newRent)}',
        SalaryChangeChange(:final currentGross, :final newGross) =>
          '₺${_compactNum(currentGross)} → ₺${_compactNum(newGross)}',
        IncomeChange(:final amount) => '+₺${_compactNum(amount)}',
        ExpenseChange(:final amount) => '-₺${_compactNum(amount)}',
        InvestmentChange(:final principal, :final termMonths) =>
          '₺${_compactNum(principal)} · $termMonths ay',
      };
}

String _compactNum(double v) {
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e4) return '${(v / 1e3).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}
