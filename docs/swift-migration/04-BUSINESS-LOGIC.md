# 04 — Business Logic: Calculator, Aggregator, Formatter Portlari

## Demir Kural: BL-001

> Tum hesaplamalar `FinancialCalculator` sinifinda. UI hesaplama yapmaz. Repository hesaplama yapmaz.

Bu kural Swift'te de aynen gecerli. Tum hesaplamalar `SavvyFoundation` paketindeki pure function'larda yasayacak.

## FinancialCalculator

Flutter: `lib/core/utils/financial_calculator.dart`
Swift: `Packages/Core/SavvyFoundation/Sources/Calculator/FinancialCalculator.swift`

### Core Summary Functions

```swift
enum FinancialCalculator {
    // ─── Net Balance ─────────────────────────────────
    /// Birikim dusulmez — birikim yatirim/tasarruftur, kayip degil.
    static func netBalance(
        totalIncome: Decimal,
        totalExpense: Decimal,
        totalSavings: Decimal
    ) -> Decimal {
        precondition(totalIncome >= 0, "Income cannot be negative")
        precondition(totalExpense >= 0, "Expense cannot be negative")
        precondition(totalSavings >= 0, "Savings cannot be negative")
        return totalIncome - totalExpense
    }
    
    static func netWithCarryOver(netBalance: Decimal, carryOver: Decimal) -> Decimal {
        netBalance + carryOver
    }
    
    static func expenseRatio(totalExpense: Decimal, totalIncome: Decimal) -> Double {
        guard totalIncome > 0 else { return 0.0 }
        return NSDecimalNumber(decimal: totalExpense / totalIncome).doubleValue
    }
    
    static func savingsRate(totalSavings: Decimal, totalIncome: Decimal) -> Double {
        guard totalIncome > 0 else { return 0.0 }
        return NSDecimalNumber(decimal: totalSavings / totalIncome).doubleValue
    }
    
    static func targetSavings(totalIncome: Decimal, targetRate: Decimal = 0.20) -> Decimal {
        totalIncome * targetRate
    }
}
```

### Financial Health Score (0–100)

```swift
extension FinancialCalculator {
    static func financialHealthScore(
        savingsRate: Double,
        expenseRatio: Double,
        netBalance: Decimal,
        emergencyFundMonths: Double
    ) -> Int {
        var score = 0
        
        // Savings rate (max 35 pts)
        switch savingsRate {
        case 0.25...: score += 35
        case 0.20...: score += 28
        case 0.15...: score += 20
        case 0.10...: score += 12
        case 0.05...: score += 5
        default: break
        }
        
        // Expense ratio (max 30 pts)
        switch expenseRatio {
        case ...0.50: score += 30
        case ...0.60: score += 25
        case ...0.70: score += 18
        case ...0.80: score += 10
        case ...0.90: score += 4
        default: break
        }
        
        // Net balance (max 20 pts)
        if netBalance > 0 { score += 20 }
        else if netBalance == 0 { score += 8 }
        
        // Emergency fund (max 15 pts)
        switch emergencyFundMonths {
        case 6...: score += 15
        case 3...: score += 10
        case 1...: score += 5
        default: break
        }
        
        return min(max(score, 0), 100)
    }
    
    static func healthScoreLabel(_ score: Int) -> String {
        switch score {
        case 80...: "Mukemmel"
        case 65...: "Iyi"
        case 50...: "Orta"
        case 35...: "Dikkat"
        default: "Kritik"
        }
    }
}
```

### Savings Goal Functions

