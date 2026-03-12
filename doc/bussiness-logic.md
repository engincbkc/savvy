# Savvy — Business Logic & Veri Modeli
## BL v1.0 | Hesaplama, Kural & Mimari Standartları

> **AI Kullanım Notu:** Herhangi bir hesaplama, veri işleme veya iş kuralı kodu yazarken
> bu dosyayı referans al. Business logic **sadece** burada tanımlanan sınıf ve
> kurallara uygun yazılır. UI katmanında hesaplama yapılmaz.

---

## 📋 İçindekiler

1. [Mimari Prensipleri](#1-mimari-prensipleri)
2. [Temel Finansal Alanlar](#2-temel-finansal-alanlar)
3. [Finansal Hesaplama Motoru](#3-finansal-hesaplama-motoru)
4. [İş Kuralları (BL Kodları)](#4-i̇ş-kuralları-bl-kodları)
5. [Veri Modelleri](#5-veri-modelleri)
6. [Firestore Şeması](#6-firestore-şeması)
7. [State Yönetimi Standartları](#7-state-yönetimi-standartları)
8. [Repository Katmanı](#8-repository-katmanı)
9. [Validasyon Kuralları](#9-validasyon-kuralları)
10. [Para Formatlama Standartları](#10-para-formatlama-standartları)
11. [Hata Yönetimi](#11-hata-yönetimi)
12. [Simülasyon Motorları](#12-simülasyon-motorları)
13. [AI Analiz Motoru](#13-ai-analiz-motoru)
14. [Test Standartları](#14-test-standartları)

---

## 1. Mimari Prensipleri

### 1.1 Katman Mimarisi

```
┌──────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                  │
│  Screens → Widgets                                   │
│  Kural: Görüntüler. Hesaplama yapmaz. Format uygular │
│  Dependency: Domain katmanına bağlı                  │
└────────────────────────┬─────────────────────────────┘
                         │ watch() / read()
┌────────────────────────▼─────────────────────────────┐
│                   DOMAIN LAYER                       │
│  Providers (Riverpod) → Calculators → Validators     │
│  Kural: İş kuralları burada. I/O işlemi yapmaz.      │
│  Dependency: Data katmanına bağlı                    │
└────────────────────────┬─────────────────────────────┘
                         │ call()
┌────────────────────────▼─────────────────────────────┐
│                    DATA LAYER                        │
│  Repositories → DataSources (Firestore / Hive)       │
│  Kural: Sadece CRUD. İş kuralı içermez.              │
│  Dependency: Dış servisler (Firebase, Gemini)        │
└──────────────────────────────────────────────────────┘
```

### 1.2 Bağımlılık Yönü

```
Presentation → Domain → Data → External Services

Ters yön yasak:
  ❌ Data katmanı Provider import edemez
  ❌ Repository Calculator çağıramaz
  ❌ Widget doğrudan Firestore'a yazamaz
```

### 1.3 Sorumluluk Dağılımı

```
FinancialCalculator  → Tüm matematiksel hesaplamalar
TransactionValidator → Kullanıcı girişi doğrulama
CurrencyFormatter    → Para birimi formatlama
Repository           → Firestore CRUD operasyonları
Provider (Notifier)  → State tutma + use-case orchestration
Screen               → Layout + Provider watch + formatlanmış değer gösterimi
Widget               → Reusable UI bileşeni, iş kuralı bilmez
```

---

## 2. Temel Finansal Alanlar

### 2.1 Alan Tanımları ve Sınırları

```
GELİR (Income)
  Tanım    : Herhangi bir kaynaktan gelen para girişi
  Firestore: users/{uid}/incomes/{id}
  Enum     : IncomeCategory
  Kural    : Asla gider veya birikim olarak sınıflandırılamaz
  İşaret   : Her zaman pozitif double (negatif gelir girilmez)

GİDER (Expense)
  Tanım    : Harcama, ödeme veya transfer çıkışı
  Firestore: users/{uid}/expenses/{id}
  Enum     : ExpenseCategory, ExpenseType
  Kural    : Birikim gider değildir — ayrı koleksiyona yazılır
  İşaret   : Her zaman pozitif double (UI'da - ile gösterilir)

BİRİKİM (Savings)
  Tanım    : Gelirden bilinçli ayrılan, harcanmayan para
  Firestore: users/{uid}/savings/{id}
  Enum     : SavingsCategory, SavingsStatus
  Kural    : Net bakiye hesabında ayrı çıkarılır, gider toplamına eklenmez
  İşaret   : Her zaman pozitif double

TEMEL FORMÜL:
  Net Bakiye      = Gelir − Gider − Birikim
  Net (Devir ile) = Net Bakiye + Önceki Ay Net (Devir ile)
  Gider Oranı     = Gider / Gelir
  Birikim Oranı   = Birikim / Gelir
  Hedef Birikim   = Gelir × 0.20 (varsayılan %20 kural)
```

### 2.2 Kategori Enum'ları

```dart
// lib/core/constants/financial_enums.dart

enum IncomeCategory {
  salary,       // Maaş
  sideJob,      // Ek İş
  freelance,    // Freelance
  transfer,     // Kişiden Gelen Transfer
  debtCollection, // Verilen Borcun Tahsilatı
  refund,       // İade
  rentalIncome, // Kira Geliri
  investment,   // Yatırım Getirisi
  other;        // Diğer

  String get label => switch (this) {
    salary        => 'Maaş',
    sideJob       => 'Ek İş',
    freelance     => 'Freelance',
    transfer      => 'Transfer',
    debtCollection => 'Borç Tahsilatı',
    refund        => 'İade',
    rentalIncome  => 'Kira Geliri',
    investment    => 'Yatırım',
    other         => 'Diğer',
  };
}

enum ExpenseCategory {
  rent, market, transport, bills, creditCard,
  loanInstallment, health, education, food,
  entertainment, clothing, subscription,
  advertising, businessTool, tax, other;
}

enum ExpenseType {
  fixed,         // Sabit — her ay aynı (kira, taksit)
  variable,      // Değişken — her ay farklı (market, ulaşım)
  discretionary, // İsteğe bağlı (eğlence, giyim)
  business;      // İş/yatırım gideri (reklam)
}

enum SavingsCategory {
  emergency,   // Acil durum fonu
  goal,        // Hedef birikimi
  gold,        // Altın
  forex,       // Döviz
  stock,       // Hisse senedi
  fund,        // Yatırım fonu
  deposit,     // Vadeli mevduat
  retirement,  // Emeklilik
  other;
}

enum SavingsStatus {
  active,    // Aktif birikim
  withdrawn, // Çekildi (gelir olarak kaydedilir)
  completed; // Hedef tamamlandı
}
```

---

## 3. Finansal Hesaplama Motoru

```dart
// lib/core/utils/financial_calculator.dart
// TÜM hesaplamalar bu sınıfta — başka yerde hesaplama yapılmaz

import 'dart:math';

class FinancialCalculator {

  // ─── Temel Özet Hesaplamaları ──────────────────────────────────

  /// Devirsiz net bakiye
  static double netBalance({
    required double totalIncome,
    required double totalExpense,
    required double totalSavings,
  }) {
    assert(totalIncome >= 0, 'Gelir negatif olamaz');
    assert(totalExpense >= 0, 'Gider negatif olamaz');
    assert(totalSavings >= 0, 'Birikim negatif olamaz');
    return totalIncome - totalExpense - totalSavings;
  }

  /// Devir dahil net bakiye
  static double netWithCarryOver({
    required double netBalance,
    required double carryOver,
  }) => netBalance + carryOver;

  /// Gider oranı (0.0 – 1.0+)
  static double expenseRatio({
    required double totalExpense,
    required double totalIncome,
  }) => totalIncome > 0 ? totalExpense / totalIncome : 0.0;

  /// Birikim oranı (0.0 – 1.0)
  static double savingsRate({
    required double totalSavings,
    required double totalIncome,
  }) => totalIncome > 0 ? totalSavings / totalIncome : 0.0;

  /// Hedef birikim tutarı (%20 kuralı)
  static double targetSavings({
    required double totalIncome,
    double targetRate = 0.20,
  }) => totalIncome * targetRate;

  // ─── Finansal Sağlık Skoru (0–100) ────────────────────────────

  static int financialHealthScore({
    required double savingsRate,         // 0.0–1.0
    required double expenseRatio,        // 0.0–1.0+
    required double netBalance,          // Pozitif/negatif
    required double emergencyFundMonths, // Aylık gidere göre ay sayısı
  }) {
    int score = 0;

    // Birikim oranı (max 35 puan)
    if (savingsRate >= 0.25)      score += 35;
    else if (savingsRate >= 0.20) score += 28;
    else if (savingsRate >= 0.15) score += 20;
    else if (savingsRate >= 0.10) score += 12;
    else if (savingsRate >= 0.05) score += 5;

    // Gider oranı (max 30 puan)
    if (expenseRatio <= 0.50)      score += 30;
    else if (expenseRatio <= 0.60) score += 25;
    else if (expenseRatio <= 0.70) score += 18;
    else if (expenseRatio <= 0.80) score += 10;
    else if (expenseRatio <= 0.90) score += 4;

    // Net bakiye (max 20 puan)
    if (netBalance > 0) score += 20;
    else if (netBalance == 0) score += 8;

    // Acil durum fonu (max 15 puan)
    if (emergencyFundMonths >= 6)      score += 15;
    else if (emergencyFundMonths >= 3) score += 10;
    else if (emergencyFundMonths >= 1) score += 5;

    return score.clamp(0, 100);
  }

  /// Sağlık skoru etiketi
  static String healthScoreLabel(int score) => switch (score) {
    >= 80 => 'Mükemmel',
    >= 65 => 'İyi',
    >= 50 => 'Orta',
    >= 35 => 'Dikkat',
    _     => 'Kritik',
  };

  // ─── Birikim Hedefi Hesaplamaları ─────────────────────────────

  /// Hedefe ulaşmak için kalan ay
  static int monthsToGoal({
    required double targetAmount,
    required double currentAmount,
    required double monthlySavings,
  }) {
    if (monthlySavings <= 0) return -1; // Ulaşılamaz
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlySavings).ceil();
  }

  /// Belirli sürede hedefe ulaşmak için gereken aylık birikim
  static double requiredMonthlySavings({
    required double targetAmount,
    required double currentAmount,
    required int monthsLeft,
  }) {
    if (monthsLeft <= 0) return double.infinity;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return remaining / monthsLeft;
  }

  /// Hedef tamamlanma yüzdesi
  static double goalProgress({
    required double targetAmount,
    required double currentAmount,
  }) {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // ─── Kredi / Taksit Hesaplamaları ─────────────────────────────

  /// Aylık taksit (eşit taksitli kredi — EMI)
  static double monthlyLoanPayment({
    required double principal,     // Anapara
    required double annualRate,    // Yıllık faiz oranı (örn: 0.45 = %45)
    required int termMonths,       // Vade (ay)
  }) {
    if (annualRate == 0) return principal / termMonths;
    final r = annualRate / 12;
    final n = termMonths;
    return principal * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  /// Toplam geri ödeme
  static double totalLoanPayment({
    required double monthlyPayment,
    required int termMonths,
  }) => monthlyPayment * termMonths;

  /// Toplam faiz
  static double totalInterest({
    required double totalPayment,
    required double principal,
  }) => totalPayment - principal;

  /// Kredinin karşılanabilirlik durumu
  static AffordabilityStatus loanAffordability({
    required double monthlyPayment,
    required double monthlyIncome,
  }) {
    final ratio = monthlyIncome > 0 ? monthlyPayment / monthlyIncome : 1.0;
    return switch (ratio) {
      < 0.25 => AffordabilityStatus.comfortable,
      < 0.35 => AffordabilityStatus.manageable,
      < 0.45 => AffordabilityStatus.tight,
      _      => AffordabilityStatus.risky,
    };
  }

  // ─── Projeksiyon Hesaplamaları ─────────────────────────────────

  /// N ay sonraki kümülatif birikim (sabit aylık birikim varsayımı)
  static double projectedSavings({
    required double currentSavings,
    required double monthlySavings,
    required int months,
  }) => currentSavings + (monthlySavings * months);

  /// Maaş artışının bütçeye etkisi
  static BudgetImpact salaryIncreaseImpact({
    required MonthSummary current,
    required double newSalary,
  }) {
    final salaryIncrease = newSalary - current.totalIncome;
    final newNet = current.netBalance + salaryIncrease;
    final newSavingsRate = (current.totalSavings + salaryIncrease * 0.5) /
        newSalary; // Varsayım: artışın %50'si birikime

    return BudgetImpact(
      monthlyDiff: salaryIncrease,
      newNetBalance: newNet,
      newSavingsRate: newSavingsRate,
      projectedAnnualSavings: (current.totalSavings + salaryIncrease * 0.5) * 12,
    );
  }
}

enum AffordabilityStatus { comfortable, manageable, tight, risky }
```

---

## 4. İş Kuralları (BL Kodları)

```
BL-001  Tüm finansal hesaplamalar FinancialCalculator sınıfında toplanır.
        Başka hiçbir dosyada matematiksel hesaplama yapılmaz.

BL-002  UI katmanı (Screen/Widget) hesaplama yapmaz.
        Sadece Provider'dan gelen hazır değerleri görüntüler ve formatlar.

BL-003  Repository katmanı iş kuralı içermez.
        Sadece CRUD operasyonları (create/read/update/delete) yapılır.

BL-004  Provider (AsyncNotifier) hesaplamaları tetikler ve sonuçları state'e yazar.
        Use-case orchestration provider'da yapılır.

BL-005  Tüm para değerleri double olarak saklanır.
        UI'da CurrencyFormatter ile formatlanır — asla raw double gösterilmez.

BL-006  Tarihler UTC olarak Firestore'a yazılır (Timestamp.fromDate(date.toUtc())).
        UI'da local timezone'a çevrilir (timestamp.toDate().toLocal()).

BL-007  Silme işlemi soft-delete'dir.
        isDeleted: true set edilir, Firestore'dan fiziksel silme yapılmaz.
        Hard delete: 30 gün sonra Cloud Function ile.

BL-008  Tekrarlayan kayıtlar (isRecurring: true) her ayın 1'inde
        Firebase Cloud Function tarafından otomatik kopyalanır.
        Kopyada: yeni id, yeni tarih, aynı tutar/kategori.

BL-009  Aylık özet (monthSummaries) her write işlemi sonrası recalculate edilir.
        Recalculate: Firestore transaction içinde atomic olarak yapılır.

BL-010  Offline'da yapılan işlemler Firestore offline persistence tarafından
        queue'ya alınır. Sync edildiğinde BL-009 tetiklenir.

BL-011  Birikim çekildiğinde (SavingsStatus.withdrawn):
        - savings kaydı withdrawn olarak güncellenir
        - Aynı tutar ve tarihte income kaydı oluşturulur (category: refund)
        - monthSummaries recalculate edilir

BL-012  Para tutarı asla negatif olamaz.
        Negatif net bakiye: kullanıcıya gösterilebilir (kırmızı)
        ama hiçbir kayıt negatif amount ile oluşturulamaz.

BL-013  Kategori silindi ise o kategorideki mevcut kayıtlar "Diğer" kategorisine
        taşınır. Kategori hard-delete edilemez, sadece isActive: false.

BL-014  Aylık devir (carryOver): Her ayın monthSummary.netWithCarryOver değeri
        bir sonraki ayın carryOver alanına kopyalanır. Manuel değiştirilemez.

BL-015  Finansal sağlık skoru her monthSummary write'ında otomatik hesaplanır.
        FinancialCalculator.financialHealthScore() çağrılır.
```

---

## 5. Veri Modelleri

```dart
// lib/features/transactions/domain/models/income.dart
@freezed
class Income with _$Income {
  const factory Income({
    required String id,
    required double amount,
    required IncomeCategory category,
    String? person,           // Kişiden geliyorsa kişi adı
    String? source,           // Kaynak açıklaması
    required DateTime date,
    String? note,
    @Default(false) bool isRecurring,
    DateTime? recurringEndDate,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _Income;
  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
}

// lib/features/transactions/domain/models/expense.dart
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required double amount,
    required ExpenseCategory category,
    @Default(ExpenseType.variable) ExpenseType expenseType,
    String? subcategory,
    String? person,
    required DateTime date,
    String? note,
    @Default(false) bool isRecurring,
    DateTime? recurringEndDate,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _Expense;
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

// lib/features/savings/domain/models/savings.dart
@freezed
class Savings with _$Savings {
  const factory Savings({
    required String id,
    required double amount,
    required SavingsCategory category,
    String? goalId,           // Bağlı hedef (opsiyonel)
    String? note,
    required DateTime date,
    @Default(SavingsStatus.active) SavingsStatus status,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _Savings;
  factory Savings.fromJson(Map<String, dynamic> json) => _$SavingsFromJson(json);
}

// lib/features/savings_goals/domain/models/savings_goal.dart
@freezed
class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    DateTime? targetDate,
    required SavingsCategory category,
    @Default('#D97706') String colorHex,
    @Default('target') String iconName,
    @Default(GoalStatus.active) GoalStatus status,
    required DateTime createdAt,
  }) = _SavingsGoal;
  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}

// lib/features/dashboard/domain/models/month_summary.dart
@freezed
class MonthSummary with _$MonthSummary {
  const factory MonthSummary({
    required String yearMonth,         // "2025-03"
    @Default(0.0) double totalIncome,
    @Default(0.0) double totalExpense,
    @Default(0.0) double totalSavings, // Ayrı alan — gider değil
    @Default(0.0) double netBalance,   // Gelir - Gider - Birikim
    @Default(0.0) double carryOver,    // Önceki ay net (devir)
    @Default(0.0) double netWithCarryOver,
    @Default(0.0) double savingsRate,
    @Default(0.0) double expenseRate,
    @Default(0) int healthScore,
    required DateTime updatedAt,
  }) = _MonthSummary;
  factory MonthSummary.fromJson(Map<String, dynamic> json) =>
      _$MonthSummaryFromJson(json);
}

enum GoalStatus { active, completed, cancelled }
```

---

## 6. Firestore Şeması

```
users/{uid}/
│
├── profile/
│   ├── name: String
│   ├── email: String?
│   ├── currency: String        = "TRY"
│   ├── monthlyIncomeGoal: double?
│   ├── monthlyExpenseBudget: double?
│   ├── monthlySavingsGoalRate: double = 0.20
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
│
├── incomes/{id}
│   ├── amount: double          (> 0)
│   ├── category: String        (IncomeCategory enum value)
│   ├── person: String?
│   ├── source: String?
│   ├── date: Timestamp         (UTC)
│   ├── note: String?
│   ├── isRecurring: bool
│   ├── recurringEndDate: Timestamp?
│   ├── isDeleted: bool         = false
│   └── createdAt: Timestamp
│
├── expenses/{id}
│   ├── amount: double          (> 0)
│   ├── category: String
│   ├── expenseType: String     (fixed|variable|discretionary|business)
│   ├── subcategory: String?
│   ├── person: String?
│   ├── date: Timestamp
│   ├── note: String?
│   ├── isRecurring: bool
│   ├── recurringEndDate: Timestamp?
│   ├── isDeleted: bool         = false
│   └── createdAt: Timestamp
│
├── savings/{id}
│   ├── amount: double          (> 0)
│   ├── category: String        (SavingsCategory enum value)
│   ├── goalId: String?
│   ├── note: String?
│   ├── date: Timestamp
│   ├── status: String          (active|withdrawn|completed)
│   ├── isDeleted: bool         = false
│   └── createdAt: Timestamp
│
├── savingsGoals/{id}
│   ├── title: String
│   ├── targetAmount: double
│   ├── currentAmount: double   (savings collection'dan sum alınır)
│   ├── targetDate: Timestamp?
│   ├── category: String
│   ├── colorHex: String
│   ├── iconName: String
│   ├── status: String          (active|completed|cancelled)
│   └── createdAt: Timestamp
│
├── monthSummaries/{yearMonth}  ("2025-03" format)
│   ├── totalIncome: double
│   ├── totalExpense: double
│   ├── totalSavings: double    ← Ayrı alan, gider değil
│   ├── netBalance: double      ← Gelir - Gider - Birikim
│   ├── carryOver: double
│   ├── netWithCarryOver: double
│   ├── savingsRate: double
│   ├── expenseRate: double
│   ├── healthScore: int
│   └── updatedAt: Timestamp
│
└── simulations/{id}
    ├── type: String            (credit|car|rent|savings|salary)
    ├── params: Map
    ├── result: Map
    └── createdAt: Timestamp
```

### 6.1 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Kullanıcı yardımcı fonksiyonları
    function isAuth() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuth() && request.auth.uid == userId;
    }

    function isValidAmount() {
      return request.resource.data.amount is number
          && request.resource.data.amount > 0
          && request.resource.data.amount <= 10000000;
    }

    // Kullanıcı kendi verilerine tam erişim
    match /users/{userId}/{document=**} {
      allow read:  if isOwner(userId);
      allow write: if isOwner(userId) && isValidAmount();
    }

    // monthSummaries: sadece okuma (write sadece Cloud Function'dan)
    match /users/{userId}/monthSummaries/{month} {
      allow read:  if isOwner(userId);
      allow write: if false; // Sadece Cloud Function yazar
    }

    // Tüm diğer yollar kapalı
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 6.2 Sık Kullanılan Query'ler

```dart
// Aylık işlemler (isDeleted filtresi zorunlu)
FirebaseFirestore.instance
  .collection('users/$uid/expenses')
  .where('isDeleted', isEqualTo: false)
  .where('date', isGreaterThanOrEqualTo: monthStart)
  .where('date', isLessThan: monthEnd)
  .orderBy('date', descending: true);

// Tekrarlayan kayıtlar
.where('isRecurring', isEqualTo: true)
.where('isDeleted', isEqualTo: false);

// Kategori bazlı filtreleme
.where('category', isEqualTo: category.name)
.where('isDeleted', isEqualTo: false);

// UYARI: Compound index gerektirir — Firestore Console'dan oluştur
// (isDeleted + date), (isDeleted + category + date)
```

---

## 7. State Yönetimi Standartları

### 7.1 Provider Hiyerarşisi

```
authProvider                     → FirebaseAuth.instance.userChanges()
  └── profileProvider            → users/{uid}/profile
      └── monthSummaryProvider   → users/{uid}/monthSummaries/{month}
          └── dashboardProvider  → Özet + son işlemler

transactionsProvider(month, type) → Filtrelenmiş işlemler
savingsGoalsProvider              → Tüm aktif hedefler
analyticsProvider(month)          → Grafik verileri
simulationProvider                → Simülasyon hesaplamaları
aiAdvisorProvider                 → Gemini analiz
```

### 7.2 AsyncNotifier Şablonu

```dart
// lib/features/transactions/presentation/providers/expense_provider.dart

@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {

  @override
  Future<List<Expense>> build(String yearMonth) async {
    return ref.watch(expenseRepositoryProvider)
        .watchMonthExpenses(yearMonth)
        .first;
  }

  Future<void> add(Expense expense) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).add(expense);
      // monthSummary recalculate tetiklenir (BL-009)
      await ref.read(monthSummaryRepositoryProvider)
          .recalculate(expense.date.toYearMonth());
      return ref.read(expenseRepositoryProvider)
          .watchMonthExpenses(yearMonth).first;
    });
  }

  Future<void> softDelete(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).softDelete(id); // BL-007
      return ref.read(expenseRepositoryProvider)
          .watchMonthExpenses(yearMonth).first;
    });
  }
}
```

### 7.3 State Türleri

```dart
// Basit okuma — Provider (not Notifier)
@riverpod
Stream<MonthSummary?> monthSummary(Ref ref, String yearMonth) {
  final uid = ref.watch(authProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(monthSummaryRepositoryProvider).watch(yearMonth);
}

// Yazma + okuma — AsyncNotifier
// Her feature için ayrı Notifier dosyası
// Dosya adı: [feature]_provider.dart
```

---

## 8. Repository Katmanı

### 8.1 Base Repository Interface

```dart
// lib/core/data/base_repository.dart
abstract interface class BaseRepository<T> {
  Stream<List<T>> watchAll();
  Future<T?> getById(String id);
  Future<void> add(T entity);
  Future<void> update(T entity);
  Future<void> softDelete(String id); // BL-007: isDeleted: true
  Future<void> hardDelete(String id); // Sadece Cloud Function kullanır
}
```

### 8.2 Expense Repository

```dart
// lib/features/transactions/data/expense_repository.dart
class ExpenseRepository implements BaseRepository<Expense> {

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/expenses');

  Stream<List<Expense>> watchMonthExpenses(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('isDeleted', isEqualTo: false)        // BL-007
        .where('date', isGreaterThanOrEqualTo: range.start)
        .where('date', isLessThan: range.end)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<void> add(Expense expense) async {
    await _collection.doc(expense.id).set({
      ...expense.toJson(),
      'date': Timestamp.fromDate(expense.date.toUtc()), // BL-006
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> softDelete(String id) async {    // BL-007
    await _collection.doc(id).update({'isDeleted': true});
  }
}
```

---

## 9. Validasyon Kuralları

```dart
// lib/core/utils/transaction_validator.dart

class TransactionValidator {

  static const double _maxAmount = 10_000_000.0;
  static const int _maxNoteLength = 200;

  static ValidationResult validateAmount(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.error('Tutar giriniz');
    }
    final normalized = input.replaceAll(',', '.').replaceAll(' ', '');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return ValidationResult.error('Geçerli bir tutar giriniz');
    }
    if (amount <= 0) {
      return ValidationResult.error('Tutar 0\'dan büyük olmalıdır');
    }
    if (amount > _maxAmount) {
      return ValidationResult.error('Maksimum tutar ₺10.000.000');
    }
    return ValidationResult.ok(amount);
  }

  static ValidationResult validateDate(DateTime? date) {
    if (date == null) return ValidationResult.error('Tarih seçiniz');
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    if (date.isBefore(minDate)) {
      return ValidationResult.error('2020 öncesi tarih girilemez');
    }
    if (date.isAfter(now.add(const Duration(days: 366)))) {
      return ValidationResult.error('1 yıldan fazla ilerisi seçilemez');
    }
    return ValidationResult.ok(date);
  }

  static ValidationResult validateNote(String? note) {
    if (note == null || note.isEmpty) return ValidationResult.ok(null);
    if (note.length > _maxNoteLength) {
      return ValidationResult.error('Not en fazla $_maxNoteLength karakter');
    }
    return ValidationResult.ok(note);
  }
}

@freezed
class ValidationResult<T> with _$ValidationResult<T> {
  const factory ValidationResult.ok([T? value]) = ValidationOk;
  const factory ValidationResult.error(String message) = ValidationError;

  bool get isValid => this is ValidationOk;
  String? get errorMessage => mapOrNull(error: (e) => e.message);
}
```

---

## 10. Para Formatlama Standartları

```dart
// lib/core/utils/currency_formatter.dart
// UI'da asla raw double gösterilmez — her zaman bu sınıf kullanılır

class CurrencyFormatter {

  static final _standard = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compactCurrency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 1,
  );

  static final _noDecimal = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  /// Standart: ₺1.250,00
  static String format(double amount) => _standard.format(amount);

  /// Tam sayı: ₺1.250 (küçük tutarlar için de kullanılabilir)
  static String formatNoDecimal(double amount) => _noDecimal.format(amount);

  /// Kompakt: ₺1,2B  (1.000.000+), ₺12,5B  (yüksek tutarlar)
  static String compact(double amount) =>
      amount.abs() >= 1_000_000 ? _compact.format(amount) : format(amount);

  /// İşaretli: +₺1.250,00 veya -₺500,00
  static String withSign(double amount) {
    final abs = format(amount.abs());
    return amount >= 0 ? '+$abs' : '-$abs';
  }

  /// Değişim yüzdesi: +%5,2 veya -%3,1
  static String changePercent(double ratio) {
    final pct = (ratio * 100).abs();
    final sign = ratio >= 0 ? '+' : '-';
    return '$sign%${pct.toStringAsFixed(1)}';
  }

  /// Yüzde: %38,5
  static String percent(double ratio) =>
      '%${(ratio * 100).toStringAsFixed(1)}';

  /// Input parse: "1.250,00" veya "1250.00" → 1250.0
  static double? parse(String input) {
    final cleaned = input
        .replaceAll('₺', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')  // TR binlik ayracı
        .replaceAll(',', '.'); // TR ondalık → nokta
    return double.tryParse(cleaned);
  }
}
```

---

## 11. Hata Yönetimi

### 11.1 Exception Hiyerarşisi

```dart
// lib/core/errors/app_exception.dart

sealed class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

// Ağ / Firebase hataları
class NetworkException extends AppException {
  const NetworkException()
      : super('İnternet bağlantısı yok', code: 'NETWORK');
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

// Auth hataları
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Bu işlem için giriş yapınız', code: 'UNAUTHORIZED');
}

// Validasyon
class ValidationException extends AppException {
  final String field;
  const ValidationException(super.message, {required this.field});
}

// AI / Gemini
class AiException extends AppException {
  const AiException(super.message, {super.code});
}

class AiRateLimitException extends AppException {
  const AiRateLimitException()
      : super('AI analizi şu an kullanılamıyor. Daha sonra tekrar dene.',
            code: 'AI_RATE_LIMIT');
}
```

### 11.2 Hata→Kullanıcı Mesajı Dönüşümü

```dart
// lib/core/errors/error_mapper.dart
// Firebase hata kodları → kullanıcı dostu Türkçe mesaj

class ErrorMapper {
  static String toUserMessage(Object error) {
    if (error is AppException) return error.message;

    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable'          => 'İnternet bağlantısı yok',
        'permission-denied'    => 'Bu işlem için yetkiniz yok',
        'not-found'            => 'Kayıt bulunamadı',
        'already-exists'       => 'Bu kayıt zaten mevcut',
        'resource-exhausted'   => 'Günlük limit doldu, yarın tekrar dene',
        'unauthenticated'      => 'Lütfen tekrar giriş yapın',
        _                      => 'Bir hata oluştu. Tekrar dene.',
      };
    }

    return 'Beklenmeyen bir hata oluştu.';
  }
}
```

---

## 12. Simülasyon Motorları

```dart
// lib/features/simulation/domain/simulation_calculator.dart

class SimulationCalculator {

  // ─── Kredi Simülasyonu ─────────────────────────────────────────

  static CreditSimulationResult credit({
    required double principal,
    required double annualRate,
    required int termMonths,
    required MonthSummary currentBudget,
  }) {
    final monthly = FinancialCalculator.monthlyLoanPayment(
      principal: principal, annualRate: annualRate, termMonths: termMonths,
    );
    final total = FinancialCalculator.totalLoanPayment(
      monthlyPayment: monthly, termMonths: termMonths,
    );
    return CreditSimulationResult(
      monthlyPayment: monthly,
      totalPayment: total,
      totalInterest: FinancialCalculator.totalInterest(
          totalPayment: total, principal: principal),
      incomeRatio: currentBudget.totalIncome > 0
          ? monthly / currentBudget.totalIncome : 1.0,
      newNetBalance: currentBudget.netBalance - monthly,
      newSavingsRate: currentBudget.totalIncome > 0
          ? currentBudget.totalSavings / currentBudget.totalIncome : 0,
      affordability: FinancialCalculator.loanAffordability(
          monthlyPayment: monthly,
          monthlyIncome: currentBudget.totalIncome),
      amortizationSchedule: _amortizationSchedule(
          principal: principal, annualRate: annualRate, termMonths: termMonths),
    );
  }

  // ─── Kira Değişim Simülasyonu ──────────────────────────────────

  static RentSimulationResult rentChange({
    required double currentRent,
    required double increasePercent,
    required MonthSummary currentBudget,
  }) {
    final newRent = currentRent * (1 + increasePercent / 100);
    final diff = newRent - currentRent;
    return RentSimulationResult(
      newRent: newRent,
      monthlyDiff: diff,
      annualDiff: diff * 12,
      newNetBalance: currentBudget.netBalance - diff,
      newExpenseRate: (currentBudget.totalExpense + diff) /
          currentBudget.totalIncome,
      newSavingsRate: currentBudget.savingsRate, // Birikim oranı etkilenmez
    );
  }

  // ─── Araç Alım Simülasyonu ─────────────────────────────────────

  static CarSimulationResult car({
    required double vehiclePrice,
    required double downPayment,
    required double annualRate,
    required int termMonths,
    required double estimatedMonthlyCosts, // Sigorta + yakıt + bakım
    required MonthSummary currentBudget,
  }) {
    final loanAmount = vehiclePrice - downPayment;
    final creditResult = credit(
      principal: loanAmount, annualRate: annualRate,
      termMonths: termMonths, currentBudget: currentBudget,
    );
    final totalMonthlyImpact =
        creditResult.monthlyPayment + estimatedMonthlyCosts;

    return CarSimulationResult(
      loanAmount: loanAmount,
      creditResult: creditResult,
      estimatedMonthlyCosts: estimatedMonthlyCosts,
      totalMonthlyImpact: totalMonthlyImpact,
      newNetBalance: currentBudget.netBalance - totalMonthlyImpact,
      affordability: FinancialCalculator.loanAffordability(
          monthlyPayment: totalMonthlyImpact,
          monthlyIncome: currentBudget.totalIncome),
    );
  }

  // ─── Amortisman Tablosu ────────────────────────────────────────

  static List<AmortizationRow> _amortizationSchedule({
    required double principal,
    required double annualRate,
    required int termMonths,
  }) {
    final r = annualRate / 12;
    final monthly = FinancialCalculator.monthlyLoanPayment(
        principal: principal, annualRate: annualRate, termMonths: termMonths);
    double balance = principal;
    return List.generate(termMonths, (i) {
      final interest = balance * r;
      final principalPaid = monthly - interest;
      balance -= principalPaid;
      return AmortizationRow(
        month: i + 1,
        payment: monthly,
        principal: principalPaid,
        interest: interest,
        balance: balance.clamp(0, double.infinity),
      );
    });
  }
}
```

---

## 13. AI Analiz Motoru

### 13.1 Gemini Servis

```dart
// lib/features/ai_advisor/data/gemini_service.dart

class GeminiService {
  static const _modelName = 'gemini-1.5-flash';
  static const _maxDailyRequests = 5; // Kullanıcı başına günlük limit

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,      // Düşük: finansal tutarlılık için
        maxOutputTokens: 800,  // Token tasarrufu
        topP: 0.8,
      ),
    );
  }

  Future<String> analyzeMonthlyBudget({
    required MonthSummary summary,
    required Map<String, double> incomeBreakdown,
    required Map<String, double> expenseBreakdown,
    required Map<String, double> savingsBreakdown,
  }) async {
    await _checkRateLimit();

    final prompt = _buildPrompt(
      summary: summary,
      incomeBreakdown: incomeBreakdown,
      expenseBreakdown: expenseBreakdown,
      savingsBreakdown: savingsBreakdown,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      await _incrementRequestCount();
      return response.text ?? _localFallbackAnalysis(summary);
    } on GenerativeAIException catch (e) {
      if (e.message.contains('quota')) throw const AiRateLimitException();
      throw AiException(e.message);
    }
  }

  String _buildPrompt({
    required MonthSummary summary,
    required Map<String, double> incomeBreakdown,
    required Map<String, double> expenseBreakdown,
    required Map<String, double> savingsBreakdown,
  }) => '''
Sen Savvy uygulamasının kişisel finans danışmanısın.
Kullanıcının Türk lirası cinsinden aylık bütçe verisini analiz ediyorsun.

ÖZET (${summary.yearMonth}):
- Toplam Gelir: ${CurrencyFormatter.format(summary.totalIncome)}
- Toplam Gider: ${CurrencyFormatter.format(summary.totalExpense)} (gelirin ${CurrencyFormatter.percent(summary.expenseRate)})
- Toplam Birikim: ${CurrencyFormatter.format(summary.totalSavings)} (gelirin ${CurrencyFormatter.percent(summary.savingsRate)})
- Net Bakiye: ${CurrencyFormatter.format(summary.netBalance)}
- Finansal Sağlık Skoru: ${summary.healthScore}/100

GELİR KAYNAKLARI:
${incomeBreakdown.entries.map((e) => '- ${e.key}: ${CurrencyFormatter.format(e.value)}').join('\n')}

GİDER KATEGORİLERİ:
${expenseBreakdown.entries.map((e) => '- ${e.key}: ${CurrencyFormatter.format(e.value)} (${CurrencyFormatter.percent(e.value / summary.totalExpense)})').join('\n')}

BİRİKİM DAĞILIMI:
${savingsBreakdown.entries.map((e) => '- ${e.key}: ${CurrencyFormatter.format(e.value)}').join('\n')}

KURALLAR:
- Birikim oranı hedef %20 — mevcut ${CurrencyFormatter.percent(summary.savingsRate)}
- En yüksek 2-3 gider kalemini değerlendir
- Kısılabilecek yer varsa somut tutar söyle
- Türkçe, samimi ama profesyonel ton
- 4-5 madde, her madde max 2 cümle
- Asla yatırım tavsiyesi verme
''';

  /// Rate limit yok veya API hatası durumunda yerel analiz
  String _localFallbackAnalysis(MonthSummary s) {
    final tips = <String>[];
    if (s.savingsRate < 0.10) tips.add('Birikim oranın çok düşük — gelirinin en az %10\'unu biriktirmeye çalış.');
    if (s.expenseRate > 0.80) tips.add('Giderlerin gelirinin %80\'ini aşıyor — bütçeni gözden geçir.');
    if (s.netBalance < 0) tips.add('Bu ay açık verdin. Bir sonraki ay giderlerini kısmayı hedefle.');
    if (tips.isEmpty) tips.add('Bu ay dengeli bir bütçe yakaladın. Birikimlerini büyütmeye devam et.');
    return tips.join('\n');
  }
}
```

### 13.2 AI Cache Stratejisi

```dart
// Aynı ay için Firestore'da cache — tekrar istek atılmaz
// Cache süresi: 24 saat
// Cache key: "ai_analysis_{yearMonth}"
// Firestore: users/{uid}/aiCache/{yearMonth}
//   { analysis: String, createdAt: Timestamp }

Future<String> getCachedOrFetch(String yearMonth) async {
  // 1. Cache kontrol
  final cache = await _firestoreCache.get(yearMonth);
  if (cache != null && !cache.isExpired) return cache.analysis;

  // 2. Rate limit kontrol
  if (await _dailyLimitReached()) return _localFallbackAnalysis(summary);

  // 3. API çağrısı
  final result = await analyzeMonthlyBudget(...);

  // 4. Cache kaydet
  await _firestoreCache.set(yearMonth, result);
  return result;
}
```

---

## 14. Test Standartları

### 14.1 Test Edilmesi Zorunlu Sınıflar

```
FinancialCalculator     → Tüm public metodlar (unit test)
SimulationCalculator    → Her simülasyon tipi (unit test)
TransactionValidator    → Edge case'ler dahil (unit test)
CurrencyFormatter       → Format + parse (unit test)
Repository (mock)       → CRUD operasyonları (widget test)
Provider                → State geçişleri (provider test)
```

### 14.2 Test Örneği

```dart
// test/core/utils/financial_calculator_test.dart

void main() {
  group('FinancialCalculator', () {

    group('netBalance', () {
      test('pozitif net bakiye', () {
        expect(
          FinancialCalculator.netBalance(
            totalIncome: 45000, totalExpense: 20000, totalSavings: 8000),
          equals(17000),
        );
      });

      test('negatif net bakiye', () {
        expect(
          FinancialCalculator.netBalance(
            totalIncome: 20000, totalExpense: 25000, totalSavings: 0),
          equals(-5000),
        );
      });

      test('birikim gider toplamına eklenmez', () {
        final net = FinancialCalculator.netBalance(
          totalIncome: 50000, totalExpense: 20000, totalSavings: 10000);
        expect(net, equals(20000)); // 50k - 20k - 10k = 20k
      });
    });

    group('savingsRate', () {
      test('%20 hedef eşiği', () {
        final rate = FinancialCalculator.savingsRate(
          totalSavings: 10000, totalIncome: 50000);
        expect(rate, closeTo(0.20, 0.001));
      });

      test('sıfır gelir durumu', () {
        expect(FinancialCalculator.savingsRate(
          totalSavings: 1000, totalIncome: 0), equals(0.0));
      });
    });

    group('monthlyLoanPayment', () {
      test('standart kredi hesabı', () {
        final monthly = FinancialCalculator.monthlyLoanPayment(
          principal: 100000, annualRate: 0.36, termMonths: 24);
        expect(monthly, closeTo(5696.7, 1.0));
      });

      test('sıfır faizli kredi', () {
        expect(FinancialCalculator.monthlyLoanPayment(
          principal: 12000, annualRate: 0.0, termMonths: 12), equals(1000));
      });
    });
  });
}
```

### 14.3 Test Dosya Yapısı

```
test/
├── core/
│   └── utils/
│       ├── financial_calculator_test.dart
│       ├── simulation_calculator_test.dart
│       ├── transaction_validator_test.dart
│       └── currency_formatter_test.dart
├── features/
│   ├── dashboard/
│   │   └── providers/dashboard_provider_test.dart
│   ├── transactions/
│   │   └── data/expense_repository_test.dart (mock)
│   └── simulation/
│       └── domain/simulation_calculator_test.dart
└── helpers/
    ├── mock_firestore.dart
    └── test_data.dart        ← Sabit test fixture'ları
```

---

*Savvy Business Logic v1.0 — Mart 2025*
*Bu dosya tek gerçek kaynaktır (single source of truth).*
*Hesaplama değişikliği → bu dosya güncellenir, sonra kod yazılır.*