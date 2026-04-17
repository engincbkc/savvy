import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct TransactionsView: View {
    let deps: AppDependencies
    @State private var selectedSegment = 0
    @State private var searchText = ""
    @State private var showAddSheet = false
    @State private var incomes: [Income] = []
    @State private var expenses: [Expense] = []
    @State private var savings: [Savings] = []

    private let segments = ["Gelir", "Gider", "Birikim"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tür", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { i in
                        Text(segments[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, SavvySpacing.lg)
                .padding(.vertical, SavvySpacing.sm)

                List {
                    switch selectedSegment {
                    case 0:
                        ForEach(filteredIncomes) { income in
                            incomeRow(income)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { try? await deps.incomeRepo.softDelete(id: income.id) }
                                    } label: { Label("Sil", systemImage: "trash") }
                                }
                        }
                    case 1:
                        ForEach(filteredExpenses) { expense in
                            expenseRow(expense)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { try? await deps.expenseRepo.softDelete(id: expense.id) }
                                    } label: { Label("Sil", systemImage: "trash") }
                                }
                        }
                    default:
                        ForEach(filteredSavings) { saving in
                            savingsRow(saving)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { try? await deps.savingsRepo.softDelete(id: saving.id) }
                                    } label: { Label("Sil", systemImage: "trash") }
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if currentListEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                            Text("Henüz \(segments[selectedSegment].lowercased()) yok")
                                .font(.savvyBodyMedium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("İşlemler")
            .searchable(text: $searchText, prompt: "Ara...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { selectedSegment = 0; showAddSheet = true } label: {
                            Label("Gelir Ekle", systemImage: "plus.circle")
                        }
                        Button { selectedSegment = 1; showAddSheet = true } label: {
                            Label("Gider Ekle", systemImage: "minus.circle")
                        }
                        Button { selectedSegment = 2; showAddSheet = true } label: {
                            Label("Birikim Ekle", systemImage: "banknote")
                        }
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                Group {
                    switch selectedSegment {
                    case 0: AddIncomeSheet(repo: deps.incomeRepo)
                    case 1: AddExpenseSheet(repo: deps.expenseRepo)
                    default: AddSavingsSheet(repo: deps.savingsRepo)
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .task {
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
                }
            }
        }
    }

    // MARK: - Filters

    private var filteredIncomes: [Income] {
        if searchText.isEmpty { return incomes }
        return incomes.filter { $0.category.label.localizedCaseInsensitiveContains(searchText) || ($0.note ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredExpenses: [Expense] {
        if searchText.isEmpty { return expenses }
        return expenses.filter { $0.category.label.localizedCaseInsensitiveContains(searchText) || ($0.note ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredSavings: [Savings] {
        if searchText.isEmpty { return savings }
        return savings.filter { $0.category.label.localizedCaseInsensitiveContains(searchText) || ($0.note ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    private var currentListEmpty: Bool {
        switch selectedSegment {
        case 0: return filteredIncomes.isEmpty
        case 1: return filteredExpenses.isEmpty
        default: return filteredSavings.isEmpty
        }
    }

    // MARK: - Row builders

    @ViewBuilder
    private func incomeRow(_ income: Income) -> some View {
        HStack(spacing: SavvySpacing.md) {
            Image(systemName: income.category.sfSymbol)
                .font(.savvyTitleMedium)
                .foregroundStyle(Color.savvyIncome)
                .frame(width: 40, height: 40)
                .background(Color.savvyIncome.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(income.category.label).font(.savvyTitleMedium)
                HStack(spacing: SavvySpacing.xs) {
                    Text(income.date, style: .date)
                    if let note = income.note { Text("·"); Text(note).lineLimit(1) }
                    if income.isRecurring { Image(systemName: "repeat").font(.caption2) }
                    if income.isGross { Text("brüt").font(.caption2).foregroundStyle(.orange) }
                }
                .font(.savvyCaption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(CurrencyFormatter.formatNoDecimal(income.amount))
                .font(.savvyNumericSmall).foregroundStyle(Color.savvyIncome)
        }
        .padding(.vertical, SavvySpacing.xs)
    }

    @ViewBuilder
    private func expenseRow(_ expense: Expense) -> some View {
        HStack(spacing: SavvySpacing.md) {
            Image(systemName: expense.category.sfSymbol)
                .font(.savvyTitleMedium)
                .foregroundStyle(Color.savvyExpense)
                .frame(width: 40, height: 40)
                .background(Color.savvyExpense.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category.label).font(.savvyTitleMedium)
                HStack(spacing: SavvySpacing.xs) {
                    Text(expense.date, style: .date)
                    if let note = expense.note { Text("·"); Text(note).lineLimit(1) }
                    if expense.isRecurring { Image(systemName: "repeat").font(.caption2) }
                }
                .font(.savvyCaption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(CurrencyFormatter.formatNoDecimal(expense.amount))
                .font(.savvyNumericSmall).foregroundStyle(Color.savvyExpense)
        }
        .padding(.vertical, SavvySpacing.xs)
    }

    @ViewBuilder
    private func savingsRow(_ saving: Savings) -> some View {
        HStack(spacing: SavvySpacing.md) {
            Image(systemName: saving.category.sfSymbol)
                .font(.savvyTitleMedium)
                .foregroundStyle(Color.savvySavings)
                .frame(width: 40, height: 40)
                .background(Color.savvySavings.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(saving.category.label).font(.savvyTitleMedium)
                HStack(spacing: SavvySpacing.xs) {
                    Text(saving.date, style: .date)
                    if let note = saving.note { Text("·"); Text(note).lineLimit(1) }
                }
                .font(.savvyCaption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(CurrencyFormatter.formatNoDecimal(saving.amount))
                .font(.savvyNumericSmall).foregroundStyle(Color.savvySavings)
        }
        .padding(.vertical, SavvySpacing.xs)
    }
}
