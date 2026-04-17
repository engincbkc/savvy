# 08 — Testing: Unit, Snapshot, UI Test Stratejisi

## Mevcut Flutter Testleri

Flutter'da 9/9 passing test var:
- `FinancialCalculator`: netBalance, savingsRate, monthlyLoanPayment, financialHealthScore
- `flutter analyze` → 0 issue

Swift'te bunlari koruyup genisleteceğiz.

---

## Test Piramidi

```
         ┌──────────┐
         │  UI Test  │  ← XCUITest (kritik flow'lar)
         │   (az)    │
        ┌┴──────────┴┐
        │  Snapshot   │  ← swift-snapshot-testing (her component)
        │   (orta)    │
       ┌┴────────────┴┐
       │   Unit Test   │  ← XCTest (tum business logic)
       │    (cok)      │
       └──────────────┘
```

---

## 1. Unit Tests

### FinancialCalculator Tests

```swift
// FinancialCalculatorTests.swift
import XCTest
@testable import SavvyFoundation

final class FinancialCalculatorTests: XCTestCase {
    
    // ─── Core Summary ────────────────────────────────
    
    func testNetBalance_incomeMinusExpense() {
        let result = FinancialCalculator.netBalance(
            totalIncome: 50000, totalExpense: 30000, totalSavings: 5000
        )
        XCTAssertEqual(result, 20000)  // Birikim dusulmez
    }
    
    func testNetBalance_zeroIncome() {
        let result = FinancialCalculator.netBalance(
            totalIncome: 0, totalExpense: 1000, totalSavings: 0
        )
        XCTAssertEqual(result, -1000)
    }
    
    func testExpenseRatio() {
        let ratio = FinancialCalculator.expenseRatio(totalExpense: 30000, totalIncome: 50000)
        XCTAssertEqual(ratio, 0.6, accuracy: 0.001)
    }
    
    func testExpenseRatio_zeroIncome() {
        let ratio = FinancialCalculator.expenseRatio(totalExpense: 5000, totalIncome: 0)
        XCTAssertEqual(ratio, 0.0)
    }
    
    func testSavingsRate() {
        let rate = FinancialCalculator.savingsRate(totalSavings: 10000, totalIncome: 50000)
        XCTAssertEqual(rate, 0.2, accuracy: 0.001)
    }
    
    // ─── Health Score ────────────────────────────────
    
    func testHealthScore_perfect() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.30, expenseRatio: 0.40,
            netBalance: 10000, emergencyFundMonths: 8
        )
        XCTAssertEqual(score, 100)  // 35 + 30 + 20 + 15
    }
    
    func testHealthScore_critical() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.02, expenseRatio: 0.95,
            netBalance: -5000, emergencyFundMonths: 0
        )
        XCTAssertEqual(score, 0)
    }
    
    func testHealthScore_medium() {
        let score = FinancialCalculator.financialHealthScore(
            savingsRate: 0.15, expenseRatio: 0.65,
            netBalance: 5000, emergencyFundMonths: 2
        )
        XCTAssertEqual(score, 63)  // 20 + 18 + 20 + 5
    }
    
    func testHealthScoreLabel() {
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(85), "Mukemmel")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(70), "Iyi")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(50), "Orta")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(35), "Dikkat")
        XCTAssertEqual(FinancialCalculator.healthScoreLabel(20), "Kritik")
    }
    
    // ─── Loan Calculation ────────────────────────────
    
    func testMonthlyLoanPayment() {
        let emi = FinancialCalculator.monthlyLoanPayment(
            principal: 100000, annualRate: 0.24, termMonths: 12
        )
        // Beklenen: ~9,456 TL (aylik)
        XCTAssertEqual(NSDecimalNumber(decimal: emi).doubleValue, 9456, accuracy: 50)
    }
    
    func testMonthlyLoanPayment_zeroRate() {
        let emi = FinancialCalculator.monthlyLoanPayment(
            principal: 12000, annualRate: 0, termMonths: 12
        )
        XCTAssertEqual(emi, 1000)
    }
    
    func testLoanAffordability() {
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 5000, monthlyIncome: 50000),
            .comfortable  // %10
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 15000, monthlyIncome: 50000),
            .manageable  // %30
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 20000, monthlyIncome: 50000),
            .tight  // %40
        )
        XCTAssertEqual(
            FinancialCalculator.loanAffordability(monthlyPayment: 25000, monthlyIncome: 50000),
            .risky  // %50
        )
    }
    
    // ─── Savings Goal ────────────────────────────────
    
    func testMonthsToGoal() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 20000, monthlySavings: 5000
        )
        XCTAssertEqual(months, 16)  // 80000 / 5000 = 16
    }
    
    func testMonthsToGoal_alreadyReached() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 150000, monthlySavings: 5000
        )
        XCTAssertEqual(months, 0)
    }
    
    func testMonthsToGoal_zeroSavings() {
        let months = FinancialCalculator.monthsToGoal(
            targetAmount: 100000, currentAmount: 20000, monthlySavings: 0
        )
        XCTAssertEqual(months, -1)
    }
    
    func testGoalProgress() {
        let progress = FinancialCalculator.goalProgress(
            targetAmount: 100000, currentAmount: 75000
        )
        XCTAssertEqual(progress, 0.75, accuracy: 0.001)
    }
    
    // ─── Credit Tax ──────────────────────────────────
    
    func testRealAnnualRateWithTaxes() {
        let rate = FinancialCalculator.realAnnualRateWithTaxes(Decimal(0.24))
        // 0.24 * 1.25 = 0.30
        XCTAssertEqual(rate, Decimal(0.30))
    }
    
    func testCreditTaxAmount() {
        let tax = FinancialCalculator.creditTaxAmount(Decimal(10000))
        XCTAssertEqual(tax, Decimal(2500))  // %25
    }
}
```

