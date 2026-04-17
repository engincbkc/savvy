import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class SimulationRepository: Repository, @unchecked Sendable {
    public typealias Entity = SimulationEntry
    private let service: FirestoreService<SimulationEntry>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/simulations")
    }

    public func watch() -> AsyncStream<[SimulationEntry]> { service.watch() }
    public func watchMonth(_ yearMonth: String) -> AsyncStream<[SimulationEntry]> { service.watchMonth(yearMonth) }
    public func get(id: String) async throws -> SimulationEntry? { try await service.get(id: id) }
    public func add(_ entry: SimulationEntry) async throws { try await service.add(entry) }
    public func update(_ entry: SimulationEntry) async throws { try await service.update(entry) }
    public func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
