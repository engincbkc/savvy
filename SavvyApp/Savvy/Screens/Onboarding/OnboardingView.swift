import SwiftUI
import SavvyDesignSystem

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var appeared = false

    private let pages: [(icon: String, title: String, subtitle: String, gradient: [Color])] = [
        (
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            title: "Finansal Kontrolü\nEle Al",
            subtitle: "Gelir, gider ve birikimlerini tek ekranda takip et.\nTürk vergi sistemiyle brüt-net maaş hesapla.",
            gradient: [Color(hex: "1A56DB"), Color(hex: "3F83F8")]
        ),
        (
            icon: "sparkles",
            title: "\"Ne Olur?\"\nSenaryoları",
            subtitle: "Kredi çekimi, ev alımı, maaş değişikliği...\n8 farklı senaryo ile geleceğini simüle et.",
            gradient: [Color(hex: "046C4E"), Color(hex: "0E9F6E")]
        ),
        (
            icon: "bell.badge.fill",
            title: "Akıllı\nBildirimler",
            subtitle: "Bütçe limitleri, haftalık özetler ve birikim\nhedefleri için otomatik hatırlatıcılar.",
            gradient: [Color(hex: "B45309"), Color(hex: "D97706")]
        ),
    ]

    var body: some View {
        ZStack {
            // Dynamic background
            backgroundForPage(currentPage)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Atla") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                hasCompletedOnboarding = true
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.trailing, 24)
                        .padding(.top, 8)
                    }
                }
                .frame(height: 44)

                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageContent(index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                VStack(spacing: 24) {
                    // Progress bar
                    progressBar

                    // Button
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                hasCompletedOnboarding = true
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Devam" : "Başlayalım")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: pages[currentPage].gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: pages[currentPage].gradient[0].opacity(0.4), radius: 16, y: 8)
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: currentPage)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private func pageContent(_ index: Int) -> some View {
        let page = pages[index]
        VStack(spacing: 40) {
            Spacer()

            // Icon with glow
            ZStack {
                Circle()
                    .fill(page.gradient[0].opacity(0.2))
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)

                Image(systemName: page.icon)
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(colors: page.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .symbolEffect(.bounce, value: currentPage)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(page.subtitle)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index <= currentPage
                            ? AnyShapeStyle(LinearGradient(colors: pages[currentPage].gradient, startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.white.opacity(0.2))
                    )
                    .frame(width: index == currentPage ? 32 : 8, height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private func backgroundForPage(_ page: Int) -> some View {
        ZStack {
            Color(hex: "0A0F1E")

            // Floating gradient orbs
            Circle()
                .fill(pages[page].gradient[0].opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: page == 0 ? -60 : (page == 1 ? 80 : 0), y: -150)
                .animation(.easeInOut(duration: 0.8), value: page)

            Circle()
                .fill(pages[page].gradient[1].opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: page == 0 ? 100 : (page == 1 ? -80 : 60), y: 200)
                .animation(.easeInOut(duration: 0.8), value: page)
        }
    }
}
