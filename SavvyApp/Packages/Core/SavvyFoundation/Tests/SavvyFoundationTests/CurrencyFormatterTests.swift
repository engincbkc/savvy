import XCTest
@testable import SavvyFoundation

final class CurrencyFormatterTests: XCTestCase {

    func testFormat() {
        let result = CurrencyFormatter.format(1250)
        XCTAssertTrue(result.contains("1.250"))
    }

    func testFormatNoDecimal() {
        let result = CurrencyFormatter.formatNoDecimal(1250)
        XCTAssertTrue(result.contains("1.250"))
        XCTAssertFalse(result.contains(",00"))
    }

    func testCompact_million() {
        XCTAssertEqual(CurrencyFormatter.compact(1_200_000), "₺1,2M")
    }

    func testCompact_thousand() {
        XCTAssertEqual(CurrencyFormatter.compact(50_000), "₺50K")
    }

    func testCompact_small() {
        let result = CurrencyFormatter.compact(500)
        XCTAssertTrue(result.contains("500"))
    }

    func testWithSign_positive() {
        let result = CurrencyFormatter.withSign(1000)
        XCTAssertTrue(result.hasPrefix("+"))
    }

    func testWithSign_negative() {
        let result = CurrencyFormatter.withSign(-500)
        XCTAssertTrue(result.contains("-"))
    }

    func testPercent() {
        let result = CurrencyFormatter.percent(0.385)
        XCTAssertEqual(result, "%38,5")
    }

    func testChangePercent_positive() {
        let result = CurrencyFormatter.changePercent(0.052)
        XCTAssertEqual(result, "+%5,2")
    }

    func testChangePercent_negative() {
        let result = CurrencyFormatter.changePercent(-0.031)
        XCTAssertEqual(result, "-%3,1")
    }

    func testParse_standard() {
        XCTAssertEqual(CurrencyFormatter.parse("1250"), Decimal(1250))
    }

    func testParse_withSymbol() {
        XCTAssertEqual(CurrencyFormatter.parse("₺1.250,50"), Decimal(string: "1250.50"))
    }

    func testParse_invalid() {
        XCTAssertNil(CurrencyFormatter.parse("abc"))
    }

    func testParse_empty() {
        XCTAssertNil(CurrencyFormatter.parse(""))
    }
}
