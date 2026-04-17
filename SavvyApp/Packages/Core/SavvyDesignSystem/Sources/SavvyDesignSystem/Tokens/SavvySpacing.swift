import SwiftUI

public enum SavvySpacing {
    public static let xs:   CGFloat = 4
    public static let sm:   CGFloat = 8
    public static let md:   CGFloat = 12
    public static let base: CGFloat = 16
    public static let lg:   CGFloat = 20
    public static let xl:   CGFloat = 24
    public static let xl2:  CGFloat = 32
    public static let xl3:  CGFloat = 40
    public static let xl4:  CGFloat = 48
    public static let xl5:  CGFloat = 64

    public static let screenH = EdgeInsets(top: 0, leading: lg, bottom: 0, trailing: lg)
    public static let screen  = EdgeInsets(top: base, leading: lg, bottom: base, trailing: lg)
    public static let card    = EdgeInsets(top: base, leading: base, bottom: base, trailing: base)
    public static let section = EdgeInsets(top: xl, leading: lg, bottom: xl, trailing: lg)

    public static let minTouchTarget: CGFloat = 48
    public static let bottomNavHeight: CGFloat = 64
}
