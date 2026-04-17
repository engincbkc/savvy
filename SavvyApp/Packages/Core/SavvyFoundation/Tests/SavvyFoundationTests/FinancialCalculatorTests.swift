import XCTest
@testable import SavvyFoundation

final class FinancialCalculatorTests: XCTestCase {

    // MARK: - Core Summary

    func testNetBalance_incomeMinusExpense() {
        let result = FinancialCalculator.netBalance(
            totalIncome: 50000, totalExpense: 30000, totalSavings: 5000
        )
        XCTAssertEqual(result, 20000)
    }

    func testNetBalance_zeroIncome() {
        let result = FinancialCalculator.netBalance(
            totalIncome: 0, totalExpense: 1000, totalSavings: 0
        )
        XCTAssertEqual(result, -1000)
    }

    func testNetWithCarryOver() {
        let result = FinancialCalculator.netWithCarryOver(netBalance: 5000, carryOver: 3000)
        XCTAssertEqual(result, 8000)
    }

    func testExpenseRatio() {
        let ratio = FinancialCalculator.expenseRatio(totalExpense: 30000, totalIncome: 50000)
        XCTAssertEqual(ratio, 0.6, accuracy: 0.001)
    }

    func testExpenseRatio_zeroIncome() {
        let ratio = FinancialCalculator.expenseRatio(totalExpense: 5000, totalIncome: 0)
        XCTAssertEqual(ratio, 0.0)
    }

    func testSavingsRate() {
        let rate = FinancialCalculator.savingsRate(totalSavings: 10000, totalIncome: 50000)
        XCTAssertEqual(rate, 0.2, accuracy: 0.001)
    }

    func testSavingsRate_zeroIncome() {
        let rate = FinancialCalculator.savingsRate(totalSavings: 5000, totalIncome: 0)
        XCTAssertEqual(rate, 0.0)
    }

    func testTargetSavings() {
        let target = FinancialCalculator.targetSavings(totalIncome: 50000)
        XCTAssertEqual(target, 10000)
    }

    // MARK: - Health Score

    func testHealthScore_perfect() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.30, expenseRatio: 0.40,
            netBalance: 10000, emergencyFundMonths: 8
        )
        XCTAssertEqual(score, 100)
    }

    func testHealthScore_critical() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.02, expenseRatio: 0.95,
            netBalance: -5000, emergencyFundMonths: 0
        )
        XCTAssertEqual(score, 0)
    }

    func testHealthScore_medium() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.15, expenseRatio: 0.65,
            netBalance: 5000, emergencyFundMonths: 2
        )
        XCTAssertEqual(score, 63) // 20 + 18 + 20 + 5
    }

    func testHealthScoreLabel() {
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(85), "Mükemmel")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(70), "İyi")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(50), "Orta")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(35), "Dikkat")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(20), "Kritik")
    }

    // MARK: - Loan Calculation

    func testMonthlyLoanPayment() {
        let emi = FinancialCalculator.monthlyLoanPayment(
            principal: 100000, annualRate: Decimal(string: "0.24")!, termMonths: 12
        )
        XCTAssertEqual(NSDecimalNumber(decimal: emi).doubleValue, 9456, accuracy: 50)
    }

    func testMonthlyLoanPayment_zeroRate() {
        let emi = FinancialCalculator.monthlyLoanPayment(
            principal: 12000, annualRate: 0, termMonths: 12
        )
        XCTAssertEqual(emi, 1000)
    }

    func testTotalLoanPayment() {
        let total = FinancialCalculator.totalLoanPayment(monthlyPayment: 5000, termMonths: 12)
        XCTAssertEqual(total, 60000)
    }

    func testTotalInterest() {
        let interest = FinancialCalculator.totalInterest(totalPayment: 60000, principal: 50000)
        XCTAssertEqual(interest, 10000)
    }

    func testLoanAffordability() {
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 5000, monthlyIncome: 50000),
            .comfortable
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 15000, monthlyIncome: 50000),
            .manageable
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 20000, monthlyIncome: 50000),
            .tight
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 25000, monthlyIncome: 50000),
            .risky
        )
    }

    // MARK: - Credit Tax

    func testRealAnnualRateWithTaxes() {
        let rate = FinancialCalculator.realAnnualRateWithTaxes(Decimal(string: "0.24")!)
        XCTAssertEqual(rate, Decimal(string: "0.30")!)
    }

    func testCreditTaxAmount() {
        let tax = FinancialCalculator.creditTaxAmount(10000)
        XCTAssertEqual(tax, 2500)
    }

    // MARK: - Savings Goal

    func testMonthsToGoal() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 20000, monthlySavings: 5000
        )
        XCTAssertEqual(months, 16)
    }

    func testMonthsToGoal_alreadyReached() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 150000, monthlySavings: 5000
        )
        XCTAssertEqual(months, 0)
    }

    func testMonthsToGoal_zeroSavings() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 20000, monthlySavings: 0
        )
        XCTAssertEqual(months, -1)
    }

    func testGoalProgress() {
        let progress = FinancialCalculator.goalProgress(
            targetAmount: 100000, currentAmount: 75000
        )
        XCTAssertEqual(progress, 0.75, accuracy: 0.001)
    }

    func testGoalProgress_exceeded() {
        let progress = FinancialCalculator.goalProgress(
            targetAmount: 100000, currentAmount: 120000
        )
        XCTAssertEqual(progress, 1.0)
    }

    func testRequiredMonthlySavings() {
        let required = FinancialCalculator.requiredMonthlySavings(
            targetAmount: 100000, currentAmount: 40000, monthsLeft: 12
        )
        XCTAssertEqual(required, 5000)
    }

    // MARK: - Gross-to-Net Salary

    func testGrossToNet_50K() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 50000)
        let jan = breakdown.months[0]
        let dec = breakdown.months[11]

        // January net > December net (tax bracket progression)
        XCTAssertGreaterThan(jan.netTakeHome, dec.netTakeHome)

        // Total net < total gross
        XCTAssertLessThan(breakdown.totalNet, breakdown.totalGross)

        // 12 months
        XCTAssertEqual(breakdown.months.count, 12)
    }

    func testGrossToNet_sgkTavan() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 400000)
        let jan = breakdown.months[0]
        let expectedSgk = Decimal(297270) * Decimal(string: "0.14")!
        XCTAssertEqual(jan.sgk, expectedSgk)
    }

    func testGrossToNet_taxBracketProgression() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 100000)
        XCTAssertEqual(breakdown.months[0].taxBracketRate, Decimal(string: "0.15")!)
        XCTAssertGreaterThan(breakdown.months[11].taxBracketRate, Decimal(string: "0.15")!)
    }

    func testResolveNetForMonth_notGross() {
        let net = FinancialCalculator.resolveNetForMonth(amount: 50000, isGross: false, month: 6)
        XCTAssertEqual(net, 50000)
    }

    func testResolveAllMonths_gross() {
        let months = FinancialCalculator.resolveAllMonths(amount: 50000, isGross: true)
        XCTAssertEqual(months.count, 12)
        XCTAssertNotEqual(months[0], months[11])
    }

    func testResolveAllMonths_notGross() {
        let months = FinancialCalculator.resolveAllMonths(amount: 50000, isGross: false)
        XCTAssertEqual(months.count, 12)
        XCTAssertTrue(months.allSatisfy { $0 == 50000 })
    }
}
