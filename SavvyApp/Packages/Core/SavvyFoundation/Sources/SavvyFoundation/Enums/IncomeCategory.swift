import Foundation

public enum IncomeCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case salary, sideJob, freelance, transfer, debtCollection
    case refund, rentalIncome, investment, other

    public var id: Self { self }

    public var label: String {
        switch self {
        case .salary: "Maaş"
        case .sideJob: "Ek İş"
        case .freelance: "Freelance"
        case .transfer: "Transfer"
        case .debtCollection: "Borç Tahsilatı"
        case .refund: "İade"
        case .rentalIncome: "Kira Geliri"
        case .investment: "Yatırım"
        case .other: "Diğer"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .salary: "briefcase.fill"
        case .sideJob: "hammer.fill"
        case .freelance: "laptopcomputer"
        case .transfer: "arrow.left.arrow.right"
        case .debtCollection: "banknote.fill"
        case .refund: "arrow.uturn.backward"
        case .rentalIncome: "building.2.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .other: "circle.fill"
        }
    }
}
