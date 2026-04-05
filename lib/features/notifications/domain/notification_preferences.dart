class NotificationPreferences {
  final bool installmentReminders;
  final bool budgetAlerts;
  final bool weeklyDigest;
  final bool monthlyReport;
  final int installmentWarningDays;

  const NotificationPreferences({
    this.installmentReminders = true,
    this.budgetAlerts = true,
    this.weeklyDigest = false,
    this.monthlyReport = false,
    this.installmentWarningDays = 30,
  });

  NotificationPreferences copyWith({
    bool? installmentReminders,
    bool? budgetAlerts,
    bool? weeklyDigest,
    bool? monthlyReport,
    int? installmentWarningDays,
  }) {
    return NotificationPreferences(
      installmentReminders: installmentReminders ?? this.installmentReminders,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      monthlyReport: monthlyReport ?? this.monthlyReport,
      installmentWarningDays:
          installmentWarningDays ?? this.installmentWarningDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'installmentReminders': installmentReminders,
        'budgetAlerts': budgetAlerts,
        'weeklyDigest': weeklyDigest,
        'monthlyReport': monthlyReport,
        'installmentWarningDays': installmentWarningDays,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        installmentReminders: json['installmentReminders'] as bool? ?? true,
        budgetAlerts: json['budgetAlerts'] as bool? ?? true,
        weeklyDigest: json['weeklyDigest'] as bool? ?? false,
        monthlyReport: json['monthlyReport'] as bool? ?? false,
        installmentWarningDays:
            json['installmentWarningDays'] as int? ?? 30,
      );
}
