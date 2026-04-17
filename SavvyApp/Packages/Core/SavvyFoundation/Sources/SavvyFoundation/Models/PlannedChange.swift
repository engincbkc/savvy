import Foundation

public struct PlannedChange: FirestoreEntity {
    public let id: String
    public var parentId: String
    public var parentType: String
    public var newAmount: Decimal
    public var effectiveDate: Date
    public var isGross: Bool
    public var note: String?
    public var isDeleted: Bool
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        parentId: String,
        parentType: String,
        newAmount: Decimal,
        effectiveDate: Date,
        isGross: Bool = false,
        note: String? = nil,
        isDeleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.parentId = parentId
        self.parentType = parentType
        self.newAmount = newAmount
        self.effectiveDate = effectiveDate
        self.isGross = isGross
        self.note = note
        self.isDeleted = isDeleted
        self.createdAt = createdAt
    }
}
