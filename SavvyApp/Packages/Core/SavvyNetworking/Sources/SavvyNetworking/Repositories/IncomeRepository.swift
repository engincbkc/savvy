import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class IncomeRepository: Repository, @unchecked Sendable {
    public typealias Entity = Income
    private let service: FirestoreService<Income>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/incomes")
    }

    public func watch() -> AsyncStream<[Income]> { service.watch() }
    public func watchMonth(_ yearMonth: String) -> AsyncStream<[Income]> { service.watchMonth(yearMonth) }
    public func get(id: String) async throws -> Income? { try await service.get(id: id) }
    public func add(_ income: Income) async throws { try await service.add(income) }
    public func update(_ income: Income) async throws { try await service.update(income) }
    public func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
