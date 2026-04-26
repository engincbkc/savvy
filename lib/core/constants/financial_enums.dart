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
        manageable => 'İdare edilir',
        tight => 'Sıkışık',
        risky => 'Yasal limit aşımı',
      };
}

/// Quick-start templates for creating simulations.
/// Each maps to a set of pre-configured SimulationChange items.
enum SimulationTemplate {
  credit,
  housing,
  car,
  rentChange,
  salaryChange,
  investment,
  custom;

  String get label => switch (this) {
        credit => 'Kredi Çekimi',
        housing => 'Ev Alımı',
        car => 'Araç Alımı',
        rentChange => 'Kira Değişimi',
        salaryChange => 'Maaş Değişikliği',
        investment => 'Yatırım',
        custom => 'Özel Senaryo',
      };

  String get subtitle => switch (this) {
        credit => 'İhtiyaç, konut veya ticari kredi',
        housing => 'Konut kredisi, peşinat, FuzulEv',
        car => 'Taşıt kredisi + aylık giderler',
        rentChange => 'Kira artışı veya yeni eve taşınma',
        salaryChange => 'Zam, terfi veya iş değişikliği',
        investment => 'Vadeli mevduat, fon, hisse...',
        custom => 'Örn: "3 ay sonra freelance geliri +15K" veya "Haziranda düğün gideri -50K"',
      };

  IconData get icon => switch (this) {
        credit => LucideIcons.creditCard,
        housing => LucideIcons.home,
        car => LucideIcons.car,
        rentChange => LucideIcons.building2,
        salaryChange => LucideIcons.briefcase,
        investment => LucideIcons.trendingUp,
        custom => LucideIcons.sparkles,
      };

  Color get color => switch (this) {
        credit => const Color(0xFF3F83F8),
        housing => const Color(0xFF1A56DB),
        car => const Color(0xFF0E9F6E),
        rentChange => const Color(0xFFE8590C),
        salaryChange => const Color(0xFF8B5CF6),
        investment => const Color(0xFF0891B2),
        custom => const Color(0xFF6B7280),
      };
}

/// Legacy type enum — kept for backward compat with old Firestore data.
@Deprecated('Use SimulationTemplate instead')
enum SimulationType {
  car,
  housing,
  credit,
  vacation,
  tech,
  custom;

  String get label => switch (this) {
        car => 'Araç Alımı',
        housing => 'Ev Alımı',
        credit => 'Kredi Çekimi',
        vacation => 'Tatil Planı',
        tech => 'Teknoloji',
        custom => 'Diğer',
      };

  String get subtitle => switch (this) {
        car => 'Taşıt kredisi + aylık giderler',
        housing => 'Konut kredisi, peşinat planı',
        credit => 'İhtiyaç, konut veya ticari kredi',
        vacation => 'Yurtiçi & yurtdışı tatil bütçesi',
        tech => 'Telefon, bilgisayar, kamera...',
        custom => 'Kendi senaryonu oluştur',
      };

  IconData get icon => switch (this) {
        car => LucideIcons.car,
        housing => LucideIcons.home,
        credit => LucideIcons.creditCard,
        vacation => LucideIcons.plane,
        tech => LucideIcons.smartphone,
        custom => LucideIcons.sparkles,
      };

  Color get color => switch (this) {
        car => const Color(0xFF0E9F6E),
        housing => const Color(0xFF1A56DB),
        credit => const Color(0xFF3F83F8),
        vacation => const Color(0xFFE8590C),
        tech => const Color(0xFF8B5CF6),
        custom => const Color(0xFF6B7280),
      };
}
