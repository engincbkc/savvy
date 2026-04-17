# 03 — Data Models: Flutter Freezed → Swift Struct/Enum

## Genel Prensipler

| Flutter | Swift |
|---------|-------|
| `@freezed abstract class` | `struct` (Codable, Identifiable, Hashable, Sendable) |
| `@Freezed sealed class` | `enum` with associated values |
| `double` (para tutari) | `Decimal` (finansal hassasiyet) |
| `json_serializable` + `build_runner` | Native `Codable` (sifir code generation) |
| `isDeleted: bool` | `SoftDeletable` protocol |
| `DateTime` (ISO8601 string) | `Date` (Firestore Timestamp → Date) |

### Ortak Protokoller

```swift
protocol SoftDeletable {
    var isDeleted: Bool { get }
}

protocol FirestoreEntity: Codable, Identifiable, Hashable, Sendable, SoftDeletable {
    var id: String { get }
    var createdAt: Date { get }
    var isDeleted: Bool { get }
}
```

## Income (Gelir)

```swift
struct Income: FirestoreEntity {
    let id: String
    var amount: Decimal
    var category: IncomeCategory
    var person: String?
    var source: String?
    var date: Date
    var note: String?
    var isRecurring: Bool
    var recurringEndDate: Date?
    var monthlyOverrides: [String: Decimal]  // "YYYY-MM" → amount
    var isGross: Bool
    var isDeleted: Bool
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: IncomeCategory,
        person: String? = nil,
        source: String? = nil,
        date: Date = .now,
        note: String? = nil,
        isRecurring: Bool = false,
        recurringEndDate: Date? = nil,
        monthlyOverrides: [String: Decimal] = [:],
        isGross: Bool = false,
        isDeleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.person = person
        self.source = source
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringEndDate = recurringEndDate
        self.monthlyOverrides = monthlyOverrides
        self.isGross = isGross
        self.isDeleted = isDeleted
        self.createdAt = createdAt
    }
}
```

## Expense (Gider)

```swift
struct Expense: FirestoreEntity {
    let id: String
    var amount: Decimal
    var category: ExpenseCategory
    var expenseType: ExpenseType
    var subcategory: String?
    var person: String?
    var date: Date
    var note: String?
    var isRecurring: Bool
    var recurringEndDate: Date?
    var monthlyOverrides: [String: Decimal]
    var isDeleted: Bool
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: ExpenseCategory,
        expenseType: ExpenseType = .variable,
        subcategory: String? = nil,
        person: String? = nil,
        date: Date = .now,
        note: String? = nil,
        isRecurring: Bool = false,
        recurringEndDate: Date? = nil,
        monthlyOverrides: [String: Decimal] = [:],
        isDeleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.expenseType = expenseType
        self.subcategory = subcategory
        self.person = person
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringEndDate = recurringEndDate
        self.monthlyOverrides = monthlyOverrides
        self.isDeleted = isDeleted
        self.createdAt = createdAt
    }
}
```

## Savings (Birikim)

```swift
struct Savings: FirestoreEntity {
    let id: String
    var amount: Decimal
    var category: SavingsCategory
    var goalId: String?
    var note: String?
    var date: Date
    var status: SavingsStatus
    var isDeleted: Bool
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: SavingsCategory,
        goalId: String? = nil,
        note: String? = nil,
        date: Date = .now,
        status: SavingsStatus = .active,
        isDeleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.goalId = goalId
        self.note = note
        self.date = date
        self.status = status
        self.isDeleted = isDeleted
        self.createdAt = createdAt
    }
}
```

## SavingsGoal (Birikim Hedefi)

```swift
struct SavingsGoal: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var title: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var targetDate: Date?
    var category: SavingsCategory
    var colorHex: String
    var iconName: String
    var status: GoalStatus
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date? = nil,
        category: SavingsCategory = .goal,
        colorHex: String = "#D97706",
        iconName: String = "target",
        status: GoalStatus = .active,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.category = category
        self.colorHex = colorHex
        self.iconName = iconName
        self.status = status
        self.createdAt = createdAt
    }
}
```

## BudgetLimit (Butce Limiti)

```swift
struct BudgetLimit: FirestoreEntity {
    let id: String
    var category: ExpenseCategory
    var monthlyLimit: Decimal
    var isActive: Bool
    let createdAt: Date
    var isDeleted: Bool
    
    init(
        id: String = UUID().uuidString,
        category: ExpenseCategory,
        monthlyLimit: Decimal,
        isActive: Bool = true,
        createdAt: Date = .now,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.isActive = isActive
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
}
```

## MonthSummary (Aylik Ozet)

```swift
struct MonthSummary: Codable, Identifiable, Hashable, Sendable {
    var id: String { yearMonth }
    
    let yearMonth: String       // "2025-03"
    let totalIncome: Decimal
    let totalExpense: Decimal
    let totalSavings: Decimal
    let netBalance: Decimal     // income - expense
    let carryOver: Decimal      // onceki aydan devir
    let netWithCarryOver: Decimal
    let savingsRate: Double     // 0.0 – 1.0
    let expenseRate: Double     // 0.0 – 2.0+
    let healthScore: Int        // 0 – 100
    let updatedAt: Date
}
```

## PlannedChange (Planli Degisiklik)

