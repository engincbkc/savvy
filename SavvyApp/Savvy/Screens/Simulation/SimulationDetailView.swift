import SwiftUI
import Charts
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct SimulationDetailView: View {
    let simulation: SimulationEntry
    let deps: AppDependencies
    @State private var incomes: [Income] = []
    @State private var expenses: [Expense] = []

    private var currentBudget: MonthSummary {
        let ym = Date().toYearMonth()
        let totalIncome = incomes.filter { $0.date.toYearMonth() == ym }.reduce(Decimal(0)) { $0 + $1.amount }
        let totalExpense = expenses.filter { $0.date.toYearMonth() == ym }.reduce(Decimal(0)) { $0 + $1.amount }
        let net = totalIncome - totalExpense
        return MonthSummary(
            yearMonth: ym, totalIncome: totalIncome, totalExpense: totalExpense,
            totalSavings: 0, netBalance: net, carryOver: 0, netWithCarryOver: net,
            savingsRate: totalIncome > 0 ? NSDecimalNumber(decimal: net / totalIncome).doubleValue : 0,
            expenseRate: totalIncome > 0 ? NSDecimalNumber(decimal: totalExpense / totalIncome).doubleValue : 0,
            healthScore: 50
        )
    }

    private var result: SimulationResult {
        SimulationCalculator.calculateScenario(
            changes: simulation.changes,
            currentBudget: currentBudget
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SavvySpacing.lg) {
                // Header
                HStack(spacing: SavvySpacing.md) {
                    Image(systemName: simulation.template?.sfSymbol ?? "sparkles")
                        .font(.title)
                        .foregroundStyle(Color(hex: simulation.colorHex))
                    VStack(alignment: .leading) {
                        Text(simulation.title).font(.savvyHeadlineSmall)
                        if let desc = simulation.description {
                            Text(desc).font(.savvyCaption).foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SavvySpacing.lg)

                // Before / After
                HStack(spacing: SavvySpacing.md) {
                    comparisonCard(title: "Mevcut", income: result.currentIncome, expense: result.currentExpense, net: result.currentNet)
                    comparisonCard(title: "Yeni", income: result.newIncome, expense: result.newExpense, net: result.newNet)
                }
                .padding(.horizontal, SavvySpacing.lg)

                // Net Impact
                VStack(spacing: SavvySpacing.sm) {
                    Text("Aylik Net Etki")
                        .font(.savvyLabelMedium)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.withSign(result.monthlyNetImpact))
                        .font(.savvyNumericLarge)
                        .foregroundStyle(result.monthlyNetImpact >= 0 ? Color.savvyIncome : Color.savvyExpense)
                }
                .padding(SavvySpacing.base)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.md))
                .padding(.horizontal, SavvySpacing.lg)

                // Affordability
                if let affordability = result.affordability {
                    HStack {
                        Image(systemName: affordability.sfSymbol)
                        Text(affordability.label)
                            .font(.savvyTitleMedium)
                    }
                    .padding(SavvySpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(affordabilityColor(affordability).opacity(0.12))
                    .foregroundStyle(affordabilityColor(affordability))
                    .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.md))
                    .padding(.horizontal, SavvySpacing.lg)
                }

                // 12-Month Projection Chart
                if !result.monthlyProjection.isEmpty {
                    VStack(alignment: .leading, spacing: SavvySpacing.sm) {
                        Text("12 Ay Projeksiyon")
                            .font(.savvyTitleLarge)
                            .padding(.horizontal, SavvySpacing.lg)

                        Chart(result.monthlyProjection) { month in
                            BarMark(
                                x: .value("Ay", month.monthLabel),
                                y: .value("Net", NSDecimalNumber(decimal: month.net).doubleValue)
                            )
                            .foregroundStyle(month.net >= 0 ? Color.savvyIncome : Color.savvyExpense)

                            LineMark(
                                x: .value("Ay", month.monthLabel),
                                y: .value("Kumulatif", NSDecimalNumber(decimal: month.cumulativeNet).doubleValue)
                            )
                            .foregroundStyle(Color(hex: "1A56DB"))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        .frame(height: 220)
                        .padding(.horizontal, SavvySpacing.lg)
                    }
                }

                // Change Details
                if !result.changeResults.isEmpty {
                    VStack(alignment: .leading, spacing: SavvySpacing.sm) {
                        Text("Degisiklikler")
                            .font(.savvyTitleLarge)
                            .padding(.horizontal, SavvySpacing.lg)

                        ForEach(Array(result.changeResults.enumerated()), id: \.offset) { _, cr in
                            HStack {
                                Text(cr.change.displayLabel)
                                    .font(.savvyTitleMedium)
                                Spacer()
                                Text(CurrencyFormatter.withSign(cr.monthlyImpact))
                                    .font(.savvyNumericSmall)
                                    .foregroundStyle(cr.monthlyImpact >= 0 ? Color.savvyIncome : Color.savvyExpense)
                                Text("/ay")
                                    .font(.savvyCaption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(SavvySpacing.md)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))
                            .padding(.horizontal, SavvySpacing.lg)
                        }
                    }
                }
            }
            .padding(.vertical, SavvySpacing.base)
        }
        .navigationTitle("Simulasyon")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await items in deps.incomeRepo.watch() {
                        await MainActor.run { incomes = items }
                    }
                }
                group.addTask {
                    for await items in deps.expenseRepo.watch() {
                        await MainActor.run { expenses = items }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func comparisonCard(title: String, income: Decimal, expense: Decimal, net: Decimal) -> some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            Text(title)
                .font(.savvyLabelMedium)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.formatNoDecimal(net))
                .font(.savvyNumericMedium)
                .foregroundStyle(net >= 0 ? Color.savvyIncome : Color.savvyExpense)
            VStack(alignment: .leading, spacing: 2) {
                Text("Gelir: \(CurrencyFormatter.compact(income))")
                Text("Gider: \(CurrencyFormatter.compact(expense))")
            }
            .font(.savvyCaption)
            .foregroundStyle(.secondary)
        }
        .padding(SavvySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.md))
    }

    private func affordabilityColor(_ status: AffordabilityStatus) -> Color {
        switch status {
        case .comfortable: return .savvyIncome
        case .manageable: return .savvySavings
        case .tight: return .savvyWarning
        case .risky: return .savvyExpense
        }
    }
}
