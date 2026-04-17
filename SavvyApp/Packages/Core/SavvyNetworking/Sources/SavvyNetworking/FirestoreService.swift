import Foundation
import FirebaseFirestore
import SavvyFoundation

public final class FirestoreService<T: Codable & Identifiable & SoftDeletable>: @unchecked Sendable where T.ID == String {
    public let collectionRef: CollectionReference

    public init(db: Firestore, path: String) {
        self.collectionRef = db.collection(path)
    }

    // MARK: - Watch (Real-time Stream)

    public func watch() -> AsyncStream<[T]> {
        AsyncStream { continuation in
            let listener = collectionRef
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, _ in
                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    let items = documents.compactMap { doc -> T? in
                        try? doc.data(as: T.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    // MARK: - Watch by Month

    public func watchMonth(_ yearMonth: String) -> AsyncStream<[T]> {
        guard let range = YearMonthRange.from(yearMonth) else {
            return AsyncStream { $0.finish() }
        }

        return AsyncStream { continuation in
            let listener = collectionRef
                .whereField("isDeleted", isEqualTo: false)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: range.start))
                .whereField("date", isLessThan: Timestamp(date: range.end))
                .addSnapshotListener { snapshot, _ in
                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    let items = documents.compactMap { doc -> T? in
                        try? doc.data(as: T.self)
                    }
                    continuation.yield(items)
                }
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    // MARK: - CRUD

    public func get(id: String) async throws -> T? {
        try await collectionRef.document(id).getDocument(as: T.self)
    }

    public func add(_ entity: T) async throws {
        try collectionRef.document(entity.id).setData(from: entity)
    }

    public func update(_ entity: T) async throws {
        try collectionRef.document(entity.id).setData(from: entity, merge: true)
    }

    public func softDelete(id: String) async throws {
        try await collectionRef.document(id).updateData(["isDeleted": true])
    }

    public func hardDelete(id: String) async throws {
        try await collectionRef.document(id).delete()
    }

    public func softDeleteMany(ids: [String]) async throws {
        let batch = collectionRef.firestore.batch()
        for id in ids {
            batch.updateData(["isDeleted": true], forDocument: collectionRef.document(id))
        }
        try await batch.commit()
    }
}
