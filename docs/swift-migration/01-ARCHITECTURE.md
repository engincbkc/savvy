# 01 — Mimari: MVVM + @Observable + Swift Concurrency

## Neden MVVM + @Observable?

| Alternatif | Neden Secilmedi |
|-----------|----------------|
| TCA (The Composable Architecture) | Asiri boilerplate, Firestore stream'leriyle catisma, ogrenme egrisi yuksek |
| MVC | Test edilebilirlik dusuk, ViewModel ayirimi yok |
| VIPER | Fazla katman, SwiftUI'in declarative yapisina uyumsuz |
| **MVVM + @Observable** | **Riverpod'a 1:1 map, idiomatic SwiftUI, minimal boilerplate** |

### Flutter → Swift Eslesmesi

```
Riverpod AsyncNotifier     →  @Observable class ViewModel
StreamProvider             →  AsyncStream<[T]> in ViewModel
ref.watch(provider)        →  @Environment(ViewModel.self)
ConsumerWidget             →  SwiftUI View (otomatik observe)
keepAlive: true            →  @Observable in @main App
```

## Katmanli Mimari

```
┌─────────────────────────────────────────────┐
│  View (SwiftUI)                             │
│  ── Sadece UI render, sifir business logic  │
├─────────────────────────────────────────────┤
│  ViewModel (@Observable)                     │
│  ── State yonetimi, View'a data hazirlama   │
├─────────────────────────────────────────────┤
│  Repository (Protocol)                       │
│  ── Data access interface, CRUD             │
├─────────────────────────────────────────────┤
│  DataSource (Firebase / Local)               │
│  ── Firestore SDK, UserDefaults, Keychain   │
└─────────────────────────────────────────────┘
```

## SPM Modul Yapisi

```
SavvyApp/                              ← Xcode project (composition root)
│
Packages/
├── Core/
│   ├── SavvyFoundation/               ← Sifir UI dependency
│   │   ├── Models/                    (Income, Expense, Savings, etc.)
│   │   ├── Enums/                     (IncomeCategory, ExpenseCategory, etc.)
│   │   ├── Calculator/                (FinancialCalculator, SimulationCalculator)
│   │   ├── Formatters/                (CurrencyFormatter, DateFormatter+TR)
│   │   ├── Validators/                (TransactionValidator)
│   │   └── Extensions/                (Date+YearMonth, Decimal+Clamped)
│   │
│   ├── SavvyDesignSystem/             ← UI atomlari, business logic yok
│   │   ├── Tokens/                    (Colors, Typography, Spacing, Radius, Animation)
│   │   ├── Components/                (SavvyCard, SavvyButton, SavvyTextField, etc.)
│   │   ├── Charts/                    (FinancialBarChart, TrendChart, DonutChart)
│   │   ├── Feedback/                  (SavvyHaptics, SavvyToast, ShimmerView)
│   │   └── Modifiers/                 (CountUpModifier, SlideInModifier, PressEffect)
│   │
│   └── SavvyNetworking/              ← Firebase abstraction
│       ├── FirestoreService.swift     (Generic CRUD: AsyncStream + Codable)
│       ├── AuthService.swift          (Firebase Auth wrapper)
│       └── Protocols/                 (Repository, DataSource)
│
├── Features/
│   ├── DashboardFeature/
│   │   ├── Domain/                    (MonthSummaryAggregator)
│   │   ├── Data/                      (DashboardRepository)
│   │   └── Presentation/
│   │       ├── DashboardViewModel.swift
│   │       ├── DashboardView.swift
│   │       └── Widgets/               (HeroCard, QuickStats, TrendChart, GoalsSummary)
│   │
│   ├── TransactionsFeature/
│   │   ├── Data/                      (IncomeRepository, ExpenseRepository)
│   │   └── Presentation/
│   │       ├── TransactionsViewModel.swift
│   │       ├── TransactionsView.swift
│   │       ├── AddTransactionSheet.swift
│   │       └── RecurringManagementView.swift
│   │
│   ├── SavingsFeature/
│   │   ├── Data/                      (SavingsRepository, SavingsGoalRepository)
│   │   └── Presentation/
│   │       ├── SavingsGoalsViewModel.swift
│   │       ├── GoalsView.swift
│   │       └── GoalDetailSheet.swift
│   │
│   ├── SimulationFeature/
│   │   ├── Domain/                    (SimulationCalculator)
│   │   ├── Data/                      (SimulationRepository)
│   │   └── Presentation/
│   │       ├── SimulationListViewModel.swift
│   │       ├── SimulationEditorViewModel.swift
│   │       ├── SimulationListView.swift
│   │       ├── SimulationEditorView.swift
│   │       ├── SimulationTemplateView.swift
│   │       ├── CashFlowProjectionView.swift
│   │       └── Widgets/               (AffordabilityGauge, AmortizationTable)
│   │
│   ├── BudgetFeature/
│   │   ├── Data/                      (BudgetLimitRepository)
│   │   └── Presentation/
│   │       ├── BudgetViewModel.swift
│   │       └── BudgetOverviewView.swift
│   │
│   ├── DebtFeature/
│   ├── AuthFeature/
│   ├── SettingsFeature/
│   ├── OnboardingFeature/
│   ├── AIAdvisorFeature/
│   └── FamilyFeature/
│
└── Extensions/
    ├── SavvyWidgets/                  ← WidgetKit target
    ├── SavvyWatch/                    ← watchOS target
    └── SavvyIntents/                  ← App Intents / Siri
```

