import Foundation
import UserNotifications

enum NotificationManager {

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    // MARK: - Budget Warning

    static func sendBudgetWarning(category: String, percentUsed: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Bütçe Uyarısı"
        content.body = "\(category) harcamanız limitin %\(percentUsed)'ine ulaştı."
        content.sound = .default
        content.categoryIdentifier = "BUDGET_WARNING"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget-\(category)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Budget Exceeded

    static func sendBudgetExceeded(category: String, overAmount: String) {
        let content = UNMutableNotificationContent()
        content.title = "Limit Aşıldı!"
        content.body = "\(category) harcamanız limiti \(overAmount) aştı."
        content.sound = .defaultCritical
        content.categoryIdentifier = "BUDGET_EXCEEDED"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "exceeded-\(category)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Weekly Digest

    static func scheduleWeeklyDigest() {
        let content = UNMutableNotificationContent()
        content.title = "Haftalık Özet"
        content.body = "Bu haftanın finansal özetinize göz atın."
        content.sound = .default

        // Her Pazar saat 10:00
        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // Sunday
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly-digest",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Month End Summary

    static func scheduleMonthEndReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Ay Sonu Özeti"
        content.body = "Bu ayın finansal özetinizi inceleyin ve gelecek ay için plan yapın."
        content.sound = .default

        // Her ayın 28'i saat 18:00
        var dateComponents = DateComponents()
        dateComponents.day = 28
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "month-end",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Goal Progress

    static func sendGoalProgress(goalTitle: String, percentComplete: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Hedef İlerlemesi"
        content.body = "\(goalTitle) hedefinin %\(percentComplete)'ine ulaştınız!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "goal-\(goalTitle)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
