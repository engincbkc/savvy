import Foundation

enum SharedDataManager {
    static let suiteName = "group.com.savvy.shared"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static var netBalance: Double { defaults?.double(forKey: "netBalance") ?? 0 }
    static var totalIncome: Double { defaults?.double(forKey: "totalIncome") ?? 0 }
    static var totalExpense: Double { defaults?.double(forKey: "totalExpense") ?? 0 }
    static var totalSavings: Double { defaults?.double(forKey: "totalSavings") ?? 0 }
    static var monthLabel: String { defaults?.string(forKey: "monthLabel") ?? "" }
    static var healthScore: Int { defaults?.integer(forKey: "healthScore") ?? 0 }
    static var expenseRatio: Double { defaults?.double(forKey: "expenseRatio") ?? 0 }
}
