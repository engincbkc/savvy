import SwiftUI
import SavvyDesignSystem
import SavvyNetworking

struct LoginView: View {
    let authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var appeared = false
    @FocusState private var focusedField: LoginField?

    enum LoginField { case email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                backgroundGradient

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 80)

                        // Logo with glow
                        logoSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : -30)

                        Spacer().frame(height: 48)

                        // Glass card
                        VStack(spacing: 24) {
                            // Email field
                            customTextField(
                                icon: "envelope.fill",
                                placeholder: "E-posta",
                                text: $email,
                                field: .email,
                                isSecure: false
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)

                            // Password field
                            customTextField(
                                icon: "lock.fill",
                                placeholder: "Şifre",
                                text: $password,
                                field: .password,
                                isSecure: true
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)

                            // Error
                            if let errorMessage {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(errorMessage)
                                }
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }

                            // Login button
                            loginButton
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                        }
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                        )
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 32)

                        // Links
                        VStack(spacing: 16) {
                            NavigationLink {
                                ForgotPasswordView(authService: authService)
                            } label: {
                                Text("Şifremi Unuttum")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            NavigationLink {
                                RegisterView(authService: authService)
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Hesabın yok mu?")
                                        .foregroundStyle(.white.opacity(0.5))
                                    Text("Kayıt Ol")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                                .font(.subheadline)
                            }
                        }
                        .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 60)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Components

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0A0F1E"),
                    Color(hex: "0F172A"),
                    Color(hex: "1A1F3A"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Floating orbs
            Circle()
                .fill(Color(hex: "1A56DB").opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -200)

            Circle()
                .fill(Color(hex: "8B5CF6").opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 100, y: 100)
        }
    }

    private var logoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color(hex: "1A56DB").opacity(0.3))
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)

                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "3F83F8"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))
            }

            Text("Eco")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Kişisel Bütçe Yönetimi")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    @ViewBuilder
    private func customTextField(icon: String, placeholder: String, text: Binding<String>, field: LoginField, isSecure: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(focusedField == field ? Color(hex: "3F83F8") : .white.opacity(0.4))
                .frame(width: 20)
                .animation(.easeInOut(duration: 0.2), value: focusedField)

            if isSecure {
                SecureField(placeholder, text: text)
                    .textContentType(.password)
                    .focused($focusedField, equals: field)
            } else {
                TextField(placeholder, text: text)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: field)
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    focusedField == field
                        ? LinearGradient(colors: [Color(hex: "3F83F8"), Color(hex: "8B5CF6")], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .leading, endPoint: .trailing),
                    lineWidth: focusedField == field ? 1.5 : 0.5
                )
                .animation(.easeInOut(duration: 0.3), value: focusedField)
        )
    }

    private var loginButton: some View {
        Button {
            login()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    HStack(spacing: 8) {
                        Text("Giriş Yap")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: (email.isEmpty || password.isEmpty)
                        ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                        : [Color(hex: "1A56DB"), Color(hex: "3F83F8")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color(hex: "1A56DB").opacity(email.isEmpty ? 0 : 0.4), radius: 12, y: 6)
        }
        .disabled(email.isEmpty || password.isEmpty || isLoading)
        .scaleEffect(isLoading ? 0.97 : 1)
        .animation(.spring(response: 0.3), value: isLoading)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLoading)
    }

    private func login() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                withAnimation(.spring(response: 0.4)) {
                    errorMessage = AuthService.mapError(error)
                }
            }
            isLoading = false
        }
    }
}
