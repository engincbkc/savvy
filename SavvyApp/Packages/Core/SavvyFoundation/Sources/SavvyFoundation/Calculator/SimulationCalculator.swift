import Foundation

public enum SimulationCalculator {

    // MARK: - Main Entry Point

    public static func calculateScenario(
        changes: [SimulationChange],
        currentBudget: MonthSummary,
        existingIncomeItems: [MonthLineItem] = [],
        existingExpenseItems: [MonthLineItem] = []
    ) -> SimulationResult {
        if changes.isEmpty {
            return emptyResult(currentBudget, existingIncomeItems, existingExpenseItems)
        }

        var totalIncomeImpact: Decimal = 0
        var totalExpenseImpact: Decimal = 0
        var changeResults: [ChangeResult] = []

        for change in changes {
            let result = calculateChange(change, budget: currentBudget)
            changeResults.append(result)
            if result.monthlyImpact > 0 {
                totalIncomeImpact += result.monthlyImpact
            } else {
                totalExpenseImpact += abs(result.monthlyImpact)
            }
        }

        let newIncome = currentBudget.totalIncome + totalIncomeImpact
        let newExpense = currentBudget.totalExpense + totalExpenseImpact
        let newNet = newIncome - newExpense
        let monthlyNetImpact = totalIncomeImpact - totalExpenseImpact

        let newExpenseRate = newIncome > 0
            ? NSDecimalNumber(decimal: newExpense / newIncome).doubleValue
            : 0.0
        let newSavingsRate = newIncome > 0
            ? min(max(NSDecimalNumber(decimal: (newIncome - newExpense) / newIncome).doubleValue, 0), 1)
            : 0.0

        var affordability: AffordabilityStatus? = nil
        if totalExpenseImpact > 0 {
            affordability = FinancialCalculator.loanAffordability(
                monthlyPayment: totalExpenseImpact,
                monthlyIncome: newIncome
            )
        }

        let projection = buildProjection(
            changes: changes,
            changeResults: changeResults,
            currentBudget: currentBudget,
            existingIncomeItems: existingIncomeItems,
            existingExpenseItems: existingExpenseItems
        )

        return SimulationResult(
            currentIncome: currentBudget.totalIncome,
            currentExpense: currentBudget.totalExpense,
            currentNet: currentBudget.netBalance,
            newIncome: newIncome,
            newExpense: newExpense,
            newNet: newNet,
            monthlyNetImpact: monthlyNetImpact,
            annualNetImpact: calculateAnnualImpact(changes, changeResults),
            newSavingsRate: newSavingsRate,
            newExpenseRate: newExpenseRate,
            affordability: affordability,
            changeResults: changeResults,
            monthlyProjection: projection
        )
    }

    // MARK: - Per-Change Calculators

    private static func calculateChange(_ change: SimulationChange, budget: MonthSummary) -> ChangeResult {
        switch change {
        case .credit(let principal, let annualRate, let termMonths, _):
            return calcLoanBased(
                change: change,
                loanPrincipal: principal,
                annualRate: annualRate,
                termMonths: termMonths,
                downPayment: 0,
                monthlyExtras: 0
            )
        case .housing(let price, let downPayment, let annualRate, let termMonths, let monthlyExtras, _):
            return calcLoanBased(
                change: change,
                loanPrincipal: price - downPayment,
                annualRate: annualRate,
                termMonths: termMonths,
                downPayment: downPayment,
                monthlyExtras: monthlyExtras
            )
        case .car(let price, let downPayment, let annualRate, let termMonths, let monthlyRunningCosts, _):
            return calcLoanBased(
                change: change,
                loanPrincipal: price - downPayment,
                annualRate: annualRate,
                termMonths: termMonths,
                downPayment: downPayment,
                monthlyExtras: monthlyRunningCosts
            )
        case .rentChange(let currentRent, let newRent, _, _):
            let diff = newRent - currentRent
            return ChangeResult(change: change, monthlyImpact: -diff)
        case .salaryChange(let currentGross, let newGross, _):
            return calcSalaryChange(change: change, currentGross: currentGross, newGross: newGross)
        case .income(let amount, _, _, _):
            return ChangeResult(change: change, monthlyImpact: amount)
        case .expense(let amount, _, _, _):
            return ChangeResult(change: change, monthlyImpact: -amount)
        case .investment(let principal, let annualReturnRate, let termMonths, let isCompound, _):
            return calcInvestment(change: change, principal: principal, annualReturnRate: annualReturnRate, termMonths: termMonths, isCompound: isCompound)
        }
    }

