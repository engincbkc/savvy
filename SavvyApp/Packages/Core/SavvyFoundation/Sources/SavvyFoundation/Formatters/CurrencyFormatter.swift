import Foundation

public enum CurrencyFormatter {
    private static let trLocale = Locale(identifier: "tr_TR")

    /// "₺1.250,00"
    public static func format(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = trLocale
        return formatter.string(from: amount as NSDecimalNumber) ?? "₺0"
    }

    /// "₺1.250"
    public static func formatNoDecimal(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = trLocale
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₺0"
    }

    /// "₺1,2M" / "₺102K" / "₺1.250"
    public static func compact(_ amount: Decimal) -> String {
        let d = NSDecimalNumber(decimal: amount).doubleValue
        switch abs(d) {
        case 1_000_000...:
            return String(format: "₺%.1fM", d / 1_000_000)
                .replacingOccurrences(of: ".", with: ",")
        case 10_000...:
            return "₺\(Int(d / 1_000))K"
        default:
            return formatNoDecimal(amount)
        }
    }

    /// "+₺1.250,00" / "-₺500,00"
    public static func withSign(_ amount: Decimal) -> String {
        let prefix = amount >= 0 ? "+" : ""
        return prefix + format(amount)
    }

    /// "+%5,2" / "-%3,1"
    public static func changePercent(_ ratio: Double) -> String {
        let sign = ratio >= 0 ? "+" : "-"
        let pct = abs(ratio) * 100
        return "\(sign)%\(String(format: "%.1f", pct).replacingOccurrences(of: ".", with: ","))"
    }

    /// "%38,5"
    public static func percent(_ ratio: Double) -> String {
        "%\(String(format: "%.1f", ratio * 100).replacingOccurrences(of: ".", with: ","))"
    }

    /// Reverse Turkish format → Decimal
    public static func parse(_ input: String) -> Decimal? {
        let cleaned = input
            .replacingOccurrences(of: "₺", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleaned)
    }
}
