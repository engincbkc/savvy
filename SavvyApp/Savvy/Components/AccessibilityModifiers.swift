import SwiftUI
import SavvyFoundation

// MARK: - Currency Accessibility Label

extension View {
    /// Adds a VoiceOver-friendly accessibility label for currency amounts
    func currencyAccessibility(_ amount: Decimal, label: String) -> some View {
        self.accessibilityLabel("\(label): \(accessibleCurrency(amount))")
    }

    private func accessibleCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? ""
    }
}

// MARK: - Reduce Motion

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation

    func body(content: Content) -> some View {
        if reduceMotion {
            content.animation(nil, value: true)
        } else {
            content.animation(animation, value: true)
        }
    }
}

extension View {
    func savvyAnimation(_ animation: Animation = .savvyNormal) -> some View {
        modifier(ReduceMotionModifier(animation: animation))
    }
}

// MARK: - Dynamic Type Scaling

struct ScaledPaddingModifier: ViewModifier {
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1.0
    let padding: CGFloat

    func body(content: Content) -> some View {
        content.padding(padding * scale)
    }
}

extension View {
    func scaledPadding(_ padding: CGFloat) -> some View {
        modifier(ScaledPaddingModifier(padding: padding))
    }
}
