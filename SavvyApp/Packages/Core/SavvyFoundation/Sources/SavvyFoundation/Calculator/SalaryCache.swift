import Foundation

public actor SalaryCache {
    public static let shared = SalaryCache()

    private var cache: [Decimal: AnnualSalaryBreakdown] = [:]

    public func get(gross: Decimal) -> AnnualSalaryBreakdown? {
        cache[gross]
    }

    public func set(gross: Decimal, _ breakdown: AnnualSalaryBreakdown) {
        cache[gross] = breakdown
    }

    public func clear() {
        cache.removeAll()
    }
}
