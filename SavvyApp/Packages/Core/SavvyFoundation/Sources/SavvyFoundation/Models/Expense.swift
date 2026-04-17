import Foundation

public struct Expense: FirestoreEntity {
    public let id: String
    public var amount: Decimal
    public var category: ExpenseCategory
    public var expenseType: ExpenseType
    public var subcategory: String?
    public var person: String?
    public var date: Date
    public var note: String?
    public var isRecurring: Bool
    public var recurringEndDate: Date?
    public var monthlyOverrides: [String: Decimal]
    public var isDeleted: Bool
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: ExpenseCategory,
        expenseType: ExpenseType = .variable,
        subcategory: String? = nil,
        person: String? = nil,
        date: Date = Date(),
        note: String? = nil,
        isRecurring: Bool = false,
        recurringEndDate: Date? = nil,
        monthlyOverrides: [String: Decimal] = [:],
        isDeleted: Bool = false,
        createdAt: Date = Date()
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
