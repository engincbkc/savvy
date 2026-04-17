import Foundation
import FirebaseAuth
import Observation

@Observable
public final class AuthService: @unchecked Sendable {
    public private(set) var user: User?
    public private(set) var isAuthenticated = false
    private var authListener: AuthStateDidChangeListenerHandle?

    public var userId: String? { user?.uid }
    public var displayName: String? { user?.displayName }
    public var email: String? { user?.email }

    public init() {
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

    // MARK: - Email/Password

    public func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    public func signUp(name: String, email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
    }

    public func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Error Mapping (Turkish)

    public static func mapError(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return error.localizedDescription
        }
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Hatalı şifre"
        case AuthErrorCode.userNotFound.rawValue:
            return "Kullanıcı bulunamadı"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Bu e-posta zaten kullanımda"
        case AuthErrorCode.weakPassword.rawValue:
            return "Şifre en az 6 karakter olmalı"
        case AuthErrorCode.networkError.rawValue:
            return "Bağlantı hatası, lütfen tekrar deneyin"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Çok fazla deneme, lütfen bekleyin"
        default:
            return "Bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
