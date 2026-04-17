import Foundation

public enum FinancialCalculator {

    // MARK: - Core Summary

    /// Net balance without carry-over. Birikim düşülmez.
    public static func netBalance(
        totalIncome: Decimal, totalExpense: Decimal, totalSavings: Decimal
    ) -> Decimal {
        precondition(totalIncome >= 0, "Income cannot be negative")
        precondition(totalExpense >= 0, "Expense cannot be negative")
        precondition(totalSavings >= 0, "Savings cannot be negative")
        return totalIncome - totalExpense
    }

    public static func netWithCarryOver(netBalance: Decimal, carryOver: Decimal) -> Decimal {
        netBalance + carryOver
    }

    public static func expenseRatio(totalExpense: Decimal, totalIncome: Decimal) -> Double {
        guard totalIncome > 0 else { return 0.0 }
        return NSDecimalNumber(decimal: totalExpense / totalIncome).doubleValue
    }

    public static func savingsRate(totalSavings: Decimal, totalIncome: Decimal) -> Double {
        guard totalIncome > 0 else { return 0.0 }
        return NSDecimalNumber(decimal: totalSavings / totalIncome).doubleValue
    }

    public static func targetSavings(totalIncome: Decimal, targetRate: Decimal = Decimal(string: "0.20")!) -> Decimal {
        totalIncome * targetRate
    }

    // MARK: - Financial Health Score (0–100)

    public static func financialHealthScore(
        savingsRate: Double, expenseRatio: Double,
        netBalance: Decimal, emergencyFundMonths: Double
    ) -> Int {
        var score = 0

        // Savings rate (max 35 pts)
        switch savingsRate {
        case 0.25...: score += 35
        case 0.20...: score += 28
        case 0.15...: score += 20
        case 0.10...: score += 12
        case 0.05...: score += 5
        default: break
        }

        // Expense ratio (max 30 pts)
        switch expenseRatio {
        case ...0.50: score += 30
        case ...0.60: score += 25
        case ...0.70: score += 18
        case ...0.80: score += 10
        case ...0.90: score += 4
        default: break
        }

        // Net balance (max 20 pts)
        if netBalance > 0 { score += 20 }
        else if netBalance == 0 { score += 8 }

        // Emergency fund (max 15 pts)
        switch emergencyFundMonths {
        case 6...: score += 15
        case 3...: score += 10
        case 1...: score += 5
        default: break
        }

        return min(max(score, 0), 100)
    }

    public static func healthScoreLabel(_ score: Int) -> String {
        switch score {
        case 80...: "Mükemmel"
        case 65...: "İyi"
        case 50...: "Orta"
        case 35...: "Dikkat"
        default: "Kritik"
        }
    }

    // MARK: - Savings Goal

    public static func monthsToGoal(
        targetAmount: Decimal, currentAmount: Decimal, monthlySavings: Decimal
    ) -> Int {
        guard monthlySavings > 0 else { return -1 }
        let remaining = targetAmount - currentAmount
        guard remaining > 0 else { return 0 }
        let months = NSDecimalNumber(decimal: remaining / monthlySavings).doubleValue
        return Int(months.rounded(.up))
    }

    public static func requiredMonthlySavings(
        targetAmount: Decimal, currentAmount: Decimal, monthsLeft: Int
    ) -> Decimal {
        guard monthsLeft > 0 else { return Decimal.greatestFiniteMagnitude }
        let remaining = targetAmount - currentAmount
        guard remaining > 0 else { return 0 }
        return remaining / Decimal(monthsLeft)
    }

    public static func goalProgress(targetAmount: Decimal, currentAmount: Decimal) -> Double {
        guard targetAmount > 0 else { return 0 }
        let ratio = NSDecimalNumber(decimal: currentAmount / targetAmount).doubleValue
        return min(max(ratio, 0), 1)
    }

    public static func suggestedMonthlySaving(_ monthlyNet: Decimal, rate: Decimal = Decimal(string: "0.20")!) -> Decimal {
        max(monthlyNet * rate, 0)
    }

    public static func isOnTrackForGoal(monthlyNet: Decimal, requiredMonthly: Decimal) -> Bool {
        requiredMonthly > 0 && monthlyNet >= requiredMonthly
    }

    // MARK: - Loan / Installment

