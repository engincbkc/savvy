import Foundation

public struct SimulationEntry: FirestoreEntity {
    public let id: String
    public var title: String
    public var description: String?
    public var template: SimulationTemplate?
    public var iconName: String
    public var colorHex: String
    public var changes: [SimulationChange]
    public var compareWithId: String?
    public var isIncluded: Bool
    public var isDeleted: Bool
    public let createdAt: Date
    public var updatedAt: Date?

    public init(
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
        createdAt: Date = Date(),
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
