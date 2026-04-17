import Foundation

public enum SavingsCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case emergency, goal, gold, forex, stock, fund, deposit, retirement, other

    public var id: Self { self }

    public var label: String {
        switch self {
        case .emergency: "Acil Durum Fonu"
        case .goal: "Hedef Birikimi"
        case .gold: "Altın"
        case .forex: "Döviz"
        case .stock: "Hisse Senedi"
        case .fund: "Yatırım Fonu"
        case .deposit: "Vadeli Mevduat"
        case .retirement: "Emeklilik"
        case .other: "Diğer"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .emergency: "shield.checkered"
        case .goal: "target"
        case .gold: "bitcoinsign.circle.fill"
        case .forex: "dollarsign.circle.fill"
        case .stock: "chart.bar.fill"
        case .fund: "chart.pie.fill"
        case .deposit: "building.columns.fill"
        case .retirement: "sun.max.fill"
        case .other: "circle.fill"
        }
    }
}