    /// EMI (Equal Monthly Installment)
    public static func monthlyLoanPayment(
        principal: Decimal, annualRate: Decimal, termMonths: Int
    ) -> Decimal {
        guard annualRate != 0 else { return principal / Decimal(termMonths) }
        let r = NSDecimalNumber(decimal: annualRate / 12).doubleValue
        let n = Double(termMonths)
        let emi = NSDecimalNumber(decimal: principal).doubleValue *
            (r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
        return Decimal(emi)
    }

    public static func totalLoanPayment(monthlyPayment: Decimal, termMonths: Int) -> Decimal {
        monthlyPayment * Decimal(termMonths)
    }

    public static func totalInterest(totalPayment: Decimal, principal: Decimal) -> Decimal {
        totalPayment - principal
    }

    // MARK: - Kredi Vergi (KKDF + BSMV)

    /// KKDF: %15, BSMV: %10 → toplam %25
    public static func realAnnualRateWithTaxes(_ nominalRate: Decimal) -> Decimal {
        let kkdf: Decimal = Decimal(string: "0.15")!
        let bsmv: Decimal = Decimal(string: "0.10")!
        return nominalRate * (1 + kkdf + bsmv)
    }

    public static func creditTaxAmount(_ totalInterest: Decimal) -> Decimal {
        totalInterest * Decimal(string: "0.25")!
    }

    public static func loanAffordability(
        monthlyPayment: Decimal, monthlyIncome: Decimal
    ) -> AffordabilityStatus {
        guard monthlyIncome > 0 else { return .risky }
        let ratio = NSDecimalNumber(decimal: monthlyPayment / monthlyIncome).doubleValue
        return switch ratio {
        case ..<0.25: .comfortable
        case ..<0.35: .manageable
        case ..<0.45: .tight
        default: .risky
        }
    }

    // MARK: - Brüt → Net Maaş (2026 Türkiye)

    public static let sgkWorkerRate: Decimal = Decimal(string: "0.14")!
    public static let unemploymentRate: Decimal = Decimal(string: "0.01")!
    public static let brutAsgariUcret: Decimal = 33030
    public static let sgkTavan: Decimal = 297270
    public static let damgaVergisiOrani: Decimal = Decimal(string: "0.00759")!
    public static let asgariUcretGvMatrahi: Decimal = Decimal(string: "28075.50")!

    public static let taxBrackets2026: [(limit: Decimal, rate: Decimal)] = [
        (190_000, Decimal(string: "0.15")!),
        (400_000, Decimal(string: "0.20")!),
        (1_500_000, Decimal(string: "0.27")!),
        (5_300_000, Decimal(string: "0.35")!),
        (Decimal.greatestFiniteMagnitude, Decimal(string: "0.40")!),
    ]

    public static let monthNamesTR = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
    ]

    public static let monthShortNamesTR = [
        "Oca", "Şub", "Mar", "Nis", "May", "Haz",
        "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara",
    ]

    /// Full 12-month gross-to-net
    public static func calculateAnnualNetSalary(grossMonthly: Decimal) -> AnnualSalaryBreakdown {
        var months: [MonthlySalaryDetail] = []
        var cumBase: Decimal = 0
        var cumTax: Decimal = 0
        var cumAsgariBase: Decimal = 0
        var cumAsgariTax: Decimal = 0

        for i in 0..<12 {
            let sgkMatrahi = min(grossMonthly, sgkTavan)
            let sgkIsci = sgkMatrahi * sgkWorkerRate
            let issizlikIsci = sgkMatrahi * unemploymentRate

            let aylikGvMatrahi = grossMonthly - sgkIsci - issizlikIsci

            let yeniCumBase = cumBase + aylikGvMatrahi
            let yeniCumTax = cumulativeTax(yeniCumBase)
            let aylikGelirVergisi = max(yeniCumTax - cumTax, 0)

            let damgaMatrahi = max(grossMonthly - brutAsgariUcret, 0)
            let damgaVergisi = damgaMatrahi * damgaVergisiOrani

            let netMaas = grossMonthly - sgkIsci - issizlikIsci - aylikGelirVergisi - damgaVergisi

            let yeniCumAsgariBase = cumAsgariBase + asgariUcretGvMatrahi
            let yeniCumAsgariTax = cumulativeTax(yeniCumAsgariBase)
            var aylikGvIstisnasi = yeniCumAsgariTax - cumAsgariTax
            aylikGvIstisnasi = min(aylikGvIstisnasi, aylikGelirVergisi)

            let damgaIstisnasi = min(
                brutAsgariUcret * damgaVergisiOrani,
                damgaVergisi + (brutAsgariUcret * damgaVergisiOrani)
            )

            let netEleGecen = netMaas + aylikGvIstisnasi + damgaIstisnasi

            months.append(MonthlySalaryDetail(
                monthIndex: i,
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
                taxBracketRate: getCurrentBracketRate(yeniCumBase)
            ))

            cumBase = yeniCumBase
            cumTax = yeniCumTax
            cumAsgariBase = yeniCumAsgariBase
            cumAsgariTax = yeniCumAsgariTax
        }

        let totalNet = months.reduce(Decimal(0)) { $0 + $1.netTakeHome }
        let totalGross = grossMonthly * 12

        return AnnualSalaryBreakdown(
            grossMonthly: grossMonthly,
            months: months,
            totalNet: totalNet,
            totalGross: totalGross,
            totalTax: months.reduce(Decimal(0)) { $0 + $1.monthlyIncomeTax - $1.gvExemption },
            totalSgk: months.reduce(Decimal(0)) { $0 + $1.sgk + $1.unemploymentInsurance },
            totalStampTax: months.reduce(Decimal(0)) { $0 + $1.stampTax - $1.stampExemption },
            effectiveTaxRate: totalGross > 0 ?
                NSDecimalNumber(decimal: (totalGross - totalNet) / totalGross).doubleValue : 0
        )
    }

