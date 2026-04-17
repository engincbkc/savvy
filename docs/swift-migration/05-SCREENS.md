# 05 — Screens: Her Ekranin Native iOS Karsiligi

## Screen Listesi

| Flutter Ekran | Swift Karsiligi | Navigasyon |
|--------------|-----------------|------------|
| DashboardScreen | DashboardView | Tab 1, NavigationStack |
| TransactionsScreen | TransactionsView | Tab 2, NavigationStack |
| SimulationListScreen | SimulationListView | Tab 3, NavigationStack |
| SettingsScreen | SettingsView | Tab 4, NavigationStack |
| LoginScreen | LoginView | Auth flow (fullScreenCover) |
| RegisterScreen | RegisterView | Auth flow push |
| ForgotPasswordScreen | ForgotPasswordView | Auth flow push |
| AddIncomeSheet | AddIncomeSheet | .sheet(detents: [.medium, .large]) |
| AddExpenseSheet | AddExpenseSheet | .sheet(detents: [.medium, .large]) |
| AddSavingsSheet | AddSavingsSheet | .sheet(detents: [.medium, .large]) |
| MonthDetailScreen | MonthDetailView | NavigationLink push |
| CashFlowForecastScreen | CashFlowForecastView | NavigationLink push |
| MonthCompareScreen | MonthCompareView | NavigationLink push |
| SimulationTemplateScreen | SimulationTemplateView | NavigationLink push |
| SimulationEditorScreen | SimulationEditorView | NavigationLink push |
| SimulationCashFlowScreen | CashFlowProjectionView | NavigationLink push |
| BudgetOverviewScreen | BudgetOverviewView | Dashboard icinden push |
| DebtDashboardScreen | DebtDashboardView | Dashboard icinden push |
| RecurringManagementScreen | RecurringManagementView | Transactions icinden push |
| TaxReportScreen | TaxReportView | Settings icinden push |

---

## 1. Dashboard

### Yapisi

```
DashboardView
├── ScrollView
│   ├── GreetingHeader
│   │   ├── Zamana gore selamlama (Gunaydin, Iyi gunler, etc.)
│   │   ├── Mevcut ay badge
│   │   └── AI Advisor butonu (gradient purple+blue)
│   │
│   ├── WalletHeroCard
│   │   ├── MeshGradient background (iOS 18) / LinearGradient (iOS 17)
│   │   ├── Net bakiye (SavvyHeroNumber, animated count-up)
│   │   ├── Aylik delta pill (yesil ↑ / kirmizi ↓)
│   │   ├── DragGesture ile acilir flap
│   │   ├── Icerideki mini kartlar (gelir/gider/birikim)
│   │   └── sensoryFeedback(.impact) on drag
│   │
│   ├── QuickStatsGrid
│   │   ├── Grid(horizontalSpacing:) 3 kolon
│   │   ├── StatCard(Gelir, green, amount)
│   │   ├── StatCard(Gider, red, amount)
│   │   └── StatCard(Birikim, amber, amount)
│   │
│   ├── TrendChart (Swift Charts)
│   │   ├── BarMark per month
│   │   ├── RuleMark for goal targets
│   │   ├── .chartScrollableAxes(.horizontal)
│   │   ├── .chartXVisibleDomain(length: 6)
│   │   └── sensoryFeedback(.selection) on tap
│   │
│   ├── GoalsSummary
│   │   ├── Top 3 aktif hedef
│   │   ├── LinearProgressIndicator + yuzde
│   │   └── NavigationLink to GoalsView
│   │
│   └── MonthlyFlowTable
│       ├── ScrollView(.horizontal)
│       ├── Grid: Ay × (Gelir, Gider, Birikim, Net, Kumulatif)
│       ├── Tap → ay detay modal
│       └── Expand → fullScreenCover
│
└── .toolbar { QuickAddButton }
```

### SwiftUI Ornegi: WalletHeroCard

```swift
struct WalletHeroCard: View {
    let summary: MonthSummary?
    @State private var isExpanded = false
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: SavvyRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: SavvySpacing.md) {
                // Net balance
                SavvyHeroNumber(
                    amount: summary?.netWithCarryOver ?? 0,
                    style: .savvyNumericHero,
                    color: .white
                )
                
                // Monthly delta
                if let delta = summary?.netBalance {
                    DeltaPill(amount: delta)
                }
                
                // Expandable content
                if isExpanded {
                    HStack(spacing: SavvySpacing.md) {
                        MiniStatCard(label: "Gelir", amount: summary?.totalIncome ?? 0, color: .savvyIncome)
                        MiniStatCard(label: "Gider", amount: summary?.totalExpense ?? 0, color: .savvyExpense)
                        MiniStatCard(label: "Birikim", amount: summary?.totalSavings ?? 0, color: .savvySavings)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(SavvySpacing.xl)
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in state = value.translation.height }
                .onEnded { value in
                    withAnimation(.savvyBounce) {
                        isExpanded = value.translation.height > 50
                    }
                }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: isExpanded)
    }
}
```