```swift
extension FinancialCalculator {
    static func monthsToGoal(
        targetAmount: Decimal, currentAmount: Decimal, monthlySavings: Decimal
    ) -> Int {
        guard monthlySavings > 0 else { return -1 }
        let remaining = targetAmount - currentAmount
        guard remaining > 0 else { return 0 }
        let months = NSDecimalNumber(decimal: remaining / monthlySavings).doubleValue
        return Int(months.rounded(.up))
    }
    
    static func requiredMonthlySavings(
        targetAmount: Decimal, currentAmount: Decimal, monthsLeft: Int
    ) -> Decimal {
        guard monthsLeft > 0 else { return Decimal.greatestFiniteMagnitude }
        let remaining = targetAmount - currentAmount
        guard remaining > 0 else { return 0 }
        return remaining / Decimal(monthsLeft)
    }
    
    static func goalProgress(targetAmount: Decimal, currentAmount: Decimal) -> Double {
        guard targetAmount > 0 else { return 0 }
        let ratio = NSDecimalNumber(decimal: currentAmount / targetAmount).doubleValue
        return min(max(ratio, 0), 1)
    }
    
    static func suggestedMonthlySaving(_ monthlyNet: Decimal, rate: Decimal = 0.20) -> Decimal {
        max(monthlyNet * rate, 0)
    }
    
    static func isOnTrackForGoal(monthlyNet: Decimal, requiredMonthly: Decimal) -> Bool {
        requiredMonthly > 0 && monthlyNet >= requiredMonthly
    }
}
```

### Loan / Installment Functions

```swift
extension FinancialCalculator {
    /// EMI (Equal Monthly Installment)
    static func monthlyLoanPayment(
        principal: Decimal, annualRate: Decimal, termMonths: Int
    ) -> Decimal {
        guard annualRate != 0 else { return principal / Decimal(termMonths) }
        let r = NSDecimalNumber(decimal: annualRate / 12).doubleValue
        let n = Double(termMonths)
        let emi = NSDecimalNumber(decimal: principal).doubleValue *
            (r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
        return Decimal(emi)
    }
    
    static func totalLoanPayment(monthlyPayment: Decimal, termMonths: Int) -> Decimal {
        monthlyPayment * Decimal(termMonths)
    }
    
    static func totalInterest(totalPayment: Decimal, principal: Decimal) -> Decimal {
        totalPayment - principal
    }
    
    // ─── Kredi Vergi (KKDF + BSMV) ──────────────────
    /// KKDF: %15, BSMV: %10 → toplam %25
    static func realAnnualRateWithTaxes(_ nominalRate: Decimal) -> Decimal {
        let kkdf: Decimal = 0.15
        let bsmv: Decimal = 0.10
        return nominalRate * (1 + kkdf + bsmv)
    }
    
    static func creditTaxAmount(_ totalInterest: Decimal) -> Decimal {
        totalInterest * Decimal(0.25)
    }
    
    static func loanAffordability(
        monthlyPayment: Decimal, monthlyIncome: Decimal
    ) -> AffordabilityStatus {
        guard monthlyIncome > 0 else { return .risky }
        let ratio = NSDecimalNumber(decimal: monthlyPayment / monthlyIncome).doubleValue
        return switch ratio {
        case ..<0.25: .comfortable
        case ..<0.35: .manageable
        case ..<0.45: .tight
        default: .risky
        }
    }
}
```

### Brut → Net Maas (2026 Turkiye Vergi Sistemi)

