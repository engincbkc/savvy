import Foundation

public struct MonthSummary: Codable, Identifiable, Hashable, Sendable {
    public var id: String { yearMonth }

    public let yearMonth: String
    public let totalIncome: Decimal
    public let totalExpense: Decimal
    public let totalSavings: Decimal
    public let netBalance: Decimal
    public let carryOver: Decimal
    public let netWithCarryOver: Decimal
    public let savingsRate: Double
    public let expenseRate: Double
    public let healthScore: Int
    public let updatedAt: Date

    public init(
        yearMonth: String,
        totalIncome: Decimal,
        totalExpense: Decimal,
        totalSavings: Decimal,
        netBalance: Decimal,
        carryOver: Decimal,
        netWithCarryOver: Decimal,
        savingsRate: Double,
        expenseRate: Double,
        healthScore: Int,
        updatedAt: Date = Date()
    ) {
        self.yearMonth = yearMonth
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
        self.totalSavings = totalSavings
        self.netBalance = netBalance
        self.carryOver = carryOver
        self.netWithCarryOver = netWithCarryOver
        self.savingsRate = savingsRate
        self.expenseRate = expenseRate
        self.healthScore = healthScore
        self.updatedAt = updatedAt
    }
}
