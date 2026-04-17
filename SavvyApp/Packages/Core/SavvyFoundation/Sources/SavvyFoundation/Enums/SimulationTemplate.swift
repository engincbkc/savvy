import Foundation

public enum SimulationTemplate: String, Codable, CaseIterable, Identifiable, Sendable {
    case credit, housing, car, rentChange, salaryChange, investment, custom

    public var id: Self { self }

    public var label: String {
        switch self {
        case .credit: "Kredi Çekimi"
        case .housing: "Ev Alımı"
        case .car: "Araç Alımı"
        case .rentChange: "Kira Değişimi"
        case .salaryChange: "İş Değişikliği / Zam"
        case .investment: "Yatırım"
        case .custom: "Özel Senaryo"
        }
    }

    public var subtitle: String {
        switch self {
        case .credit: "İhtiyaç, konut veya ticari kredi"
        case .housing: "Konut kredisi, peşinat, FuzulEv"
        case .car: "Taşıt kredisi + aylık giderler"
        case .rentChange: "Kira artışı veya yeni eve taşınma"
        case .salaryChange: "Zam, terfi veya iş değişikliği"
        case .investment: "Vadeli mevduat, fon, hisse..."
        case .custom: "Gelir/gider ekleyerek kendi senaryonu oluştur"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .credit: "creditcard.fill"
        case .housing: "house.fill"
        case .car: "car.fill"
        case .rentChange: "building.2.fill"
        case .salaryChange: "briefcase.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .custom: "sparkles"
        }
    }

    public var colorHex: String {
        switch self {
        case .credit: "#3F83F8"
        case .housing: "#1A56DB"
        case .car: "#0E9F6E"
        case .rentChange: "#E8590C"
        case .salaryChange: "#8B5CF6"
        case .investment: "#0891B2"
        case .custom: "#6B7280"
        }
    }
}
