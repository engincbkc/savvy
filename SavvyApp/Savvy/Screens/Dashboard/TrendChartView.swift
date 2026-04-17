import SwiftUI
import Charts
import SavvyFoundation
import SavvyDesignSystem

struct TrendChartView: View {
    let incomes: [Income]
    let expenses: [Expense]

    private struct MonthData: Identifiable {
        let id: String
        let label: String
        let income: Double
        let expense: Double
        var net: Double { income - expense }
    }

    private var monthlyData: [MonthData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<6).reversed().compactMap { offset -> MonthData? in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: now) else { return nil }
            let ym = date.toYearMonth()
            let inc = incomes.filter { $0.date.toYearMonth() == ym }.reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
            let exp = expenses.filter { $0.date.toYearMonth() == ym }.reduce(0.0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
            return MonthData(id: ym, label: MonthLabels.shortName(ym), income: inc, expense: exp)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            Text("6 Aylık Trend")
                .font(.savvyTitleLarge)

            if monthlyData.allSatisfy({ $0.income == 0 && $0.expense == 0 }) {
                Text("Henüz yeterli veri yok")
                    .font(.savvyCaption)
                    .foregroundStyle(.secondary)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(monthlyData) { data in
                    BarMark(
                        x: .value("Ay", data.label),
                        y: .value("Tutar", data.income)
                    )
                    .foregroundStyle(Color.savvyIncome)
                    .position(by: .value("Tür", "Gelir"))

                    BarMark(
                        x: .value("Ay", data.label),
                        y: .value("Tutar", data.expense)
                    )
                    .foregroundStyle(Color.savvyExpense)
                    .position(by: .value("Tür", "Gider"))
                }
                .chartForegroundStyleScale([
                    "Gelir": Color.savvyIncome,
                    "Gider": Color.savvyExpense,
                ])
                .frame(height: 180)
            }
        }
    }
}
