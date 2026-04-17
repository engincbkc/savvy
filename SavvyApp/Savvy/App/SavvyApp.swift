import SwiftUI
import Firebase
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

@main
struct SavvyApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var authService: AuthService

    init() {
        FirebaseApp.configure()
        _authService = State(initialValue: AuthService())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else if authService.isAuthenticated, let userId = authService.userId {
                    let deps = AppDependencies(userId: userId)
                    MainTabView(deps: deps, authService: authService)
                } else {
                    LoginView(authService: authService)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.savvyNormal, value: authService.isAuthenticated)
            .animation(.savvyNormal, value: hasCompletedOnboarding)
        }
    }
}

enum AppTab: String, CaseIterable {
    case dashboard, transactions, simulation, settings
}
