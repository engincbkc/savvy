import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class ExpenseRepository: Repository, @unchecked Sendable {
    public typealias Entity = Expense
    private let service: FirestoreService<Expense>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/expenses")
    }

    public func watch() -> AsyncStream<[Expense]> { service.watch() }
    public func watchMonth(_ yearMonth: String) -> AsyncStream<[Expense]> { service.watchMonth(yearMonth) }
    public func get(id: String) async throws -> Expense? { try await service.get(id: id) }
    public func add(_ expense: Expense) async throws { try await service.add(expense) }
    public func update(_ expense: Expense) async throws { try await service.update(expense) }
    public func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
