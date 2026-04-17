import Foundation

public enum TransactionValidator {
    public static let maxAmount: Decimal = 10_000_000
    public static let maxNoteLength = 200

    public enum ValidationResult<T> {
        case ok(T)
        case error(String)
    }

    public static func validateAmount(_ input: String?) -> ValidationResult<Decimal> {
        guard let input, !input.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .error("Tutar giriniz")
        }
        let normalized = input
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        guard let amount = Decimal(string: normalized) else {
            return .error("Geçerli bir tutar giriniz")
        }
        guard amount > 0 else {
            return .error("Tutar 0'dan büyük olmalıdır")
        }
        guard amount <= maxAmount else {
            return .error("Maksimum tutar ₺10.000.000")
        }
        return .ok(amount)
    }

    public static func validateDate(_ date: Date?) -> ValidationResult<Date> {
        guard let date else {
            return .error("Tarih seçiniz")
        }
        let minDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let maxDate = Calendar.current.date(byAdding: .day, value: 366, to: Date())!
        guard date >= minDate && date <= maxDate else {
            return .error("Tarih 2020 – gelecek yıl aralığında olmalı")
        }
        return .ok(date)
    }

    public static func validateNote(_ note: String?) -> ValidationResult<String?> {
        guard let note, !note.isEmpty else { return .ok(nil) }
        guard note.count <= maxNoteLength else {
            return .error("Not en fazla \(maxNoteLength) karakter")
        }
        return .ok(note)
    }
}
