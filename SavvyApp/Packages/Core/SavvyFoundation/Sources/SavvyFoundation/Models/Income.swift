import Foundation

public struct Income: FirestoreEntity {
    public let id: String
    public var amount: Decimal
    public var category: IncomeCategory
    public var person: String?
    public var source: String?
    public var date: Date
    public var note: String?
    public var isRecurring: Bool
    public var recurringEndDate: Date?
    public var monthlyOverrides: [String: Decimal]
    public var isGross: Bool
    public var isDeleted: Bool
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: IncomeCategory,
        person: String? = nil,
        source: String? = nil,
        date: Date = Date(),
        note: String? = nil,
        isRecurring: Bool = false,
        recurringEndDate: Date? = nil,
        monthlyOverrides: [String: Decimal] = [:],
        isGross: Bool = false,
        isDeleted: Bool = false,
        createdAt: Date = Date()
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
