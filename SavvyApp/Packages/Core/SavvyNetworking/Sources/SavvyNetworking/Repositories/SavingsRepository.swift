import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class SavingsRepository: Repository, @unchecked Sendable {
    public typealias Entity = Savings
    private let service: FirestoreService<Savings>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/savings")
    }

    public func watch() -> AsyncStream<[Savings]> { service.watch() }
    public func watchMonth(_ yearMonth: String) -> AsyncStream<[Savings]> { service.watchMonth(yearMonth) }
    public func get(id: String) async throws -> Savings? { try await service.get(id: id) }
    public func add(_ savings: Savings) async throws { try await service.add(savings) }
    public func update(_ savings: Savings) async throws { try await service.update(savings) }
    public func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
