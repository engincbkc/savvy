import Foundation

public enum SavingsStatus: String, Codable, CaseIterable, Sendable {
    case active, withdrawn, completed

    public var label: String {
        switch self {
        case .active: "Aktif"
        case .withdrawn: "Çekildi"
        case .completed: "Tamamlandı"
        }
    }
}

public enum GoalStatus: String, Codable, CaseIterable, Sendable {
    case active, completed, cancelled

    public var label: String {
        switch self {
        case .active: "Aktif"
        case .completed: "Tamamlandı"
        case .cancelled: "İptal Edildi"
        }
    }
}

public enum AffordabilityStatus: String, Codable, CaseIterable, Sendable {
    case comfortable, manageable, tight, risky

    public var label: String {
        switch self {
        case .comfortable: "Rahat"
        case .manageable: "İdare Edilebilir"
        case .tight: "Sıkışık"
        case .risky: "Riskli"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .comfortable: "checkmark.circle.fill"
        case .manageable: "exclamationmark.circle.fill"
        case .tight: "exclamationmark.triangle.fill"
        case .risky: "xmark.octagon.fill"
        }
    }
}
