# 06 — iOS Exclusive: Widget, Live Activity, Siri, Watch, Notifications

Flutter'da bulunmayan, native iOS'a ozel ozellikler.

---

## 1. WidgetKit — Home Screen Widgets

### Hedef: 3 Widget Boyutu

| Boyut | Icerik | Guncelleme |
|-------|--------|------------|
| Small | Net bakiye + aylik delta | Her islem eklendiginde |
| Medium | Gelir/Gider/Birikim ozet + progress bar | Her islem eklendiginde |
| Large | Top 4 butce kategorisi progress | Her islem eklendiginde |

### Small Widget — Balance Summary

```swift
struct BalanceSummaryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "balance", provider: BalanceProvider()) { entry in
            BalanceSummaryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Bakiye")
        .description("Aylik net bakiye ozeti")
        .supportedFamilies([.systemSmall])
    }
}

struct BalanceSummaryView: View {
    let entry: BalanceEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Savvy")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text("Net Bakiye")
                .font(.caption)
            
            Text(entry.netBalance, format: .currency(code: "TRY").precision(.fractionLength(0)))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(entry.netBalance >= 0 ? .green : .red)
            
            HStack(spacing: 2) {
                Image(systemName: entry.delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(entry.delta, format: .currency(code: "TRY").precision(.fractionLength(0)))
            }
            .font(.caption2)
            .foregroundStyle(entry.delta >= 0 ? .green : .red)
        }
    }
}
```

### Medium Widget — Monthly Overview

```swift
struct MonthlyOverviewView: View {
    let entry: MonthlyEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Savvy")
                    .font(.caption2.bold())
                Spacer()
                Text(entry.monthLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                StatColumn(label: "Gelir", amount: entry.income, color: .green)
                StatColumn(label: "Gider", amount: entry.expense, color: .red)
                StatColumn(label: "Net", amount: entry.net, color: entry.net >= 0 ? .green : .red)
            }
            
            // Budget progress
            ProgressView(value: entry.expenseRatio)
                .tint(entry.expenseRatio < 0.7 ? .green : entry.expenseRatio < 0.9 ? .orange : .red)
            
            Text("Harcama orani: %\(Int(entry.expenseRatio * 100))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
```

### Data Sharing — App Groups

```
App Group: group.com.savvy.shared
├── UserDefaults (son ozet verileri)
│   ├── "netBalance": Double
│   ├── "totalIncome": Double
│   ├── "totalExpense": Double
│   ├── "totalSavings": Double
│   └── "monthLabel": String
│
└── Guncelleme: WidgetCenter.shared.reloadAllTimelines()
    → Her add/update/delete isleminden sonra cagirilir
```

---

## 2. Live Activities (ActivityKit)

### Aylik Butce Takibi — Lock Screen + Dynamic Island

