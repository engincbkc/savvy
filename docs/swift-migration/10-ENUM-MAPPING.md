# 10 — Enum Mapping: Flutter → Swift + SF Symbol Eslestirmesi

Flutter'da Lucide Icons kullaniliyor. Swift'te SF Symbols kullanilacak (3rd-party icon kutuphanesi yok).

---

## IncomeCategory

| Flutter Enum | Turkish Label | Lucide Icon | SF Symbol |
|-------------|--------------|-------------|-----------|
| `salary` | Maas | `briefcase` | `briefcase.fill` |
| `sideJob` | Ek Is | `hammer` | `hammer.fill` |
| `freelance` | Freelance | `laptop` | `laptopcomputer` |
| `transfer` | Transfer | `arrowLeftRight` | `arrow.left.arrow.right` |
| `debtCollection` | Borc Tahsilati | `banknote` | `banknote.fill` |
| `refund` | Iade | `undo2` | `arrow.uturn.backward` |
| `rentalIncome` | Kira Geliri | `building2` | `building.2.fill` |
| `investment` | Yatirim | `lineChart` | `chart.line.uptrend.xyaxis` |
| `other` | Diger | `circle` | `circle.fill` |

```swift
enum IncomeCategory: String, Codable, CaseIterable, Identifiable {
    case salary, sideJob, freelance, transfer, debtCollection
    case refund, rentalIncome, investment, other
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .salary: "Maas"
        case .sideJob: "Ek Is"
        case .freelance: "Freelance"
        case .transfer: "Transfer"
        case .debtCollection: "Borc Tahsilati"
        case .refund: "Iade"
        case .rentalIncome: "Kira Geliri"
        case .investment: "Yatirim"
        case .other: "Diger"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .salary: "briefcase.fill"
        case .sideJob: "hammer.fill"
        case .freelance: "laptopcomputer"
        case .transfer: "arrow.left.arrow.right"
        case .debtCollection: "banknote.fill"
        case .refund: "arrow.uturn.backward"
        case .rentalIncome: "building.2.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .other: "circle.fill"
        }
    }
}
```

---

## ExpenseCategory

| Flutter Enum | Turkish Label | Lucide Icon | SF Symbol |
|-------------|--------------|-------------|-----------|
| `rent` | Kira | `building2` | `house.fill` |
| `market` | Market | `shoppingCart` | `cart.fill` |
| `transport` | Ulasim | `car` | `car.fill` |
| `bills` | Faturalar | `zap` | `bolt.fill` |
| `creditCard` | Kredi Karti | `creditCard` | `creditcard.fill` |
| `loanInstallment` | Kredi Taksiti | `banknote` | `banknote.fill` |
| `health` | Saglik | `heartPulse` | `heart.fill` |
| `education` | Egitim | `graduationCap` | `graduationcap.fill` |
| `food` | Yeme-Icme | `utensils` | `fork.knife` |
| `entertainment` | Eglence | `gamepad2` | `gamecontroller.fill` |
| `clothing` | Giyim | `shirt` | `tshirt.fill` |
| `subscription` | Abonelik | `rss` | `repeat` |
| `advertising` | Reklam | `megaphone` | `megaphone.fill` |
| `businessTool` | Is Araci | `wrench` | `wrench.fill` |
| `tax` | Vergi | `receipt` | `doc.text.fill` |
| `other` | Diger | `circle` | `circle.fill` |

```swift
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case rent, market, transport, bills, creditCard, loanInstallment
    case health, education, food, entertainment, clothing, subscription
    case advertising, businessTool, tax, other
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .rent: "Kira"
        case .market: "Market"
        case .transport: "Ulasim"
        case .bills: "Faturalar"
        case .creditCard: "Kredi Karti"
        case .loanInstallment: "Kredi Taksiti"
        case .health: "Saglik"
        case .education: "Egitim"
        case .food: "Yeme-Icme"
        case .entertainment: "Eglence"
        case .clothing: "Giyim"
        case .subscription: "Abonelik"
        case .advertising: "Reklam"
        case .businessTool: "Is Araci"
        case .tax: "Vergi"
        case .other: "Diger"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .rent: "house.fill"
        case .market: "cart.fill"
        case .transport: "car.fill"
        case .bills: "bolt.fill"
        case .creditCard: "creditcard.fill"
        case .loanInstallment: "banknote.fill"
        case .health: "heart.fill"
        case .education: "graduationcap.fill"
        case .food: "fork.knife"
        case .entertainment: "gamecontroller.fill"
        case .clothing: "tshirt.fill"
        case .subscription: "repeat"
        case .advertising: "megaphone.fill"
        case .businessTool: "wrench.fill"
        case .tax: "doc.text.fill"
        case .other: "circle.fill"
        }
    }
    
    /// Watch app icin hizli erisim kategorileri
    static var quickCategories: [ExpenseCategory] {
        [.market, .transport, .food, .bills, .entertainment, .health, .other]
    }
}
```