### Gross-to-Net Salary Tests

```swift
final class SalaryCalculatorTests: XCTestCase {
    
    func testGrossToNet_asgariUcret() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 33030)
        let jan = breakdown.months[0]
        // Asgari ucret icin Ocak net: ~28,058 TL (verginet.net dogrulamasi)
        XCTAssertEqual(
            NSDecimalNumber(decimal: jan.netTakeHome).doubleValue,
            28058, accuracy: 100
        )
    }
    
    func testGrossToNet_50K() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 50000)
        let jan = breakdown.months[0]
        let dec = breakdown.months[11]
        
        // Ocak net > Aralik net (vergi dilimi artisi)
        XCTAssertGreaterThan(jan.netTakeHome, dec.netTakeHome)
        
        // 12 ay toplamda net < gross
        XCTAssertLessThan(breakdown.totalNet, breakdown.totalGross)
    }
    
    func testGrossToNet_sgkTavan() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 400000)
        // SGK matrahi tavan: 297270
        let jan = breakdown.months[0]
        let expectedSgk = Decimal(297270) * Decimal(0.14)
        XCTAssertEqual(jan.sgk, expectedSgk)
    }
    
    func testGrossToNet_taxBracketProgression() {
        let breakdown = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 100000)
        // Yil icinde vergi dilimi degisir
        // Ilk ay %15, sonra %20, sonra %27...
        XCTAssertEqual(breakdown.months[0].taxBracketRate, Decimal(0.15))
        // Son aylarda daha yuksek dilim
        XCTAssertGreaterThan(breakdown.months[11].taxBracketRate, Decimal(0.15))
    }
    
    func testResolveNetForMonth_notGross() {
        let net = FinancialCalculator.resolveNetForMonth(amount: 50000, isGross: false, month: 6)
        XCTAssertEqual(net, 50000)  // Brut degilse dogrudan doner
    }
    
    func testResolveAllMonths_gross() {
        let months = FinancialCalculator.resolveAllMonths(amount: 50000, isGross: true)
        XCTAssertEqual(months.count, 12)
        // Her ay farkli net (vergi dilimi)
        XCTAssertNotEqual(months[0], months[11])
    }
}
```

### CurrencyFormatter Tests

```swift
final class CurrencyFormatterTests: XCTestCase {
    func testFormat() {
        XCTAssertTrue(CurrencyFormatter.format(1250).contains("1.250"))
    }
    
    func testCompact_million() {
        XCTAssertEqual(CurrencyFormatter.compact(1_200_000), "₺1,2M")
    }
    
    func testCompact_thousand() {
        XCTAssertEqual(CurrencyFormatter.compact(50_000), "₺50K")
    }
    
    func testParse() {
        XCTAssertEqual(CurrencyFormatter.parse("₺1.250,50"), Decimal(string: "1250.50"))
        XCTAssertEqual(CurrencyFormatter.parse("1250"), Decimal(1250))
        XCTAssertNil(CurrencyFormatter.parse("abc"))
    }
    
    func testWithSign() {
        XCTAssertTrue(CurrencyFormatter.withSign(1000).hasPrefix("+"))
        XCTAssertTrue(CurrencyFormatter.withSign(-500).contains("-"))
    }
}
```

