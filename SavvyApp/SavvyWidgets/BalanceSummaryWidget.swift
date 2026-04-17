import WidgetKit
import SwiftUI

struct BalanceEntry: TimelineEntry {
    let date: Date
    let netBalance: Double
    let delta: Double
    let monthLabel: String
}

struct BalanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(date: Date(), netBalance: 20500, delta: 3200, monthLabel: "Nisan 2026")
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> Void) {
        let entry = BalanceEntry(
            date: Date(),
            netBalance: SharedDataManager.netBalance,
            delta: SharedDataManager.totalIncome - SharedDataManager.totalExpense,
            monthLabel: SharedDataManager.monthLabel
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> Void) {
        let entry = BalanceEntry(
            date: Date(),
            netBalance: SharedDataManager.netBalance,
            delta: SharedDataManager.totalIncome - SharedDataManager.totalExpense,
            monthLabel: SharedDataManager.monthLabel
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct BalanceSummaryView: View {
    let entry: BalanceEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Eco")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)

            Text("Net Bakiye")
                .font(.caption)

            Text(formatCurrency(entry.netBalance))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(entry.netBalance >= 0 ? .green : .red)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: entry.delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(formatCurrency(abs(entry.delta)))
            }
            .font(.caption2)
            .foregroundStyle(entry.delta >= 0 ? .green : .red)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "₺0"
    }
}

struct BalanceSummaryWidget: Widget {
    let kind = "BalanceSummary"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BalanceProvider()) { entry in
            BalanceSummaryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Bakiye")
        .description("Aylık net bakiye özeti")
        .supportedFamilies([.systemSmall])
    }
}
