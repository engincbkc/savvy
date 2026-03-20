import 'dart:math';
import 'package:savvy/core/constants/financial_enums.dart';

/// ALL financial calculations happen here — nowhere else.
/// BL-001: No math in UI. No math in Repository.
class FinancialCalculator {
  // ─── Core Summary ────────────────────────────────────────────────

  /// Net balance without carry-over.
  /// Birikim düşülmez — birikim para kaybı değil, yatırım/tasarruftur.
  static double netBalance({
    required double totalIncome,
    required double totalExpense,
    required double totalSavings,
  }) {
    assert(totalIncome >= 0, 'Income cannot be negative');
    assert(totalExpense >= 0, 'Expense cannot be negative');
    assert(totalSavings >= 0, 'Savings cannot be negative');
    return totalIncome - totalExpense;
  }

  /// Net balance with carry-over from previous month
  static double netWithCarryOver({
    required double netBalance,
    required double carryOver,
  }) =>
      netBalance + carryOver;

  /// Expense ratio (0.0 – 1.0+)
  static double expenseRatio({
    required double totalExpense,
    required double totalIncome,
  }) =>
      totalIncome > 0 ? totalExpense / totalIncome : 0.0;

  /// Savings rate (0.0 – 1.0)
  static double savingsRate({
    required double totalSavings,
    required double totalIncome,
  }) =>
      totalIncome > 0 ? totalSavings / totalIncome : 0.0;

  /// Target savings amount (default 20% rule)
  static double targetSavings({
    required double totalIncome,
    double targetRate = 0.20,
  }) =>
      totalIncome * targetRate;

  // ─── Financial Health Score (0–100) ──────────────────────────────

  static int financialHealthScore({
    required double savingsRate,
    required double expenseRatio,
    required double netBalance,
    required double emergencyFundMonths,
  }) {
    int score = 0;

    // Savings rate (max 35 pts)
    if (savingsRate >= 0.25) {
      score += 35;
    } else if (savingsRate >= 0.20) {
      score += 28;
    } else if (savingsRate >= 0.15) {
      score += 20;
    } else if (savingsRate >= 0.10) {
      score += 12;
    } else if (savingsRate >= 0.05) {
      score += 5;
    }

    // Expense ratio (max 30 pts)
    if (expenseRatio <= 0.50) {
      score += 30;
    } else if (expenseRatio <= 0.60) {
      score += 25;
    } else if (expenseRatio <= 0.70) {
      score += 18;
    } else if (expenseRatio <= 0.80) {
      score += 10;
    } else if (expenseRatio <= 0.90) {
      score += 4;
    }

    // Net balance (max 20 pts)
    if (netBalance > 0) {
      score += 20;
    } else if (netBalance == 0) {
      score += 8;
    }

    // Emergency fund (max 15 pts)
    if (emergencyFundMonths >= 6) {
      score += 15;
    } else if (emergencyFundMonths >= 3) {
      score += 10;
    } else if (emergencyFundMonths >= 1) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  static String healthScoreLabel(int score) => switch (score) {
        >= 80 => 'Mükemmel',
        >= 65 => 'İyi',
        >= 50 => 'Orta',
        >= 35 => 'Dikkat',
        _ => 'Kritik',
      };

  // ─── Savings Goal ────────────────────────────────────────────────

  static int monthsToGoal({
    required double targetAmount,
    required double currentAmount,
    required double monthlySavings,
  }) {
    if (monthlySavings <= 0) return -1;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlySavings).ceil();
  }

  static double requiredMonthlySavings({
    required double targetAmount,
    required double currentAmount,
    required int monthsLeft,
  }) {
    if (monthsLeft <= 0) return double.infinity;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return remaining / monthsLeft;
  }

