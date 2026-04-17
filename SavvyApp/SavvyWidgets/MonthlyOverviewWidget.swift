import WidgetKit
import SwiftUI

struct MonthlyEntry: TimelineEntry {
    let date: Date
    let income: Double
    let expense: Double
    let net: Double
    let expenseRatio: Double
    let monthLabel: String
}

struct MonthlyProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthlyEntry {
        MonthlyEntry(date: Date(), income: 52000, expense: 31500, net: 20500, expenseRatio: 0.61, monthLabel: "Nisan 2026")
    }

    func getSnapshot(in context: Context, completion: @escaping (MonthlyEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MonthlyEntry>) -> Void) {
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [currentEntry()], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> MonthlyEntry {
        MonthlyEntry(
            date: Date(),
            income: SharedDataManager.totalIncome,
            expense: SharedDataManager.totalExpense,
            net: SharedDataManager.netBalance,
            expenseRatio: SharedDataManager.expenseRatio,
            monthLabel: SharedDataManager.monthLabel
        )
    }
}

struct MonthlyOverviewView: View {
    let entry: MonthlyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Eco")
                    .font(.caption2.bold())
                Spacer()
                Text(entry.monthLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                statColumn(label: "Gelir", amount: entry.income, color: .green)
                statColumn(label: "Gider", amount: entry.expense, color: .red)
                statColumn(label: "Net", amount: entry.net, color: entry.net >= 0 ? .green : .red)
            }

            ProgressView(value: min(entry.expenseRatio, 1.0))
                .tint(progressColor)

            Text("Harcama oranı: %\(Int(entry.expenseRatio * 100))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func statColumn(label: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(formatCompact(amount))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressColor: Color {
        switch entry.expenseRatio {
        case ..<0.7: return .green
        case ..<0.9: return .orange
        default: return .red
        }
    }

    private func formatCompact(_ value: Double) -> String {
        switch abs(value) {
        case 1_000_000...:
            return String(format: "₺%.1fM", value / 1_000_000).replacingOccurrences(of: ".", with: ",")
        case 10_000...:
            return "₺\(Int(value / 1_000))K"
        default:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "TRY"
            formatter.locale = Locale(identifier: "tr_TR")
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value)) ?? "₺0"
        }
    }
}

struct MonthlyOverviewWidget: Widget {
    let kind = "MonthlyOverview"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonthlyProvider()) { entry in
            MonthlyOverviewView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Aylık Özet")
        .description("Gelir, gider ve net bakiye özeti")
        .supportedFamilies([.systemMedium])
    }
}