```swift
struct PlannedChange: FirestoreEntity {
    let id: String
    var parentId: String        // Income.id veya Expense.id
    var parentType: String      // "income" veya "expense"
    var newAmount: Decimal
    var effectiveDate: Date
    var isGross: Bool
    var note: String?
    var isDeleted: Bool
    let createdAt: Date
}
```

## SimulationEntry (Simulasyon)

```swift
struct SimulationEntry: FirestoreEntity {
    let id: String
    var title: String
    var description: String?
    var template: SimulationTemplate?
    var iconName: String
    var colorHex: String
    var changes: [SimulationChange]
    var compareWithId: String?
    var isIncluded: Bool
    var isDeleted: Bool
    let createdAt: Date
    var updatedAt: Date?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        template: SimulationTemplate? = nil,
        iconName: String = "sparkles",
        colorHex: String = "#3F83F8",
        changes: [SimulationChange] = [],
        compareWithId: String? = nil,
        isIncluded: Bool = false,
        isDeleted: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.template = template
        self.iconName = iconName
        self.colorHex = colorHex
        self.changes = changes
        self.compareWithId = compareWithId
        self.isIncluded = isIncluded
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

## SimulationChange (Sealed Type → Swift Enum)

Flutter'daki `@Freezed sealed class SimulationChange` → Swift native enum:

```swift
enum SimulationChange: Codable, Hashable, Sendable {
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
        label: String = "Ev Alimi"
    )
    
    case car(
        price: Decimal,
        downPayment: Decimal = 0,
        annualRate: Decimal,
        termMonths: Int,
        monthlyRunningCosts: Decimal = 0,
        label: String = "Arac Alimi"
    )
    
    case rentChange(
        currentRent: Decimal,
        newRent: Decimal,
        annualIncreaseRate: Decimal = 0,
        label: String = "Kira Degisimi"
    )
    
    case salaryChange(
        currentGross: Decimal,
        newGross: Decimal,
        label: String = "Maas Degisikligi"
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
        label: String = "Yatirim"
    )
}

// Pattern matching ornegi (Flutter'daki when/map yerine):
extension SimulationChange {
    var displayLabel: String {
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
    
    var isLoanBased: Bool {
        switch self {
        case .credit, .housing, .car: true
        default: false
        }
    }
}
```

## Simulation Result Modelleri

```swift
struct SimulationResult: Sendable {
    let currentIncome: Decimal
    let currentExpense: Decimal
    let currentNet: Decimal
    let newIncome: Decimal
    let newExpense: Decimal
    let newNet: Decimal
    let monthlyNetImpact: Decimal
    let annualNetImpact: Decimal
    let newSavingsRate: Double
    let newExpenseRate: Double
    let affordability: AffordabilityStatus?
    let changeResults: [ChangeResult]
    let monthlyProjection: [MonthProjection]
}

struct ChangeResult: Sendable {
    let change: SimulationChange
    let monthlyImpact: Decimal
    let totalCost: Decimal?
    let totalInterest: Decimal?
    let amortizationSchedule: [AmortizationRow]?
    let salaryImpact: SalaryImpact?
    let investmentImpact: InvestmentImpact?
}

struct MonthProjection: Identifiable, Sendable {
    var id: String { yearMonth }
    let yearMonth: String
    let monthLabel: String
    let income: Decimal
    let expense: Decimal
    let net: Decimal
    let cumulativeNet: Decimal
    let incomeItems: [MonthLineItem]
    let expenseItems: [MonthLineItem]
}

struct AmortizationRow: Identifiable, Sendable {
    var id: Int { month }
    let month: Int
    let payment: Decimal
    let principal: Decimal
    let interest: Decimal
    let balance: Decimal
}

struct MonthLineItem: Identifiable, Sendable {
    let id: String
    let label: String
    let amount: Decimal
    let isSimulated: Bool
}
```

## Codable Custom Encoding (SimulationChange)

SimulationChange enum'u Firestore'da JSON olarak saklanacak:

```swift
extension SimulationChange {
    // Custom Codable — Flutter'daki toJson/fromJson'a karsilik
    enum CodingKeys: String, CodingKey {
        case type, principal, annualRate, termMonths, label
        case price, downPayment, monthlyExtras, monthlyRunningCosts
        case currentRent, newRent, annualIncreaseRate
        case currentGross, newGross
        case amount, description, isRecurring
        case annualReturnRate, isCompound
    }
    
    init(from decoder: Decoder) throws {
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
        // ... diger case'ler
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown type: \(type)"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .credit(let principal, let rate, let term, let label):
            try container.encode("credit", forKey: .type)
            try container.encode(principal, forKey: .principal)
            try container.encode(rate, forKey: .annualRate)
            try container.encode(term, forKey: .termMonths)
            try container.encode(label, forKey: .label)
        // ... diger case'ler
        }
    }
}
```

## Date + YearMonth Extension

```swift
extension Date {
    /// "2025-03" formatinda yearMonth string
    func toYearMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
    
    /// YearMonth string'den ayin baslangic tarihini olustur
    static func fromYearMonth(_ ym: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.date(from: ym)
    }
}

struct YearMonthRange {
    let start: Date
    let end: Date
    
    static func from(_ yearMonth: String) -> YearMonthRange? {
        guard let start = Date.fromYearMonth(yearMonth) else { return nil }
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start)!
        return YearMonthRange(start: start, end: end)
    }
}
```
