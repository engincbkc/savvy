import SwiftUI
import SavvyDesignSystem
import SavvyNetworking

struct SettingsView: View {
    let authService: AuthService
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showLogoutAlert = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Card
                    profileCard
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    // Preferences
                    settingsSection(title: "Tercihler", delay: 0.1) {
                        settingsRow(icon: "moon.fill", iconColor: Color(hex: "8B5CF6"), title: "Karanlık Mod") {
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                                .tint(Color(hex: "1A56DB"))
                        }
                    }

                    // About
                    settingsSection(title: "Hakkında", delay: 0.2) {
                        infoRow(icon: "info.circle.fill", iconColor: Color(hex: "3F83F8"), title: "Versiyon", value: "1.0.0")
                        Divider().padding(.leading, 52)
                        infoRow(icon: "swift", iconColor: .orange, title: "Platform", value: "iOS Native (Swift)")
                        Divider().padding(.leading, 52)
                        infoRow(icon: "heart.fill", iconColor: .pink, title: "Yapımcı", value: "Eco Team")
                    }

                    // Logout
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.red)
                                .frame(width: 36, height: 36)
                                .background(.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Çıkış Yap")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.5))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ayarlar")
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) {}
                Button("Çıkış Yap", role: .destructive) {
                    try? authService.signOut()
                }
            } message: {
                Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A56DB"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Text(String((authService.displayName ?? "U").prefix(1)).uppercased())
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(authService.displayName ?? "Kullanıcı")
                    .font(.system(size: 18, weight: .semibold))
                Text(authService.email ?? "")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func settingsSection(title: String, delay: Double, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                content()
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
            .padding(.horizontal, 20)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    @ViewBuilder
    private func settingsRow(icon: String, iconColor: Color, title: String, @ViewBuilder trailing: () -> some View) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.system(size: 16))
            Spacer()
            trailing()
        }
        .padding(12)
    }

    @ViewBuilder
    private func infoRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.system(size: 16))
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }
}