### SwiftUI Ornegi: TrendChart

```swift
struct TrendChart: View {
    let projections: [MonthSummary]
    @State private var selectedMonth: MonthSummary?
    
    var body: some View {
        Chart(projections) { month in
            BarMark(
                x: .value("Ay", month.yearMonth),
                y: .value("Net", NSDecimalNumber(decimal: month.netWithCarryOver).doubleValue)
            )
            .foregroundStyle(month.netWithCarryOver >= 0 ? Color.savvyIncome : Color.savvyExpense)
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 6)
        .chartYAxis {
            AxisMarks(format: .currency(code: "TRY").precision(.fractionLength(0)))
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(SpatialTapGesture().onEnded { value in
                        if let month = findMonth(at: value.location, proxy: proxy, geo: geo) {
                            selectedMonth = month
                        }
                    })
            }
        }
        .sensoryFeedback(.selection, trigger: selectedMonth?.yearMonth)
        .frame(height: 200)
    }
}
```

---

## 2. Transactions

### Yapisi

```
TransactionsView
├── NavigationStack
│   ├── .toolbar {
│   │   ├── Picker("Tab", segmented) [Gelir | Gider | Birikim]
│   │   └── Menu { FilterOptions }
│   │ }
│   ├── .searchable(text:, placement: .toolbar)
│   │
│   ├── List {
│   │   ForEach(filteredTransactions) { tx in
│   │       TransactionRow(tx)
│   │           .swipeActions(edge: .trailing) {
│   │               Button(role: .destructive) { delete(tx) }
│   │               Button { edit(tx) }
│   │           }
│   │           .swipeActions(edge: .leading) {
│   │               Button { duplicate(tx) }
│   │           }
│   │           .contextMenu { ... } preview: { TransactionPreview(tx) }
│   │   }
│   │ }
│   │ .refreshable { await viewModel.refresh() }
│   │
│   └── .sheet(item: $editingTransaction) { tx in
│       EditTransactionSheet(tx)
│           .presentationDetents([.medium, .large])
│   }
│
└── .toolbar { AddButton → .sheet(AddTransactionSheet) }
```

### TransactionRow

```swift
struct TransactionRow: View {
    let transaction: any FinancialTransaction
    
    var body: some View {
        HStack(spacing: SavvySpacing.md) {
            // Kategori ikonu
            Image(systemName: transaction.category.sfSymbol)
                .font(.savvyTitleMedium)
                .foregroundStyle(transaction.accentColor)
                .frame(width: 40, height: 40)
                .background(transaction.accentColor.opacity(0.12))
                .clipShape(Circle())
            
            // Baslik + alt bilgi
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.label)
                    .font(.savvyTitleMedium)
                    .foregroundStyle(.savvyTextPrimary)
                
                HStack(spacing: SavvySpacing.xs) {
                    Text(transaction.date, style: .date)
                    if let note = transaction.note {
                        Text("·")
                        Text(note).lineLimit(1)
                    }
                    if transaction.isRecurring {
                        Image(systemName: "repeat")
                            .font(.caption2)
                    }
                }
                .font(.savvyCaption)
                .foregroundStyle(.savvyTextTertiary)
            }
            
            Spacer()
            
            // Tutar
            Text(transaction.amount, format: .currency(code: "TRY"))
                .font(.savvyNumericSmall)
                .foregroundStyle(transaction.accentColor)
                .monospacedDigit()
        }
        .padding(.vertical, SavvySpacing.sm)
    }
}
```

---

## 3. Add Transaction Sheets

### Form Pattern (Native iOS)

```swift
struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var category: ExpenseCategory = .market
    @State private var expenseType: ExpenseType = .variable
    @State private var date = Date()
    @State private var note = ""
    @State private var isRecurring = false
    @State private var endDate = Date()
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tutar") {
                    TextField("Tutar", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                    
                    Picker("Tur", selection: $expenseType) {
                        ForEach(ExpenseType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Detaylar") {
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                    TextField("Not", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                    
                    Toggle("Tekrarlayan", isOn: $isRecurring)
                    if isRecurring {
                        DatePicker("Bitis Tarihi", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Gider Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Iptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .disabled(!isValid)
                        .sensoryFeedback(.success, trigger: saved)
                }
            }
        }
    }
}
```

