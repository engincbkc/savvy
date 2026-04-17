# 02 — Design System: Token Migrasyonu ve Component Library

## Renk Sistemi

### Flutter → Swift Eslesmesi

Flutter'da `SavvyColors` ThemeExtension + `ColorPrimitives` kullaniliyor. Swift'te **Asset Catalog** ile light/dark otomatik yonetilecek.

### Renk Tokenlari

```swift
// SavvyColors.swift — Semantic color extensions
extension Color {
    // ─── Brand ───────────────────────────────────
    static let savvyBrand       = Color("Brand700")      // #1A56DB
    static let savvyBrandDim    = Color("Brand800")      // Flutter: brandPrimaryDim
    static let savvyBrandAccent = Color("Brand500")      // #3F83F8
    static let savvyBrandLight  = Color("Brand50")       // #EBF5FF
    
    // ─── Income (Yesil) ──────────────────────────
    static let savvyIncome          = Color("Income500")      // #0E9F6E
    static let savvyIncomeStrong    = Color("Income700")      // #046C4E
    static let savvyIncomeMuted     = Color("Income400")
    static let savvyIncomeSurface   = Color("Income100")
    static let savvyIncomeSurfaceDim = Color("Income50")
    
    // ─── Expense (Kirmizi) ───────────────────────
    static let savvyExpense          = Color("Expense500")    // #E02424
    static let savvyExpenseStrong    = Color("Expense700")    // #C81E1E
    static let savvyExpenseMuted     = Color("Expense400")
    static let savvyExpenseSurface   = Color("Expense100")
    static let savvyExpenseSurfaceDim = Color("Expense50")
    
    // ─── Savings (Amber) ─────────────────────────
    static let savvySavings          = Color("Savings600")    // #D97706
    static let savvySavingsStrong    = Color("Savings700")    // #B45309
    static let savvySavingsMuted     = Color("Savings400")
    static let savvySavingsSurface   = Color("Savings100")
    static let savvySavingsSurfaceDim = Color("Savings50")
    
    // ─── Status ──────────────────────────────────
    static let savvySuccess = Color("Success")  // Green500
    static let savvyWarning = Color("Warning")  // Amber500
    static let savvyError   = Color("Error")    // Red500
    
    // ─── Text ────────────────────────────────────
    static let savvyTextPrimary   = Color("TextPrimary")    // Light: gray900, Dark: gray50
    static let savvyTextSecondary = Color("TextSecondary")  // Light: gray600, Dark: gray400
    static let savvyTextTertiary  = Color("TextTertiary")   // Light: gray400, Dark: gray500
    static let savvyTextInverse   = Color("TextInverse")    // Light: white,  Dark: gray900
    
    // ─── Surface ─────────────────────────────────
    static let savvySurfaceBackground = Color("SurfaceBackground")  // Light: gray50, Dark: #1a1a1e
    static let savvySurfaceCard       = Color("SurfaceCard")        // Light: white,  Dark: #242428
    static let savvySurfaceElevated   = Color("SurfaceElevated")    // Light: white,  Dark: #2c2c31
    static let savvySurfaceOverlay    = Color("SurfaceOverlay")     // Light: gray100, Dark: #2c2c31
    static let savvySurfaceInput      = Color("SurfaceInput")       // Light: gray50, Dark: #2c2c31
    
    // ─── Border ──────────────────────────────────
    static let savvyBorderDefault = Color("BorderDefault")  // Light: gray200, Dark: #3a3a3f
    static let savvyBorderStrong  = Color("BorderStrong")   // Light: gray300, Dark: #48484d
    static let savvyBorderFocus   = Color("BorderFocus")    // Brand color
}
```

### Dark Mode Asset Catalog Yapisi

```
Assets.xcassets/
├── Colors/
│   ├── Brand/
│   │   ├── Brand700.colorset/    (Light: #1A56DB, Dark: #3F83F8)
│   │   ├── Brand800.colorset/    (Light: #1E429F, Dark: #2563EB)
│   │   └── Brand50.colorset/     (Light: #EBF5FF, Dark: #172554)
│   ├── Income/
│   │   ├── Income500.colorset/   (Light: #0E9F6E, Dark: #34D399)
│   │   └── ...
│   ├── Expense/
│   ├── Savings/
│   ├── Text/
│   ├── Surface/
│   └── Border/
```

### EnvironmentValues ile Injection

