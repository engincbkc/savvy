import SwiftUI
import SavvyDesignSystem
import SavvyNetworking

struct RegisterView: View {
    let authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var appeared = false
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirm }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0A0F1E").ignoresSafeArea()
            Circle()
                .fill(Color(hex: "046C4E").opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 80, y: -200)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(colors: [Color(hex: "0E9F6E"), Color(hex: "34D399")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Text("Hesap Oluştur")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -20)

                    // Form
                    VStack(spacing: 20) {
                        formField(icon: "person.fill", placeholder: "Ad Soyad", text: $name, field: .name)
                        formField(icon: "envelope.fill", placeholder: "E-posta", text: $email, field: .email)
                        secureField(icon: "lock.fill", placeholder: "Şifre", text: $password, field: .password)
                        secureField(icon: "lock.rotation", placeholder: "Şifre Tekrar", text: $confirmPassword, field: .confirm)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                    )
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    if let errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Register button
                    Button { register() } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                HStack(spacing: 8) {
                                    Text("Kayıt Ol").font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right").font(.system(size: 14, weight: .bold))
                                }
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: canSubmit ? [Color(hex: "046C4E"), Color(hex: "0E9F6E")] : [.gray.opacity(0.3), .gray.opacity(0.2)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "0E9F6E").opacity(canSubmit ? 0.4 : 0), radius: 12, y: 6)
                    }
                    .disabled(!canSubmit || isLoading)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) { appeared = true }
        }
    }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }

    @ViewBuilder
    private func formField(icon: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(focusedField == field ? Color(hex: "0E9F6E") : .white.opacity(0.4))
                .frame(width: 20)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(field == .email ? .never : .words)
                .keyboardType(field == .email ? .emailAddress : .default)
                .focused($focusedField, equals: field)
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.07)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(focusedField == field ? Color(hex: "0E9F6E").opacity(0.8) : .white.opacity(0.08), lineWidth: focusedField == field ? 1.5 : 0.5)
        )
    }

    @ViewBuilder
    private func secureField(icon: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(focusedField == field ? Color(hex: "0E9F6E") : .white.opacity(0.4))
                .frame(width: 20)
            SecureField(placeholder, text: text)
                .focused($focusedField, equals: field)
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.07)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(focusedField == field ? Color(hex: "0E9F6E").opacity(0.8) : .white.opacity(0.08), lineWidth: focusedField == field ? 1.5 : 0.5)
        )
    }

    private func register() {
        guard password == confirmPassword else {
            withAnimation(.spring(response: 0.4)) { errorMessage = "Şifreler eşleşmiyor" }
            return
        }
        errorMessage = nil; isLoading = true
        Task {
            do {
                try await authService.signUp(name: name, email: email, password: password)
            } catch {
                withAnimation(.spring(response: 0.4)) { errorMessage = AuthService.mapError(error) }
            }
            isLoading = false
        }
    }
}
