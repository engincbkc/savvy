import Foundation

enum SharedDataManager {
    static let suiteName = "group.com.savvy.shared"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Write (from main app)

    static func updateDashboard(
        netBalance: Double,
        totalIncome: Double,
        totalExpense: Double,
        totalSavings: Double,
        monthLabel: String,
        healthScore: Int,
        expenseRatio: Double
    ) {
        let d = defaults
        d?.set(netBalance, forKey: "netBalance")
        d?.set(totalIncome, forKey: "totalIncome")
        d?.set(totalExpense, forKey: "totalExpense")
        d?.set(totalSavings, forKey: "totalSavings")
        d?.set(monthLabel, forKey: "monthLabel")
        d?.set(healthScore, forKey: "healthScore")
        d?.set(expenseRatio, forKey: "expenseRatio")
        d?.set(Date().timeIntervalSince1970, forKey: "lastUpdated")
    }

    // MARK: - Read (from widgets)

    static var netBalance: Double { defaults?.double(forKey: "netBalance") ?? 0 }
    static var totalIncome: Double { defaults?.double(forKey: "totalIncome") ?? 0 }
    static var totalExpense: Double { defaults?.double(forKey: "totalExpense") ?? 0 }
    static var totalSavings: Double { defaults?.double(forKey: "totalSavings") ?? 0 }
    static var monthLabel: String { defaults?.string(forKey: "monthLabel") ?? "" }
    static var healthScore: Int { defaults?.integer(forKey: "healthScore") ?? 0 }
    static var expenseRatio: Double { defaults?.double(forKey: "expenseRatio") ?? 0 }
}