    /// Simple single-month gross-to-net (January values)
    public static func grossToNet(grossMonthly: Decimal) -> SalaryBreakdown {
        let annual = calculateAnnualNetSalary(grossMonthly: grossMonthly)
        let jan = annual.months[0]
        return SalaryBreakdown(
            grossMonthly: grossMonthly,
            sgk: jan.sgk,
            unemploymentInsurance: jan.unemploymentInsurance,
            incomeTax: jan.monthlyIncomeTax - jan.gvExemption,
            stampTax: jan.stampTax - jan.stampExemption,
            totalDeductions: grossMonthly - jan.netTakeHome,
            netMonthly: jan.netTakeHome
        )
    }

    // MARK: - Gross → Net Resolution

    public static func resolveNetForMonth(amount: Decimal, isGross: Bool, month: Int) -> Decimal {
        guard isGross else { return amount }
        let breakdown = calculateAnnualNetSalary(grossMonthly: amount)
        let index = min(max(month - 1, 0), 11)
        return breakdown.months[index].netTakeHome
    }

    public static func resolveAllMonths(amount: Decimal, isGross: Bool) -> [Decimal] {
        guard isGross else { return Array(repeating: amount, count: 12) }
        let breakdown = calculateAnnualNetSalary(grossMonthly: amount)
        return breakdown.months.map(\.netTakeHome)
    }

    // MARK: - Projections

    public static func projectedSavings(
        currentSavings: Decimal, monthlySavings: Decimal, months: Int
    ) -> Decimal {
        currentSavings + (monthlySavings * Decimal(months))
    }

    // MARK: - Debt Tracking

    public static func totalRemainingDebt(_ expenses: [Expense]) -> Decimal {
        let now = Date()
        return expenses
            .filter { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now }
            .reduce(Decimal(0)) { sum, e in
                let remaining = monthsRemaining(from: now, to: e.recurringEndDate!)
                return sum + e.amount * Decimal(remaining)
            }
    }

    public static func monthlyDebtPayment(_ expenses: [Expense]) -> Decimal {
        let now = Date()
        return expenses
            .filter { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    public static func debtFreeDate(_ expenses: [Expense]) -> Date? {
        let now = Date()
        return expenses
            .compactMap { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now ? $0.recurringEndDate : nil }
            .max()
    }

    // MARK: - PlannedChange Resolution

    public static func resolveAmountForDate(
        baseAmount: Decimal, plannedChanges: [PlannedChange], targetDate: Date
    ) -> Decimal {
        let applicable = plannedChanges
            .filter { $0.effectiveDate <= targetDate }
            .sorted { $0.effectiveDate < $1.effectiveDate }
        guard let last = applicable.last else { return baseAmount }
        return last.newAmount
    }

    // MARK: - Private Helpers

    private static func cumulativeTax(_ cumulativeBase: Decimal) -> Decimal {
        var tax: Decimal = 0
        var prevLimit: Decimal = 0
        for bracket in taxBrackets2026 {
            guard cumulativeBase > prevLimit else { break }
            let taxableInBracket = min(cumulativeBase, bracket.limit) - prevLimit
            tax += taxableInBracket * bracket.rate
            prevLimit = bracket.limit
        }
        return tax
    }

    private static func getCurrentBracketRate(_ cumulativeBase: Decimal) -> Decimal {
        for bracket in taxBrackets2026 {
            if cumulativeBase <= bracket.limit { return bracket.rate }
        }
        return Decimal(string: "0.40")!
    }

    private static func monthsRemaining(from: Date, to: Date) -> Int {
        let components = Calendar.current.dateComponents([.month], from: from, to: to)
        return max(components.month ?? 0, 0)
    }
}