```swift
extension FinancialCalculator {
    // ─── Sabitler ────────────────────────────────────
    static let sgkWorkerRate: Decimal = 0.14
    static let unemploymentRate: Decimal = 0.01
    static let brutAsgariUcret: Decimal = 33030
    static let sgkTavan: Decimal = 297270      // 33030 × 9
    static let damgaVergisiOrani: Decimal = 0.00759
    static let asgariUcretGvMatrahi: Decimal = 28075.50
    
    /// 2026 gelir vergisi dilimleri (yillik kumulatif)
    static let taxBrackets2026: [(limit: Decimal, rate: Decimal)] = [
        (190_000, 0.15),
        (400_000, 0.20),
        (1_500_000, 0.27),
        (5_300_000, 0.35),
        (Decimal.greatestFiniteMagnitude, 0.40),
    ]
    
    /// 12 aylik brut → net hesaplama
    static func calculateAnnualNetSalary(grossMonthly: Decimal) -> AnnualSalaryBreakdown {
        // Cache kontrolu (actor uzerinden — bkz. SalaryCache)
        var months: [MonthlySalaryDetail] = []
        var cumBase: Decimal = 0
        var cumTax: Decimal = 0
        var cumAsgariBase: Decimal = 0
        var cumAsgariTax: Decimal = 0
        
        for i in 0..<12 {
            // Adim 1: SGK ve Issizlik (tavan sinirli)
            let sgkMatrahi = min(grossMonthly, sgkTavan)
            let sgkIsci = sgkMatrahi * sgkWorkerRate
            let issizlikIsci = sgkMatrahi * unemploymentRate
            
            // Adim 2: Aylik GV matrahi
            let aylikGvMatrahi = grossMonthly - sgkIsci - issizlikIsci
            
            // Adim 3: Kumulatif GV
            let yeniCumBase = cumBase + aylikGvMatrahi
            let yeniCumTax = cumulativeTax(yeniCumBase)
            let aylikGelirVergisi = max(yeniCumTax - cumTax, 0)
            
            // Adim 4: Damga vergisi (asgari ucret istisna matrahi)
            let damgaMatrahi = max(grossMonthly - brutAsgariUcret, 0)
            let damgaVergisi = damgaMatrahi * damgaVergisiOrani
            
            // Adim 5: Net (istisna oncesi)
            let netMaas = grossMonthly - sgkIsci - issizlikIsci - aylikGelirVergisi - damgaVergisi
            
            // Adim 6: Asgari ucret GV istisnasi
            let yeniCumAsgariBase = cumAsgariBase + asgariUcretGvMatrahi
            let yeniCumAsgariTax = cumulativeTax(yeniCumAsgariBase)
            var aylikGvIstisnasi = yeniCumAsgariTax - cumAsgariTax
            aylikGvIstisnasi = min(aylikGvIstisnasi, aylikGelirVergisi)
            
            // Adim 7: Damga istisnasi
            let damgaIstisnasi = min(
                brutAsgariUcret * damgaVergisiOrani,
                damgaVergisi + (brutAsgariUcret * damgaVergisiOrani)
            )
            
            // Adim 8: Net ele gecen
            let netEleGecen = netMaas + aylikGvIstisnasi + damgaIstisnasi
            
            months.append(MonthlySalaryDetail(
                monthIndex: i,
                grossMonthly: grossMonthly,
                sgk: sgkIsci,
                unemploymentInsurance: issizlikIsci,
                gvMatrah: aylikGvMatrahi,
                cumulativeBase: yeniCumBase,
                monthlyIncomeTax: aylikGelirVergisi,
                stampTax: damgaVergisi,
                netBeforeExemption: netMaas,
                gvExemption: aylikGvIstisnasi,
                stampExemption: damgaIstisnasi,
                netTakeHome: netEleGecen,
                taxBracketRate: getCurrentBracketRate(yeniCumBase)
            ))
            
            cumBase = yeniCumBase
            cumTax = yeniCumTax
            cumAsgariBase = yeniCumAsgariBase
            cumAsgariTax = yeniCumAsgariTax
        }
        
        let totalNet = months.reduce(Decimal(0)) { $0 + $1.netTakeHome }
        let totalGross = grossMonthly * 12
        
        return AnnualSalaryBreakdown(
            grossMonthly: grossMonthly,
            months: months,
            totalNet: totalNet,
            totalGross: totalGross,
            totalTax: months.reduce(Decimal(0)) { $0 + $1.monthlyIncomeTax - $1.gvExemption },
            totalSgk: months.reduce(Decimal(0)) { $0 + $1.sgk + $1.unemploymentInsurance },
            totalStampTax: months.reduce(Decimal(0)) { $0 + $1.stampTax - $1.stampExemption },
            effectiveTaxRate: totalGross > 0 ? 
                NSDecimalNumber(decimal: (totalGross - totalNet) / totalGross).doubleValue : 0
        )
    }
    
    // ─── Private Helpers ─────────────────────────────
    
    private static func cumulativeTax(_ cumulativeBase: Decimal) -> Decimal {
        var tax: Decimal = 0
        var prevLimit: Decimal = 0
        for bracket in taxBrackets2026 {
            guard cumulativeBase > prevLimit else { break }
            let taxableInBracket = min(cumulativeBase, bracket.limit) - prevLimit
            tax += taxableInBracket * bracket.rate
            prevLimit = bracket.limit
        }
        return tax
    }
    
    private static func getCurrentBracketRate(_ cumulativeBase: Decimal) -> Decimal {
        for bracket in taxBrackets2026 {
            if cumulativeBase <= bracket.limit { return bracket.rate }
        }
        return 0.40
    }
}
```

