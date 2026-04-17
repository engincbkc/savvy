import SwiftUI
import SavvyDesignSystem
import SavvyNetworking

struct ForgotPasswordView: View {
    let authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isSent = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: SavvySpacing.xl) {
            Spacer().frame(height: SavvySpacing.xl2)

            Image(systemName: "envelope.badge")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "1A56DB"))

            if isSent {
                VStack(spacing: SavvySpacing.md) {
                    Text("E-posta Gönderildi!")
                        .font(.savvyHeadlineMedium)
                    Text("Şifre sıfırlama bağlantısı \(email) adresine gönderildi.")
                        .font(.savvyBodyMedium)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Geri Dön") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "1A56DB"))
                }
            } else {
                VStack(spacing: SavvySpacing.md) {
                    Text("Şifremi Unuttum")
                        .font(.savvyHeadlineMedium)
                    Text("E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz.")
                        .font(.savvyBodyMedium)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                TextField("E-posta", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding(SavvySpacing.md)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))

                if let errorMessage {
                    Text(errorMessage)
                        .font(.savvyCaption)
                        .foregroundStyle(.red)
                }

                Button {
                    resetPassword()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Gönder").font(.savvyTitleMedium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "1A56DB"))
                .disabled(email.isEmpty || isLoading)
            }

            Spacer()
        }
        .padding(.horizontal, SavvySpacing.lg)
        .navigationTitle("Şifre Sıfırlama")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetPassword() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await authService.resetPassword(email: email)
                isSent = true
            } catch {
                errorMessage = AuthService.mapError(error)
            }
            isLoading = false
        }
    }
}
