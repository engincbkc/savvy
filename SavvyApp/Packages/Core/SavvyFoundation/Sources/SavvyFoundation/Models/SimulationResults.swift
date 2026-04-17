import Foundation

public struct SimulationResult: Sendable {
    public let currentIncome: Decimal
    public let currentExpense: Decimal
    public let currentNet: Decimal
    public let newIncome: Decimal
    public let newExpense: Decimal
    public let newNet: Decimal
    public let monthlyNetImpact: Decimal
    public let annualNetImpact: Decimal
    public let newSavingsRate: Double
    public let newExpenseRate: Double
    public let affordability: AffordabilityStatus?
    public let changeResults: [ChangeResult]
    public let monthlyProjection: [MonthProjection]

    public init(
        currentIncome: Decimal, currentExpense: Decimal, currentNet: Decimal,
        newIncome: Decimal, newExpense: Decimal, newNet: Decimal,
        monthlyNetImpact: Decimal, annualNetImpact: Decimal,
        newSavingsRate: Double, newExpenseRate: Double,
        affordability: AffordabilityStatus?,
        changeResults: [ChangeResult],
        monthlyProjection: [MonthProjection]
    ) {
        self.currentIncome = currentIncome
        self.currentExpense = currentExpense
        self.currentNet = currentNet
        self.newIncome = newIncome
        self.newExpense = newExpense
        self.newNet = newNet
        self.monthlyNetImpact = monthlyNetImpact
        self.annualNetImpact = annualNetImpact
        self.newSavingsRate = newSavingsRate
        self.newExpenseRate = newExpenseRate
        self.affordability = affordability
        self.changeResults = changeResults
        self.monthlyProjection = monthlyProjection
    }
}

public struct ChangeResult: Sendable {
    public let change: SimulationChange
    public let monthlyImpact: Decimal
    public let totalCost: Decimal?
    public let totalInterest: Decimal?
    public let amortizationSchedule: [AmortizationRow]?
    public let salaryImpact: SalaryImpact?
    public let investmentImpact: InvestmentImpact?

    public init(
        change: SimulationChange, monthlyImpact: Decimal,
        totalCost: Decimal? = nil, totalInterest: Decimal? = nil,
        amortizationSchedule: [AmortizationRow]? = nil,
        salaryImpact: SalaryImpact? = nil, investmentImpact: InvestmentImpact? = nil
    ) {
        self.change = change
        self.monthlyImpact = monthlyImpact
        self.totalCost = totalCost
        self.totalInterest = totalInterest
        self.amortizationSchedule = amortizationSchedule
        self.salaryImpact = salaryImpact
        self.investmentImpact = investmentImpact
    }
}

public struct MonthProjection: Identifiable, Sendable {
    public var id: String { yearMonth }
    public let yearMonth: String
    public let monthLabel: String
    public let income: Decimal
    public let expense: Decimal
    public let net: Decimal
    public let cumulativeNet: Decimal
    public let incomeItems: [MonthLineItem]
    public let expenseItems: [MonthLineItem]

    public init(
        yearMonth: String, monthLabel: String,
        income: Decimal, expense: Decimal, net: Decimal, cumulativeNet: Decimal,
        incomeItems: [MonthLineItem], expenseItems: [MonthLineItem]
    ) {
        self.yearMonth = yearMonth
        self.monthLabel = monthLabel
        self.income = income
        self.expense = expense
        self.net = net
        self.cumulativeNet = cumulativeNet
        self.incomeItems = incomeItems
        self.expenseItems = expenseItems
    }
}

public struct AmortizationRow: Identifiable, Sendable {
    public var id: Int { month }
    public let month: Int
    public let payment: Decimal
    public let principal: Decimal
    public let interest: Decimal
    public let balance: Decimal

    public init(month: Int, payment: Decimal, principal: Decimal, interest: Decimal, balance: Decimal) {
        self.month = month
        self.payment = payment
        self.principal = principal
        self.interest = interest
        self.balance = balance
    }
}

public struct MonthLineItem: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let amount: Decimal
    public let isSimulated: Bool

    public init(id: String = UUID().uuidString, label: String, amount: Decimal, isSimulated: Bool = false) {
        self.id = id
        self.label = label
        self.amount = amount
        self.isSimulated = isSimulated
    }
}

public struct SalaryImpact: Sendable {
    public let oldNet: Decimal
    public let newNet: Decimal
    public let difference: Decimal

    public init(oldNet: Decimal, newNet: Decimal) {
        self.oldNet = oldNet
        self.newNet = newNet
        self.difference = newNet - oldNet
    }
}

public struct InvestmentImpact: Sendable {
    public let totalReturn: Decimal
    public let totalInvested: Decimal
    public let profit: Decimal

    public init(totalReturn: Decimal, totalInvested: Decimal) {
        self.totalReturn = totalReturn
        self.totalInvested = totalInvested
        self.profit = totalReturn - totalInvested
    }
}
