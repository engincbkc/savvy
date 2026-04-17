import Foundation

public struct BudgetLimit: FirestoreEntity {
    public let id: String
    public var category: ExpenseCategory
    public var monthlyLimit: Decimal
    public var isActive: Bool
    public let createdAt: Date
    public var isDeleted: Bool

    public init(
        id: String = UUID().uuidString,
        category: ExpenseCategory,
        monthlyLimit: Decimal,
        isActive: Bool = true,
        createdAt: Date = Date(),
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
