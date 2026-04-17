import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class BudgetLimitRepository: Repository, @unchecked Sendable {
    public typealias Entity = BudgetLimit
    private let service: FirestoreService<BudgetLimit>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/budget_limits")
    }

    public func watch() -> AsyncStream<[BudgetLimit]> { service.watch() }
    public func watchMonth(_ yearMonth: String) -> AsyncStream<[BudgetLimit]> { service.watchMonth(yearMonth) }
    public func get(id: String) async throws -> BudgetLimit? { try await service.get(id: id) }
    public func add(_ limit: BudgetLimit) async throws { try await service.add(limit) }
    public func update(_ limit: BudgetLimit) async throws { try await service.update(limit) }
    public func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