```swift
struct BudgetActivity: ActivityAttributes {
    let monthLabel: String
    let monthlyBudget: Decimal
    
    struct ContentState: Codable, Hashable {
        var totalSpent: Decimal
        var topCategory: String
        var daysRemaining: Int
    }
}

// Dynamic Island (compact)
struct BudgetActivityCompact: View {
    let context: ActivityViewContext<BudgetActivity>
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "chart.pie.fill")
            Text(CurrencyFormatter.compact(context.state.totalSpent))
                .font(.caption.monospacedDigit())
            Text("/")
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.compact(context.attributes.monthlyBudget))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

// Lock Screen (expanded)
struct BudgetActivityExpanded: View {
    let context: ActivityViewContext<BudgetActivity>
    
    var progress: Double {
        NSDecimalNumber(decimal: context.state.totalSpent / context.attributes.monthlyBudget).doubleValue
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Savvy — \(context.attributes.monthLabel)")
                    .font(.caption.bold())
                Spacer()
                Text("\(context.state.daysRemaining) gun kaldi")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: min(progress, 1.0))
                .tint(progress < 0.7 ? .green : progress < 0.9 ? .orange : .red)
            
            HStack {
                Text(CurrencyFormatter.formatNoDecimal(context.state.totalSpent))
                    .font(.caption.bold().monospacedDigit())
                Text("/ \(CurrencyFormatter.formatNoDecimal(context.attributes.monthlyBudget))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("En cok: \(context.state.topCategory)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

### Yasam Dongusu

1. Ay basinda `Activity.request()` ile baslatilir
2. Her gider eklenmesinde `activity.update(contentState:)` cagirilir
3. Ay sonunda `activity.end()` ile sonlandirilir

---

## 3. App Intents / Siri Shortcuts

### Quick Expense Entry

```swift
struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Harcama Ekle"
    static var description = IntentDescription("Hizli gider girisi")
    static var openAppWhenRun = false
    
    @Parameter(title: "Tutar")
    var amount: Double
    
    @Parameter(title: "Kategori")
    var category: ExpenseCategoryEntity
    
    @Parameter(title: "Not", default: "")
    var note: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let expense = Expense(
            amount: Decimal(amount),
            category: category.wrapped,
            date: .now,
            note: note.isEmpty ? nil : note
        )
        
        try await ExpenseRepository.shared.add(expense)
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result(dialog: "₺\(Int(amount)) \(category.wrapped.label) eklendi")
    }
}
```

### Budget Check

```swift
struct CheckBudgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Butce Durumu"
    static var description = IntentDescription("Aylik butce ozetini gor")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let summary = try await DashboardRepository.shared.currentMonthSummary()
        let net = CurrencyFormatter.formatNoDecimal(summary.netBalance)
        let ratio = Int(summary.expenseRate * 100)
        
        return .result(dialog: "Bu ay net \(net). Harcama orani: %\(ratio).")
    }
}
```

### Shortcuts Provider

```swift
struct SavvyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Savvy'ye harcama ekle",
                "\(.applicationName)'ye \(\.$amount) lira \(\.$category) ekle",
                "\(.applicationName)'ye gider gir"
            ],
            shortTitle: "Harcama Ekle",
            systemImageName: "minus.circle"
        )
        
        AppShortcut(
            intent: CheckBudgetIntent(),
            phrases: [
                "Savvy butce durumu",
                "\(.applicationName) bu ay ne kadar harcadim",
            ],
            shortTitle: "Butce Durumu",
            systemImageName: "chart.pie"
        )
    }
}
```

**Ornek Siri Komutu**: "Hey Siri, Savvy'ye 150 lira market ekle"

---

## 4. Smart Notifications

### Bildirim Turleri

```swift
enum SavvyNotification {
    case budgetWarning(category: ExpenseCategory, percentUsed: Double)    // >80%
    case budgetExceeded(category: ExpenseCategory, overAmount: Decimal)   // >100%
    case weeklyDigest(income: Decimal, expense: Decimal, net: Decimal)
    case goalProgress(goalTitle: String, percentComplete: Double)
    case recurringReminder(description: String, amount: Decimal)
    case monthEndSummary(monthLabel: String, net: Decimal, healthScore: Int)
}
```

### Background Task ile Kontrol

```swift
// BGAppRefreshTask — gunluk butce kontrolu
func scheduleBudgetCheck() {
    let request = BGAppRefreshTaskRequest(identifier: "com.savvy.budgetCheck")
    request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 8, to: .now)
    try? BGTaskScheduler.shared.submit(request)
}

