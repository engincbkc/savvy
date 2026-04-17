# 07 — Firebase: Firestore Service, Auth, Data Access

## Firestore Yapisi (Degismiyor)

Mevcut Flutter uygulamasindaki Firestore yapisi aynen korunacak:

```
savvy-cffb8/
└── users/{uid}/
    ├── incomes/{id}          → Income documents
    ├── expenses/{id}         → Expense documents
    ├── savings/{id}          → Savings documents
    ├── savingsGoals/{id}     → SavingsGoal documents
    ├── simulations/{id}      → SimulationEntry documents
    ├── budget_limits/{id}    → BudgetLimit documents
    └── plannedChanges/{id}   → PlannedChange documents
```

**Avantaj**: Mevcut kullanici verileri korunur, migration gerekmez.

---

## Generic FirestoreService

Flutter'da her repository'de tekrarlanan boilerplate (timestamp conversion, soft-delete filtering, doc mapping) tek bir generic service'e tasinacak:

```swift
final class FirestoreService<T: Codable & Identifiable & SoftDeletable>: Sendable where T.ID == String {
    let collectionRef: CollectionReference
    
    init(db: Firestore, path: String) {
        self.collectionRef = db.collection(path)
    }
    
    // ─── Watch (Real-time Stream) ────────────────────
    func watch() -> AsyncStream<[T]> {
        AsyncStream { continuation in
            let listener = collectionRef
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
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
    
    // ─── Watch by Month ──────────────────────────────
    func watchMonth(_ yearMonth: String) -> AsyncStream<[T]> {
        guard let range = YearMonthRange.from(yearMonth) else {
            return AsyncStream { $0.finish() }
        }
        
        return AsyncStream { continuation in
            let listener = collectionRef
                .whereField("isDeleted", isEqualTo: false)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: range.start))
                .whereField("date", isLessThan: Timestamp(date: range.end))
                .addSnapshotListener { snapshot, error in
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
    
    // ─── CRUD ────────────────────────────────────────
    func get(id: String) async throws -> T? {
        try await collectionRef.document(id).getDocument(as: T.self)
    }
    
    func add(_ entity: T) async throws {
        try collectionRef.document(entity.id).setData(from: entity)
    }
    
    func update(_ entity: T) async throws {
        try collectionRef.document(entity.id).setData(from: entity, merge: true)
    }
    
    func softDelete(id: String) async throws {
        try await collectionRef.document(id).updateData(["isDeleted": true])
    }
    
    func hardDelete(id: String) async throws {
        try await collectionRef.document(id).delete()
    }
    
    func softDeleteMany(ids: [String]) async throws {
        let batch = collectionRef.firestore.batch()
        for id in ids {
            batch.updateData(["isDeleted": true], forDocument: collectionRef.document(id))
        }
        try await batch.commit()
    }
}
```

---

## Repository Protocol

```swift
protocol Repository<Entity>: Sendable {
    associatedtype Entity: Codable & Identifiable & SoftDeletable
    func watch() -> AsyncStream<[Entity]>
    func watchMonth(_ yearMonth: String) -> AsyncStream<[Entity]>
    func get(id: String) async throws -> Entity?
    func add(_ entity: Entity) async throws
    func update(_ entity: Entity) async throws
    func softDelete(id: String) async throws
}
```

---

## Concrete Repositories

Her repository FirestoreService'i sararlar ve ek islemleri yaparlar:

```swift
final class IncomeRepository: Repository, Sendable {
    typealias Entity = Income
    private let service: FirestoreService<Income>
    
    init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/incomes")
    }
    
    func watch() -> AsyncStream<[Income]> { service.watch() }
    func watchMonth(_ yearMonth: String) -> AsyncStream<[Income]> { service.watchMonth(yearMonth) }
    func get(id: String) async throws -> Income? { try await service.get(id: id) }
    
    func add(_ income: Income) async throws {
        var entity = income
        // Server timestamp icin Firestore'un kendi timestamp'ini kullan
        try await service.add(entity)
    }
    
    func update(_ income: Income) async throws {
        try await service.update(income)
    }
    
    func softDelete(id: String) async throws {
        try await service.softDelete(id: id)
    }
}

// ExpenseRepository, SavingsRepository, vs. ayni pattern
```

### SavingsGoalRepository (Hard Delete)

