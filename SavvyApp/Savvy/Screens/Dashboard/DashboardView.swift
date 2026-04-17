import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct DashboardView: View {
    let deps: AppDependencies
    @State private var incomes: [Income] = []
    @State private var expenses: [Expense] = []
    @State private var savings: [Savings] = []
    @State private var isLoading = true
    @State private var selectedYearMonth = Date().toYearMonth()

    // Premium UI state
    @State private var heroExpanded = false
    @GestureState private var dragOffset: CGFloat = 0
    @State private var sectionsAppeared = false
    @State private var showFAB = false
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var showAddSavings = false
    @State private var fabExpanded = false

    // MARK: - Computed (data logic preserved)

    private var totalIncome: Decimal { incomes.filter { $0.date.toYearMonth() == selectedYearMonth }.reduce(0) { $0 + $1.amount } }
    private var totalExpense: Decimal { expenses.filter { $0.date.toYearMonth() == selectedYearMonth }.reduce(0) { $0 + $1.amount } }
    private var totalSavings: Decimal { savings.filter { $0.date.toYearMonth() == selectedYearMonth }.reduce(0) { $0 + $1.amount } }

    private var netBalance: Decimal {
        FinancialCalculator.netBalance(totalIncome: totalIncome, totalExpense: totalExpense, totalSavings: totalSavings)
    }
    private var healthScore: Int {
        FinancialCalculator.financialHealthScore(
            savingsRate: FinancialCalculator.savingsRate(totalSavings: totalSavings, totalIncome: totalIncome),
            expenseRatio: FinancialCalculator.expenseRatio(totalExpense: totalExpense, totalIncome: totalIncome),
            netBalance: netBalance,
            emergencyFundMonths: 0
        )
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Günaydın"
        case 12..<18: return "İyi günler"
        default: return "İyi akşamlar"
        }
    }

    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "☀️"
        case 12..<18: return "🌤"
        default: return "🌙"
        }
    }

    private var recentItems: [(id: String, title: String, sfSymbol: String, amount: Decimal, isIncome: Bool, date: Date, note: String?, isRecurring: Bool)] {
        let incomeItems = incomes.prefix(5).map { i in
            (id: i.id, title: i.category.label, sfSymbol: i.category.sfSymbol, amount: i.amount, isIncome: true, date: i.date, note: i.note, isRecurring: i.isRecurring)
        }
        let expenseItems = expenses.prefix(5).map { e in
            (id: e.id, title: e.category.label, sfSymbol: e.category.sfSymbol, amount: e.amount, isIncome: false, date: e.date, note: e.note, isRecurring: e.isRecurring)
        }
        return (incomeItems + expenseItems).sorted { $0.date > $1.date }.prefix(8).map { $0 }
    }

    private var healthColor: Color {
        switch healthScore {
        case 80...: return .savvyIncome
        case 50...: return .savvySavings
        default: return .savvyExpense
        }
    }

    private var effectiveExpanded: Bool {
        heroExpanded || dragOffset > 40
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    if isLoading {
                        loadingView
                    } else {
                        VStack(spacing: 0) {
                            // Greeting header
                            greetingHeader
                                .padding(.top, SavvySpacing.base)
                                .opacity(sectionsAppeared ? 1 : 0)
                                .offset(y: sectionsAppeared ? 0 : 10)

                            // Hero wallet card
                            premiumHeroCard
                                .padding(.top, SavvySpacing.base)
                                .opacity(sectionsAppeared ? 1 : 0)
                                .offset(y: sectionsAppeared ? 0 : 20)

                            // Quick stat glassmorphism cards
                            quickStatsRow
                                .padding(.top, SavvySpacing.base)

                            // Trend chart
                            sectionContainer(delay: 0.3) {
                                TrendChartView(incomes: incomes, expenses: expenses)
                            }
                            .padding(.top, SavvySpacing.lg)

                            // Quick links
                            quickLinksRow
                                .padding(.top, SavvySpacing.lg)

                            // Recent transactions
                            recentTransactionsSection
                                .padding(.top, SavvySpacing.lg)

                            // Bottom spacer for tab bar
                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, SavvySpacing.xl2)
                    }
                }
                .scrollIndicators(.hidden)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "0F172A").opacity(0.03), location: 0),
                            .init(color: Color(.systemGroupedBackground), location: 0.3),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .navigationBarTitleDisplayMode(.inline)

                // Floating action button
                floatingActionButton
                    .padding(.trailing, SavvySpacing.lg)
                    .padding(.bottom, 90)
            }
            .task { await startObserving() }
            .onChange(of: incomes.count) { _, _ in updateWidgetData() }
            .onChange(of: expenses.count) { _, _ in updateWidgetData() }
            .onChange(of: savings.count) { _, _ in updateWidgetData() }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(repo: deps.incomeRepo)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(repo: deps.expenseRepo)
            }
            .sheet(isPresented: $showAddSavings) {
                AddSavingsSheet(repo: deps.savingsRepo)
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 20) {
            // Shimmer hero placeholder
            RoundedRectangle(cornerRadius: SavvyRadius.lg)
                .fill(Color(.systemGray5))
                .frame(height: 180)
                .padding(.horizontal, SavvySpacing.lg)
                .shimmer()

            HStack(spacing: SavvySpacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: SavvyRadius.md)
                        .fill(Color(.systemGray5))
                        .frame(height: 80)
                        .shimmer()
                }
            }
            .padding(.horizontal, SavvySpacing.lg)

            RoundedRectangle(cornerRadius: SavvyRadius.md)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .padding(.horizontal, SavvySpacing.lg)
                .shimmer()
        }
        .padding(.top, SavvySpacing.xl3)
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(greetingEmoji)
                        .font(.system(size: 20))
                    Text(greeting)
                        .font(.savvyHeadlineSmall)
                }
                Text(MonthLabels.full(selectedYearMonth))
                    .font(.savvyCaption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // Health score badge
            healthBadge
        }
        .padding(.horizontal, SavvySpacing.lg)
    }

    private var healthBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(healthColor)
                .frame(width: 8, height: 8)
                .shadow(color: healthColor.opacity(0.5), radius: 4)
            Text("\(healthScore)")
                .font(.savvyLabelMedium)
                .foregroundStyle(healthColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(healthColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Premium Hero Card

    private var premiumHeroCard: some View {
        let expandedHeight: CGFloat = 260
        let collapsedHeight: CGFloat = 170
        let currentHeight = effectiveExpanded ? expandedHeight : collapsedHeight

        return VStack(spacing: 0) {
            VStack(spacing: SavvySpacing.md) {
                // Top row: label + balance
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Bakiye")
                            .font(.savvyLabelMedium)
                            .foregroundStyle(.white.opacity(0.6))

                        Text(CurrencyFormatter.formatNoDecimal(netBalance))
                            .font(.savvyNumericHero)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    Spacer()

                    // Expand chevron
                    Image(systemName: effectiveExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.3))
                        .rotationEffect(.degrees(effectiveExpanded ? 0 : 0))
                }

                // Balance bar visualization
                if totalIncome > 0 {
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            let incomeRatio = CGFloat(NSDecimalNumber(decimal: totalIncome).doubleValue)
                            let expenseRatio = CGFloat(NSDecimalNumber(decimal: totalExpense).doubleValue)
                            let savingsRatio = CGFloat(NSDecimalNumber(decimal: totalSavings).doubleValue)
                            let total = incomeRatio

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.savvyIncome.opacity(0.8))
                                .frame(width: total > 0 ? geo.size.width * min(expenseRatio / total, 1) : 0)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.savvySavings.opacity(0.8))
                                .frame(width: total > 0 ? geo.size.width * min(savingsRatio / total, 1) : 0)

                            Spacer(minLength: 0)
                        }
                    }
                    .frame(height: 4)
                    .background(RoundedRectangle(cornerRadius: 3).fill(.white.opacity(0.1)))
                }

                // Expanded mini stats
                if effectiveExpanded {
                    HStack(spacing: SavvySpacing.xl) {
                        PremiumMiniStat(label: "Gelir", amount: totalIncome, icon: "arrow.down.left", color: .savvyIncome)
                        PremiumMiniStat(label: "Gider", amount: totalExpense, icon: "arrow.up.right", color: .savvyExpense)
                        PremiumMiniStat(label: "Birikim", amount: totalSavings, icon: "leaf.fill", color: .savvySavings)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(SavvySpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .frame(height: currentHeight + max(dragOffset * 0.5, 0))
        .background(
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Subtle mesh-like overlay
                RadialGradient(
                    colors: [Color(hex: "1A56DB").opacity(0.15), .clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 200
                )
                RadialGradient(
                    colors: [Color(hex: "3F83F8").opacity(0.1), .clear],
                    center: .bottomLeading,
                    startRadius: 10,
                    endRadius: 180
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: SavvyRadius.xl)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color(hex: "1A56DB").opacity(0.2), radius: 30, y: 15)
        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
        .padding(.horizontal, SavvySpacing.lg)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    withAnimation(.savvyModerate) {
                        if value.translation.height > 50 {
                            heroExpanded = true
                        } else if value.translation.height < -50 {
                            heroExpanded = false
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.savvyModerate) {
                heroExpanded.toggle()
            }
        }
        .animation(.savvyModerate, value: effectiveExpanded)
    }

    // MARK: - Quick Stats (Glassmorphism)

    private var quickStatsRow: some View {
        HStack(spacing: SavvySpacing.md) {
            GlassStatCard(
                title: "Gelir",
                amount: totalIncome,
                color: .savvyIncome,
                icon: "arrow.down.circle.fill"
            )
            .opacity(sectionsAppeared ? 1 : 0)
            .offset(y: sectionsAppeared ? 0 : 20)
            .animation(.savvyEnter.delay(0.15), value: sectionsAppeared)

            GlassStatCard(
                title: "Gider",
                amount: totalExpense,
                color: .savvyExpense,
                icon: "arrow.up.circle.fill"
            )
            .opacity(sectionsAppeared ? 1 : 0)
            .offset(y: sectionsAppeared ? 0 : 20)
            .animation(.savvyEnter.delay(0.25), value: sectionsAppeared)

            GlassStatCard(
                title: "Birikim",
                amount: totalSavings,
                color: .savvySavings,
                icon: "banknote.fill"
            )
            .opacity(sectionsAppeared ? 1 : 0)
            .offset(y: sectionsAppeared ? 0 : 20)
            .animation(.savvyEnter.delay(0.35), value: sectionsAppeared)
        }
        .padding(.horizontal, SavvySpacing.lg)
    }

    // MARK: - Quick Links

    private var quickLinksRow: some View {
        sectionContainer(delay: 0.4) {
            HStack(spacing: SavvySpacing.md) {
                NavigationLink {
                    BudgetOverviewView(deps: deps)
                } label: {
                    HStack(spacing: SavvySpacing.sm) {
                        Image(systemName: "gauge.with.dots.needle.33percent")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "1A56DB"))
                        Text("Bütçe")
                            .font(.savvyLabelMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SavvySpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SavvyRadius.md)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: SavvyRadius.md)
                                    .stroke(Color.savvyBorderDefault.opacity(0.5), lineWidth: 0.5)
                            )
                    )
                }

                NavigationLink {
                    GoalsView(deps: deps)
                } label: {
                    HStack(spacing: SavvySpacing.sm) {
                        Image(systemName: "target")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "1A56DB"))
                        Text("Hedefler")
                            .font(.savvyLabelMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SavvySpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SavvyRadius.md)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: SavvyRadius.md)
                                    .stroke(Color.savvyBorderDefault.opacity(0.5), lineWidth: 0.5)
                            )
                    )
                }
            }
            .foregroundStyle(.primary)
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        sectionContainer(delay: 0.5) {
            if !recentItems.isEmpty {
                VStack(alignment: .leading, spacing: SavvySpacing.md) {
                    // Section header
                    HStack {
                        HStack(spacing: SavvySpacing.sm) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "1A56DB"), Color(hex: "3F83F8")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 3, height: 18)
                            Text("Son İşlemler")
                                .font(.savvyTitleLarge)
                        }
                        Spacer()
                        Text("\(recentItems.count) işlem")
                            .font(.savvyCaption)
                            .foregroundStyle(.tertiary)
                    }

                    // Transaction rows
                    VStack(spacing: 0) {
                        ForEach(Array(recentItems.enumerated()), id: \.element.id) { index, item in
                            premiumTransactionRow(item, index: index)
                            if item.id != recentItems.last?.id {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: SavvyRadius.md)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: SavvyRadius.md)
                            .stroke(Color.savvyBorderDefault.opacity(0.3), lineWidth: 0.5)
                    )
                }
            } else {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 64, height: 64)
                        Image(systemName: "tray")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(.tertiary)
                    }
                    Text("Henüz işlem yok")
                        .font(.savvyBodyMedium)
                        .foregroundStyle(.secondary)
                    Text("İşlemler sekmesinden gelir veya gider ekleyin")
                        .font(.savvyCaption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, SavvySpacing.xl2)
            }
        }
    }

    @ViewBuilder
    private func premiumTransactionRow(_ item: (id: String, title: String, sfSymbol: String, amount: Decimal, isIncome: Bool, date: Date, note: String?, isRecurring: Bool), index: Int) -> some View {
        let color: Color = item.isIncome ? .savvyIncome : .savvyExpense

        HStack(spacing: SavvySpacing.md) {
            // Left color accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3, height: 36)

            // Icon
            Image(systemName: item.sfSymbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))

            // Title & meta
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.savvyTitleMedium)
                    .lineLimit(1)
                HStack(spacing: SavvySpacing.xs) {
                    Text(item.date, style: .date)
                    if let note = item.note, !note.isEmpty {
                        Text("·")
                        Text(note).lineLimit(1)
                    }
                    if item.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 9))
                    }
                }
                .font(.savvyCaption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text("\(item.isIncome ? "+" : "-")\(CurrencyFormatter.formatNoDecimal(item.amount))")
                .font(.savvyNumericSmall)
                .foregroundStyle(color)
        }
        .padding(.horizontal, SavvySpacing.md)
        .padding(.vertical, SavvySpacing.sm)
    }

    // MARK: - Floating Action Button

    private var floatingActionButton: some View {
        VStack(spacing: SavvySpacing.md) {
            if fabExpanded {
                // Mini action buttons
                VStack(spacing: SavvySpacing.sm) {
                    fabOption(icon: "arrow.down.circle.fill", label: "Gelir", color: .savvyIncome) {
                        showAddIncome = true
                        fabExpanded = false
                    }
                    fabOption(icon: "arrow.up.circle.fill", label: "Gider", color: .savvyExpense) {
                        showAddExpense = true
                        fabExpanded = false
                    }
                    fabOption(icon: "banknote.fill", label: "Birikim", color: .savvySavings) {
                        showAddSavings = true
                        fabExpanded = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }

            // Main FAB
            Button {
                withAnimation(.savvyBounce) {
                    fabExpanded.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1A56DB"), Color(hex: "3F83F8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(hex: "1A56DB").opacity(0.4), radius: 12, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(fabExpanded ? 45 : 0))
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: fabExpanded)
        }
        .opacity(showFAB ? 1 : 0)
        .scaleEffect(showFAB ? 1 : 0.5)
        .animation(.savvyEnter.delay(0.6), value: showFAB)
    }

    private func fabOption(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: SavvySpacing.sm) {
                Text(label)
                    .font(.savvyLabelMedium)
                    .foregroundStyle(.primary)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(color.opacity(0.12))
                    )
            }
            .padding(.leading, SavvySpacing.md)
            .padding(.trailing, SavvySpacing.xs)
            .padding(.vertical, SavvySpacing.xs)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section Container (Staggered animation)

    @ViewBuilder
    private func sectionContainer<Content: View>(delay: Double, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, SavvySpacing.lg)
            .opacity(sectionsAppeared ? 1 : 0)
            .offset(y: sectionsAppeared ? 0 : 24)
            .animation(.savvyEnter.delay(delay), value: sectionsAppeared)
    }

    // MARK: - Widget data

    private func updateWidgetData() {
        SharedDataManager.updateDashboard(
            netBalance: NSDecimalNumber(decimal: netBalance).doubleValue,
            totalIncome: NSDecimalNumber(decimal: totalIncome).doubleValue,
            totalExpense: NSDecimalNumber(decimal: totalExpense).doubleValue,
            totalSavings: NSDecimalNumber(decimal: totalSavings).doubleValue,
            monthLabel: MonthLabels.full(selectedYearMonth),
            healthScore: healthScore,
            expenseRatio: FinancialCalculator.expenseRatio(totalExpense: totalExpense, totalIncome: totalIncome)
        )
    }

    // MARK: - Data streaming

    private func startObserving() async {
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await items in deps.incomeRepo.watch() {
                    await MainActor.run { incomes = items }
                }
            }
            group.addTask {
                for await items in deps.expenseRepo.watch() {
                    await MainActor.run { expenses = items }
                }
            }
            group.addTask {
                for await items in deps.savingsRepo.watch() {
                    await MainActor.run { savings = items }
                }
            }
            // Give streams time to deliver first batch
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run {
                isLoading = false
                withAnimation(.savvyEnter) {
                    sectionsAppeared = true
                }
                showFAB = true
            }
        }
    }
}

// MARK: - Premium Mini Stat (Hero expanded)

struct PremiumMiniStat: View {
    let label: String
    let amount: Decimal
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(color)
            Text(CurrencyFormatter.compact(amount))
                .font(.savvyNumericSmall)
                .foregroundStyle(.white)
            Text(label)
                .font(.savvyCaption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Glass Stat Card

struct GlassStatCard: View {
    let title: String
    let amount: Decimal
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(color)
                Spacer()
            }
            Text(CurrencyFormatter.compact(amount))
                .font(.savvyNumericSmall)
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(title)
                .font(.savvyCaption)
                .foregroundStyle(.secondary)
        }
        .padding(SavvySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SavvyRadius.md)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: SavvyRadius.md)
                        .fill(color.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: SavvyRadius.md)
                        .stroke(color.opacity(0.12), lineWidth: 0.5)
                )
        )
        .shadow(color: color.opacity(0.08), radius: 8, y: 4)
    }
}