### SalaryCache — Swift Actor

Flutter'daki `static Map<double, AnnualSalaryBreakdown> _salaryCache` yerine thread-safe actor:

```swift
actor SalaryCache {
    static let shared = SalaryCache()
    private var cache: [Decimal: AnnualSalaryBreakdown] = [:]
    
    func get(gross: Decimal) -> AnnualSalaryBreakdown? {
        cache[gross]
    }
    
    func set(gross: Decimal, _ breakdown: AnnualSalaryBreakdown) {
        cache[gross] = breakdown
    }
    
    func clear() {
        cache.removeAll()
    }
}

// Kullanim:
// let cached = await SalaryCache.shared.get(gross: 50000)
// if cached == nil {
//     let result = FinancialCalculator.calculateAnnualNetSalary(grossMonthly: 50000)
//     await SalaryCache.shared.set(gross: 50000, result)
// }
```

### Gross → Net Resolution

```swift
extension FinancialCalculator {
    /// Brut gelir icin belirli bir aydaki net
    /// month: 1-indexed (1=Ocak, 12=Aralik)
    static func resolveNetForMonth(amount: Decimal, isGross: Bool, month: Int) -> Decimal {
        guard isGross else { return amount }
        let breakdown = calculateAnnualNetSalary(grossMonthly: amount)
        let index = min(max(month - 1, 0), 11)
        return breakdown.months[index].netTakeHome
    }
    
    /// 12 aylik net breakdown
    static func resolveAllMonths(amount: Decimal, isGross: Bool) -> [Decimal] {
        guard isGross else { return Array(repeating: amount, count: 12) }
        let breakdown = calculateAnnualNetSalary(grossMonthly: amount)
        return breakdown.months.map(\.netTakeHome)
    }
}
```

### Debt Tracking

```swift
extension FinancialCalculator {
    static func totalRemainingDebt(_ expenses: [Expense]) -> Decimal {
        let now = Date()
        return expenses
            .filter { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now }
            .reduce(Decimal(0)) { sum, e in
                let remaining = monthsRemaining(from: now, to: e.recurringEndDate!)
                return sum + e.amount * Decimal(remaining)
            }
    }
    
    static func monthlyDebtPayment(_ expenses: [Expense]) -> Decimal {
        let now = Date()
        return expenses
            .filter { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }
    
    static func debtFreeDate(_ expenses: [Expense]) -> Date? {
        let now = Date()
        return expenses
            .compactMap { $0.isRecurring && $0.recurringEndDate != nil && $0.recurringEndDate! > now ? $0.recurringEndDate : nil }
            .max()
    }
    
    private static func monthsRemaining(from: Date, to: Date) -> Int {
        let components = Calendar.current.dateComponents([.month], from: from, to: to)
        return max(components.month ?? 0, 0)
    }
}
```

## CurrencyFormatter

Flutter: `lib/core/utils/currency_formatter.dart`
Swift: `Packages/Core/SavvyFoundation/Sources/Formatters/CurrencyFormatter.swift`

