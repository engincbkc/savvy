import Foundation

public enum ExpenseType: String, Codable, CaseIterable, Identifiable, Sendable {
    case fixed, variable, discretionary, business

    public var id: Self { self }

    public var label: String {
        switch self {
        case .fixed: "Sabit"
        case .variable: "Değişken"
        case .discretionary: "İsteğe Bağlı"
        case .business: "İş/Yatırım"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .fixed: "pin.fill"
        case .variable: "arrow.up.arrow.down"
        case .discretionary: "sparkles"
        case .business: "building.2.crop.circle"
        }
    }
}
