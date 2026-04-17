import AppIntents

struct SavvyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Eco'ya harcama ekle",
                "\(.applicationName) harcama ekle",
                "\(.applicationName) gider gir",
            ],
            shortTitle: "Harcama Ekle",
            systemImageName: "minus.circle"
        )
        AppShortcut(
            intent: CheckBudgetIntent(),
            phrases: [
                "Eco bütçe durumu",
                "\(.applicationName) bu ay ne kadar harcadım",
                "\(.applicationName) bütçe özeti",
            ],
            shortTitle: "Bütçe Durumu",
            systemImageName: "chart.pie"
        )
    }
}