### Dependency Graph (Strictly Acyclic)

```
SavvyApp → all Features
Features → SavvyFoundation, SavvyDesignSystem, SavvyNetworking
SavvyDesignSystem → SavvyFoundation (CurrencyFormatter, enums icin)
SavvyNetworking → SavvyFoundation (model types icin)
SavvyFoundation → (bag yok, sadece Foundation + Swift stdlib)
```

## Dependency Injection

`@Environment` + merkezi `Dependencies` container:

```swift
@Observable
final class Dependencies {
    let auth: AuthService
    let incomeRepo: any Repository<Income>
    let expenseRepo: any Repository<Expense>
    let savingsRepo: any Repository<Savings>
    let savingsGoalRepo: any Repository<SavingsGoal>
    let simulationRepo: any Repository<SimulationEntry>
    let budgetLimitRepo: any Repository<BudgetLimit>
    
    init(userId: String, firestore: Firestore) {
        self.auth = AuthService()
        self.incomeRepo = IncomeRepository(userId: userId, db: firestore)
        self.expenseRepo = ExpenseRepository(userId: userId, db: firestore)
        // ...
    }
}

// Root injection
@main
struct SavvyApp: App {
    @State private var dependencies = Dependencies(...)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
    }
}

// View consumption
struct DashboardView: View {
    @Environment(Dependencies.self) private var deps
    @State private var viewModel: DashboardViewModel
    
    init() {
        // ViewModel deps'ten inject edilir
    }
}
```

## Data Flow: Firestore → UI

```
Firestore snapshotListener
    ↓
FirestoreService<T>.watch() → AsyncStream<[T]>
    ↓
Repository.watchAll() → AsyncStream<[T]>
    ↓
ViewModel.startObserving() → for await items in repo.watchAll()
    ↓
@Observable property assignment → SwiftUI auto-invalidation
    ↓
View re-render (sadece degisen property'ler icin)
```

### Ornek ViewModel

