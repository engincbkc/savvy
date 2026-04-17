import Foundation

extension Date {
    /// "2025-03" format
    public func toYearMonth() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        return "\(year)-\(String(format: "%02d", month))"
    }

    /// YearMonth string'den ayın başlangıç tarihini oluştur
    public static func fromYearMonth(_ ym: String) -> Date? {
        let parts = ym.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]) else { return nil }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))
    }
}

public struct YearMonthRange: Sendable {
    public let start: Date
    public let end: Date

    public static func from(_ yearMonth: String) -> YearMonthRange? {
        guard let start = Date.fromYearMonth(yearMonth) else { return nil }
        guard let end = Calendar.current.date(byAdding: .month, value: 1, to: start) else { return nil }
        return YearMonthRange(start: start, end: end)
    }
}

public enum MonthLabels {
    private static let months = [
        "", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
    ]

    /// "Ocak 2025"
    public static func full(_ yearMonth: String) -> String {
        let parts = yearMonth.split(separator: "-")
        guard parts.count == 2, let month = Int(parts[1]), month >= 1, month <= 12 else { return yearMonth }
        return "\(months[month]) \(parts[0])"
    }

    /// "Oca '25"
    public static func short(_ yearMonth: String) -> String {
        let parts = yearMonth.split(separator: "-")
        guard parts.count == 2, let month = Int(parts[1]), month >= 1, month <= 12 else { return yearMonth }
        let name = months[month]
        let abbr = name.count > 3 ? String(name.prefix(3)) : name
        return "\(abbr) '\(parts[0].suffix(2))"
    }

    /// "Oca"
    public static func shortName(_ yearMonth: String) -> String {
        let parts = yearMonth.split(separator: "-")
        guard parts.count == 2, let month = Int(parts[1]), month >= 1, month <= 12 else { return "" }
        return String(months[month].prefix(3))
    }

    /// "Ocak" (by month index 1-12)
    public static func monthName(_ month: Int) -> String {
        guard month >= 1 && month <= 12 else { return "" }
        return months[month]
    }
}
