import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';

class CreditBreakdownCard extends StatelessWidget {
  final CreditSimulationResult result;
  final Color color;

  const CreditBreakdownCard(
      {super.key, required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BreakdownContainer(
      color: color,
      children: [
        BreakdownRow('Toplam Ödeme',
            CurrencyFormatter.formatNoDecimal(result.totalPayment), c.textPrimary),
        BreakdownRow('Toplam Faiz',
            CurrencyFormatter.formatNoDecimal(result.totalInterest), c.expense),
        BreakdownRow(
            'Faiz / Anapara',
            '%${(result.totalInterest / (result.totalPayment == 0 ? 1 : result.totalPayment) * 100).toStringAsFixed(1)}',
            c.textSecondary),
      ],
    );
  }
}

class CarBreakdownCard extends StatelessWidget {
  final CarSimulationResult result;
  final Color color;

  const CarBreakdownCard(
      {super.key, required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BreakdownContainer(
      color: color,
      children: [
        BreakdownRow('Kredi Tutarı',
            CurrencyFormatter.formatNoDecimal(result.loanAmount), c.textPrimary),
        BreakdownRow(
            'Aylık Taksit',
            CurrencyFormatter.formatNoDecimal(
                result.creditResult.monthlyPayment),
            c.textSecondary),
        BreakdownRow(
            'Aylık Ek Giderler',
            CurrencyFormatter.formatNoDecimal(result.estimatedMonthlyCosts),
            c.textSecondary),
        BreakdownRow(
            'Toplam Faiz',
            CurrencyFormatter.formatNoDecimal(
                result.creditResult.totalInterest),
            c.expense),
      ],
    );
  }
}

class RentBreakdownCard extends StatelessWidget {
  final RentSimulationResult result;
  final Color color;

  const RentBreakdownCard(
      {super.key, required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BreakdownContainer(
      color: color,
      children: [
        BreakdownRow('Yeni Kira',
            CurrencyFormatter.formatNoDecimal(result.newRent), c.textPrimary),
        BreakdownRow('Yıllık Fark',
            CurrencyFormatter.withSign(result.annualDiff), c.expense),
        BreakdownRow(
            'Yeni Gider Oranı',
            '%${(result.newExpenseRate * 100).toStringAsFixed(1)}',
            c.textSecondary),
      ],
    );
  }
}

class BreakdownContainer extends StatelessWidget {
  final Color color;
  final List<Widget> children;

  const BreakdownContainer(
      {super.key, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.receipt, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text('Detay',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const BreakdownRow(this.label, this.value, this.valueColor, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
          Text(value,
              style: AppTypography.numericSmall
                  .copyWith(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