    private static func calcLoanBased(
        change: SimulationChange,
        loanPrincipal: Decimal,
        annualRate: Decimal,
        termMonths: Int,
        downPayment: Decimal,
        monthlyExtras: Decimal
    ) -> ChangeResult {
        guard loanPrincipal > 0 else {
            return ChangeResult(change: change, monthlyImpact: -monthlyExtras, totalCost: downPayment)
        }

        let rate = annualRate / 100
        let monthly = FinancialCalculator.monthlyLoanPayment(
            principal: loanPrincipal, annualRate: rate, termMonths: termMonths
        )
        let total = monthly * Decimal(termMonths)
        let interest = total - loanPrincipal
        let totalMonthly = monthly + monthlyExtras

        return ChangeResult(
            change: change,
            monthlyImpact: -totalMonthly,
            totalCost: total + downPayment + (monthlyExtras * Decimal(termMonths)),
            totalInterest: interest,
            amortizationSchedule: amortizationSchedule(
                principal: loanPrincipal, annualRate: rate, termMonths: termMonths
            )
        )
    }

    private static func calcSalaryChange(
        change: SimulationChange,
        currentGross: Decimal,
        newGross: Decimal
    ) -> ChangeResult {
        let currentNets = FinancialCalculator.resolveAllMonths(amount: currentGross, isGross: true)
        let newNets = FinancialCalculator.resolveAllMonths(amount: newGross, isGross: true)

        let currentAvg = currentNets.reduce(Decimal(0), +) / 12
        let newAvg = newNets.reduce(Decimal(0), +) / 12
        let monthlyDelta = newAvg - currentAvg

        return ChangeResult(
            change: change,
            monthlyImpact: monthlyDelta,
            salaryImpact: SalaryImpact(oldNet: currentAvg, newNet: newAvg)
        )
    }

    private static func calcInvestment(
        change: SimulationChange,
        principal: Decimal,
        annualReturnRate: Decimal,
        termMonths: Int,
        isCompound: Bool
    ) -> ChangeResult {
        let totalReturn: Decimal
        let p = NSDecimalNumber(decimal: principal).doubleValue
        let rate = NSDecimalNumber(decimal: annualReturnRate / 100).doubleValue

        if isCompound {
            let monthlyRate = rate / 12
            let result = p * (pow(1 + monthlyRate, Double(termMonths)) - 1)
            totalReturn = Decimal(result)
        } else {
            let result = p * rate * (Double(termMonths) / 12)
            totalReturn = Decimal(result)
        }

        let monthlyReturn = totalReturn / Decimal(termMonths)
        return ChangeResult(
            change: change,
            monthlyImpact: monthlyReturn,
            investmentImpact: InvestmentImpact(
                totalReturn: principal + totalReturn,
                totalInvested: principal
            )
        )
    }

    // MARK: - Annual Impact

    private static func calculateAnnualImpact(
        _ changes: [SimulationChange],
        _ changeResults: [ChangeResult]
    ) -> Decimal {
        var annual: Decimal = 0
        for i in 0..<changes.count {
            let change = changes[i]
            let result = changeResults[i]

            if case .salaryChange = change, let si = result.salaryImpact {
                annual += (si.newNet - si.oldNet) * 12
            } else {
                let effectiveMonths: Int
                switch change {
                case .credit(_, _, let term, _),
                     .housing(_, _, _, let term, _, _),
                     .car(_, _, _, let term, _, _),
                     .investment(_, _, let term, _, _):
                    effectiveMonths = min(term, 12)
                default:
                    effectiveMonths = 12
                }
                annual += result.monthlyImpact * Decimal(effectiveMonths)
            }
        }
        return annual
    }

    // MARK: - 12-Month Projection

