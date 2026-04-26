import 'package:flutter_test/flutter_test.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

void main() {
  group('SimulationCalculator - Kredi Hesaplamaları', () {
    // ─── EMI (Aylık Taksit) Formül Doğruluğu ─────────────────────────
    group('EMI Formülü', () {
      test('100K @ %2.5 aylık, 60 ay — bankacılık standart EMI', () {
        // EMI = P × [r(1+r)^n] / [(1+r)^n - 1]
        // P = 100.000, r = 0.025, n = 60
        // factor = (1.025)^60 = 4.3997895
        // EMI = 100000 × (0.025 × 4.3997895) / (4.3997895 - 1) = 3235.34 ₺
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000,
          monthlyRate: 0.025,
          termMonths: 60,
        );
        expect(monthly, closeTo(3235.34, 1.0));
      });

      test('500K @ %2.0 aylık, 120 ay — konut kredisi örneği', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 500000,
          monthlyRate: 0.02,
          termMonths: 120,
        );
        // factor = (1.02)^120 = 10.7652
        // EMI = 500000 × (0.02 × 10.7652) / (10.7652 - 1) = 11.048 ₺
        expect(monthly, closeTo(11048, 50));
      });

      test('200K @ %3.5 aylık, 36 ay — yüksek faizli ihtiyaç kredisi', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 200000,
          monthlyRate: 0.035,
          termMonths: 36,
        );
        // factor = (1.035)^36 = 3.4502
        // EMI = 200000 × (0.035 × 3.4502) / (3.4502 - 1) = 9857 ₺
        expect(monthly, closeTo(9857, 50));
      });

      test('sıfır faizli kredi — basit bölme', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 120000,
          monthlyRate: 0.0,
          termMonths: 12,
        );
        expect(monthly, equals(10000.0));
      });

      test('sıfır anapara — 0 döner', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 0,
          monthlyRate: 0.025,
          termMonths: 60,
        );
        expect(monthly, equals(0.0));
      });

      test('sıfır vade — 0 döner', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000,
          monthlyRate: 0.025,
          termMonths: 0,
        );
        expect(monthly, equals(0.0));
      });
    });

    // ─── YMO (Yıllık Maliyet Oranı) ─────────────────────────────────
    group('YMO Hesaplama', () {
      test('%2.0 aylık → %26.82 YMO', () {
        // YMO = (1 + 0.02)^12 - 1 = 0.2682
        final ymo = FinancialCalculator.calculateYMO(0.02);
        expect(ymo, closeTo(0.2682, 0.001));
      });

      test('%2.5 aylık → %34.49 YMO', () {
        final ymo = FinancialCalculator.calculateYMO(0.025);
        expect(ymo, closeTo(0.3449, 0.001));
      });

      test('%3.0 aylık → %42.58 YMO', () {
        final ymo = FinancialCalculator.calculateYMO(0.03);
        expect(ymo, closeTo(0.4258, 0.001));
      });

      test('%1.5 aylık → %19.56 YMO', () {
        final ymo = FinancialCalculator.calculateYMO(0.015);
        expect(ymo, closeTo(0.1956, 0.001));
      });

      test('%0 aylık → %0 YMO', () {
        final ymo = FinancialCalculator.calculateYMO(0.0);
        expect(ymo, equals(0.0));
      });
    });

    // ─── Toplam Faiz Hesabı ─────────────────────────────────────────
    group('Toplam Faiz', () {
      test('100K @ %2.5 aylık, 60 ay — toplam faiz', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000,
          monthlyRate: 0.025,
          termMonths: 60,
        );
        final totalPayment = FinancialCalculator.totalLoanPayment(
          monthlyPayment: monthly,
          termMonths: 60,
        );
        final interest = FinancialCalculator.totalInterest(
          totalPayment: totalPayment,
          principal: 100000,
        );
        // Taksit: 3235.34 × 60 = 194.120 ₺, Faiz: 94.120 ₺
        expect(totalPayment, closeTo(194120, 100));
        expect(interest, closeTo(94120, 100));
      });

      test('1M @ %2.0 aylık, 120 ay — uzun vadeli konut kredisi', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 1000000,
          monthlyRate: 0.02,
          termMonths: 120,
        );
        final totalPayment = monthly * 120;
        final interest = totalPayment - 1000000;
        // Taksit: 22.048 × 120 = 2.645.772 ₺, Faiz: 1.645.772 ₺
        expect(totalPayment, closeTo(2645772, 1000));
        expect(interest, closeTo(1645772, 1000));
      });
    });

    // ─── Kredi Vergi Hesabı (KKDF + BSMV) ───────────────────────────
    group('Kredi Vergileri', () {
      test('konut kredisi vergiden muaf', () {
        final effectiveRate = FinancialCalculator.effectiveMonthlyRate(
          monthlyRate: 0.02,
          isHousing: true,
          includeTaxes: true,
        );
        expect(effectiveRate, equals(0.02));
      });

      test('ihtiyaç kredisi %30 vergi ekler', () {
        final effectiveRate = FinancialCalculator.effectiveMonthlyRate(
          monthlyRate: 0.02,
          isHousing: false,
          includeTaxes: true,
        );
        // 0.02 × 1.30 = 0.026
        expect(effectiveRate, closeTo(0.026, 0.0001));
      });

      test('vergi tutarı hesabı', () {
        final taxAmount = FinancialCalculator.creditTaxAmount(100000);
        // %30 vergi
        expect(taxAmount, equals(30000.0));
      });
    });

    // ─── Affordability (Karşılanabilirlik) ─────────────────────────
    group('Affordability Status', () {
      test('<%30 gelir oranı → comfortable', () {
        final status = FinancialCalculator.loanAffordability(
          monthlyPayment: 2500,
          monthlyIncome: 10000,
        );
        expect(status, equals(AffordabilityStatus.comfortable));
      });

      test('%30-40 gelir oranı → manageable', () {
        final status = FinancialCalculator.loanAffordability(
          monthlyPayment: 3500,
          monthlyIncome: 10000,
        );
        expect(status, equals(AffordabilityStatus.manageable));
      });

      test('%40-50 gelir oranı → tight', () {
        final status = FinancialCalculator.loanAffordability(
          monthlyPayment: 4500,
          monthlyIncome: 10000,
        );
        expect(status, equals(AffordabilityStatus.tight));
      });

      test('>%50 gelir oranı → risky', () {
        final status = FinancialCalculator.loanAffordability(
          monthlyPayment: 6000,
          monthlyIncome: 10000,
        );
        expect(status, equals(AffordabilityStatus.risky));
      });
    });
  });

  group('SimulationCalculator - Senaryo Hesaplamaları', () {
    late MonthSummary mockBudget;

    setUp(() {
      mockBudget = MonthSummary(
        yearMonth: '2026-04',
        totalIncome: 60000,
        totalExpense: 40000,
        totalSavings: 5000,
        netBalance: 20000,
        netWithCarryOver: 20000,
        savingsRate: 0.083,
        expenseRate: 0.667,
        carryOver: 0,
        updatedAt: DateTime.now(),
      );
    });

    // ─── İhtiyaç Kredisi ─────────────────────────────────────────────
    group('İhtiyaç Kredisi', () {
      test('100K @ %2.5 aylık, 60 ay — aylık etki', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5, // UI'dan gelen %2.5
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        // monthlyRate UI'dan % olarak gelir, calculator /100 yapar
        // EMI = 3235.34 ₺
        expect(result.monthlyNetImpact, closeTo(-3235, 10));
        expect(result.newExpense, closeTo(43235, 10));
        expect(result.newNet, closeTo(16765, 10));

        // Toplam maliyet: 3235 × 60 = 194.120 ₺
        final changeResult = result.changeResults.first;
        expect(changeResult.totalCost, closeTo(194120, 100));
        expect(changeResult.totalInterest, closeTo(94120, 100));
      });

      test('amortisman çizelgesi — ilk ay kontrolü', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        final schedule = result.changeResults.first.amortizationSchedule;
        expect(schedule, isNotNull);
        expect(schedule!.length, equals(60));

        // İlk ay: faiz = 100000 × 0.025 = 2500, anapara = taksit - faiz = 735
        final firstRow = schedule[0];
        expect(firstRow.month, equals(1));
        expect(firstRow.interest, closeTo(2500, 1));
        expect(firstRow.payment, closeTo(3235, 10));
        expect(firstRow.principal, closeTo(735, 10));
        expect(firstRow.balance, closeTo(99265, 10));
      });

      test('amortisman çizelgesi — son ay bakiye 0', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        final schedule = result.changeResults.first.amortizationSchedule!;
        final lastRow = schedule.last;
        expect(lastRow.month, equals(60));
        expect(lastRow.balance, closeTo(0, 1)); // Sıfıra yakın
      });
    });

    // ─── Konut Kredisi ───────────────────────────────────────────────
    group('Konut Kredisi', () {
      test('500K ev, 150K peşinat, 350K kredi @ %1.85 aylık, 240 ay', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.housing(
              price: 500000,
              downPayment: 150000,
              monthlyRate: 1.85,
              termMonths: 240,
              monthlyExtras: 500, // Vergi/sigorta
            ),
          ],
          currentBudget: mockBudget,
        );

        // Kredi tutarı: 350K
        // EMI @ %1.85 aylık, 240 ay ≈ 6.555 ₺
        // Toplam aylık: 6.555 + 500 = 7.055 ₺
        expect(result.monthlyNetImpact, closeTo(-7055, 100));

        // Yeni gider: 40000 + 7055 = 47055
        expect(result.newExpense, closeTo(47055, 100));
      });

      test('peşinatsız konut kredisi', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.housing(
              price: 300000,
              downPayment: 0,
              monthlyRate: 2.0,
              termMonths: 120,
            ),
          ],
          currentBudget: mockBudget,
        );

        // 300K @ %2 aylık, 120 ay ≈ 6.607 ₺
        expect(result.monthlyNetImpact, closeTo(-6607, 50));
      });

      test('tam peşinatlı ev — kredi yok', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.housing(
              price: 200000,
              downPayment: 200000, // Tam peşinat
              monthlyRate: 2.0,
              termMonths: 120,
              monthlyExtras: 300,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Kredi yok, sadece aylık ekstralar
        expect(result.monthlyNetImpact, closeTo(-300, 1));
      });
    });

    // ─── Taşıt Kredisi ───────────────────────────────────────────────
    group('Taşıt Kredisi', () {
      test('400K araç, 100K peşinat, 300K kredi @ %2.8 aylık, 48 ay', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.car(
              price: 400000,
              downPayment: 100000,
              monthlyRate: 2.8,
              termMonths: 48,
              monthlyRunningCosts: 3000, // Sigorta, yakıt, bakım
            ),
          ],
          currentBudget: mockBudget,
        );

        // Kredi: 300K @ %2.8 aylık, 48 ay ≈ 11.439 ₺
        // Toplam: 11.439 + 3.000 = 14.439 ₺
        expect(result.monthlyNetImpact, closeTo(-14439, 100));
      });

      test('işletme gidersiz taşıt kredisi', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.car(
              price: 200000,
              downPayment: 50000,
              monthlyRate: 3.0,
              termMonths: 36,
            ),
          ],
          currentBudget: mockBudget,
        );

        // 150K @ %3 aylık, 36 ay ≈ 6.871 ₺
        expect(result.monthlyNetImpact, closeTo(-6871, 50));
      });
    });

    // ─── Yıllık Etki ve Vade Kontrolü ────────────────────────────────
    group('Yıllık Etki', () {
      test('60 aylık kredi — yıllık etki 12 ay ile sınırlı', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Aylık etki ≈ -3235 ₺
        // Yıllık etki: -3235 × min(60, 12) = -3235 × 12 ≈ -38.824 ₺
        expect(result.annualNetImpact, closeTo(-38824, 150));
      });

      test('6 aylık kısa vadeli kredi — yıllık etki 6 ay', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 60000,
              monthlyRate: 2.0,
              termMonths: 6,
            ),
          ],
          currentBudget: mockBudget,
        );

        // EMI ≈ 10.712 ₺
        // Yıllık etki: -10.712 × 6 ≈ -64.272 ₺
        expect(result.annualNetImpact, closeTo(-64272, 300));
      });
    });

    // ─── 12 Aylık Projeksiyon ────────────────────────────────────────
    group('12 Aylık Projeksiyon', () {
      test('projeksiyon 12 ay döndürür', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        expect(result.monthlyProjection.length, equals(12));
      });

      test('projeksiyon kümülatif net doğru hesaplanır', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        final projections = result.monthlyProjection;

        // İlk ay kümülatif = ilk ay net
        expect(projections[0].cumulativeNet, equals(projections[0].net));

        // İkinci ay kümülatif = 1. ay net + 2. ay net
        expect(
          projections[1].cumulativeNet,
          closeTo(projections[0].net + projections[1].net, 1),
        );
      });

      test('vade dışı aylarda simülasyon etkisi yok', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 30000,
              monthlyRate: 2.0,
              termMonths: 3, // Sadece 3 ay
            ),
          ],
          currentBudget: mockBudget,
        );

        final projections = result.monthlyProjection;

        // İlk 3 ayda kredi etkisi var
        expect(projections[0].expense, greaterThan(mockBudget.totalExpense));
        expect(projections[2].expense, greaterThan(mockBudget.totalExpense));

        // 4. aydan itibaren etkisi yok (base expense'e döner)
        expect(projections[3].expense, equals(mockBudget.totalExpense));
        expect(projections[11].expense, equals(mockBudget.totalExpense));
      });
    });

    // ─── Kira Değişimi ───────────────────────────────────────────────
    group('Kira Değişimi', () {
      test('kira artışı — basit fark', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.rentChange(
              currentRent: 8000,
              newRent: 12000,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Fark: 12000 - 8000 = 4000 ₺ ek gider
        expect(result.monthlyNetImpact, equals(-4000));
      });

      test('kira düşüşü — pozitif etki', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.rentChange(
              currentRent: 15000,
              newRent: 10000,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Fark: 10000 - 15000 = -5000 → +5000 tasarruf
        expect(result.monthlyNetImpact, equals(5000));
      });

      test('yıllık artış oranı ile kira — 2. yılda artış', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.rentChange(
              currentRent: 10000,
              newRent: 15000,
              annualIncreaseRate: 25.0, // %25 yıllık artış
            ),
          ],
          currentBudget: mockBudget,
        );

        final projections = result.monthlyProjection;

        // İlk 12 ayda artış uygulanmaz (yearsPassed = 0)
        // Fark her ayda 5000 ₺
        for (int i = 0; i < 12; i++) {
          expect(
            projections[i].expense - mockBudget.totalExpense,
            closeTo(5000, 100),
          );
        }
      });
    });

    // ─── Gelir ve Gider Değişiklikleri ───────────────────────────────
    group('Gelir/Gider', () {
      test('ek gelir ekleme', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.income(
              amount: 5000,
              description: 'Freelance',
            ),
          ],
          currentBudget: mockBudget,
        );

        expect(result.monthlyNetImpact, equals(5000));
        expect(result.newIncome, equals(65000));
        expect(result.newNet, equals(25000));
      });

      test('ek gider ekleme', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.expense(
              amount: 3000,
              description: 'Abonelik',
            ),
          ],
          currentBudget: mockBudget,
        );

        expect(result.monthlyNetImpact, equals(-3000));
        expect(result.newExpense, equals(43000));
        expect(result.newNet, equals(17000));
      });
    });

    // ─── Yatırım ─────────────────────────────────────────────────────
    group('Yatırım', () {
      test('bileşik faiz yatırım — 100K @ %12 yıllık, 24 ay', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.investment(
              principal: 100000,
              annualReturnRate: 12.0,
              termMonths: 24,
              isCompound: true,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Aylık oran: 12% / 12 = 1% = 0.01
        // Toplam getiri: 100000 × ((1.01)^24 - 1) ≈ 26.973 ₺
        // Aylık getiri: 26.973 / 24 ≈ 1.124 ₺
        expect(result.monthlyNetImpact, closeTo(1124, 50));
      });

      test('basit faiz yatırım — 100K @ %12 yıllık, 24 ay', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.investment(
              principal: 100000,
              annualReturnRate: 12.0,
              termMonths: 24,
              isCompound: false,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Basit faiz: 100000 × 0.12 × (24/12) = 24.000 ₺
        // Aylık: 24.000 / 24 = 1.000 ₺
        expect(result.monthlyNetImpact, equals(1000));
      });
    });

    // ─── Çoklu Değişiklik ────────────────────────────────────────────
    group('Çoklu Değişiklik', () {
      test('kredi + kira artışı — toplam etki', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 50000,
              monthlyRate: 2.0,
              termMonths: 24,
            ),
            const SimulationChange.rentChange(
              currentRent: 10000,
              newRent: 13000,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Kredi: ~2.617 ₺, Kira farkı: 3.000 ₺
        // Toplam: ~-5.617 ₺
        expect(result.monthlyNetImpact, closeTo(-5617, 50));
        expect(result.changeResults.length, equals(2));
      });

      test('gelir artışı + gider ekleme — net etki', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.income(
              amount: 10000,
              description: 'Zam',
            ),
            const SimulationChange.expense(
              amount: 4000,
              description: 'Araba taksidi',
            ),
          ],
          currentBudget: mockBudget,
        );

        // Gelir: +10.000, Gider: -4.000
        // Net: +6.000
        expect(result.monthlyNetImpact, equals(6000));
        expect(result.newIncome, equals(70000));
        expect(result.newExpense, equals(44000));
        expect(result.newNet, equals(26000));
      });
    });

    // ─── Boş Değişiklik ──────────────────────────────────────────────
    group('Boş Senaryo', () {
      test('değişiklik yoksa mevcut durumu döner', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [],
          currentBudget: mockBudget,
        );

        expect(result.monthlyNetImpact, equals(0));
        expect(result.newIncome, equals(mockBudget.totalIncome));
        expect(result.newExpense, equals(mockBudget.totalExpense));
        expect(result.newNet, equals(mockBudget.netBalance));
        expect(result.changeResults, isEmpty);
      });
    });

    // ─── Tasarruf ve Gider Oranları ──────────────────────────────────
    group('Oranlar', () {
      test('yeni tasarruf oranı doğru hesaplanır', () {
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 100000,
              monthlyRate: 2.5,
              termMonths: 60,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Yeni net: ~17.092 ₺
        // Yeni gelir: 60.000 ₺
        // Yeni tasarruf oranı: 17.092 / 60.000 ≈ 0.285
        expect(result.newSavingsRate, closeTo(0.285, 0.01));
      });

      test('negatif net — tasarruf oranı 0', () {
        // Çok büyük kredi ile negatif net
        final result = SimulationCalculator.calculateScenario(
          changes: [
            const SimulationChange.credit(
              principal: 500000,
              monthlyRate: 3.0,
              termMonths: 36,
            ),
          ],
          currentBudget: mockBudget,
        );

        // Taksit çok yüksek → net negatif → tasarruf 0
        expect(result.newSavingsRate, equals(0.0));
      });
    });
  });

  group('FinancialCalculator - Brüt/Net Maaş', () {
    test('50K brüt — Ocak net', () {
      final breakdown = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: 50000,
      );
      final jan = breakdown.months[0];

      // SGK: 50000 × 0.14 = 7000
      // İşsizlik: 50000 × 0.01 = 500
      // GV Matrahı: 50000 - 7500 = 42500
      expect(jan.sgk, closeTo(7000, 0.01));
      expect(jan.unemploymentInsurance, closeTo(500, 0.01));
      expect(jan.gvMatrah, closeTo(42500, 0.01));

      // Net ele geçen (istisna dahil) yaklaşık 39-40K civarı
      expect(jan.netTakeHome, greaterThan(38000));
      expect(jan.netTakeHome, lessThan(42000));
    });

    test('yıl boyunca vergi dilimi değişimi', () {
      final breakdown = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: 100000,
      );

      // Yılın başında düşük vergi, sonunda yüksek (dilim değişimi)
      final janNet = breakdown.months[0].netTakeHome;
      final decNet = breakdown.months[11].netTakeHome;

      // Aralık'ta daha düşük net (yüksek vergi dilimi)
      expect(decNet, lessThan(janNet));
    });

    test('asgari ücret GV istisnası uygulanır', () {
      final breakdown = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: 50000,
      );
      final jan = breakdown.months[0];

      // İstisna sıfırdan büyük olmalı
      expect(jan.gvExemption, greaterThan(0));
    });

    test('SGK tavanı uygulanır', () {
      final breakdown = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: 400000, // Tavandan yüksek
      );
      final jan = breakdown.months[0];

      // SGK tavanı: 297.270 × 0.14 = 41.618
      expect(jan.sgk, closeTo(41618, 100));
    });
  });
}