```swift
// Alternatif: Struct-based approach (daha esnek)
struct SavvyColorScheme {
    let income: Color
    let incomeStrong: Color
    let expense: Color
    let expenseStrong: Color
    let savings: Color
    let savingsStrong: Color
    // ...
    
    static let light = SavvyColorScheme(...)
    static let dark = SavvyColorScheme(...)
}

private struct SavvyColorSchemeKey: EnvironmentKey {
    static let defaultValue = SavvyColorScheme.light
}

extension EnvironmentValues {
    var savvyColors: SavvyColorScheme {
        get { self[SavvyColorSchemeKey.self] }
        set { self[SavvyColorSchemeKey.self] = newValue }
    }
}

// Root'ta set et
ContentView()
    .environment(\.savvyColors, colorScheme == .dark ? .dark : .light)

// View'da kullan
@Environment(\.savvyColors) private var colors
```

## Tipografi

### Flutter → Swift Eslesmesi

Flutter'da `Inter` font + `FontFeature.tabularFigures()` kullaniliyor. Swift'te system font `.rounded` design + `.monospacedDigit()` kullanilacak.

```swift
// SavvyTypography.swift
extension Font {
    // ─── Numeric (Para tutarlari) ────────────────
    static let savvyNumericHero = Font.system(size: 44, weight: .heavy, design: .rounded)
        .monospacedDigit()
    // Flutter: numericHero (44px, w800, tabularFigures)
    
    static let savvyNumericLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        .monospacedDigit()
    // Flutter: numericLarge (28px, w700)
    
    static let savvyNumericMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
        .monospacedDigit()
    // Flutter: numericMedium (20px, w600)
    
    static let savvyNumericSmall = Font.system(size: 14, weight: .medium, design: .rounded)
        .monospacedDigit()
    // Flutter: numericSmall (14px, w500)
    
    // ─── Headline ────────────────────────────────
    static let savvyHeadlineLarge  = Font.system(size: 26, weight: .bold)
    static let savvyHeadlineMedium = Font.system(size: 22, weight: .bold)
    static let savvyHeadlineSmall  = Font.system(size: 18, weight: .semibold)
    
    // ─── Title ───────────────────────────────────
    static let savvyTitleLarge  = Font.system(size: 16, weight: .semibold)
    static let savvyTitleMedium = Font.system(size: 15, weight: .medium)
    static let savvyTitleSmall  = Font.system(size: 13, weight: .semibold)
    
    // ─── Body ────────────────────────────────────
    static let savvyBodyLarge  = Font.system(size: 16, weight: .regular)
    static let savvyBodyMedium = Font.system(size: 14, weight: .regular)
    static let savvyBodySmall  = Font.system(size: 12, weight: .regular)
    
    // ─── Label ───────────────────────────────────
    static let savvyLabelLarge  = Font.system(size: 14, weight: .semibold)
    static let savvyLabelMedium = Font.system(size: 12, weight: .semibold)
    static let savvyLabelSmall  = Font.system(size: 11, weight: .medium)
    
    // ─── Caption ─────────────────────────────────
    static let savvyCaption = Font.system(size: 11, weight: .regular)
}
```

### Dynamic Type Destegi

```swift
// @ScaledMetric ile spacing'ler de olceklenir
@ScaledMetric(relativeTo: .body) private var cardPadding: CGFloat = 16

// Font'lar otomatik olceklenir (.system kullanildiginda)
// Custom Inter font istenirse:
static let savvyHeadlineLarge = Font.custom("Inter", size: 26, relativeTo: .title)
```

## Spacing Sistemi

Flutter'daki 4px grid aynen korunacak:

```swift
// SavvySpacing.swift
enum SavvySpacing {
    static let xs:   CGFloat = 4    // Flutter: AppSpacing.xs
    static let sm:   CGFloat = 8    // Flutter: AppSpacing.sm
    static let md:   CGFloat = 12   // Flutter: AppSpacing.md
    static let base: CGFloat = 16   // Flutter: AppSpacing.base
    static let lg:   CGFloat = 20   // Flutter: AppSpacing.lg
    static let xl:   CGFloat = 24   // Flutter: AppSpacing.xl
    static let xl2:  CGFloat = 32   // Flutter: AppSpacing.xl2
    static let xl3:  CGFloat = 40   // Flutter: AppSpacing.xl3
    static let xl4:  CGFloat = 48   // Flutter: AppSpacing.xl4
    static let xl5:  CGFloat = 64   // Flutter: AppSpacing.xl5
    
    // Ready-made EdgeInsets
    static let screenH = EdgeInsets(top: 0, leading: lg, bottom: 0, trailing: lg)
    static let screen  = EdgeInsets(top: base, leading: lg, bottom: base, trailing: lg)
    static let card    = EdgeInsets(top: base, leading: base, bottom: base, trailing: base)
    static let section = EdgeInsets(top: xl, leading: lg, bottom: xl, trailing: lg)
    
    // Touch targets
    static let minTouchTarget: CGFloat = 48
    static let bottomNavHeight: CGFloat = 64
}
```

