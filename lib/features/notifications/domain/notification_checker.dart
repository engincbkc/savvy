import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/features/notifications/domain/notification_preferences.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';

// ─── Pending notification types ──────────────────────────────────────────────

enum NotificationType {
  installmentExpiring,
  budgetAlert,
  weeklyDigest,
  monthlyReport,
}

class PendingNotification {
  final NotificationType type;
  final String title;
  final String body;

  const PendingNotification({
    required this.type,
    required this.title,
    required this.body,
  });
}

// ─── Checker ─────────────────────────────────────────────────────────────────

/// Checks which notifications should be triggered.
/// Returns a list of [PendingNotification] objects.
/// Actual dispatch happens when flutter_local_notifications is integrated.
class NotificationChecker {
  const NotificationChecker._();

  static List<PendingNotification> check({
    required List<Expense> expenses,
    required NotificationPreferences prefs,
    required Map<ExpenseCategory, double> budgetUsage,
    required Map<ExpenseCategory, double> budgetLimits,
  }) {
    final notifications = <PendingNotification>[];
    final now = DateTime.now();

    // ── Installment expiry warnings ──────────────────────────────────────
    if (prefs.installmentReminders) {
      for (final e in expenses) {
        if (e.isRecurring && e.recurringEndDate != null) {
          final daysLeft = e.recurringEndDate!.difference(now).inDays;
          if (daysLeft <= prefs.installmentWarningDays && daysLeft > 0) {
            notifications.add(PendingNotification(
              type: NotificationType.installmentExpiring,
              title: 'Taksit Bitiyor',
              body:
                  '${e.note ?? e.category.label}: $daysLeft gün kaldı',
            ));
          }
        }
      }
    }

    // ── Budget alert — category usage >= 80% of limit ────────────────────
    if (prefs.budgetAlerts) {
      for (final entry in budgetLimits.entries) {
        final category = entry.key;
        final limit = entry.value;
        if (limit <= 0) continue;
        final usage = budgetUsage[category] ?? 0;
        final ratio = usage / limit;
        if (ratio >= 0.8) {
          final percent = (ratio * 100).round();
          notifications.add(PendingNotification(
            type: NotificationType.budgetAlert,
            title: 'Bütçe Uyarısı',
            body:
                '${category.label} kategorisinde bütçenin %$percent\'ini kullandınız.',
          ));
        }
      }
    }

    return notifications;
  }
}
