import XCTest
@testable import SavvyFoundation

final class SimulationCalculatorTests: XCTestCase {

    private var mockBudget: MonthSummary {
        MonthSummary(
            yearMonth: "2026-04",
            totalIncome: 50000,
            totalExpense: 30000,
            totalSavings: 5000,
            netBalance: 20000,
            carryOver: 0,
            netWithCarryOver: 20000,
            savingsRate: 0.10,
            expenseRate: 0.60,
            healthScore: 70
        )
    }

    // MARK: - Empty Changes

    func testEmptyChanges_returnsCurrentBudget() {
        let result = SimulationCalculator.calculateScenario(
            changes: [],
            currentBudget: mockBudget
        )
        XCTAssertEqual(result.currentIncome, 50000)
        XCTAssertEqual(result.currentExpense, 30000)
        XCTAssertEqual(result.monthlyNetImpact, 0)
        XCTAssertEqual(result.monthlyProjection.count, 12)
    }

    // MARK: - Credit

    func testCredit_calculatesMonthlyPayment() {
        let changes: [SimulationChange] = [
            .credit(principal: 100000, annualRate: 24, termMonths: 12)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        // Monthly impact should be negative (expense)
        XCTAssertLessThan(result.monthlyNetImpact, 0)
        XCTAssertEqual(result.changeResults.count, 1)
        // Should have amortization schedule
        XCTAssertNotNil(result.changeResults[0].amortizationSchedule)
        XCTAssertEqual(result.changeResults[0].amortizationSchedule?.count, 12)
    }

    // MARK: - Housing

    func testHousing_includesDownPaymentAndExtras() {
        let changes: [SimulationChange] = [
            .housing(price: 5_000_000, downPayment: 1_000_000, annualRate: 36, termMonths: 120, monthlyExtras: 2000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertLessThan(result.monthlyNetImpact, 0)
        // Total cost should include down payment + extras
        if let totalCost = result.changeResults[0].totalCost {
            XCTAssertGreaterThan(totalCost, 5_000_000)
        }
    }

    // MARK: - Rent Change

    func testRentChange_calculatesDifference() {
        let changes: [SimulationChange] = [
            .rentChange(currentRent: 10000, newRent: 15000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        // 5000 increase in expense
        XCTAssertEqual(result.changeResults[0].monthlyImpact, -5000)
        XCTAssertEqual(result.newExpense, 35000)
    }

    // MARK: - Salary Change

    func testSalaryChange_usesGrossToNet() {
        let changes: [SimulationChange] = [
            .salaryChange(currentGross: 50000, newGross: 60000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        // Should be positive (income increase)
        XCTAssertGreaterThan(result.monthlyNetImpact, 0)
        XCTAssertNotNil(result.changeResults[0].salaryImpact)
    }

    // MARK: - Income/Expense

    func testIncome_addsToIncome() {
        let changes: [SimulationChange] = [
            .income(amount: 10000, description: "Freelance")
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertEqual(result.monthlyNetImpact, 10000)
        XCTAssertEqual(result.newIncome, 60000)
    }

    func testExpense_addsToExpense() {
        let changes: [SimulationChange] = [
            .expense(amount: 5000, description: "Araba bakım")
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertEqual(result.monthlyNetImpact, -5000)
        XCTAssertEqual(result.newExpense, 35000)
    }

    // MARK: - Investment

    func testInvestment_compoundReturns() {
        let changes: [SimulationChange] = [
            .investment(principal: 100000, annualReturnRate: 30, termMonths: 12, isCompound: true)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertGreaterThan(result.monthlyNetImpact, 0)
        XCTAssertNotNil(result.changeResults[0].investmentImpact)
    }

    func testInvestment_simpleReturns() {
        let changes: [SimulationChange] = [
            .investment(principal: 100000, annualReturnRate: 30, termMonths: 12, isCompound: false)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        let impact = result.changeResults[0]
        // Simple interest: 100000 * 0.30 = 30000 / 12 = 2500/month
        XCTAssertEqual(NSDecimalNumber(decimal: impact.monthlyImpact).doubleValue, 2500, accuracy: 10)
    }

    // MARK: - Multiple Changes

    func testMultipleChanges_combinesImpacts() {
        let changes: [SimulationChange] = [
            .income(amount: 15000),
            .expense(amount: 5000),
            .rentChange(currentRent: 10000, newRent: 12000),
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        // +15000 - 5000 - 2000 = +8000
        XCTAssertEqual(result.changeResults.count, 3)
        XCTAssertEqual(NSDecimalNumber(decimal: result.monthlyNetImpact).doubleValue, 8000, accuracy: 1)
    }

    // MARK: - Projection

    func testProjection_has12Months() {
        let changes: [SimulationChange] = [
            .income(amount: 5000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertEqual(result.monthlyProjection.count, 12)
        // Cumulative should grow
        XCTAssertGreaterThan(
            result.monthlyProjection[11].cumulativeNet,
            result.monthlyProjection[0].cumulativeNet
        )
    }

    // MARK: - Affordability

    func testAffordability_setForExpenses() {
        let changes: [SimulationChange] = [
            .expense(amount: 25000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertNotNil(result.affordability)
    }

    func testAffordability_nilForIncomeOnly() {
        let changes: [SimulationChange] = [
            .income(amount: 10000)
        ]
        let result = SimulationCalculator.calculateScenario(
            changes: changes, currentBudget: mockBudget
        )
        XCTAssertNil(result.affordability)
    }
}
