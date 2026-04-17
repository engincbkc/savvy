import XCTest
@testable import SavvyFoundation

final class DateYearMonthTests: XCTestCase {

    func testToYearMonth() {
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 15))!
        XCTAssertEqual(date.toYearMonth(), "2025-03")
    }

    func testFromYearMonth() {
        let date = Date.fromYearMonth("2025-03")
        XCTAssertNotNil(date)
        let components = Calendar.current.dateComponents([.year, .month], from: date!)
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 3)
    }

    func testFromYearMonth_invalid() {
        XCTAssertNil(Date.fromYearMonth("invalid"))
        XCTAssertNil(Date.fromYearMonth("2025"))
    }

    func testYearMonthRange() {
        let range = YearMonthRange.from("2025-03")
        XCTAssertNotNil(range)
        let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: range!.start)
        XCTAssertEqual(startComponents.month, 3)
        XCTAssertEqual(startComponents.day, 1)
    }

    func testMonthLabels_full() {
        XCTAssertEqual(MonthLabels.full("2025-03"), "Mart 2025")
        XCTAssertEqual(MonthLabels.full("2025-01"), "Ocak 2025")
    }

    func testMonthLabels_short() {
        XCTAssertEqual(MonthLabels.short("2025-03"), "Mar '25")
    }

    func testMonthLabels_monthName() {
        XCTAssertEqual(MonthLabels.monthName(1), "Ocak")
        XCTAssertEqual(MonthLabels.monthName(12), "Aralık")
    }
}
