import SwiftUI
import SavvyFoundation
import SavvyDesignSystem

struct SavvyHeroNumber: View {
    let amount: Decimal
    let style: Font
    let color: Color

    var body: some View {
        Text(CurrencyFormatter.formatNoDecimal(amount))
            .font(style)
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(countsDown: amount < 0))
            .animation(.savvyCountUp, value: amount)
            .accessibilityLabel("Bakiye: \(accessibleAmount)")
    }

    private var accessibleAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: "tr_TR")
        let intValue = NSDecimalNumber(decimal: amount).intValue
        let spelled = formatter.string(from: NSNumber(value: abs(intValue))) ?? ""
        return amount < 0 ? "eksi \(spelled) lira" : "\(spelled) lira"
    }
}
