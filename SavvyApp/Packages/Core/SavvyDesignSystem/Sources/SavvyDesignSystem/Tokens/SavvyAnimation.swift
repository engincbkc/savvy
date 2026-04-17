import SwiftUI

extension Animation {
    public static let savvyInstant  = Animation.easeInOut(duration: 0.08)
    public static let savvyFast     = Animation.easeInOut(duration: 0.15)
    public static let savvyNormal   = Animation.easeInOut(duration: 0.25)
    public static let savvyModerate = Animation.spring(response: 0.35, dampingFraction: 0.8)
    public static let savvySlow     = Animation.spring(response: 0.5, dampingFraction: 0.7)

    public static let savvyCountUp   = Animation.spring(response: 0.9, dampingFraction: 0.85)
    public static let savvyEnter     = Animation.spring(response: 0.4, dampingFraction: 0.75)
    public static let savvyBounce    = Animation.spring(response: 0.35, dampingFraction: 0.5)
    public static let savvyOvershoot = Animation.spring(response: 0.4, dampingFraction: 0.6)
}
