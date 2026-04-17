import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct AddSavingsSheet: View {
    let repo: SavingsRepository
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var category: SavingsCategory = .emergency
    @State private var date = Date()
    @State private var note = ""
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
                        ForEach(SavingsCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                }
                Section("Detaylar") {
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    TextField("Not (isteğe bağlı)", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red).font(.savvyCaption) }
                }
            }
            .navigationTitle("Birikim Ekle")
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
        let saving = Savings(
            amount: decimal, category: category,
            note: note.isEmpty ? nil : note, date: date
        )
        Task {
            do {
                try await repo.add(saving)
                dismiss()
            } catch {
                errorMessage = "Kayıt hatası: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }
}
