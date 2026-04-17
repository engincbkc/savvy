import Foundation

public struct MonthlySalaryDetail: Sendable {
    public let monthIndex: Int
    public let grossMonthly: Decimal
    public let sgk: Decimal
    public let unemploymentInsurance: Decimal
    public let gvMatrah: Decimal
    public let cumulativeBase: Decimal
    public let monthlyIncomeTax: Decimal
    public let stampTax: Decimal
    public let netBeforeExemption: Decimal
    public let gvExemption: Decimal
    public let stampExemption: Decimal
    public let netTakeHome: Decimal
    public let taxBracketRate: Decimal

    public var monthName: String { FinancialCalculator.monthNamesTR[monthIndex] }
    public var monthShortName: String { FinancialCalculator.monthShortNamesTR[monthIndex] }
    public var netIncomeTax: Decimal { monthlyIncomeTax - gvExemption }
    public var netStampTax: Decimal { stampTax - stampExemption }
    public var totalDeductions: Decimal { grossMonthly - netTakeHome }

    public init(
        monthIndex: Int, grossMonthly: Decimal, sgk: Decimal,
        unemploymentInsurance: Decimal, gvMatrah: Decimal, cumulativeBase: Decimal,
        monthlyIncomeTax: Decimal, stampTax: Decimal, netBeforeExemption: Decimal,
        gvExemption: Decimal, stampExemption: Decimal, netTakeHome: Decimal,
        taxBracketRate: Decimal
    ) {
        self.monthIndex = monthIndex
        self.grossMonthly = grossMonthly
        self.sgk = sgk
        self.unemploymentInsurance = unemploymentInsurance
        self.gvMatrah = gvMatrah
        self.cumulativeBase = cumulativeBase
        self.monthlyIncomeTax = monthlyIncomeTax
        self.stampTax = stampTax
        self.netBeforeExemption = netBeforeExemption
        self.gvExemption = gvExemption
        self.stampExemption = stampExemption
        self.netTakeHome = netTakeHome
        self.taxBracketRate = taxBracketRate
    }
}

public struct AnnualSalaryBreakdown: Sendable {
    public let grossMonthly: Decimal
    public let months: [MonthlySalaryDetail]
    public let totalNet: Decimal
    public let totalGross: Decimal
    public let totalTax: Decimal
    public let totalSgk: Decimal
    public let totalStampTax: Decimal
    public let effectiveTaxRate: Double

    public var maxNet: Decimal { months.map(\.netTakeHome).max() ?? 0 }
    public var minNet: Decimal { months.map(\.netTakeHome).min() ?? 0 }

    public init(
        grossMonthly: Decimal, months: [MonthlySalaryDetail],
        totalNet: Decimal, totalGross: Decimal, totalTax: Decimal,
        totalSgk: Decimal, totalStampTax: Decimal, effectiveTaxRate: Double
    ) {
        self.grossMonthly = grossMonthly
        self.months = months
        self.totalNet = totalNet
        self.totalGross = totalGross
        self.totalTax = totalTax
        self.totalSgk = totalSgk
        self.totalStampTax = totalStampTax
        self.effectiveTaxRate = effectiveTaxRate
    }
}

public struct SalaryBreakdown: Sendable {
    public let grossMonthly: Decimal
    public let sgk: Decimal
    public let unemploymentInsurance: Decimal
    public let incomeTax: Decimal
    public let stampTax: Decimal
    public let totalDeductions: Decimal
    public let netMonthly: Decimal

    public init(
        grossMonthly: Decimal, sgk: Decimal, unemploymentInsurance: Decimal,
        incomeTax: Decimal, stampTax: Decimal, totalDeductions: Decimal, netMonthly: Decimal
    ) {
        self.grossMonthly = grossMonthly
        self.sgk = sgk
        self.unemploymentInsurance = unemploymentInsurance
        self.incomeTax = incomeTax
        self.stampTax = stampTax
        self.totalDeductions = totalDeductions
        self.netMonthly = netMonthly
    }
}
