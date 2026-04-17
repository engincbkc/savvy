import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct BudgetOverviewView: View {
    let deps: AppDependencies
    @State private var budgets: [BudgetLimit] = []
    @State private var expenses: [Expense] = []
    @State private var showAddBudget = false
    @State private var newCategory: ExpenseCategory = .market
    @State private var newLimit = ""

    private var budgetProgress: [(budget: BudgetLimit, spent: Decimal, ratio: Double)] {
        let currentMonth = Date().toYearMonth()
        return budgets.filter(\.isActive).map { b in
            let spent = expenses
                .filter { $0.category == b.category && $0.date.toYearMonth() == currentMonth }
                .reduce(Decimal(0)) { $0 + $1.amount }
            let ratio = b.monthlyLimit > 0
                ? NSDecimalNumber(decimal: spent / b.monthlyLimit).doubleValue
                : 0
            return (budget: b, spent: spent, ratio: ratio)
        }
    }

    var body: some View {
        List {
            if budgetProgress.isEmpty {
                Section {
                    VStack(spacing: SavvySpacing.md) {
                        Image(systemName: "gauge.with.dots.needle.33percent")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Henüz bütçe limiti yok")
                            .font(.savvyBodyMedium)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SavvySpacing.xl)
                }
            }

            ForEach(budgetProgress, id: \.budget.id) { item in
                budgetCard(item)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { try? await deps.budgetLimitRepo.softDelete(id: item.budget.id) }
                        } label: { Label("Sil", systemImage: "trash") }
                    }
            }
        }
        .navigationTitle("Bütçe Limitleri")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddBudget = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddBudget) {
            NavigationStack {
                Form {
                    Picker("Kategori", selection: $newCategory) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                    HStack {
                        Text("₺").foregroundStyle(.secondary)
                        TextField("Limit", text: $newLimit)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Limit Ekle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("İptal") { showAddBudget = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kaydet") {
                            if let amount = Decimal(string: newLimit.replacingOccurrences(of: ",", with: ".")), amount > 0 {
                                let limit = BudgetLimit(category: newCategory, monthlyLimit: amount)
                                Task { try? await deps.budgetLimitRepo.add(limit); showAddBudget = false }
                            }
                        }
                        .disabled(newLimit.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { for await items in deps.budgetLimitRepo.watch() { await MainActor.run { budgets = items } } }
                group.addTask { for await items in deps.expenseRepo.watch() { await MainActor.run { expenses = items } } }
            }
        }
    }

    @ViewBuilder
    private func budgetCard(_ item: (budget: BudgetLimit, spent: Decimal, ratio: Double)) -> some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            HStack {
                Label(item.budget.category.label, systemImage: item.budget.category.sfSymbol)
                    .font(.savvyTitleMedium)
                Spacer()
                Text(CurrencyFormatter.compact(item.spent))
                    .font(.savvyNumericSmall)
                Text("/")
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.compact(item.budget.monthlyLimit))
                    .font(.savvyNumericSmall)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(item.ratio, 1.0))
                .tint(progressColor(item.ratio))
            if item.ratio > 1 {
                Label("Limit aşıldı!", systemImage: "exclamationmark.triangle.fill")
                    .font(.savvyCaption)
                    .foregroundStyle(Color.savvyExpense)
            }
        }
        .padding(.vertical, SavvySpacing.xs)
    }

    private func progressColor(_ ratio: Double) -> Color {
        switch ratio {
        case ..<0.6: return .savvyIncome
        case ..<0.8: return .savvySavings
        default: return .savvyExpense
        }
    }
}
