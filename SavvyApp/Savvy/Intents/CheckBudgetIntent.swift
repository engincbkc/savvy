import AppIntents

struct CheckBudgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Bütçe Durumu"
    static var description = IntentDescription("Aylık bütçe özetini gör")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let net = SharedDataManager.netBalance
        let ratio = SharedDataManager.expenseRatio

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        let netStr = formatter.string(from: NSNumber(value: net)) ?? "₺0"

        return .result(dialog: "Bu ay net \(netStr). Harcama oranı: %\(Int(ratio * 100)).")
    }
}
