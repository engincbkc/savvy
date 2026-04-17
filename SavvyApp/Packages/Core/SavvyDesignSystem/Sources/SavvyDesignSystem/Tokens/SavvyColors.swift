import SwiftUI

extension Color {
    // MARK: - Brand
    static let savvyBrand       = Color("Brand700")
    static let savvyBrandDim    = Color("Brand800")
    static let savvyBrandAccent = Color("Brand500")
    static let savvyBrandLight  = Color("Brand50")

    // MARK: - Income (Green)
    public static let savvyIncome          = Color(hex: "0E9F6E")
    public static let savvyIncomeStrong    = Color(hex: "046C4E")
    public static let savvyIncomeMuted     = Color(hex: "31C48D")
    public static let savvyIncomeSurface   = Color(hex: "DEF7EC")
    public static let savvyIncomeSurfaceDim = Color(hex: "F3FAF7")

    // MARK: - Expense (Red)
    public static let savvyExpense          = Color(hex: "E02424")
    public static let savvyExpenseStrong    = Color(hex: "9B1C1C")
    public static let savvyExpenseMuted     = Color(hex: "F05252")
    public static let savvyExpenseSurface   = Color(hex: "FDE8E8")
    public static let savvyExpenseSurfaceDim = Color(hex: "FDF2F2")

    // MARK: - Savings (Amber)
    public static let savvySavings          = Color(hex: "D97706")
    public static let savvySavingsStrong    = Color(hex: "8E4B10")
    public static let savvySavingsMuted     = Color(hex: "FBBF24")
    public static let savvySavingsSurface   = Color(hex: "FDE8C8")
    public static let savvySavingsSurfaceDim = Color(hex: "FFF8EE")

    // MARK: - Status
    public static let savvySuccess = Color(hex: "0E9F6E")
    public static let savvyWarning = Color(hex: "F59E0B")
    public static let savvyError   = Color(hex: "E02424")

    // MARK: - Text
    public static let savvyTextPrimary   = Color(hex: "111827")
    public static let savvyTextSecondary = Color(hex: "4B5563")
    public static let savvyTextTertiary  = Color(hex: "9CA3AF")
    public static let savvyTextInverse   = Color.white

    // MARK: - Surface
    public static let savvySurfaceBackground = Color(hex: "F9FAFB")
    public static let savvySurfaceCard       = Color.white
    public static let savvySurfaceElevated   = Color.white
    public static let savvySurfaceOverlay    = Color(hex: "F3F4F6")
    public static let savvySurfaceInput      = Color(hex: "F9FAFB")

    // MARK: - Border
    public static let savvyBorderDefault = Color(hex: "E5E7EB")
    public static let savvyBorderStrong  = Color(hex: "D1D5DB")
    public static let savvyBorderFocus   = Color(hex: "1A56DB")

    // MARK: - Dark Surface
    public static let savvyDarkBackground = Color(hex: "0F172A")
    public static let savvyDarkCard       = Color(hex: "1E293B")
    public static let savvyDarkElevated   = Color(hex: "253347")
}

// MARK: - Hex Initializer

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
