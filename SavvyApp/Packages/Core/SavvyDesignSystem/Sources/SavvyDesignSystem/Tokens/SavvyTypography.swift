import SwiftUI

extension Font {
    // MARK: - Numeric (Money amounts)
    public static let savvyNumericHero = Font.system(size: 44, weight: .heavy, design: .rounded)
        .monospacedDigit()
    public static let savvyNumericLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        .monospacedDigit()
    public static let savvyNumericMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
        .monospacedDigit()
    public static let savvyNumericSmall = Font.system(size: 14, weight: .medium, design: .rounded)
        .monospacedDigit()

    // MARK: - Headline
    public static let savvyHeadlineLarge  = Font.system(size: 26, weight: .bold)
    public static let savvyHeadlineMedium = Font.system(size: 22, weight: .bold)
    public static let savvyHeadlineSmall  = Font.system(size: 18, weight: .semibold)

    // MARK: - Title
    public static let savvyTitleLarge  = Font.system(size: 16, weight: .semibold)
    public static let savvyTitleMedium = Font.system(size: 15, weight: .medium)
    public static let savvyTitleSmall  = Font.system(size: 13, weight: .semibold)

    // MARK: - Body
    public static let savvyBodyLarge  = Font.system(size: 16, weight: .regular)
    public static let savvyBodyMedium = Font.system(size: 14, weight: .regular)
    public static let savvyBodySmall  = Font.system(size: 12, weight: .regular)

    // MARK: - Label
    public static let savvyLabelLarge  = Font.system(size: 14, weight: .semibold)
    public static let savvyLabelMedium = Font.system(size: 12, weight: .semibold)
    public static let savvyLabelSmall  = Font.system(size: 11, weight: .medium)

    // MARK: - Caption
    public static let savvyCaption = Font.system(size: 11, weight: .regular)
}