### TransactionValidator Tests

```swift
final class TransactionValidatorTests: XCTestCase {
    func testValidateAmount_valid() {
        if case .ok(let amount) = TransactionValidator.validateAmount("1250") {
            XCTAssertEqual(amount, 1250)
        } else {
            XCTFail("Should be valid")
        }
    }
    
    func testValidateAmount_tooLarge() {
        if case .error = TransactionValidator.validateAmount("15000000") {
            // OK
        } else {
            XCTFail("Should reject > 10M")
        }
    }
    
    func testValidateAmount_negative() {
        if case .error = TransactionValidator.validateAmount("-100") {
            // OK
        } else {
            XCTFail("Should reject negative")
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
}
```

---

## 2. ViewModel Tests

### Mock Repository

```swift
// MockRepository.swift (test target'da)
final class MockRepository<T: Codable & Identifiable & SoftDeletable>: Repository {
    typealias Entity = T
    
    var items: [T] = []
    var addedItems: [T] = []
    var deletedIds: [String] = []
    
    func watch() -> AsyncStream<[T]> {
        AsyncStream { continuation in
            continuation.yield(items)
        }
    }
    
    func watchMonth(_ yearMonth: String) -> AsyncStream<[T]> { watch() }
    func get(id: String) async throws -> T? { items.first { $0.id as? String == id } }
    func add(_ entity: T) async throws { addedItems.append(entity) }
    func update(_ entity: T) async throws { /* track */ }
    func softDelete(id: String) async throws { deletedIds.append(id) }
}
```

### DashboardViewModel Tests

```swift
final class DashboardViewModelTests: XCTestCase {
    func testMonthSummary_computesCorrectly() async {
        let incomeRepo = MockRepository<Income>()
        incomeRepo.items = [
            Income(amount: 50000, category: .salary, date: .now),
        ]
        
        let expenseRepo = MockRepository<Expense>()
        expenseRepo.items = [
            Expense(amount: 20000, category: .rent, date: .now),
        ]
        
        let savingsRepo = MockRepository<Savings>()
        savingsRepo.items = [
            Savings(amount: 5000, category: .emergency, date: .now),
        ]
        
        let vm = DashboardViewModel(
            incomeRepo: incomeRepo,
            expenseRepo: expenseRepo,
            savingsRepo: savingsRepo
        )
        
        // Trigger observation
        // Assert computed properties
        XCTAssertNotNil(vm.monthSummary)
    }
}
```

---

## 3. Snapshot Tests

### Setup

```swift
// Package.swift dependency
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")
```

### Component Snapshots

```swift
import SnapshotTesting
import SwiftUI

final class DesignSystemSnapshotTests: XCTestCase {
    
    func testSavvyCard_light() {
        let view = SavvyCard(style: .income) {
            Text("Test Card")
        }
        .frame(width: 300)
        .environment(\.colorScheme, .light)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSavvyCard_dark() {
        let view = SavvyCard(style: .income) {
            Text("Test Card")
        }
        .frame(width: 300)
        .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSavvyHeroNumber() {
        let view = SavvyHeroNumber(
            amount: 24350, style: .savvyNumericHero, color: .savvyIncome
        )
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testTransactionRow() {
        let expense = Expense(
            amount: 1500, category: .market,
            date: .now, note: "Haftalik alisveris"
        )
        let view = TransactionRow(transaction: expense)
            .frame(width: 375)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testBudgetProgressCard_normal() {
        // progress < 60%
        assertSnapshot(of: makeBudgetCard(ratio: 0.4), as: .image)
    }
    
    func testBudgetProgressCard_warning() {
        // progress 60-80%
        assertSnapshot(of: makeBudgetCard(ratio: 0.75), as: .image)
    }
    
    func testBudgetProgressCard_exceeded() {
        // progress > 100%
        assertSnapshot(of: makeBudgetCard(ratio: 1.2), as: .image)
    }
}
```

