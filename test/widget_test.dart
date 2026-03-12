import 'package:flutter_test/flutter_test.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

void main() {
  group('FinancialCalculator', () {
    group('netBalance', () {
      test('positive net balance', () {
        expect(
          FinancialCalculator.netBalance(
            totalIncome: 45000,
            totalExpense: 20000,
            totalSavings: 8000,
          ),
          equals(17000),
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

      test('savings is not added to expense', () {
        final net = FinancialCalculator.netBalance(
          totalIncome: 50000,
          totalExpense: 20000,
          totalSavings: 10000,
        );
        expect(net, equals(20000));
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
      test('standard loan calculation', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000,
          annualRate: 0.36,
          termMonths: 24,
        );
        expect(monthly, closeTo(5904.7, 1.0));
      });

      test('zero interest loan', () {
        expect(
          FinancialCalculator.monthlyLoanPayment(
            principal: 12000,
            annualRate: 0.0,
            termMonths: 12,
          ),
          equals(1000),
        );
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