```swift
@Observable
final class DashboardViewModel {
    // Published state
    private(set) var incomes: [Income] = []
    private(set) var expenses: [Expense] = []
    private(set) var savings: [Savings] = []
    private(set) var isLoading = true
    var selectedYearMonth: String = Date().toYearMonth()
    var includeSavingsInProjection = false
    
    // Computed (otomatik re-calculate)
    var monthSummary: MonthSummary? {
        MonthSummaryAggregator.buildSummary(
            incomes: incomes, expenses: expenses, savings: savings,
            yearMonth: selectedYearMonth
        )
    }
    
    var projections: [MonthSummary] {
        MonthSummaryAggregator.buildProjections(
            incomes: incomes, expenses: expenses, savings: savings,
            includeSavings: includeSavingsInProjection
        )
    }
    
    // Repositories
    private let incomeRepo: any Repository<Income>
    private let expenseRepo: any Repository<Expense>
    private let savingsRepo: any Repository<Savings>
    
    init(deps: Dependencies) {
        self.incomeRepo = deps.incomeRepo
        self.expenseRepo = deps.expenseRepo
        self.savingsRepo = deps.savingsRepo
    }
    
    func startObserving() async {
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                for await items in incomeRepo.watch() {
                    self.incomes = items
                }
            }
            group.addTask { [self] in
                for await items in expenseRepo.watch() {
                    self.expenses = items
                }
            }
            group.addTask { [self] in
                for await items in savingsRepo.watch() {
                    self.savings = items
                }
            }
        }
        isLoading = false
    }
}
```

## Navigation

### Tab Yapisi

```swift
enum AppTab: String, CaseIterable {
    case dashboard    // house.fill
    case transactions // list.bullet.rectangle.fill
    case simulation   // chart.line.uptrend.xyaxis
    case settings     // gearshape.fill
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardNavigationStack()
                .tag(AppTab.dashboard)
                .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }
            
            TransactionsNavigationStack()
                .tag(AppTab.transactions)
                .tabItem { Label("Islemler", systemImage: "list.bullet.rectangle.fill") }
            
            SimulationNavigationStack()
                .tag(AppTab.simulation)
                .tabItem { Label("Simulasyon", systemImage: "chart.line.uptrend.xyaxis") }
            
            SettingsNavigationStack()
                .tag(AppTab.settings)
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}
```

### Typed Navigation Paths

```swift
// Her tab'in kendi typed route'lari
enum DashboardRoute: Hashable {
    case monthDetail(yearMonth: String)
    case forecast
    case compare(initialMonth: String?)
}

enum TransactionsRoute: Hashable {
    case recurring
}

enum SimulationRoute: Hashable {
    case templatePicker
    case editor(simulationId: String)
    case cashflow(simulationId: String)
    case compare
}

// Kullanim
struct DashboardNavigationStack: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            DashboardView()
                .navigationDestination(for: DashboardRoute.self) { route in
                    switch route {
                    case .monthDetail(let ym): MonthDetailView(yearMonth: ym)
                    case .forecast: CashFlowForecastView()
                    case .compare(let m): MonthCompareView(initialMonth: m)
                    }
                }
        }
    }
}
```

### Auth Gate

```swift
@main
struct SavvyApp: App {
    @State private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    MainTabView()
                        .environment(Dependencies(userId: authVM.userId!))
                } else {
                    AuthFlowView()
                }
            }
            .environment(authVM)
        }
    }
}
```

### Sheet Pattern

```swift
// Form sheets: .sheet + presentationDetents
struct TransactionsView: View {
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var editingTransaction: (any Identifiable)?
    
    var body: some View {
        // ...
        .sheet(isPresented: $showAddIncome) {
            AddIncomeSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
```

## iOS 17+ Minimum Target — Neden?

| Ozellik | iOS Versiyonu | Kullanim |
|---------|--------------|----------|
| @Observable macro | iOS 17 | Tum ViewModel'lar |
| contentTransition(.numericText()) | iOS 17 | Para animasyonlari |
| sensoryFeedback modifier | iOS 17 | Contextual haptics |
| TipKit | iOS 17 | Onboarding ipuclari |
| presentationSizing | iOS 17 | Sheet boyutlandirma |
| ScrollView paging | iOS 17 | Horizontal scroll |
| #Preview macro | iOS 17 | Preview-driven development |
| Swift Charts scrolling | iOS 17 | Chart scroll |
| MeshGradient | iOS 18 | Wallet card (if #available) |

**iOS 17 Turkiye Adoption**: 2026 itibariyla iOS 17+ kullanim orani %90+ beklendiginden guvenli hedef.