## Radius ve Shadow

```swift
// SavvyRadius.swift
enum SavvyRadius {
    static let xs:     CGFloat = 4
    static let sm:     CGFloat = 8
    static let md:     CGFloat = 12   // Card default
    static let lg:     CGFloat = 16   // Large card
    static let xl:     CGFloat = 20
    static let full:   CGFloat = 999  // Pill shape
}

// SavvyShadow.swift — ViewModifier olarak
struct SavvyShadow: ViewModifier {
    enum Level { case xs, sm, md, lg }
    let level: Level
    
    func body(content: Content) -> some View {
        switch level {
        case .xs: content.shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        case .sm: content.shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        case .md: content.shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        case .lg: content.shadow(color: .black.opacity(0.12), radius: 16, y: 8)
        }
    }
}

extension View {
    func savvyShadow(_ level: SavvyShadow.Level) -> some View {
        modifier(SavvyShadow(level: level))
    }
}
```

## Animasyon Tokenlari

```swift
// SavvyAnimation.swift
extension Animation {
    // Flutter AppDuration + AppCurve karsiliklari
    static let savvyInstant  = Animation.easeInOut(duration: 0.08)
    static let savvyFast     = Animation.easeInOut(duration: 0.15)
    static let savvyNormal   = Animation.easeInOut(duration: 0.25)
    static let savvyModerate = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let savvySlow     = Animation.spring(response: 0.5, dampingFraction: 0.7)
    
    // Ozel animasyonlar
    static let savvyCountUp  = Animation.spring(response: 0.9, dampingFraction: 0.85)
    static let savvyEnter    = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let savvyBounce   = Animation.spring(response: 0.35, dampingFraction: 0.5)
    static let savvyOvershoot = Animation.spring(response: 0.4, dampingFraction: 0.6)
}
```

## Component Library

### SavvyCard

```swift
struct SavvyCard<Content: View>: View {
    let style: CardStyle
    @ViewBuilder let content: () -> Content
    
    enum CardStyle {
        case standard
        case income
        case expense
        case savings
        case elevated
    }
    
    var body: some View {
        content()
            .padding(SavvySpacing.card)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SavvyRadius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
            .savvyShadow(.sm)
    }
}
```

### SavvyHeroNumber (Animated Count-Up)

```swift
struct SavvyHeroNumber: View {
    let amount: Decimal
    let style: Font
    let color: Color
    
    var body: some View {
        Text(amount, format: .currency(code: "TRY").precision(.fractionLength(0)))
            .font(style)
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(countsDown: false))
            .animation(.savvyCountUp, value: amount)
    }
}
// Flutter'daki TweenAnimationBuilder<double> + CurrencyFormatter.format() 
// yerine tek satir SwiftUI
```

### SavvyShimmer (Loading Skeleton)

```swift
struct SavvyShimmer: ViewModifier {
    @State private var phase = false
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase ? 400 : -400)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = true
                }
            }
    }
}

extension View {
    func savvyShimmer() -> some View {
        modifier(SavvyShimmer())
    }
}
```

### SavvyProgressRing

```swift
struct SavvyProgressRing: View {
    let progress: Double  // 0.0 – 1.0
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.savvyModerate, value: progress)
        }
    }
}
```

## Haptic Feedback Sistemi

Flutter'daki `HapticFeedback.lightImpact()` yerine contextual haptics:

```swift
// Kullanim ornekleri:

// Tab degisimi
TabView(selection: $tab) { ... }
    .sensoryFeedback(.selection, trigger: tab)

// Basarili kaydetme
Button("Kaydet") { save() }
    .sensoryFeedback(.success, trigger: saveCompleted)

// Butce asimi uyarisi
BudgetCard(budget)
    .sensoryFeedback(.warning, trigger: budgetExceeded)

// Silme onay
Button(role: .destructive) { delete() }
    .sensoryFeedback(.impact(weight: .medium), trigger: deleted)

// Hata
ErrorView()
    .sensoryFeedback(.error, trigger: errorOccurred)
```

## Staggered Entry Animasyonu

Flutter'daki `_StaggeredEntry` widget'inin SwiftUI karsiligi:

```swift
struct StaggeredEntry: ViewModifier {
    let index: Int
    let delay: Double
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .savvyEnter.delay(Double(index) * delay),
                value: appeared
            )
            .onAppear { appeared = true }
    }
}

extension View {
    func staggeredEntry(index: Int, delay: Double = 0.08) -> some View {
        modifier(StaggeredEntry(index: index, delay: delay))
    }
}

// Kullanim
ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
    section.view
        .staggeredEntry(index: index)
}
```
