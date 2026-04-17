import SwiftUI
import SavvyDesignSystem

struct ShimmerView: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerView())
    }
}

// MARK: - Dashboard Shimmer Skeleton

struct DashboardShimmer: View {
    var body: some View {
        VStack(spacing: SavvySpacing.lg) {
            // Hero card placeholder
            RoundedRectangle(cornerRadius: SavvyRadius.lg)
                .fill(Color(.systemGray5))
                .frame(height: 180)
                .padding(.horizontal, SavvySpacing.lg)

            // Quick stats placeholder
            HStack(spacing: SavvySpacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: SavvyRadius.md)
                        .fill(Color(.systemGray5))
                        .frame(height: 80)
                }
            }
            .padding(.horizontal, SavvySpacing.lg)

            // Transaction rows placeholder
            VStack(spacing: SavvySpacing.sm) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: SavvySpacing.md) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(width: 120, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 10)
                        }
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 70, height: 14)
                    }
                    .padding(.horizontal, SavvySpacing.lg)
                }
            }
        }
        .shimmer()
        .padding(.vertical, SavvySpacing.base)
    }
}
