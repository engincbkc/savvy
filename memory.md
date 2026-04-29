# SAVVY - Proje Hafıza Dosyası

> Son güncelleme: 26 Nisan 2026

## Proje Özeti

**SAVVY** — Türkiye pazarı için kişisel bütçe yönetimi ve finansal simülasyon mobil uygulaması.

- **Platform:** Flutter 3.41.4 (iOS + Android)
- **State Management:** Riverpod 3.x (AsyncNotifier + riverpod_generator v4)
- **Backend:** Firebase (Firestore + Auth) — Project ID: `savvy-cffb8`
- **AI:** Google Gemini API (gemini-1.5-flash) — henüz aktif değil
- **Mimari:** Feature-first modüler yapı

---

## Teknik Stack

| Katman | Teknoloji |
|--------|-----------|
| Framework | Flutter 3.41.4, Dart 3.11.1 |
| State | Riverpod 3.x, riverpod_generator v4 |
| Backend | Firebase Firestore + Auth |
| Navigation | go_router (shell routes + auth guard) |
| Models | freezed 3.x (abstract class) + json_serializable |
| Charts | fl_chart |
| Icons | lucide_icons |
| Fonts | Inter (Google Fonts) |

---

## Klasör Yapısı

```
lib/
├── core/
│   ├── constants/
│   │   └── financial_enums.dart       # Tüm enumlar (kategori, tip, durum)
│   ├── data/
│   │   └── base_repository.dart       # Repository base class
│   ├── design/
│   │   ├── app_theme.dart             # Light/Dark tema
│   │   └── tokens/
│   │       ├── app_colors.dart        # Semantik renkler
│   │       ├── savvy_colors.dart      # ThemeExtension
│   │       ├── app_typography.dart    # Tipografi sistemi
│   │       ├── app_spacing.dart       # 4px grid spacing
│   │       ├── app_radius.dart        # Border radius
│   │       ├── app_shadow.dart        # Gölgeler
│   │       └── app_animation.dart     # Animasyon token'ları
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_mapper.dart
│   ├── navigation/
│   │   ├── app_router.dart            # GoRouter config + auth guard
│   │   └── app_shell.dart             # Bottom nav shell
│   ├── providers/
│   │   ├── firebase_providers.dart    # Firebase instance'lar
│   │   ├── repository_providers.dart  # Repository factory'ler
│   │   ├── theme_provider.dart        # Tema state
│   │   └── wallet_color_provider.dart
│   └── utils/
│       ├── financial_calculator.dart  # TÜM HESAPLAMALAR BURADA (BL-001)
│       ├── currency_formatter.dart    # Para formatı (BL-005)
│       ├── transaction_validator.dart # Validasyon
│       └── year_month_helper.dart     # Tarih yardımcıları
│
├── features/
│   ├── auth/                          # Giriş/Kayıt/Şifre sıfırlama
│   ├── dashboard/                     # Ana ekran + özet kartları
│   ├── transactions/                  # Gelir/Gider CRUD
│   ├── savings/                       # Birikim takibi
│   ├── savings_goals/                 # Hedef yönetimi
│   ├── simulation/                    # Finansal simülasyon
│   ├── planned_changes/               # Planlı değişiklikler
│   ├── budget/                        # Bütçe limitleri
│   ├── debt/                          # Borç takibi
│   ├── settings/                      # Ayarlar
│   ├── import/                        # CSV import
│   ├── notifications/                 # Bildirimler (placeholder)
│   ├── onboarding/                    # İlk kullanım
│   ├── family/                        # Aile bütçesi (placeholder)
│   └── ai_advisor/                    # AI danışman (placeholder)
│
├── shared/widgets/                    # Paylaşılan widget'lar
│   ├── financial_card.dart
│   ├── transaction_tile.dart
│   ├── loading_shimmer.dart
│   ├── empty_state.dart
│   ├── fab_radial_menu.dart
│   ├── collapsible_section.dart
│   ├── portfolio_table.dart
│   └── salary_breakdown_panel.dart
│
├── firebase_options.dart
└── main.dart
```

---

## Veri Modelleri (Freezed)

### Income (Gelir)
```dart
- id, amount, category (IncomeCategory)
- person?, source?, date, note?
- isRecurring, recurringEndDate?
- isGross (brüt maaş için)
- monthlyOverrides (ay bazlı override)
- isSettled, settledMonths (ödeme takibi)
- isDeleted, createdAt
```

