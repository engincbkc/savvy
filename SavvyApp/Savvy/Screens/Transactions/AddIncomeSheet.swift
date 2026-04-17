import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct AddIncomeSheet: View {
    let repo: IncomeRepository
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var category: IncomeCategory = .salary
    @State private var date = Date()
    @State private var note = ""
    @State private var isRecurring = false
    @State private var isGross = false
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
                    Toggle("Brüt Tutar", isOn: $isGross)
                }
                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(IncomeCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                }
                Section("Detaylar") {
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    TextField("Not (isteğe bağlı)", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                    Toggle("Tekrarlayan", isOn: $isRecurring)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red).font(.savvyCaption) }
                }
            }
            .navigationTitle("Gelir Ekle")
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
        let income = Income(
            amount: decimal, category: category, date: date,
            note: note.isEmpty ? nil : note,
            isRecurring: isRecurring, isGross: isGross
        )
        Task {
            do {
                try await repo.add(income)
                dismiss()
            } catch {
                errorMessage = "Kayıt hatası: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }
}
