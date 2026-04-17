import Foundation

public enum ExpenseCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case rent, market, transport, bills, creditCard, loanInstallment
    case health, education, food, entertainment, clothing, subscription
    case advertising, businessTool, tax, other

    public var id: Self { self }

    public var label: String {
        switch self {
        case .rent: "Kira"
        case .market: "Market"
        case .transport: "Ulaşım"
        case .bills: "Faturalar"
        case .creditCard: "Kredi Kartı"
        case .loanInstallment: "Kredi Taksiti"
        case .health: "Sağlık"
        case .education: "Eğitim"
        case .food: "Yeme-İçme"
        case .entertainment: "Eğlence"
        case .clothing: "Giyim"
        case .subscription: "Abonelik"
        case .advertising: "Reklam"
        case .businessTool: "İş Aracı"
        case .tax: "Vergi"
        case .other: "Diğer"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .rent: "house.fill"
        case .market: "cart.fill"
        case .transport: "car.fill"
        case .bills: "bolt.fill"
        case .creditCard: "creditcard.fill"
        case .loanInstallment: "banknote.fill"
        case .health: "heart.fill"
        case .education: "graduationcap.fill"
        case .food: "fork.knife"
        case .entertainment: "gamecontroller.fill"
        case .clothing: "tshirt.fill"
        case .subscription: "repeat"
        case .advertising: "megaphone.fill"
        case .businessTool: "wrench.fill"
        case .tax: "doc.text.fill"
        case .other: "circle.fill"
        }
    }

    public static var quickCategories: [ExpenseCategory] {
        [.market, .transport, .food, .bills, .entertainment, .health, .other]
    }
}
