import 'package:flutter/widgets.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';

IconData incomeIcon(IncomeCategory cat) => switch (cat) {
  IncomeCategory.salary => AppIcons.salary,
  IncomeCategory.sideJob => AppIcons.freelance,
  IncomeCategory.freelance => AppIcons.freelance,
  IncomeCategory.transfer => AppIcons.transfer,
  IncomeCategory.debtCollection => AppIcons.loan,
  IncomeCategory.refund => AppIcons.transfer,
  IncomeCategory.rentalIncome => AppIcons.rent,
  IncomeCategory.investment => AppIcons.investment,
  IncomeCategory.other => AppIcons.income,
};

IconData expenseIcon(ExpenseCategory cat) => switch (cat) {
  ExpenseCategory.rent => AppIcons.rent,
  ExpenseCategory.market => AppIcons.market,
  ExpenseCategory.transport => AppIcons.transport,
  ExpenseCategory.bills => AppIcons.bills,
  ExpenseCategory.creditCard => AppIcons.loan,
  ExpenseCategory.loanInstallment => AppIcons.loan,
  ExpenseCategory.health => AppIcons.health,
  ExpenseCategory.education => AppIcons.education,
  ExpenseCategory.food => AppIcons.food,
  ExpenseCategory.entertainment => AppIcons.fun,
  ExpenseCategory.clothing => AppIcons.clothing,
  ExpenseCategory.subscription => AppIcons.subscription,
  ExpenseCategory.advertising => AppIcons.ad,
  ExpenseCategory.businessTool => AppIcons.freelance,
  ExpenseCategory.tax => AppIcons.tax,
  ExpenseCategory.other => AppIcons.expense,
};

IconData savingsIcon(SavingsCategory cat) => switch (cat) {
  SavingsCategory.emergency => AppIcons.emergency,
  SavingsCategory.goal => AppIcons.goal,
  SavingsCategory.gold => AppIcons.gold,
  SavingsCategory.forex => AppIcons.transfer,
  SavingsCategory.stock => AppIcons.stock,
  SavingsCategory.fund => AppIcons.investment,
  SavingsCategory.deposit => AppIcons.loan,
  SavingsCategory.retirement => AppIcons.retirement,
  SavingsCategory.other => AppIcons.savings,
};