```swift
final class SavingsGoalRepository: Sendable {
    private let service: FirestoreService<SavingsGoal>
    
    init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/savingsGoals")
    }
    
    func watch() -> AsyncStream<[SavingsGoal]> { service.watch() }
    func get(id: String) async throws -> SavingsGoal? { try await service.get(id: id) }
    func add(_ goal: SavingsGoal) async throws { try await service.add(goal) }
    func update(_ goal: SavingsGoal) async throws { try await service.update(goal) }
    
    // SavingsGoal hard delete kullanir (soft-delete yok)
    func delete(id: String) async throws {
        try await service.hardDelete(id: id)
    }
}
```

### SimulationRepository (Nested JSON)

```swift
final class SimulationRepository: Repository, Sendable {
    typealias Entity = SimulationEntry
    private let service: FirestoreService<SimulationEntry>
    
    init(userId: String, db: Firestore) {
        self.service = FirestoreService(db: db, path: "users/\(userId)/simulations")
    }
    
    // SimulationChange enum'u nested JSON olarak saklanir
    // Codable custom encoding/decoding 03-DATA-MODELS.md'de tanimli
    
    func watch() -> AsyncStream<[SimulationEntry]> { service.watch() }
    func watchMonth(_ yearMonth: String) -> AsyncStream<[SimulationEntry]> { service.watchMonth(yearMonth) }
    func get(id: String) async throws -> SimulationEntry? { try await service.get(id: id) }
    func add(_ entry: SimulationEntry) async throws { try await service.add(entry) }
    func update(_ entry: SimulationEntry) async throws { try await service.update(entry) }
    func softDelete(id: String) async throws { try await service.softDelete(id: id) }
}
```

---

## AuthService

```swift
@Observable
final class AuthService {
    private(set) var user: User?
    private(set) var isAuthenticated = false
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // ─── Email/Password ──────────────────────────────
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(name: String, email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // ─── Google Sign-In ──────────────────────────────
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw SavvyError.auth("Google client ID bulunamadi")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw SavvyError.auth("Root view controller bulunamadi")
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        guard let idToken = result.user.idToken?.tokenString else {
            throw SavvyError.auth("Google ID token alinamadi")
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    // ─── Apple Sign-In ───────────────────────────────
    func signInWithApple(authorization: ASAuthorization, nonce: String) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw SavvyError.auth("Apple credential alinamadi")
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    // ─── Sign Out ────────────────────────────────────
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
    
    // ─── Error Mapping (Turkish) ─────────────────────
    static func mapError(_ error: Error) -> String {
        guard let authError = error as? AuthErrorCode else {
            return error.localizedDescription
        }
        return switch authError.code {
        case .invalidEmail: "Gecersiz e-posta adresi"
        case .wrongPassword: "Hatali sifre"
        case .userNotFound: "Kullanici bulunamadi"
        case .emailAlreadyInUse: "Bu e-posta zaten kullanimda"
        case .weakPassword: "Sifre en az 6 karakter olmali"
        case .networkError: "Baglanti hatasi, lutfen tekrar deneyin"
        case .tooManyRequests: "Cok fazla deneme, lutfen bekleyin"
        default: "Bir hata olustu: \(error.localizedDescription)"
        }
    }
}
```

---

## Timestamp Handling

Flutter'da tarihler ISO8601 string olarak saklaniyordu. Swift'te Firebase iOS SDK native `@ServerTimestamp` ve `Codable` destegi var:

```swift
import FirebaseFirestore

struct Income: Codable {
    // ...
    
    // @ServerTimestamp otomatik olarak Firestore Timestamp ↔ Date donusumu yapar
    @ServerTimestamp var createdAt: Date?
    
    // Normal Date alanlari icin custom CodingKeys gerekmez
    // Firebase iOS SDK Codable support Timestamp'i otomatik handle eder
    var date: Date
}
```

**Not**: Flutter reposundaki `_docToMap` helper ve manual Timestamp conversion'a gerek yok. Firebase iOS SDK'nin `Codable` destegi bunu otomatik yapar.

---

## Firebase Setup

```swift
// SavvyApp.swift
import Firebase

@main
struct SavvyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Firestore Rules (Mevcut — degismez)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Dependencies (SPM)

```swift
// Package.swift — SavvyNetworking
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
],
targets: [
    .target(
        name: "SavvyNetworking",
        dependencies: [
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            "SavvyFoundation",
        ]
    ),
]
```