```swift
enum CurrencyFormatter {
    private static let trLocale = Locale(identifier: "tr_TR")
    
    /// "₺1.250,00"
    static func format(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = trLocale
        return formatter.string(from: amount as NSDecimalNumber) ?? "₺0"
    }
    
    /// "₺1.250"
    static func formatNoDecimal(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = trLocale
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₺0"
    }
    
    /// "₺1,2M" / "₺102K" / "₺1.250"
    static func compact(_ amount: Decimal) -> String {
        let d = NSDecimalNumber(decimal: amount).doubleValue
        switch abs(d) {
        case 1_000_000...:
            return String(format: "₺%.1fM", d / 1_000_000)
                .replacingOccurrences(of: ".", with: ",")
        case 10_000...:
            return "₺\(Int(d / 1_000))K"
        default:
            return formatNoDecimal(amount)
        }
    }
    
    /// "+₺1.250,00" / "-₺500,00"
    static func withSign(_ amount: Decimal) -> String {
        let prefix = amount >= 0 ? "+" : ""
        return prefix + format(amount)
    }
    
    /// "+%5,2" / "-%3,1"
    static func changePercent(_ ratio: Double) -> String {
        let sign = ratio >= 0 ? "+" : ""
        return "\(sign)%\(String(format: "%.1f", ratio * 100).replacingOccurrences(of: ".", with: ","))"
    }
    
    /// "%38,5"
    static func percent(_ ratio: Double) -> String {
        "%\(String(format: "%.1f", ratio * 100).replacingOccurrences(of: ".", with: ","))"
    }
    
    /// Reverse Turkish format → Decimal
    static func parse(_ input: String) -> Decimal? {
        let cleaned = input
            .replacingOccurrences(of: "₺", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleaned)
    }
}
```

## TransactionValidator

Flutter: `lib/core/utils/transaction_validator.dart`

```swift
enum TransactionValidator {
    static let maxAmount: Decimal = 10_000_000
    static let maxNoteLength = 200
    
    enum ValidationResult<T> {
        case ok(T)
        case error(String)
    }
    
    static func validateAmount(_ input: String?) -> ValidationResult<Decimal> {
        guard let input, !input.isEmpty else {
            return .error("Tutar giriniz")
        }
        guard let amount = CurrencyFormatter.parse(input) else {
            return .error("Gecersiz tutar")
        }
        guard amount > 0 else {
            return .error("Tutar 0'dan buyuk olmali")
        }
        guard amount <= maxAmount else {
            return .error("Tutar en fazla ₺10.000.000 olabilir")
        }
        return .ok(amount)
    }
    
    static func validateDate(_ date: Date?) -> ValidationResult<Date> {
        guard let date else {
            return .error("Tarih seciniz")
        }
        let minDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let maxDate = Calendar.current.date(byAdding: .day, value: 366, to: .now)!
        guard date >= minDate && date <= maxDate else {
            return .error("Tarih 2020 – gelecek yil araliginda olmali")
        }
        return .ok(date)
    }
    
    static func validateNote(_ note: String?) -> ValidationResult<String?> {
        guard let note, !note.isEmpty else { return .ok(nil) }
        guard note.count <= maxNoteLength else {
            return .error("Not en fazla \(maxNoteLength) karakter olabilir")
        }
        return .ok(note)
    }
}
```

## SimulationCalculator

Flutter: `lib/features/simulation/domain/simulation_calculator.dart`
Swift: `Packages/Features/SimulationFeature/Sources/Domain/SimulationCalculator.swift`

Cok uzun oldugundan sadece ana yapiyi veriyoruz — tam port implementation sirasinda yapilacak:

```swift
enum SimulationCalculator {
    /// Ana giris noktasi
    static func calculateScenario(
        changes: [SimulationChange],
        currentBudget: MonthSummary,
        existingIncomeItems: [MonthLineItem] = [],
        existingExpenseItems: [MonthLineItem] = [],
        baseItems: [ProjectionBaseItem] = []
    ) -> SimulationResult {
        // Her SimulationChange icin:
        // 1. Monthly impact hesapla
        // 2. Annual impact hesapla (vergi dilimleri dahil)
        // 3. 12 aylik projeksiyon olustur
        // 4. Amortizasyon tablosu (kredi bazli degisiklikler icin)
        // 5. Affordability status belirle
        fatalError("Implementation in Phase 3")
    }
}
```

