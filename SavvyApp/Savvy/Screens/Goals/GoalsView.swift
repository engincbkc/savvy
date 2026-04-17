import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct GoalsView: View {
    let deps: AppDependencies
    @State private var goals: [SavingsGoal] = []
    @State private var showAddGoal = false
    @State private var newTitle = ""
    @State private var newTarget = ""

    var body: some View {
        List {
            if goals.isEmpty {
                Section {
                    VStack(spacing: SavvySpacing.md) {
                        Image(systemName: "target")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Henüz birikim hedefi yok")
                            .font(.savvyBodyMedium)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SavvySpacing.xl)
                }
            }

            ForEach(goals) { goal in
                goalCard(goal)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { try? await deps.savingsGoalRepo.delete(id: goal.id) }
                        } label: { Label("Sil", systemImage: "trash") }
                    }
            }
        }
        .navigationTitle("Birikim Hedefleri")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddGoal = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            NavigationStack {
                Form {
                    TextField("Hedef Adı", text: $newTitle)
                    HStack {
                        Text("₺").foregroundStyle(.secondary)
                        TextField("Hedef Tutar", text: $newTarget)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Hedef Ekle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("İptal") { showAddGoal = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kaydet") {
                            if let amount = Decimal(string: newTarget.replacingOccurrences(of: ",", with: ".")), amount > 0 {
                                let goal = SavingsGoal(title: newTitle, targetAmount: amount)
                                Task { try? await deps.savingsGoalRepo.add(goal); showAddGoal = false }
                            }
                        }
                        .disabled(newTitle.isEmpty || newTarget.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .task {
            for await items in deps.savingsGoalRepo.watch() {
                goals = items
            }
        }
    }

    @ViewBuilder
    private func goalCard(_ goal: SavingsGoal) -> some View {
        VStack(alignment: .leading, spacing: SavvySpacing.sm) {
            HStack {
                Image(systemName: goal.iconName)
                    .foregroundStyle(Color(hex: goal.colorHex))
                Text(goal.title).font(.savvyTitleMedium)
                Spacer()
                Text(CurrencyFormatter.percent(
                    FinancialCalculator.goalProgress(targetAmount: goal.targetAmount, currentAmount: goal.currentAmount)
                ))
                .font(.savvyLabelMedium)
                .foregroundStyle(.secondary)
            }
            ProgressView(value: FinancialCalculator.goalProgress(
                targetAmount: goal.targetAmount, currentAmount: goal.currentAmount
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
        .padding(.vertical, SavvySpacing.xs)
    }
}