---

## 4. Simulation

### Template Picker

```swift
struct SimulationTemplateView: View {
    var body: some View {
        List {
            ForEach(SimulationTemplate.allCases, id: \.self) { template in
                NavigationLink(value: SimulationRoute.editor(template: template)) {
                    HStack(spacing: SavvySpacing.md) {
                        Image(systemName: template.sfSymbol)
                            .font(.title2)
                            .foregroundStyle(Color(hex: template.colorHex))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: template.colorHex).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.label).font(.savvyTitleMedium)
                            Text(template.subtitle).font(.savvyCaption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, SavvySpacing.xs)
                }
            }
        }
        .navigationTitle("Senaryo Sec")
    }
}
```

### Simulation Editor

```
SimulationEditorView
├── Form
│   ├── Section("Senaryo Bilgisi")
│   │   ├── TextField(title)
│   │   └── TextField(description)
│   │
│   ├── Section("Degisiklikler")
│   │   ├── ForEach(changes) { ChangeCard(change) }
│   │   └── Button("Degisiklik Ekle") → sheet
│   │
│   ├── Section("Sonuc")
│   │   ├── Before/After comparison cards
│   │   ├── AffordabilityGauge
│   │   └── MonthlyNetImpact
│   │
│   └── Section("12 Ay Projeksiyon")
│       └── NavigationLink → CashFlowProjectionView
│
└── .toolbar { SaveButton }
```

### CashFlow Projection

```swift
struct CashFlowProjectionView: View {
    let projection: [MonthProjection]
    
    var body: some View {
        List {
            // Chart
            Section {
                Chart(projection) { month in
                    BarMark(
                        x: .value("Ay", month.monthLabel),
                        y: .value("Net", NSDecimalNumber(decimal: month.net).doubleValue)
                    )
                    .foregroundStyle(month.net >= 0 ? Color.savvyIncome : Color.savvyExpense)
                    
                    LineMark(
                        x: .value("Ay", month.monthLabel),
                        y: .value("Kumulatif", NSDecimalNumber(decimal: month.cumulativeNet).doubleValue)
                    )
                    .foregroundStyle(.savvyBrand)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .frame(height: 200)
            }
            
            // Aylik detay
            Section("Aylik Detay") {
                ForEach(projection) { month in
                    DisclosureGroup {
                        ForEach(month.incomeItems) { item in
                            MonthLineItemRow(item: item, color: .savvyIncome)
                        }
                        ForEach(month.expenseItems) { item in
                            MonthLineItemRow(item: item, color: .savvyExpense)
                        }
                    } label: {
                        HStack {
                            Text(month.monthLabel).font(.savvyTitleMedium)
                            Spacer()
                            Text(month.net, format: .currency(code: "TRY"))
                                .font(.savvyNumericSmall)
                                .foregroundStyle(month.net >= 0 ? .savvyIncome : .savvyExpense)
                        }
                    }
                }
            }
        }
        .navigationTitle("Nakit Akis Projeksiyonu")
    }
}
```

---

## 5. Settings

```swift
struct SettingsView: View {
    @Environment(AuthViewModel.self) private var auth
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            // Profil
            Section {
                ProfileCard(user: auth.user)
            }
            
            // Finansal Araclar
            Section("Finansal Araclar") {
                NavigationLink("AI Danismani", destination: AIAdvisorView())
                NavigationLink("Borc Takibi", destination: DebtDashboardView())
                NavigationLink("Butce Limitleri", destination: BudgetOverviewView())
                NavigationLink("Vergi Raporu", destination: TaxReportView())
            }
            
            // Veri
            Section("Veri") {
                NavigationLink("CSV Import", destination: CSVImportView())
                Button("Veriyi Disari Aktar") { export() }
            }
            
            // Tercihler
            Section("Tercihler") {
                Toggle("Karanlik Mod", isOn: $isDarkMode)
                NavigationLink("Bildirimler", destination: NotificationSettingsView())
            }
            
            // Hakkinda
            Section("Hakkinda") {
                LabeledContent("Versiyon", value: "1.0.0")
                Link("Gizlilik Politikasi", destination: URL(string: "...")!)
                Link("Kullanim Kosullari", destination: URL(string: "...")!)
            }
            
            // Cikis
            Section {
                Button("Cikis Yap", role: .destructive) { auth.signOut() }
            }
        }
        .navigationTitle("Ayarlar")
    }
}
```

