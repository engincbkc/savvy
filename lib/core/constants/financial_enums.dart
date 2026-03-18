import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum IncomeCategory {
  salary,
  sideJob,
  freelance,
  transfer,
  debtCollection,
  refund,
  rentalIncome,
  investment,
  other;

  String get label => switch (this) {
        salary => 'Maaş',
        sideJob => 'Ek İş',
        freelance => 'Freelance',
        transfer => 'Transfer',
        debtCollection => 'Borç Tahsilatı',
        refund => 'İade',
        rentalIncome => 'Kira Geliri',
        investment => 'Yatırım',
        other => 'Diğer',
      };

  IconData get icon => switch (this) {
        salary => LucideIcons.briefcase,
        sideJob => LucideIcons.hammer,
        freelance => LucideIcons.laptop,
        transfer => LucideIcons.arrowLeftRight,
        debtCollection => LucideIcons.banknote,
        refund => LucideIcons.undo2,
        rentalIncome => LucideIcons.building2,
        investment => LucideIcons.lineChart,
        other => LucideIcons.circle,
      };
}

enum ExpenseCategory {
  rent,
  market,
  transport,
  bills,
  creditCard,
  loanInstallment,
  health,
  education,
  food,
  entertainment,
  clothing,
  subscription,
  advertising,
  businessTool,
  tax,
  other;

  String get label => switch (this) {
        rent => 'Kira',
        market => 'Market',
        transport => 'Ulaşım',
        bills => 'Faturalar',
        creditCard => 'Kredi Kartı',
        loanInstallment => 'Kredi Taksiti',
        health => 'Sağlık',
        education => 'Eğitim',
        food => 'Yeme-İçme',
        entertainment => 'Eğlence',
        clothing => 'Giyim',
        subscription => 'Abonelik',
        advertising => 'Reklam',
        businessTool => 'İş Aracı',
        tax => 'Vergi',
        other => 'Diğer',
      };

  IconData get icon => switch (this) {
        rent => LucideIcons.building2,
        market => LucideIcons.shoppingCart,
        transport => LucideIcons.car,
        bills => LucideIcons.zap,
        creditCard => LucideIcons.creditCard,
        loanInstallment => LucideIcons.banknote,
        health => LucideIcons.heartPulse,
        education => LucideIcons.graduationCap,
        food => LucideIcons.utensils,
        entertainment => LucideIcons.gamepad2,
        clothing => LucideIcons.shirt,
        subscription => LucideIcons.rss,
        advertising => LucideIcons.megaphone,
        businessTool => LucideIcons.wrench,
        tax => LucideIcons.receipt,
        other => LucideIcons.circle,
      };
}

enum ExpenseType {
  fixed,
  variable,
  discretionary,
  business;

  String get label => switch (this) {
        fixed => 'Sabit',
        variable => 'Değişken',
        discretionary => 'İsteğe Bağlı',
        business => 'İş/Yatırım',
      };
}

enum SavingsCategory {
  emergency,
  goal,
  gold,
  forex,
  stock,
  fund,
  deposit,
  retirement,
  other;

  String get label => switch (this) {
        emergency => 'Acil Durum Fonu',
        goal => 'Hedef Birikimi',
        gold => 'Altın',
        forex => 'Döviz',
        stock => 'Hisse Senedi',
        fund => 'Yatırım Fonu',
        deposit => 'Vadeli Mevduat',
        retirement => 'Emeklilik',
        other => 'Diğer',
      };

  IconData get icon => switch (this) {
        emergency => LucideIcons.shieldCheck,
        goal => LucideIcons.target,
        gold => LucideIcons.coins,
        forex => LucideIcons.dollarSign,
        stock => LucideIcons.candlestickChart,
        fund => LucideIcons.pieChart,
        deposit => LucideIcons.landmark,
        retirement => LucideIcons.sunMedium,
        other => LucideIcons.circle,
      };
}

enum SavingsStatus {
  active,
  withdrawn,
  completed;

  String get label => switch (this) {
        active => 'Aktif',
        withdrawn => 'Çekildi',
        completed => 'Tamamlandı',
      };
}

enum GoalStatus {
  active,
  completed,
  cancelled;

  String get label => switch (this) {
        active => 'Aktif',
        completed => 'Tamamlandı',
        cancelled => 'İptal Edildi',
      };
}

enum AffordabilityStatus {
  comfortable,
  manageable,
  tight,
  risky;

  String get label => switch (this) {
        comfortable => 'Rahat',
        manageable => 'İdare Edilebilir',
        tight => 'Sıkışık',
        risky => 'Riskli',
      };
}
