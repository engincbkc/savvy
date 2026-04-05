# Savvy — Kisisel Butce Yonetimi & Finansal Simulasyon

## Proje Ozeti
Flutter 3.41+ cross-platform mobil uygulama (iOS + Android).
Turkiye pazari icin kisisel gelir/gider/birikim takibi ve finansal simulasyon araci.

## Teknik Stack
- **Flutter** 3.41.4 (Dart 3.11.1)
- **State**: Riverpod 3.x (AsyncNotifier pattern, riverpod_generator v4)
- **Backend**: Firebase (Firestore + Auth) — Project ID: `savvy-cffb8`
- **AI**: Google Gemini API (gemini-1.5-flash)
- **Navigation**: go_router (shell route + auth redirect guard)
- **Models**: freezed 3.x (`abstract class` keyword required) + json_serializable
- **Charts**: fl_chart
- **Icons**: lucide_icons
- **Mimari**: Feature-first (`lib/features/...`)

## Demir Kurallar
- **BL-001**: Tum hesaplamalar `FinancialCalculator` sinifinda. UI hesaplama yapmaz.
- **DS**: Hardcoded renk/boyut/font yasak. `AppColors` / `AppTypography` / `AppSpacing` kullan.
- **UX**: Spinner kullanma, shimmer skeleton kullan. Her islem max 3 tap.
- **DB**: Silme = soft-delete (`isDeleted: true`). Hard delete yok.
- **FMT**: Para → `CurrencyFormatter.format()`. Raw double asla UI'a gecmez.
- **TEST**: `FinancialCalculator` ve Validator'in her public metodu test edilir.
- **NO MOCK**: Mock data veya mock mode kullanma. Gercek Firebase baglantisi kullan.

## Riverpod Generator v4 Isimlendirme
Riverpod generator v4, provider isimlerini farkli uretiyor:
- `AuthNotifier` class → `authProvider` (NOT `authNotifierProvider`)
- `TransactionFormNotifier` class → `transactionFormProvider`
- `AsyncValue` uzerinde `.value` kullan (`.valueOrNull` yok, riverpod 3.2+)
- `DropdownButtonFormField` → `initialValue` kullan (`value` deprecated Flutter 3.33+)

## Firebase Durumu
- Firebase projesi olusturuldu: `savvy-cffb8` (Spark plan)
- Hesap: engincubukcuogluu@gmail.com
- `firebase_options.dart` PLACEHOLDER degerler iceriyor
- **Yapilmasi gereken:**
  1. Firebase Console'da Authentication > Email/Password aktif et
  2. Firebase Console'da Cloud Firestore > Create database (test mode)
  3. `~/.pub-cache/bin/flutterfire configure --project=savvy-cffb8` calistir
  4. Simulator/cihazda `flutter run`

## Tamamlanan Isler
- Core: design tokens, theme (light+dark), financial_calculator, currency_formatter, transaction_validator, year_month_helper
- Models: Income, Expense, Savings, SavingsGoal, MonthSummary (freezed 3.x)
- Repos: IncomeRepository, ExpenseRepository, SavingsRepository (Firestore, soft-delete)
- Providers: firebase_providers, repository_providers, dashboard_provider, auth_provider, transaction_form_provider
- Auth: LoginScreen, RegisterScreen, ForgotPasswordScreen + auth guard in router
- Dashboard: NetBalanceHero (gradient, count-up), 3 FinancialCards, recent transactions (real Firestore streams)
- Forms: AddIncomeSheet, AddExpenseSheet, AddSavingsSheet (bottom sheets via FAB)
- Shared: FinancialCard, TransactionTile, SavvyShimmer, EmptyState, FabRadialMenu
- Navigation: GoRouter shell route + auth redirect
- Simulation: calculator logic (credit, rentChange, car) — UI placeholder
- Settings: profile, dark mode toggle, export, about, logout tiles

## Yapilacaklar
> Detayli yol haritasi: `doc/ROADMAP.md`

### Faz 1 (Oncelik: Yuksek)
- Periyodik islem yonetim ekrani (tum tekrar eden gelir/giderleri tek ekranda gor/yonet)
- Gelir/gider adim degisikligi (maas artisi, kira zammi projeksiyona yansitma)
- Borc takip modulu (taksit takvimi, "ne zaman borcsuz" projeksiyonu)
- Butce/kategori limitleri (aylik harcama limiti + uyari)

### Faz 2 (Oncelik: Orta)
- Nakit akis tahmini (12 ay forward view, milestone'lar)
- Bildirimler & hatirlaticilar
- Ay vs ay karsilastirma
- CSV/Excel import
- Vergi raporu / yillik ozet

### Faz 3 (Oncelik: Dusuk)
- AI Advisor (Gemini entegrasyonu)
- Aile/coklu kisi destegi
- Hedef bazli akilli planlama
- Hizli giris & home screen widget

## Klasor Yapisi
```
lib/
├── core/
│   ├── constants/financial_enums.dart
│   ├── data/base_repository.dart
│   ├── design/ (app_theme + tokens/)
│   ├── errors/ (app_exception, error_mapper)
│   ├── navigation/ (app_router, app_shell)
│   ├── providers/ (firebase_providers, repository_providers)
│   └── utils/ (financial_calculator, currency_formatter, transaction_validator, year_month_helper)
├── features/
│   ├── auth/presentation/ (providers/auth_provider, screens/login+register+forgot_password)
│   ├── dashboard/ (models/month_summary, providers/dashboard_provider, screens/dashboard_screen)
│   ├── transactions/ (data/repos, models/income+expense, providers/transaction_form_provider, screens/add_*_sheet+transactions_screen)
│   ├── savings/ (data/savings_repo, models/savings)
│   ├── savings_goals/ (models/savings_goal)
│   ├── simulation/ (domain/simulation_calculator, screens/simulation_screen)
│   ├── ai_advisor/ [not yet implemented]
│   └── settings/ (settings_screen)
├── shared/widgets/ (financial_card, transaction_tile, loading_shimmer, empty_state, fab_radial_menu)
├── firebase_options.dart [PLACEHOLDER]
└── main.dart
```

## Testler
- 9/9 passing (FinancialCalculator: netBalance, savingsRate, monthlyLoanPayment, financialHealthScore)
- `flutter analyze` → 0 issues

## Komutlar
```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
~/.pub-cache/bin/flutterfire configure --project=savvy-cffb8
```