  static double goalProgress({
    required double targetAmount,
    required double currentAmount,
  }) {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // ─── Loan / Installment ──────────────────────────────────────────

  /// Monthly loan payment (EMI - Equal Monthly Installment)
  static double monthlyLoanPayment({
    required double principal,
    required double annualRate,
    required int termMonths,
  }) {
    if (annualRate == 0) return principal / termMonths;
    final r = annualRate / 12;
    final n = termMonths;
    return principal * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  static double totalLoanPayment({
    required double monthlyPayment,
    required int termMonths,
  }) =>
      monthlyPayment * termMonths;

  static double totalInterest({
    required double totalPayment,
    required double principal,
  }) =>
      totalPayment - principal;

  static AffordabilityStatus loanAffordability({
    required double monthlyPayment,
    required double monthlyIncome,
  }) {
    final ratio =
        monthlyIncome > 0 ? monthlyPayment / monthlyIncome : 1.0;
    return switch (ratio) {
      < 0.25 => AffordabilityStatus.comfortable,
      < 0.35 => AffordabilityStatus.manageable,
      < 0.45 => AffordabilityStatus.tight,
      _ => AffordabilityStatus.risky,
    };
  }

  // ─── Brüt → Net Maaş Hesaplama (2026 Türkiye) ─────────────────
  // Kaynak: GİB Gelir Vergisi Tarifesi 2026 (Tebliğ Seri No: 332)
  // Doğrulama: verginet.net brüt-net tablosuyla ay ay eşleştirilmiştir.

  static const sgkWorkerRate = 0.14;
  static const unemploymentInsuranceRate = 0.01;
  static const double brutAsgariUcret = 33030.0;
  static const double _sgkTavan = 297270.0; // 33030 × 9
  static const double _damgaVergisiOrani = 0.00759;
  // Asgari ücret GV matrahı: 33030 - (33030 × 0.14) - (33030 × 0.01)
  static const double _asgariUcretGvMatrahi = 28075.50;

  /// 2026 Türkiye gelir vergisi dilimleri (ücret gelirleri — yıllık kümülatif)
  static const _taxBrackets2026 = [
    (limit: 190000.0, rate: 0.15),
    (limit: 400000.0, rate: 0.20),
    (limit: 1500000.0, rate: 0.27),
    (limit: 5300000.0, rate: 0.35),
    (limit: double.infinity, rate: 0.40),
  ];

  static const monthNamesTR = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  static const monthShortNamesTR = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  /// Kümülatif gelir vergisi hesapla (yıllık matrah üzerinden)
  static double _cumulativeTax(double cumulativeBase) {
    double tax = 0;
    double prevLimit = 0;
    for (final bracket in _taxBrackets2026) {
      if (cumulativeBase <= prevLimit) break;
      final taxableInBracket = min(cumulativeBase, bracket.limit) - prevLimit;
      tax += taxableInBracket * bracket.rate;
      prevLimit = bracket.limit;
    }
    return tax;
  }

  /// Returns the tax bracket rate for a given cumulative base
  static double _getCurrentBracketRate(double cumulativeBase) {
    for (final bracket in _taxBrackets2026) {
      if (cumulativeBase <= bracket.limit) return bracket.rate;
    }
    return 0.40;
  }

  /// Full 12-month gross-to-net with proper cumulative tax, SGK tavan,
  /// asgari ücret GV istisnası, and damga vergisi istisnası.
  static AnnualSalaryBreakdown calculateAnnualNetSalary({
    required double grossMonthly,
  }) {
    final months = <MonthlySalaryDetail>[];
    double cumBase = 0;
    double cumTax = 0;
    double cumAsgariBase = 0;
    double cumAsgariTax = 0;

    for (int i = 0; i < 12; i++) {
      // Adım 1: SGK ve İşsizlik (tavan sınırlı)
      final sgkMatrahi = min(grossMonthly, _sgkTavan);
      final sgkIsci = sgkMatrahi * sgkWorkerRate;
      final issizlikIsci = sgkMatrahi * unemploymentInsuranceRate;

      // Adım 2: Aylık GV matrahı
      final aylikGvMatrahi = grossMonthly - sgkIsci - issizlikIsci;

      // Adım 3: Kümülatif GV
      final yeniCumBase = cumBase + aylikGvMatrahi;
      final yeniCumTax = _cumulativeTax(yeniCumBase);
      final aylikGelirVergisi = max(yeniCumTax - cumTax, 0.0);

      // Adım 4: Damga vergisi (asgari ücret istisna matrahı)
      final damgaMatrahi = max(grossMonthly - brutAsgariUcret, 0.0);
      final damgaVergisi = damgaMatrahi * _damgaVergisiOrani;

      // Adım 5: Net (istisna öncesi)
      final netMaas =
          grossMonthly - sgkIsci - issizlikIsci - aylikGelirVergisi - damgaVergisi;

      // Adım 6: Asgari ücret GV istisnası (kümülatif)
      final yeniCumAsgariBase = cumAsgariBase + _asgariUcretGvMatrahi;
      final yeniCumAsgariTax = _cumulativeTax(yeniCumAsgariBase);
      var aylikGvIstisnasi = yeniCumAsgariTax - cumAsgariTax;
      aylikGvIstisnasi = min(aylikGvIstisnasi, aylikGelirVergisi);

      // Adım 7: Damga istisnası (sabit, her ay aynı)
      final damgaIstisnasi = min(
        brutAsgariUcret * _damgaVergisiOrani,
        damgaVergisi + (brutAsgariUcret * _damgaVergisiOrani),
      );

      // Adım 8: Toplam net ele geçen
      final netEleGecen = netMaas + aylikGvIstisnasi + damgaIstisnasi;

      months.add(MonthlySalaryDetail(
        monthIndex: i,
        monthName: monthNamesTR[i],
        monthShortName: monthShortNamesTR[i],
        grossMonthly: grossMonthly,
        sgk: sgkIsci,
        unemploymentInsurance: issizlikIsci,
        gvMatrah: aylikGvMatrahi,
        cumulativeBase: yeniCumBase,
        monthlyIncomeTax: aylikGelirVergisi,
        stampTax: damgaVergisi,
        netBeforeExemption: netMaas,
        gvExemption: aylikGvIstisnasi,
        stampExemption: damgaIstisnasi,
        netTakeHome: netEleGecen,
        taxBracketRate: _getCurrentBracketRate(yeniCumBase),
      ));

      // Adım 9: Sonraki aya taşı
      cumBase = yeniCumBase;
      cumTax = yeniCumTax;
      cumAsgariBase = yeniCumAsgariBase;
      cumAsgariTax = yeniCumAsgariTax;
    }

    final totalNet = months.fold(0.0, (s, m) => s + m.netTakeHome);
    final totalGross = grossMonthly * 12;

    return AnnualSalaryBreakdown(
      grossMonthly: grossMonthly,
      months: months,
      totalNet: totalNet,
      totalGross: totalGross,
      totalTax: months.fold(
          0.0, (s, m) => s + m.monthlyIncomeTax - m.gvExemption),
      totalSgk: months.fold(0.0, (s, m) => s + m.sgk + m.unemploymentInsurance),
      totalStampTax:
          months.fold(0.0, (s, m) => s + m.stampTax - m.stampExemption),
      effectiveTaxRate: totalGross > 0 ? (totalGross - totalNet) / totalGross : 0,
    );
  }

  /// Simple single-month gross-to-net (backward compat, returns January values)
  static SalaryBreakdown grossToNet({required double grossMonthly}) {
    final annual = calculateAnnualNetSalary(grossMonthly: grossMonthly);
    final jan = annual.months[0];
    return SalaryBreakdown(
      grossMonthly: grossMonthly,
      sgk: jan.sgk,
      unemploymentInsurance: jan.unemploymentInsurance,
      incomeTax: jan.monthlyIncomeTax - jan.gvExemption,
      stampTax: jan.stampTax - jan.stampExemption,
      totalDeductions: grossMonthly - jan.netTakeHome,
      netMonthly: jan.netTakeHome,
    );
  }

  // ─── Gross → Net Resolution ─────────────────────────────────────

  /// Brüt gelir kaydı için belirli bir aydaki net ele geçeni döndür.
  /// [month] 1-indexed (1=Ocak, 12=Aralık).
  /// Brüt değilse doğrudan amount döner.
  static double resolveNetForMonth({
    required double amount,
    required bool isGross,
    required int month,
  }) {
    if (!isGross) return amount;
    final breakdown = calculateAnnualNetSalary(grossMonthly: amount);
    return breakdown.months[(month - 1).clamp(0, 11)].netTakeHome;
  }

  /// 12 aylık net breakdown döndür (brüt değilse her ay aynı amount).
  static List<double> resolveAllMonths({
    required double amount,
    required bool isGross,
  }) {
    if (!isGross) return List.filled(12, amount);
    final breakdown = calculateAnnualNetSalary(grossMonthly: amount);
    return breakdown.months.map((m) => m.netTakeHome).toList();
  }

  // ─── Projections ─────────────────────────────────────────────────

  static double projectedSavings({
    required double currentSavings,
    required double monthlySavings,
    required int months,
  }) =>
      currentSavings + (monthlySavings * months);
}

/// Brüt → Net maaş hesaplama sonucu (basit, tek ay)
class SalaryBreakdown {
  final double grossMonthly;
  final double sgk;
  final double unemploymentInsurance;
  final double incomeTax;
  final double stampTax;
  final double totalDeductions;
  final double netMonthly;

  const SalaryBreakdown({
    required this.grossMonthly,
    required this.sgk,
    required this.unemploymentInsurance,
    required this.incomeTax,
    required this.stampTax,
    required this.totalDeductions,
    required this.netMonthly,
  });
}

/// Tek bir ayın detaylı brüt→net hesaplama sonucu
class MonthlySalaryDetail {
  final int monthIndex;
  final String monthName;
  final String monthShortName;
  final double grossMonthly;
  final double sgk;
  final double unemploymentInsurance;
  final double gvMatrah;
  final double cumulativeBase;
  final double monthlyIncomeTax;
  final double stampTax;
  final double netBeforeExemption;
  final double gvExemption;
  final double stampExemption;
  final double netTakeHome;
  final double taxBracketRate;

  const MonthlySalaryDetail({
    required this.monthIndex,
    required this.monthName,
    required this.monthShortName,
    required this.grossMonthly,
    required this.sgk,
    required this.unemploymentInsurance,
    required this.gvMatrah,
    required this.cumulativeBase,
    required this.monthlyIncomeTax,
    required this.stampTax,
    required this.netBeforeExemption,
    required this.gvExemption,
    required this.stampExemption,
    required this.netTakeHome,
    required this.taxBracketRate,
  });

  /// Net vergi yükü (istisna sonrası)
  double get netIncomeTax => monthlyIncomeTax - gvExemption;

  /// Net damga vergisi (istisna sonrası)
  double get netStampTax => stampTax - stampExemption;

  /// Toplam kesinti
  double get totalDeductions => grossMonthly - netTakeHome;
}

/// 12 aylık brüt→net hesaplama sonucu
class AnnualSalaryBreakdown {
  final double grossMonthly;
  final List<MonthlySalaryDetail> months;
  final double totalNet;
  final double totalGross;
  final double totalTax;
  final double totalSgk;
  final double totalStampTax;
  final double effectiveTaxRate;

  const AnnualSalaryBreakdown({
    required this.grossMonthly,
    required this.months,
    required this.totalNet,
    required this.totalGross,
    required this.totalTax,
    required this.totalSgk,
    required this.totalStampTax,
    required this.effectiveTaxRate,
  });

  /// En yüksek net (genellikle Ocak)
  double get maxNet => months.fold(0.0, (m, d) => max(m, d.netTakeHome));

  /// En düşük net
  double get minNet =>
      months.fold(double.infinity, (m, d) => min(m, d.netTakeHome));
}