    private static func buildProjection(
        changes: [SimulationChange],
        changeResults: [ChangeResult],
        currentBudget: MonthSummary,
        existingIncomeItems: [MonthLineItem],
        existingExpenseItems: [MonthLineItem]
    ) -> [MonthProjection] {
        let now = Date()
        let calendar = Calendar.current
        var projections: [MonthProjection] = []
        var cumulative: Decimal = 0

        for i in 0..<12 {
            guard let projDate = calendar.date(byAdding: .month, value: i, to: now) else { continue }
            let ym = projDate.toYearMonth()
            let monthIdx = (calendar.component(.month, from: projDate) - 1) % 12
            let monthLabel = FinancialCalculator.monthShortNamesTR[monthIdx]

            var monthIncome = currentBudget.totalIncome
            var monthExpense = currentBudget.totalExpense
            var incomeItems = existingIncomeItems
            var expenseItems = existingExpenseItems

            for ci in 0..<changes.count {
                let change = changes[ci]
                let result = changeResults[ci]

                let isWithinTerm: Bool
                switch change {
                case .credit(_, _, let term, _),
                     .housing(_, _, _, let term, _, _),
                     .car(_, _, _, let term, _, _),
                     .investment(_, _, let term, _, _):
                    isWithinTerm = i < term
                default:
                    isWithinTerm = true
                }
                guard isWithinTerm else { continue }

                // Rent with annual increase
                if case .rentChange(let currentRent, let newRent, let annualIncrease, let label) = change,
                   annualIncrease > 0 {
                    let baseDiff = newRent - currentRent
                    let yearsPassed = i / 12
                    let rate = NSDecimalNumber(decimal: annualIncrease / 100).doubleValue
                    let adjustedDiff = NSDecimalNumber(decimal: baseDiff).doubleValue * pow(1 + rate, Double(yearsPassed))
                    let decimalDiff = Decimal(adjustedDiff)
                    monthExpense += decimalDiff
                    expenseItems.append(MonthLineItem(label: label, amount: decimalDiff, isSimulated: true))
                    continue
                }

                // Salary change per-month
                if case .salaryChange(let currentGross, let newGross, let label) = change {
                    let currentNets = FinancialCalculator.resolveAllMonths(amount: currentGross, isGross: true)
                    let newNets = FinancialCalculator.resolveAllMonths(amount: newGross, isGross: true)
                    let delta = newNets[monthIdx] - currentNets[monthIdx]
                    monthIncome += delta
                    incomeItems.append(MonthLineItem(label: label, amount: delta, isSimulated: true))
                    continue
                }

                if result.monthlyImpact > 0 {
                    monthIncome += result.monthlyImpact
                    incomeItems.append(MonthLineItem(label: change.displayLabel, amount: result.monthlyImpact, isSimulated: true))
                } else if result.monthlyImpact < 0 {
                    monthExpense += abs(result.monthlyImpact)
                    expenseItems.append(MonthLineItem(label: change.displayLabel, amount: abs(result.monthlyImpact), isSimulated: true))
                }
            }

            let net = monthIncome - monthExpense
            cumulative += net

            projections.append(MonthProjection(
                yearMonth: ym, monthLabel: monthLabel,
                income: monthIncome, expense: monthExpense,
                net: net, cumulativeNet: cumulative,
                incomeItems: incomeItems, expenseItems: expenseItems
            ))
        }
        return projections
    }

    // MARK: - Amortization Schedule

    private static func amortizationSchedule(
        principal: Decimal, annualRate: Decimal, termMonths: Int
    ) -> [AmortizationRow] {
        let r = NSDecimalNumber(decimal: annualRate / 12).doubleValue
        let monthly = FinancialCalculator.monthlyLoanPayment(
            principal: principal, annualRate: annualRate, termMonths: termMonths
        )
        let monthlyD = NSDecimalNumber(decimal: monthly).doubleValue
        var balance = NSDecimalNumber(decimal: principal).doubleValue

        return (0..<termMonths).map { i in
            let interest = balance * r
            let principalPaid = monthlyD - interest
            balance = max(balance - principalPaid, 0)
            return AmortizationRow(
                month: i + 1,
                payment: monthly,
                principal: Decimal(principalPaid),
                interest: Decimal(interest),
                balance: Decimal(balance)
            )
        }
    }

    // MARK: - Empty Result

    private static func emptyResult(
        _ budget: MonthSummary,
        _ incomeItems: [MonthLineItem],
        _ expenseItems: [MonthLineItem]
    ) -> SimulationResult {
        let now = Date()
        let calendar = Calendar.current
        let projection = (0..<12).map { i -> MonthProjection in
            let projDate = calendar.date(byAdding: .month, value: i, to: now)!
            let ym = projDate.toYearMonth()
            let monthIdx = (calendar.component(.month, from: projDate) - 1) % 12
            let net = budget.totalIncome - budget.totalExpense
            return MonthProjection(
                yearMonth: ym,
                monthLabel: FinancialCalculator.monthShortNamesTR[monthIdx],
                income: budget.totalIncome,
                expense: budget.totalExpense,
                net: net,
                cumulativeNet: net * Decimal(i + 1),
                incomeItems: incomeItems,
                expenseItems: expenseItems
            )
        }

        return SimulationResult(
            currentIncome: budget.totalIncome,
            currentExpense: budget.totalExpense,
            currentNet: budget.netBalance,
            newIncome: budget.totalIncome,
            newExpense: budget.totalExpense,
            newNet: budget.netBalance,
            monthlyNetImpact: 0,
            annualNetImpact: 0,
            newSavingsRate: budget.savingsRate,
            newExpenseRate: budget.expenseRate,
            affordability: nil,
            changeResults: [],
            monthlyProjection: projection
        )
    }
}
