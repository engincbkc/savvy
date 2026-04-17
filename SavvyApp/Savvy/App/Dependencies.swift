import Foundation
import FirebaseFirestore
import SavvyFoundation
import SavvyNetworking

/// Merkezi dependency container — her authenticated user için oluşturulur.
final class AppDependencies: ObservableObject {
    let userId: String
    let incomeRepo: IncomeRepository
    let expenseRepo: ExpenseRepository
    let savingsRepo: SavingsRepository
    let savingsGoalRepo: SavingsGoalRepository
    let simulationRepo: SimulationRepository
    let budgetLimitRepo: BudgetLimitRepository

    init(userId: String) {
        let db = Firestore.firestore()
        self.userId = userId
        self.incomeRepo = IncomeRepository(userId: userId, db: db)
        self.expenseRepo = ExpenseRepository(userId: userId, db: db)
        self.savingsRepo = SavingsRepository(userId: userId, db: db)
        self.savingsGoalRepo = SavingsGoalRepository(userId: userId, db: db)
        self.simulationRepo = SimulationRepository(userId: userId, db: db)
        self.budgetLimitRepo = BudgetLimitRepository(userId: userId, db: db)
    }
}
