import SwiftUI
import SavvyDesignSystem

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: SavvySpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            VStack(spacing: SavvySpacing.sm) {
                Text(title)
                    .font(.savvyTitleLarge)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.savvyBodySmall)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.savvyTitleMedium)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "1A56DB"))
            }
        }
        .padding(SavvySpacing.xl2)
    }
}