### Dynamic Type Snapshots

```swift
func testTransactionRow_accessibilityXXL() {
    let view = TransactionRow(transaction: sampleExpense)
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        .frame(width: 375)
    
    assertSnapshot(of: view, as: .image)
}
```

---

## 4. UI Tests (XCUITest)

### Kritik Flow'lar

```swift
final class SavvyUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]  // Mock Firebase
        app.launch()
    }
    
    func testLoginFlow() {
        // Email gir
        let emailField = app.textFields["E-posta"]
        emailField.tap()
        emailField.typeText("test@test.com")
        
        // Sifre gir
        let passwordField = app.secureTextFields["Sifre"]
        passwordField.tap()
        passwordField.typeText("test123")
        
        // Giris yap
        app.buttons["Giris Yap"].tap()
        
        // Dashboard gorunmeli
        XCTAssertTrue(app.staticTexts["Ana Sayfa"].waitForExistence(timeout: 5))
    }
    
    func testAddExpenseFlow() {
        // Tab'a git
        app.tabBars.buttons["Islemler"].tap()
        
        // Add butonuna bas
        app.buttons["plus"].tap()
        
        // Tutar gir
        let amountField = app.textFields["Tutar"]
        amountField.tap()
        amountField.typeText("1500")
        
        // Kaydet
        app.buttons["Kaydet"].tap()
        
        // Liste'de gorunmeli
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "₺1.500").element.exists)
    }
    
    func testNavigationBetweenTabs() {
        // Dashboard
        XCTAssertTrue(app.tabBars.buttons["Ana Sayfa"].isSelected)
        
        // Transactions
        app.tabBars.buttons["Islemler"].tap()
        XCTAssertTrue(app.tabBars.buttons["Islemler"].isSelected)
        
        // Simulation
        app.tabBars.buttons["Simulasyon"].tap()
        XCTAssertTrue(app.tabBars.buttons["Simulasyon"].isSelected)
        
        // Settings
        app.tabBars.buttons["Ayarlar"].tap()
        XCTAssertTrue(app.tabBars.buttons["Ayarlar"].isSelected)
    }
}
```

---

## 5. Preview-Driven Development

Her SwiftUI view'in `#Preview` olmali:

```swift
#Preview("Dashboard - Loading") {
    DashboardView()
        .environment(Dependencies.mock)
}

#Preview("Dashboard - Data") {
    DashboardView()
        .environment(Dependencies.mockWithData)
}

#Preview("Dashboard - Empty") {
    DashboardView()
        .environment(Dependencies.mockEmpty)
}

#Preview("Dashboard - Dark") {
    DashboardView()
        .environment(Dependencies.mockWithData)
        .preferredColorScheme(.dark)
}
```

### Mock Dependencies

```swift
extension Dependencies {
    static var mock: Dependencies {
        Dependencies(
            auth: MockAuthService(),
            incomeRepo: MockRepository<Income>(),
            expenseRepo: MockRepository<Expense>(),
            savingsRepo: MockRepository<Savings>(),
            // ...
        )
    }
    
    static var mockWithData: Dependencies {
        let deps = Dependencies.mock
        (deps.incomeRepo as! MockRepository<Income>).items = Income.samples
        (deps.expenseRepo as! MockRepository<Expense>).items = Expense.samples
        return deps
    }
}

extension Income {
    static var samples: [Income] {
        [
            Income(amount: 50000, category: .salary, person: "Zeynep", date: .now, isGross: true),
            Income(amount: 5000, category: .freelance, date: .now),
        ]
    }
}
```

---

## Test Coverage Hedefleri

| Katman | Hedef | Aciklama |
|--------|-------|----------|
| FinancialCalculator | %100 | Tum public method'lar |
| TransactionValidator | %100 | Tum validation case'leri |
| CurrencyFormatter | %100 | Tum format/parse case'leri |
| SimulationCalculator | %90+ | Tum change type'lar + edge case'ler |
| MonthSummaryAggregator | %90+ | Recurring, overrides, carry-over |
| ViewModels | %80+ | Happy path + error states |
| Design System Components | Snapshot | Light + dark + accessibility |
| Kritik UI Flow'lar | XCUITest | Login, add transaction, navigation |