func handleBudgetCheck() async {
    let budgets = try? await BudgetLimitRepository.shared.fetchAll()
    let expenses = try? await ExpenseRepository.shared.fetchCurrentMonth()
    
    for budget in budgets ?? [] {
        let spent = expenses?
            .filter { $0.category == budget.category }
            .reduce(Decimal(0)) { $0 + $1.amount } ?? 0
        
        let ratio = NSDecimalNumber(decimal: spent / budget.monthlyLimit).doubleValue
        
        if ratio >= 1.0 {
            sendNotification(.budgetExceeded(category: budget.category, overAmount: spent - budget.monthlyLimit))
        } else if ratio >= 0.8 {
            sendNotification(.budgetWarning(category: budget.category, percentUsed: ratio))
        }
    }
}
```

### Rich Notification Content

```swift
func sendNotification(_ type: SavvyNotification) {
    let content = UNMutableNotificationContent()
    
    switch type {
    case .budgetWarning(let category, let percent):
        content.title = "Butce Uyarisi"
        content.body = "\(category.label) harcamaniz limitin %\(Int(percent * 100))'ine ulasti."
        content.categoryIdentifier = "BUDGET_WARNING"
        content.sound = .default
        
    case .weeklyDigest(let income, let expense, let net):
        content.title = "Haftalik Ozet"
        content.body = "Gelir: \(CurrencyFormatter.compact(income)) | Gider: \(CurrencyFormatter.compact(expense)) | Net: \(CurrencyFormatter.compact(net))"
        
    case .monthEndSummary(let month, let net, let score):
        content.title = "\(month) Ozeti"
        content.body = "Net: \(CurrencyFormatter.formatNoDecimal(net)) | Saglik Puani: \(score)/100"
        
    default: break
    }
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}
```

---

## 5. watchOS Companion

### Minimal Watch App — Hizli Gider Girisi

```swift
// SavvyWatchApp.swift
@main
struct SavvyWatchApp: App {
    var body: some Scene {
        WindowGroup {
            QuickExpenseView()
        }
    }
}

struct QuickExpenseView: View {
    @State private var amount = ""
    @State private var category: ExpenseCategory = .market
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Bugunun toplam harcamasi
                Text("Bugun: ₺1.250")
                    .font(.headline.monospacedDigit())
                
                // Tutar girisi
                TextField("Tutar", text: $amount)
                    .multilineTextAlignment(.center)
                
                // Kategori secimi (Digital Crown ile scroll)
                Picker("Kategori", selection: $category) {
                    ForEach(ExpenseCategory.quickCategories, id: \.self) { cat in
                        Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                    }
                }
                .pickerStyle(.wheel)
                
                Button("Ekle") { save() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
```

### Complication

```swift
struct BudgetComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "watchBudget", provider: WatchBudgetProvider()) { entry in
            ZStack {
                AccessoryWidgetBackground()
                Gauge(value: entry.expenseRatio) {
                    Image(systemName: "chart.pie.fill")
                } currentValueLabel: {
                    Text("%\(Int(entry.expenseRatio * 100))")
                        .font(.caption2)
                }
                .gaugeStyle(.accessoryCircular)
            }
        }
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}
```

### Watch ↔ iPhone Sync

Watch Connectivity framework ile:
- Watch'tan eklenen giderler iPhone'a gonderilir
- iPhone Firestore'a yazar
- iPhone ozet verisini Watch'a push eder

---

## 6. Spotlight Integration

### Transaction Indexing

```swift
import CoreSpotlight

func indexTransaction(_ expense: Expense) {
    let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
    attributeSet.title = expense.category.label
    attributeSet.contentDescription = "\(CurrencyFormatter.formatNoDecimal(expense.amount)) — \(expense.note ?? "")"
    attributeSet.displayName = expense.category.label
    
    let item = CSSearchableItem(
        uniqueIdentifier: "expense-\(expense.id)",
        domainIdentifier: "com.savvy.expenses",
        attributeSet: attributeSet
    )
    
    CSSearchableIndex.default().indexSearchableItems([item])
}
```

**Sonuc**: Kullanici Spotlight'ta "kira" arattiginda kira giderlerini gorur.

---

## 7. Implementasyon Onceligi

| Ozellik | Faz | Karmasiklik |
|---------|-----|-------------|
| WidgetKit (small + medium) | Faz 4 | Orta |
| App Intents / Siri | Faz 4 | Dusuk |
| Smart Notifications | Faz 4 | Orta |
| Live Activities | Faz 4 | Yuksek |
| watchOS companion | Faz 4 | Yuksek |
| Spotlight | Faz 4 | Dusuk |
| Large widget | Faz 5 | Dusuk |
