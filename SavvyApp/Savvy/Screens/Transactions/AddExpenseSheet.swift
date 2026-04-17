import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct AddExpenseSheet: View {
    let repo: ExpenseRepository
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var category: ExpenseCategory = .market
    @State private var expenseType: ExpenseType = .variable
    @State private var date = Date()
    @State private var note = ""
    @State private var isRecurring = false
    @State private var endDate = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Tutar") {
                    HStack {
                        Text("₺").foregroundStyle(.secondary)
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                            .font(.savvyNumericMedium)
                    }
                }
                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                    Picker("Tür", selection: $expenseType) {
                        ForEach(ExpenseType.allCases) { type in Text(type.label).tag(type) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Detaylar") {
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    TextField("Not (isteğe bağlı)", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                    Toggle("Tekrarlayan", isOn: $isRecurring)
                    if isRecurring {
                        DatePicker("Bitiş Tarihi", selection: $endDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red).font(.savvyCaption) }
                }
            }
            .navigationTitle("Gider Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("İptal") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(amount.isEmpty || isSaving)
                }
            }
            .onAppear { amountFocused = true }
        }
    }

    private func save() {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: normalized), decimal > 0 else {
            errorMessage = "Geçerli bir tutar giriniz"
            return
        }
        isSaving = true
        let expense = Expense(
            amount: decimal, category: category, expenseType: expenseType,
            date: date, note: note.isEmpty ? nil : note,
            isRecurring: isRecurring,
            recurringEndDate: isRecurring ? endDate : nil
        )
        Task {
            do {
                try await repo.add(expense)
                dismiss()
            } catch {
                errorMessage = "Kayıt hatası: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }
}