---

## ExpenseType

| Flutter Enum | Turkish Label | SF Symbol |
|-------------|--------------|-----------|
| `fixed` | Sabit | `pin.fill` |
| `variable` | Degisken | `arrow.up.arrow.down` |
| `discretionary` | Istege Bagli | `sparkles` |
| `business` | Is/Yatirim | `building.2.crop.circle` |

```swift
enum ExpenseType: String, Codable, CaseIterable, Identifiable {
    case fixed, variable, discretionary, business
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .fixed: "Sabit"
        case .variable: "Degisken"
        case .discretionary: "Istege Bagli"
        case .business: "Is/Yatirim"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .fixed: "pin.fill"
        case .variable: "arrow.up.arrow.down"
        case .discretionary: "sparkles"
        case .business: "building.2.crop.circle"
        }
    }
}
```

---

## SavingsCategory

| Flutter Enum | Turkish Label | Lucide Icon | SF Symbol |
|-------------|--------------|-------------|-----------|
| `emergency` | Acil Durum Fonu | `shieldCheck` | `shield.checkered` |
| `goal` | Hedef Birikimi | `target` | `target` |
| `gold` | Altin | `coins` | `bitcoinsign.circle.fill` |
| `forex` | Doviz | `dollarSign` | `dollarsign.circle.fill` |
| `stock` | Hisse Senedi | `candlestickChart` | `chart.bar.fill` |
| `fund` | Yatirim Fonu | `pieChart` | `chart.pie.fill` |
| `deposit` | Vadeli Mevduat | `landmark` | `building.columns.fill` |
| `retirement` | Emeklilik | `sunMedium` | `sun.max.fill` |
| `other` | Diger | `circle` | `circle.fill` |

```swift
enum SavingsCategory: String, Codable, CaseIterable, Identifiable {
    case emergency, goal, gold, forex, stock, fund, deposit, retirement, other
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .emergency: "Acil Durum Fonu"
        case .goal: "Hedef Birikimi"
        case .gold: "Altin"
        case .forex: "Doviz"
        case .stock: "Hisse Senedi"
        case .fund: "Yatirim Fonu"
        case .deposit: "Vadeli Mevduat"
        case .retirement: "Emeklilik"
        case .other: "Diger"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .emergency: "shield.checkered"
        case .goal: "target"
        case .gold: "bitcoinsign.circle.fill"
        case .forex: "dollarsign.circle.fill"
        case .stock: "chart.bar.fill"
        case .fund: "chart.pie.fill"
        case .deposit: "building.columns.fill"
        case .retirement: "sun.max.fill"
        case .other: "circle.fill"
        }
    }
}
```

---

## SavingsStatus

```swift
enum SavingsStatus: String, Codable, CaseIterable {
    case active, withdrawn, completed
    
    var label: String {
        switch self {
        case .active: "Aktif"
        case .withdrawn: "Cekildi"
        case .completed: "Tamamlandi"
        }
    }
}
```

## GoalStatus

```swift
enum GoalStatus: String, Codable, CaseIterable {
    case active, completed, cancelled
    
    var label: String {
        switch self {
        case .active: "Aktif"
        case .completed: "Tamamlandi"
        case .cancelled: "Iptal Edildi"
        }
    }
}
```

## AffordabilityStatus

```swift
enum AffordabilityStatus: String, Codable, CaseIterable {
    case comfortable, manageable, tight, risky
    
    var label: String {
        switch self {
        case .comfortable: "Rahat"
        case .manageable: "Idare Edilebilir"
        case .tight: "Sikikik"
        case .risky: "Riskli"
        }
    }
    
    var color: Color {
        switch self {
        case .comfortable: .savvyIncome
        case .manageable: .savvySavings
        case .tight: .savvyWarning
        case .risky: .savvyExpense
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .comfortable: "checkmark.circle.fill"
        case .manageable: "exclamationmark.circle.fill"
        case .tight: "exclamationmark.triangle.fill"
        case .risky: "xmark.octagon.fill"
        }
    }
}
```

