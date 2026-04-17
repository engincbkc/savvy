import Foundation

public enum SimulationChange: Codable, Hashable, Sendable {
    case credit(
        principal: Decimal,
        annualRate: Decimal,
        termMonths: Int,
        label: String = "Kredi"
    )
    case housing(
        price: Decimal,
        downPayment: Decimal = 0,
        annualRate: Decimal,
        termMonths: Int,
        monthlyExtras: Decimal = 0,
        label: String = "Ev Alımı"
    )
    case car(
        price: Decimal,
        downPayment: Decimal = 0,
        annualRate: Decimal,
        termMonths: Int,
        monthlyRunningCosts: Decimal = 0,
        label: String = "Araç Alımı"
    )
    case rentChange(
        currentRent: Decimal,
        newRent: Decimal,
        annualIncreaseRate: Decimal = 0,
        label: String = "Kira Değişimi"
    )
    case salaryChange(
        currentGross: Decimal,
        newGross: Decimal,
        label: String = "Maaş Değişikliği"
    )
    case income(
        amount: Decimal,
        description: String = "",
        isRecurring: Bool = true,
        label: String = "Gelir"
    )
    case expense(
        amount: Decimal,
        description: String = "",
        isRecurring: Bool = true,
        label: String = "Gider"
    )
    case investment(
        principal: Decimal,
        annualReturnRate: Decimal,
        termMonths: Int,
        isCompound: Bool = true,
        label: String = "Yatırım"
    )
}

extension SimulationChange {
    public var displayLabel: String {
        switch self {
        case .credit(_, _, _, let label): label
        case .housing(_, _, _, _, _, let label): label
        case .car(_, _, _, _, _, let label): label
        case .rentChange(_, _, _, let label): label
        case .salaryChange(_, _, let label): label
        case .income(_, _, _, let label): label
        case .expense(_, _, _, let label): label
        case .investment(_, _, _, _, let label): label
        }
    }

    public var isLoanBased: Bool {
        switch self {
        case .credit, .housing, .car: true
        default: false
        }
    }
}

// MARK: - Custom Codable (matches Flutter JSON structure)

