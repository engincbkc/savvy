import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class SavingsGoalRepository: @unchecked Sendable {
    private let service: FirestoreService<SavingsGoal>

    public init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/savingsGoals")
    }

    public func watch() -> AsyncStream<[SavingsGoal]> { service.watch() }
    public func get(id: String) async throws -> SavingsGoal? { try await service.get(id: id) }
    public func add(_ goal: SavingsGoal) async throws { try await service.add(goal) }
    public func update(_ goal: SavingsGoal) async throws { try await service.update(goal) }
    public func delete(id: String) async throws { try await service.hardDelete(id: id) }
}
