import Foundation

public protocol SoftDeletable {
    var isDeleted: Bool { get }
}

public protocol FirestoreEntity: Codable, Identifiable, Hashable, Sendable, SoftDeletable {
    var id: String { get }
    var createdAt: Date { get }
    var isDeleted: Bool { get }
}