---

## SimulationTemplate

| Flutter Enum | Turkish Label | Lucide Icon | SF Symbol | Color |
|-------------|--------------|-------------|-----------|-------|
| `credit` | Kredi Cekimi | `creditCard` | `creditcard.fill` | #3F83F8 |
| `housing` | Ev Alimi | `home` | `house.fill` | #1A56DB |
| `car` | Arac Alimi | `car` | `car.fill` | #0E9F6E |
| `rentChange` | Kira Degisimi | `building2` | `building.2.fill` | #E8590C |
| `salaryChange` | Is Degisikligi / Zam | `briefcase` | `briefcase.fill` | #8B5CF6 |
| `investment` | Yatirim | `trendingUp` | `chart.line.uptrend.xyaxis` | #0891B2 |
| `custom` | Ozel Senaryo | `sparkles` | `sparkles` | #6B7280 |

```swift
enum SimulationTemplate: String, Codable, CaseIterable, Identifiable {
    case credit, housing, car, rentChange, salaryChange, investment, custom
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .credit: "Kredi Cekimi"
        case .housing: "Ev Alimi"
        case .car: "Arac Alimi"
        case .rentChange: "Kira Degisimi"
        case .salaryChange: "Is Degisikligi / Zam"
        case .investment: "Yatirim"
        case .custom: "Ozel Senaryo"
        }
    }
    
    var subtitle: String {
        switch self {
        case .credit: "Ihtiyac, konut veya ticari kredi"
        case .housing: "Konut kredisi, pesinat, FuzulEv"
        case .car: "Tasit kredisi + aylik giderler"
        case .rentChange: "Kira artisi veya yeni eve tasinma"
        case .salaryChange: "Zam, terfi veya is degisikligi"
        case .investment: "Vadeli mevduat, fon, hisse..."
        case .custom: "Gelir/gider ekleyerek kendi senaryonu olustur"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .credit: "creditcard.fill"
        case .housing: "house.fill"
        case .car: "car.fill"
        case .rentChange: "building.2.fill"
        case .salaryChange: "briefcase.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .custom: "sparkles"
        }
    }
    
    var colorHex: String {
        switch self {
        case .credit: "#3F83F8"
        case .housing: "#1A56DB"
        case .car: "#0E9F6E"
        case .rentChange: "#E8590C"
        case .salaryChange: "#8B5CF6"
        case .investment: "#0891B2"
        case .custom: "#6B7280"
        }
    }
}
```

---

## Color Extension: Hex Support

```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
```

---

## Tab Bar Icons

| Tab | Label | SF Symbol |
|-----|-------|-----------|
| Dashboard | Ana Sayfa | `house.fill` |
| Transactions | Islemler | `list.bullet.rectangle.fill` |
| Simulation | Simulasyon | `chart.line.uptrend.xyaxis` |
| Settings | Ayarlar | `gearshape.fill` |

---

## Not: Lucide → SF Symbol Genel Eslestirme Mantigi

| Lucide Kavrami | SF Symbol Karsiligi |
|---------------|-------------------|
| `briefcase` | `briefcase.fill` |
| `home` / `house` | `house.fill` |
| `car` | `car.fill` |
| `building2` | `building.2.fill` |
| `shoppingCart` | `cart.fill` |
| `creditCard` | `creditcard.fill` |
| `banknote` | `banknote.fill` |
| `heartPulse` | `heart.fill` |
| `graduationCap` | `graduationcap.fill` |
| `utensils` | `fork.knife` |
| `gamepad2` | `gamecontroller.fill` |
| `shirt` | `tshirt.fill` |
| `megaphone` | `megaphone.fill` |
| `wrench` | `wrench.fill` |
| `receipt` | `doc.text.fill` |
| `target` | `target` |
| `coins` | `bitcoinsign.circle.fill` |
| `dollarSign` | `dollarsign.circle.fill` |
| `lineChart` | `chart.line.uptrend.xyaxis` |
| `pieChart` | `chart.pie.fill` |
| `landmark` | `building.columns.fill` |
| `zap` | `bolt.fill` |
| `sparkles` | `sparkles` |
| `trendingUp` | `chart.line.uptrend.xyaxis` |
| `rss` | `repeat` |
| `circle` | `circle.fill` |