## MonthSummaryAggregator

Flutter: `lib/features/dashboard/domain/month_summary_aggregator.dart`
Swift: `Packages/Features/DashboardFeature/Sources/Domain/MonthSummaryAggregator.swift`

```swift
enum MonthSummaryAggregator {
    /// Tum recurring gelir/gider/birikimleri aylik bazda projeksiyon
    static func buildAllMonthTotals(
        incomes: [Income],
        expenses: [Expense],
        savings: [Savings]
    ) -> MonthTotals {
        // Recurring item'lari ileri tarafa yansit
        // monthlyOverrides varsa override degerini kullan
        // isGross ise brut → net cevir (ay bazinda)
        fatalError("Implementation in Phase 2")
    }
    
    /// Aylik ozet listesi (carry-over dahil)
    static func buildSummaries(
        incomes: [Income],
        expenses: [Expense],
        savings: [Savings]
    ) -> [MonthSummary] {
        // buildAllMonthTotals'dan al
        // Her ay icin MonthSummary olustur
        // carryOver = onceki ayin netWithCarryOver
        // healthScore hesapla
        // En son ay basta olacak sekilde sirala
        fatalError("Implementation in Phase 2")
    }
    
    /// Gelecek 12 ay projeksiyonu
    static func buildProjections(
        incomes: [Income],
        expenses: [Expense],
        savings: [Savings],
        includeSavings: Bool
    ) -> [MonthSummary] {
        // Mevcut recurring'leri ileri yansit
        // plannedChanges varsa uygula
        fatalError("Implementation in Phase 2")
    }
}
```

## Salary Result Models

```swift
struct MonthlySalaryDetail: Sendable {
    let monthIndex: Int
    let grossMonthly: Decimal
    let sgk: Decimal
    let unemploymentInsurance: Decimal
    let gvMatrah: Decimal
    let cumulativeBase: Decimal
    let monthlyIncomeTax: Decimal
    let stampTax: Decimal
    let netBeforeExemption: Decimal
    let gvExemption: Decimal
    let stampExemption: Decimal
    let netTakeHome: Decimal
    let taxBracketRate: Decimal
    
    var monthName: String { FinancialCalculator.monthNamesTR[monthIndex] }
    var monthShortName: String { FinancialCalculator.monthShortNamesTR[monthIndex] }
    var netIncomeTax: Decimal { monthlyIncomeTax - gvExemption }
    var netStampTax: Decimal { stampTax - stampExemption }
    var totalDeductions: Decimal { grossMonthly - netTakeHome }
}

struct AnnualSalaryBreakdown: Sendable {
    let grossMonthly: Decimal
    let months: [MonthlySalaryDetail]
    let totalNet: Decimal
    let totalGross: Decimal
    let totalTax: Decimal
    let totalSgk: Decimal
    let totalStampTax: Decimal
    let effectiveTaxRate: Double
    
    var maxNet: Decimal { months.map(\.netTakeHome).max() ?? 0 }
    var minNet: Decimal { months.map(\.netTakeHome).min() ?? 0 }
}

struct SalaryBreakdown: Sendable {
    let grossMonthly: Decimal
    let sgk: Decimal
    let unemploymentInsurance: Decimal
    let incomeTax: Decimal
    let stampTax: Decimal
    let totalDeductions: Decimal
    let netMonthly: Decimal
}
```

## Ay Isimleri

```swift
extension FinancialCalculator {
    static let monthNamesTR = [
        "Ocak", "Subat", "Mart", "Nisan", "Mayis", "Haziran",
        "Temmuz", "Agustos", "Eylul", "Ekim", "Kasim", "Aralik"
    ]
    
    static let monthShortNamesTR = [
        "Oca", "Sub", "Mar", "Nis", "May", "Haz",
        "Tem", "Agu", "Eyl", "Eki", "Kas", "Ara"
    ]
}
```
