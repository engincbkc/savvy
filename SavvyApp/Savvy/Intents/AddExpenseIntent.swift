import AppIntents

enum ExpenseCategoryEntity: String, AppEnum {
    case market, transport, food, bills, health, entertainment, rent, other

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Gider Kategorisi")

    static var caseDisplayRepresentations: [ExpenseCategoryEntity: DisplayRepresentation] = [
        .market: "Market",
        .transport: "Ulaşım",
        .food: "Yeme-İçme",
        .bills: "Faturalar",
        .health: "Sağlık",
        .entertainment: "Eğlence",
        .rent: "Kira",
        .other: "Diğer",
    ]

    var label: String {
        switch self {
        case .market: "Market"
        case .transport: "Ulaşım"
        case .food: "Yeme-İçme"
        case .bills: "Faturalar"
        case .health: "Sağlık"
        case .entertainment: "Eğlence"
        case .rent: "Kira"
        case .other: "Diğer"
        }
    }
}

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Harcama Ekle"
    static var description = IntentDescription("Hızlı gider girişi")
    static var openAppWhenRun = false

    @Parameter(title: "Tutar")
    var amount: Double

    @Parameter(title: "Kategori")
    var category: ExpenseCategoryEntity

    @Parameter(title: "Not", default: "")
    var note: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let formatted = String(format: "%.0f", amount)
        return .result(dialog: "₺\(formatted) \(category.label) eklendi")
    }
}
