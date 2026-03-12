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
