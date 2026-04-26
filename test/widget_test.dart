import 'package:flutter_test/flutter_test.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

void main() {
  group('FinancialCalculator', () {
    group('netBalance', () {
      test('positive net balance', () {
        // Birikim düşülmez — sadece gelir - gider
        expect(
          FinancialCalculator.netBalance(
            totalIncome: 45000,
            totalExpense: 20000,
            totalSavings: 8000,
          ),
          equals(25000),
        );
      });

      test('negative net balance', () {
        expect(
          FinancialCalculator.netBalance(
            totalIncome: 20000,
            totalExpense: 25000,
            totalSavings: 0,
          ),
          equals(-5000),
        );
      });

      test('savings is not subtracted from net', () {
        // Birikim gelir-gider dengesini etkilemez
        final net = FinancialCalculator.netBalance(
          totalIncome: 50000,
          totalExpense: 20000,
          totalSavings: 10000,
        );
        expect(net, equals(30000));
      });
    });

    group('savingsRate', () {
      test('20% target threshold', () {
        final rate = FinancialCalculator.savingsRate(
          totalSavings: 10000,
          totalIncome: 50000,
        );
        expect(rate, closeTo(0.20, 0.001));
      });

      test('zero income returns 0', () {
        expect(
          FinancialCalculator.savingsRate(
            totalSavings: 1000,
            totalIncome: 0,
          ),
          equals(0.0),
        );
      });
    });

    group('monthlyLoanPayment', () {
      test('standard loan calculation (monthly rate)', () {
        // 3% monthly rate, 100K principal, 24 months
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000,
          monthlyRate: 0.03,
          termMonths: 24,
        );
        expect(monthly, closeTo(5904.7, 1.0));
      });

      test('zero interest loan', () {
        expect(
          FinancialCalculator.monthlyLoanPayment(
            principal: 12000,
            monthlyRate: 0.0,
            termMonths: 12,
          ),
          equals(1000),
        );
      });

      test('konut kredisi — 1M @ %2.49 aylık, 120 ay', () {
        // Hesapkurdu referansı: ~26.273 ₺
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 1000000,
          monthlyRate: 0.0249,
          termMonths: 120,
        );
        expect(monthly, closeTo(26273, 200));
      });

      test('konut kredisi — 10M @ %3.00 aylık, 120 ay', () {
        // Beklenen: ~310.620 ₺
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 10000000,
          monthlyRate: 0.03,
          termMonths: 120,
        );
        expect(monthly, closeTo(310620, 2000));
      });
    });

    group('financialHealthScore', () {
      test('perfect score scenario', () {
        final score = FinancialCalculator.financialHealthScore(
          savingsRate: 0.30,
          expenseRatio: 0.40,
          netBalance: 10000,
          emergencyFundMonths: 6,
        );
        expect(score, equals(100));
      });

      test('critical score scenario', () {
        final score = FinancialCalculator.financialHealthScore(
          savingsRate: 0.0,
          expenseRatio: 1.0,
          netBalance: -5000,
          emergencyFundMonths: 0,
        );
        expect(score, equals(0));
      });
    });
  });
}
