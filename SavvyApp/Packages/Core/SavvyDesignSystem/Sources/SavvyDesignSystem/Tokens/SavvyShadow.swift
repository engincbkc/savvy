import SwiftUI

public struct SavvyShadow: ViewModifier {
    public enum Level { case xs, sm, md, lg }
    let level: Level

    public func body(content: Content) -> some View {
        switch level {
        case .xs: content.shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        case .sm: content.shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        case .md: content.shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        case .lg: content.shadow(color: .black.opacity(0.12), radius: 16, y: 8)
        }
    }
}

extension View {
    public func savvyShadow(_ level: SavvyShadow.Level) -> some View {
        modifier(SavvyShadow(level: level))
    }
}
