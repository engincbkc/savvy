import XCTest
@testable import SavvyFoundation

final class TransactionValidatorTests: XCTestCase {

    func testValidateAmount_valid() {
        if case .ok(let amount) = TransactionValidator.validateAmount("1250") {
            XCTAssertEqual(amount, 1250)
        } else {
            XCTFail("Should be valid")
        }
    }

    func testValidateAmount_withComma() {
        if case .ok(let amount) = TransactionValidator.validateAmount("1250,50") {
            XCTAssertEqual(amount, Decimal(string: "1250.50"))
        } else {
            XCTFail("Should be valid")
        }
    }

    func testValidateAmount_empty() {
        if case .error(let msg) = TransactionValidator.validateAmount("") {
            XCTAssertEqual(msg, "Tutar giriniz")
        } else {
            XCTFail("Should be error")
        }
    }

    func testValidateAmount_nil() {
        if case .error = TransactionValidator.validateAmount(nil) {
            // OK
        } else {
            XCTFail("Should be error")
        }
    }

    func testValidateAmount_negative() {
        if case .error = TransactionValidator.validateAmount("-100") {
            // OK
        } else {
            XCTFail("Should reject negative")
        }
    }

    func testValidateAmount_tooLarge() {
        if case .error = TransactionValidator.validateAmount("15000000") {
            // OK
        } else {
            XCTFail("Should reject > 10M")
        }
    }

    func testValidateAmount_zero() {
        if case .error = TransactionValidator.validateAmount("0") {
            // OK
        } else {
            XCTFail("Should reject zero")
        }
    }

    func testValidateNote_valid() {
        if case .ok(let note) = TransactionValidator.validateNote("Test note") {
            XCTAssertEqual(note, "Test note")
        } else {
            XCTFail("Should be valid")
        }
    }

    func testValidateNote_nil() {
        if case .ok(let note) = TransactionValidator.validateNote(nil) {
            XCTAssertNil(note)
        } else {
            XCTFail("Should be ok with nil")
        }
    }

    func testValidateNote_tooLong() {
        let longNote = String(repeating: "a", count: 201)
        if case .error = TransactionValidator.validateNote(longNote) {
            // OK
        } else {
            XCTFail("Should reject > 200 chars")
        }
    }

    func testValidateDate_valid() {
        if case .ok = TransactionValidator.validateDate(Date()) {
            // OK
        } else {
            XCTFail("Should be valid")
        }
    }

    func testValidateDate_nil() {
        if case .error = TransactionValidator.validateDate(nil) {
            // OK
        } else {
            XCTFail("Should be error")
        }
    }
}
