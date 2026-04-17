import Foundation
import SavvyFoundation

public protocol Repository<Entity>: Sendable {
    associatedtype Entity: Codable & Identifiable & SoftDeletable where Entity.ID == String
    func watch() -> AsyncStream<[Entity]>
    func watchMonth(_ yearMonth: String) -> AsyncStream<[Entity]>
    func get(id: String) async throws -> Entity?
    func add(_ entity: Entity) async throws
    func update(_ entity: Entity) async throws
    func softDelete(id: String) async throws
}
