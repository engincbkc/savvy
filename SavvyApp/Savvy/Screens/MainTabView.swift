import SwiftUI
import SavvyDesignSystem
import SavvyNetworking

struct MainTabView: View {
    let deps: AppDependencies
    let authService: AuthService
    @State private var selectedTab: AppTab = .dashboard
    @Namespace private var tabAnimation

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView(deps: deps)
                case .transactions:
                    TransactionsView(deps: deps)
                case .simulation:
                    SimulationListView(deps: deps)
                case .settings:
                    SettingsView(authService: authService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.tab) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    @ViewBuilder
    private func tabButton(_ item: TabItem) -> some View {
        let isSelected = selectedTab == item.tab
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = item.tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "1A56DB"), Color(hex: "3F83F8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 48, height: 32)
                            .matchedGeometryEffect(id: "tabBg", in: tabAnimation)
                    }

                    Image(systemName: isSelected ? item.iconFilled : item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .scaleEffect(isSelected ? 1.1 : 1)
                }
                .frame(height: 32)

                Text(item.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var tabItems: [TabItem] {
        [
            TabItem(tab: .dashboard, icon: "house", iconFilled: "house.fill", label: "Ana Sayfa"),
            TabItem(tab: .transactions, icon: "list.bullet.rectangle", iconFilled: "list.bullet.rectangle.fill", label: "İşlemler"),
            TabItem(tab: .simulation, icon: "chart.line.uptrend.xyaxis", iconFilled: "chart.line.uptrend.xyaxis", label: "Simülasyon"),
            TabItem(tab: .settings, icon: "gearshape", iconFilled: "gearshape.fill", label: "Ayarlar"),
        ]
    }
}

struct TabItem {
    let tab: AppTab
    let icon: String
    let iconFilled: String
    let label: String
}

struct SimulationPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Simülasyon modülü yakında...")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Simülasyon")
        }
    }
}
