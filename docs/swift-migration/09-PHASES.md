# 09 — Implementasyon Fazlari

## Faz 1: Foundation (Hafta 1-2)

**Hedef**: Core altyapi — build edilebilir, test edilebilir, UI yok.

### Hafta 1

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 1.1 | Xcode project olustur (iOS 17+, Swift 6) | `Savvy.xcodeproj` | — |
| 1.2 | SPM paketlerini olustur | `Packages/Core/SavvyFoundation/` | — |
| 1.3 | Design tokens: Colors (Asset Catalog) | `Assets.xcassets/Colors/` | — |
| 1.4 | Design tokens: Typography, Spacing, Radius, Shadow, Animation | `SavvyDesignSystem/Tokens/` | 1.3 |
| 1.5 | Tum enum'lari port et (SF Symbol mapping dahil) | `SavvyFoundation/Enums/` | — |
| 1.6 | Tum modelleri port et (Income, Expense, Savings, etc.) | `SavvyFoundation/Models/` | 1.5 |
| 1.7 | CurrencyFormatter port et | `SavvyFoundation/Formatters/` | — |
| 1.8 | TransactionValidator port et | `SavvyFoundation/Validators/` | 1.7 |
| 1.9 | YearMonthHelper / Date extensions port et | `SavvyFoundation/Extensions/` | — |

### Hafta 2

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 1.10 | FinancialCalculator port et (core summary + health score) | `SavvyFoundation/Calculator/` | 1.6 |
| 1.11 | FinancialCalculator port et (loan, affordability) | `SavvyFoundation/Calculator/` | 1.10 |
| 1.12 | FinancialCalculator port et (gross-to-net salary 2026) | `SavvyFoundation/Calculator/` | 1.10 |
| 1.13 | SalaryCache actor olustur | `SavvyFoundation/Calculator/` | 1.12 |
| 1.14 | Unit testler yaz (9 mevcut + 20+ yeni) | `SavvyFoundationTests/` | 1.10-1.13 |
| 1.15 | Firebase SDK entegre et (SPM) | `SavvyNetworking/` | — |
| 1.16 | Generic FirestoreService yaz | `SavvyNetworking/` | 1.6, 1.15 |
| 1.17 | AuthService yaz | `SavvyNetworking/` | 1.15 |
| 1.18 | Repository protocol + concrete repo'lar | `SavvyNetworking/` | 1.16 |
| 1.19 | Dependencies container olustur | `SavvyApp/` | 1.17, 1.18 |

**Cikti**: Derlenebilir foundation, %100 test kapsamli calculator, calisan Firebase baglantisi.

---

## Faz 2: Core Screens (Hafta 3-4)

**Hedef**: Temel ekranlar calisiyor — auth, dashboard, transactions, form sheets.

### Hafta 3

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 2.1 | SavvyApp entry point + auth gate | `SavvyApp.swift` | 1.19 |
| 2.2 | LoginView (Sign in with Apple + Google + Email) | `AuthFeature/` | 1.17 |
| 2.3 | RegisterView | `AuthFeature/` | 1.17 |
| 2.4 | ForgotPasswordView | `AuthFeature/` | 1.17 |
| 2.5 | MainTabView (4 tab + glassmorphism bar) | `SavvyApp/` | 2.1 |
| 2.6 | Shared components: SavvyCard, SavvyShimmer, EmptyState | `SavvyDesignSystem/Components/` | 1.4 |
| 2.7 | TransactionRow widget | `SavvyDesignSystem/Components/` | 2.6 |
| 2.8 | SavvyHeroNumber (contentTransition) | `SavvyDesignSystem/Components/` | 1.4 |
| 2.9 | StaggeredEntry modifier | `SavvyDesignSystem/Modifiers/` | 1.4 |