### Expense (Gider)
```dart
- id, amount, category (ExpenseCategory)
- expenseType, subcategory?, person?
- date, note?
- isRecurring, recurringEndDate?
- monthlyOverrides
- isSettled, settledMonths
- isDeleted, createdAt
```

### Savings (Birikim)
```dart
- id, amount, title?
- category (SavingsCategory)
- goalId?, note?, date
- status (active/withdrawn/completed)
- isDeleted, createdAt
```

### SimulationChange (Sealed Union)
```dart
- credit()      → Kredi simülasyonu
- housing()     → Konut kredisi
- car()         → Araç kredisi
- rentChange()  → Kira değişikliği
- salaryChange()→ Maaş değişikliği
- income()      → Gelir ekleme
- expense()     → Gider ekleme
- investment()  → Yatırım
```

---

## Demir Kurallar

| Kod | Kural |
|-----|-------|
| BL-001 | Tüm hesaplamalar `FinancialCalculator` sınıfında. UI hesaplama yapmaz. |
| BL-002 | Hardcoded renk/boyut/font yasak. Token kullan. |
| BL-003 | Spinner yerine shimmer skeleton kullan. |
| BL-004 | Silme = soft-delete (`isDeleted: true`). Hard delete yok. |
| BL-005 | Para formatı `CurrencyFormatter` ile. Raw double UI'a geçmez. |
| BL-006 | Her işlem max 3 tap. |
| BL-007 | Mock data/mock mode yok. Gerçek Firebase. |

---

## Riverpod Provider İsimlendirme (v4)

```dart
// Doğru kullanım:
AuthNotifier class → authProvider (NOT authNotifierProvider)
TransactionFormNotifier → transactionFormProvider

// AsyncValue kullanımı:
ref.watch(provider).value  // .valueOrNull yok (riverpod 3.2+)

// DropdownButtonFormField:
initialValue: ... // value: deprecated
```

---

## Firebase Yapısı

```
users/
  {uid}/
    incomes/          → Income documents
    expenses/         → Expense documents
    savings/          → Savings documents
    savings_goals/    → SavingsGoal documents
    simulations/      → SimulationEntry documents
    budget_limits/    → BudgetLimit documents
    planned_changes/  → PlannedChange documents
```

---

## FinancialCalculator Özeti

### Temel Hesaplamalar
- `netBalance()` — Gelir - Gider
- `expenseRatio()` — Gider/Gelir oranı
- `savingsRate()` — Birikim/Gelir oranı
- `financialHealthScore()` — 0-100 sağlık puanı

### Maaş Hesaplamaları (2026 Türkiye)
- Brüt → Net dönüşümü
- SGK (%14), İşsizlik (%1)
- Gelir vergisi (kademeli: %15-%40)
- Damga vergisi (%0.759)
- Asgari ücret istisnası
- 12 aylık kümülatif hesaplama

### Kredi Hesaplamaları
- `monthlyLoanPayment()` — Aylık taksit
- `totalInterest()` — Toplam faiz
- KKDF + BSMV vergisi (%30)
- `loanAffordability()` — Karşılanabilirlik durumu

---

## Tamamlanan Özellikler

### Faz 1 ✓
- [x] Auth (Email, Google, Apple)
- [x] Dashboard + özet kartları
- [x] Gelir/Gider CRUD
- [x] Birikim takibi
- [x] Tekrarlayan işlemler
- [x] Brüt maaş desteği
- [x] Simülasyon motoru
- [x] Ayarlar ekranı
- [x] Light/Dark tema
- [x] Aylık detay dağılımı
- [x] isSettled takibi

### UI/UX İyileştirmeleri ✓
- [x] Compact AmountInputField
- [x] Tutar maskeleme (24000 → 24.000)
- [x] Edit sheet scroll düzeltmesi
- [x] Birikim formu sadeleştirme (kategori kaldırıldı)
- [x] Swipe actions (Düzenle/Sil)
- [x] Detay popup kaldırıldı

---

## Test Durumu

- **9/9 test passing**
- `flutter analyze` → 0 hata
- FinancialCalculator ve Validator testleri mevcut

---

## Komutlar

```bash
# Analiz
flutter analyze

# Test
flutter test

# Build runner (freezed modeller)
dart run build_runner build --delete-conflicting-outputs

# Firebase config
~/.pub-cache/bin/flutterfire configure --project=savvy-cffb8

# Run
flutter run
```

---

## Notlar

- Firebase projesi: `savvy-cffb8` (Spark plan)
- Hesap: engincubukcuogluu@gmail.com
- `firebase_options.dart` placeholder değerler içeriyor, `flutterfire configure` çalıştırılmalı
