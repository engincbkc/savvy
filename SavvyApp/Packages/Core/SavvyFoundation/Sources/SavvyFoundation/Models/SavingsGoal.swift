import Foundation

public struct SavingsGoal: FirestoreEntity {
    public let id: String
    public var title: String
    public var targetAmount: Decimal
    public var currentAmount: Decimal
    public var targetDate: Date?
    public var category: SavingsCategory
    public var colorHex: String
    public var iconName: String
    public var status: GoalStatus
    public var isDeleted: Bool
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        title: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date? = nil,
        category: SavingsCategory = .goal,
        colorHex: String = "#D97706",
        iconName: String = "target",
        status: GoalStatus = .active,
        isDeleted: Bool = false,
        createdAt: Date = Date()
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
        self.isDeleted = isDeleted
        self.createdAt = createdAt
    }
}