### Hafta 4

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 2.10 | DashboardViewModel | `DashboardFeature/` | 1.18, 1.19 |
| 2.11 | MonthSummaryAggregator port et | `DashboardFeature/Domain/` | 1.10 |
| 2.12 | DashboardView (greeting + simplified hero + quick stats) | `DashboardFeature/` | 2.10, 2.8 |
| 2.13 | TransactionsViewModel | `TransactionsFeature/` | 1.18 |
| 2.14 | TransactionsView (segmented picker + list + swipe actions) | `TransactionsFeature/` | 2.13, 2.7 |
| 2.15 | AddIncomeSheet (Form + presentationDetents) | `TransactionsFeature/` | 2.13 |
| 2.16 | AddExpenseSheet | `TransactionsFeature/` | 2.13 |
| 2.17 | AddSavingsSheet | `TransactionsFeature/` | 2.13 |
| 2.18 | SettingsView (native Form) | `SettingsFeature/` | 2.1 |
| 2.19 | Dark mode toggle (AppStorage) | `SettingsFeature/` | 2.18 |

**Cikti**: Login → Dashboard → Transactions → Settings tam calisiyor. CRUD islemleri Firestore ile aktif.

---

## Faz 3: Advanced Features (Hafta 5-6)

**Hedef**: Premium UI/UX — wallet animasyonlari, charts, simulasyon, butce, hedefler.

### Hafta 5

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 3.1 | WalletHeroCard (gradient + drag + spring animation) | `DashboardFeature/Widgets/` | 2.12 |
| 3.2 | TrendChart (Swift Charts, scrollable, interactive) | `SavvyDesignSystem/Charts/` | 1.4 |
| 3.3 | GoalsSummary widget | `DashboardFeature/Widgets/` | 2.12 |
| 3.4 | MonthlyFlowTable (horizontal scroll grid) | `DashboardFeature/Widgets/` | 2.12 |
| 3.5 | Future projections provider | `DashboardFeature/` | 2.11 |
| 3.6 | MonthDetailView | `DashboardFeature/` | 2.10 |
| 3.7 | CashFlowForecastView | `DashboardFeature/` | 3.5 |
| 3.8 | MonthCompareView | `DashboardFeature/` | 2.10 |

### Hafta 6

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 3.9 | SimulationCalculator port et | `SimulationFeature/Domain/` | 1.10 |
| 3.10 | SimulationListViewModel + View | `SimulationFeature/` | 1.18 |
| 3.11 | SimulationTemplateView | `SimulationFeature/` | 3.10 |
| 3.12 | SimulationEditorViewModel + View | `SimulationFeature/` | 3.9 |
| 3.13 | CashFlowProjectionView | `SimulationFeature/` | 3.9 |
| 3.14 | AffordabilityGauge + AmortizationTable | `SimulationFeature/Widgets/` | 3.9 |
| 3.15 | BudgetViewModel + BudgetOverviewView | `BudgetFeature/` | 1.18 |
| 3.16 | SavingsGoalsViewModel + GoalsView + GoalDetailSheet | `SavingsFeature/` | 1.18 |
| 3.17 | RecurringManagementView | `TransactionsFeature/` | 2.13 |
| 3.18 | Gross-to-net salary UI (Income form icinde) | `TransactionsFeature/` | 1.12, 2.15 |
| 3.19 | DebtDashboardView | `DebtFeature/` | 1.10 |

**Cikti**: Tum ozellikler calisiyor. Premium animasyonlar ve charts aktif.

---

## Faz 4: iOS Exclusive (Hafta 7-8)

**Hedef**: Flutter'da olmayan native iOS ozellikleri.

### Hafta 7

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 4.1 | App Group setup | Xcode Capabilities | — |
| 4.2 | Shared data layer (UserDefaults + App Group) | `SavvyApp/` | 4.1 |
| 4.3 | WidgetKit: Small balance widget | `SavvyWidgets/` | 4.2 |
| 4.4 | WidgetKit: Medium monthly overview widget | `SavvyWidgets/` | 4.2 |
| 4.5 | App Intents: AddExpenseIntent | `SavvyIntents/` | 1.18 |
| 4.6 | App Intents: CheckBudgetIntent | `SavvyIntents/` | 1.18 |
| 4.7 | SavvyShortcutsProvider (Siri phrases) | `SavvyIntents/` | 4.5, 4.6 |
| 4.8 | Spotlight indexing (CSSearchableItem) | `SavvyApp/` | — |