extension SimulationChange {
    private enum CodingKeys: String, CodingKey {
        case type, principal, annualRate, termMonths, label
        case price, downPayment, monthlyExtras, monthlyRunningCosts
        case currentRent, newRent, annualIncreaseRate
        case currentGross, newGross
        case amount, description, isRecurring
        case annualReturnRate, isCompound
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "credit":
            self = .credit(
                principal: try container.decode(Decimal.self, forKey: .principal),
                annualRate: try container.decode(Decimal.self, forKey: .annualRate),
                termMonths: try container.decode(Int.self, forKey: .termMonths),
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Kredi"
            )
        case "housing":
            self = .housing(
                price: try container.decode(Decimal.self, forKey: .price),
                downPayment: try container.decodeIfPresent(Decimal.self, forKey: .downPayment) ?? 0,
                annualRate: try container.decode(Decimal.self, forKey: .annualRate),
                termMonths: try container.decode(Int.self, forKey: .termMonths),
                monthlyExtras: try container.decodeIfPresent(Decimal.self, forKey: .monthlyExtras) ?? 0,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Ev Alımı"
            )
        case "car":
            self = .car(
                price: try container.decode(Decimal.self, forKey: .price),
                downPayment: try container.decodeIfPresent(Decimal.self, forKey: .downPayment) ?? 0,
                annualRate: try container.decode(Decimal.self, forKey: .annualRate),
                termMonths: try container.decode(Int.self, forKey: .termMonths),
                monthlyRunningCosts: try container.decodeIfPresent(Decimal.self, forKey: .monthlyRunningCosts) ?? 0,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Araç Alımı"
            )
        case "rentChange":
            self = .rentChange(
                currentRent: try container.decode(Decimal.self, forKey: .currentRent),
                newRent: try container.decode(Decimal.self, forKey: .newRent),
                annualIncreaseRate: try container.decodeIfPresent(Decimal.self, forKey: .annualIncreaseRate) ?? 0,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Kira Değişimi"
            )
        case "salaryChange":
            self = .salaryChange(
                currentGross: try container.decode(Decimal.self, forKey: .currentGross),
                newGross: try container.decode(Decimal.self, forKey: .newGross),
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Maaş Değişikliği"
            )
        case "income":
            self = .income(
                amount: try container.decode(Decimal.self, forKey: .amount),
                description: try container.decodeIfPresent(String.self, forKey: .description) ?? "",
                isRecurring: try container.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? true,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Gelir"
            )
        case "expense":
            self = .expense(
                amount: try container.decode(Decimal.self, forKey: .amount),
                description: try container.decodeIfPresent(String.self, forKey: .description) ?? "",
                isRecurring: try container.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? true,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Gider"
            )
        case "investment":
            self = .investment(
                principal: try container.decode(Decimal.self, forKey: .principal),
                annualReturnRate: try container.decode(Decimal.self, forKey: .annualReturnRate),
                termMonths: try container.decode(Int.self, forKey: .termMonths),
                isCompound: try container.decodeIfPresent(Bool.self, forKey: .isCompound) ?? true,
                label: try container.decodeIfPresent(String.self, forKey: .label) ?? "Yatırım"
            )
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: container.codingPath, debugDescription: "Unknown SimulationChange type: \(type)")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .credit(let principal, let rate, let term, let label):
            try container.encode("credit", forKey: .type)
            try container.encode(principal, forKey: .principal)
            try container.encode(rate, forKey: .annualRate)
            try container.encode(term, forKey: .termMonths)
            try container.encode(label, forKey: .label)
        case .housing(let price, let down, let rate, let term, let extras, let label):
            try container.encode("housing", forKey: .type)
            try container.encode(price, forKey: .price)
            try container.encode(down, forKey: .downPayment)
            try container.encode(rate, forKey: .annualRate)
            try container.encode(term, forKey: .termMonths)
            try container.encode(extras, forKey: .monthlyExtras)
            try container.encode(label, forKey: .label)
        case .car(let price, let down, let rate, let term, let running, let label):
            try container.encode("car", forKey: .type)
            try container.encode(price, forKey: .price)
            try container.encode(down, forKey: .downPayment)
            try container.encode(rate, forKey: .annualRate)
            try container.encode(term, forKey: .termMonths)
            try container.encode(running, forKey: .monthlyRunningCosts)
            try container.encode(label, forKey: .label)
        case .rentChange(let current, let new_, let increase, let label):
            try container.encode("rentChange", forKey: .type)
            try container.encode(current, forKey: .currentRent)
            try container.encode(new_, forKey: .newRent)
            try container.encode(increase, forKey: .annualIncreaseRate)
            try container.encode(label, forKey: .label)
        case .salaryChange(let current, let new_, let label):
            try container.encode("salaryChange", forKey: .type)
            try container.encode(current, forKey: .currentGross)
            try container.encode(new_, forKey: .newGross)
            try container.encode(label, forKey: .label)
        case .income(let amount, let desc, let recurring, let label):
            try container.encode("income", forKey: .type)
            try container.encode(amount, forKey: .amount)
            try container.encode(desc, forKey: .description)
            try container.encode(recurring, forKey: .isRecurring)
            try container.encode(label, forKey: .label)
        case .expense(let amount, let desc, let recurring, let label):
            try container.encode("expense", forKey: .type)
            try container.encode(amount, forKey: .amount)
            try container.encode(desc, forKey: .description)
            try container.encode(recurring, forKey: .isRecurring)
            try container.encode(label, forKey: .label)
        case .investment(let principal, let rate, let term, let compound, let label):
            try container.encode("investment", forKey: .type)
            try container.encode(principal, forKey: .principal)
            try container.encode(rate, forKey: .annualReturnRate)
            try container.encode(term, forKey: .termMonths)
            try container.encode(compound, forKey: .isCompound)
            try container.encode(label, forKey: .label)
        }
    }
}
