import Foundation

public struct Savings: FirestoreEntity {
    public let id: String
    public var amount: Decimal
    public var category: SavingsCategory
    public var goalId: String?
    public var note: String?
    public var date: Date
    public var status: SavingsStatus
    public var isDeleted: Bool
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        amount: Decimal,
        category: SavingsCategory,
        goalId: String? = nil,
        note: String? = nil,
        date: Date = Date(),
        status: SavingsStatus = .active,
        isDeleted: Bool = false,
        createdAt: Date = Date()
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