### Hafta 8

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 4.9 | Live Activities: BudgetActivity | `SavvyApp/` | 4.2 |
| 4.10 | Live Activities: Dynamic Island UI | `SavvyApp/` | 4.9 |
| 4.11 | Smart Notifications: BGAppRefreshTask | `SavvyApp/` | — |
| 4.12 | Notification types: budget warning, weekly digest | `SavvyApp/` | 4.11 |
| 4.13 | watchOS: QuickExpenseView | `SavvyWatch/` | — |
| 4.14 | watchOS: Budget complication | `SavvyWatch/` | 4.13 |
| 4.15 | Watch Connectivity sync | `SavvyWatch/` | 4.13 |
| 4.16 | TaxReportView | `SettingsFeature/` | 1.12 |
| 4.17 | CSVImportView | `SettingsFeature/` | 1.18 |

**Cikti**: Widgets, Siri, Live Activities, Watch calisiyor.

---

## Faz 5: Polish & Launch (Hafta 9-10)

**Hedef**: Kalite guvence, performans, erisilebilirlik, App Store.

### Hafta 9

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 5.1 | Snapshot testler (tum component'lar, light+dark) | `Tests/` | — |
| 5.2 | UI testler (login, add transaction, navigation) | `SavvyUITests/` | — |
| 5.3 | Accessibility audit: VoiceOver | Tum Views | — |
| 5.4 | Accessibility: Dynamic Type (XXL) | Tum Views | — |
| 5.5 | Accessibility: Reduce Motion | Animasyonlar | — |
| 5.6 | Performance profiling (Instruments) | — | — |
| 5.7 | Memory leak audit (Instruments) | — | — |

### Hafta 10

| # | Gorev | Dosya/Modul | Bagimlilik |
|---|-------|------------|------------|
| 5.8 | App icon + launch screen | `Assets.xcassets/` | — |
| 5.9 | Onboarding flow | `OnboardingFeature/` | — |
| 5.10 | Error handling polish (Turkish messages) | Tum ViewModels | — |
| 5.11 | App Store metadata (screenshots, description, keywords) | — | — |
| 5.12 | TestFlight beta test | — | 5.1-5.7 |
| 5.13 | App Store submission | — | 5.12 |
| 5.14 | Large WidgetKit widget | `SavvyWidgets/` | 4.3 |
| 5.15 | AI Advisor temel entegrasyon (Gemini) | `AIAdvisorFeature/` | 1.18 |

**Cikti**: App Store'da yayinda.

---

## Kritik Yol (Critical Path)

```
Faz 1: Models + Calculator + Firebase
         ↓
Faz 2: Auth + Dashboard + Transactions (MVP)
         ↓
Faz 3: Charts + Simulation + Budget + Goals
         ↓
Faz 4: Widgets + Siri + Watch (parallel)
         ↓
Faz 5: Test + Polish + Launch
```

MVP (Minimum Viable Product) = Faz 2 sonu:
- Login/register calisiyor
- Dashboard ozet goruyor
- Gelir/gider/birikim CRUD calisiyor
- Temel navigasyon calisiyor

---

## Risk ve Mitigasyon

| Risk | Etki | Mitigasyon |
|------|------|------------|
| Gross-to-net hesaplama hatasi | Yuksek | Verginet.net ile ay ay dogrulama testi |
| SimulationCalculator karmasikligi | Orta | Flutter kodundan birebir port, ayni test case'ler |
| Firebase Codable uyumsuzlugu | Dusuk | Custom CodingKeys ile handle |
| watchOS sync sorunlari | Dusuk | Watch deferred (Faz 4 sonu) |
| iOS 18 MeshGradient crash | Dusuk | `if #available` guard |