---

## 6. Auth Flow

```swift
struct AuthFlowView: View {
    @Environment(AuthViewModel.self) private var auth
    
    var body: some View {
        NavigationStack {
            LoginView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .register: RegisterView()
                    case .forgotPassword: ForgotPasswordView()
                    }
                }
        }
    }
}

struct LoginView: View {
    @Environment(AuthViewModel.self) private var auth
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: SavvySpacing.xl) {
            // Logo + baslik
            VStack(spacing: SavvySpacing.sm) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.savvyBrand)
                Text("Savvy").font(.savvyHeadlineLarge)
            }
            
            // Social login (oncelikli)
            SignInWithAppleButton(.signIn) { request in
                auth.handleAppleSignIn(request)
            } onCompletion: { result in
                auth.completeAppleSignIn(result)
            }
            .frame(height: 50)
            .signInWithAppleButtonStyle(.whiteOutline)
            
            GoogleSignInButton { auth.signInWithGoogle() }
            
            // Divider
            LabeledContent { Divider() } label: { Text("veya").font(.savvyCaption) }
            
            // Email/password
            TextField("E-posta", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Sifre", text: $password)
                .textContentType(.password)
            
            Button("Giris Yap") { auth.signIn(email: email, password: password) }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)
            
            // Links
            NavigationLink("Sifremi Unuttum", value: AuthRoute.forgotPassword)
            NavigationLink("Hesap Olustur", value: AuthRoute.register)
        }
        .padding(SavvySpacing.screen)
    }
}
```

---

## 7. Budget Overview

```swift
struct BudgetOverviewView: View {
    @State private var viewModel: BudgetViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.budgets) { budget in
                BudgetProgressCard(budget: budget)
                    .swipeActions {
                        Button { edit(budget) } label: { Label("Duzenle", systemImage: "pencil") }
                        Button(role: .destructive) { delete(budget) } label: { Label("Sil", systemImage: "trash") }
                    }
            }
        }
        .navigationTitle("Butce Limitleri")
        .toolbar {
            Button { showAddBudget = true } label: { Image(systemName: "plus") }
        }
    }
}

struct BudgetProgressCard: View {
    let budget: BudgetProgress
    
    var progressColor: Color {
        switch budget.ratio {
        case ..<0.6: .savvyIncome
        case ..<0.8: .savvyWarning
        default: .savvyExpense
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            HStack {
                Label(budget.category.label, systemImage: budget.category.sfSymbol)
                Spacer()
                Text(CurrencyFormatter.compact(budget.spent))
                    .font(.savvyNumericSmall)
                Text("/")
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.compact(budget.limit))
                    .font(.savvyNumericSmall)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: budget.ratio)
                .tint(progressColor)
            
            if budget.ratio > 1 {
                Label("Limit asildi!", systemImage: "exclamationmark.triangle.fill")
                    .font(.savvyCaption)
                    .foregroundStyle(.savvyExpense)
            }
        }
    }
}
```

---

## 8. Savings Goals

```swift
struct GoalsView: View {
    @State private var viewModel: SavingsGoalsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.goals) { goal in
                GoalCard(goal: goal)
                    .staggeredEntry(index: viewModel.goals.firstIndex(of: goal) ?? 0)
            }
        }
        .navigationTitle("Birikim Hedefleri")
        .sheet(item: $editingGoal) { goal in
            GoalDetailSheet(goal: goal)
                .presentationDetents([.medium, .large])
        }
    }
}

struct GoalCard: View {
    let goal: SavingsGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: SavvySpacing.md) {
            HStack {
                Image(systemName: goal.sfSymbolName)
                    .foregroundStyle(Color(hex: goal.colorHex))
                Text(goal.title).font(.savvyTitleMedium)
                Spacer()
                Text(CurrencyFormatter.percent(
                    FinancialCalculator.goalProgress(
                        targetAmount: goal.targetAmount,
                        currentAmount: goal.currentAmount
                    )
                ))
                .font(.savvyLabelMedium)
                .foregroundStyle(.secondary)
            }
            
            ProgressView(value: FinancialCalculator.goalProgress(
                targetAmount: goal.targetAmount,
                currentAmount: goal.currentAmount
            ))
            .tint(Color(hex: goal.colorHex))
            
            HStack {
                Text(CurrencyFormatter.formatNoDecimal(goal.currentAmount))
                    .font(.savvyNumericSmall)
                Spacer()
                Text(CurrencyFormatter.formatNoDecimal(goal.targetAmount))
                    .font(.savvyCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```
