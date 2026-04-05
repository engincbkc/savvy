import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';

class AmortizationTable extends StatelessWidget {
  final List<AmortizationRow> schedule;
  final Color color;

  const AmortizationTable({
    super.key,
    required this.schedule,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final step = schedule.length > 24 ? (schedule.length / 24).ceil() : 1;
    final displayRows = <AmortizationRow>[];
    for (var i = 0; i < schedule.length; i += step) {
      displayRows.add(schedule[i]);
    }
    if (displayRows.last.month != schedule.last.month) {
      displayRows.add(schedule.last);
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.bottomOnly,
        border: Border(
          left: BorderSide(color: c.borderDefault),
          right: BorderSide(color: c.borderDefault),
          bottom: BorderSide(color: c.borderDefault),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: color.withValues(alpha: 0.05),
            child: Row(
              children: const [
                _AmortHeader('Ay'),
                _AmortHeader('Taksit'),
                _AmortHeader('Anapara'),
                _AmortHeader('Faiz'),
                _AmortHeader('Kalan'),
              ],
            ),
          ),
          ...displayRows.map((row) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: c.borderDefault.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    _AmortCell('${row.month}', c.textSecondary),
                    _AmortCell(CurrencyFormatter.formatNoDecimal(row.payment),
                        c.textPrimary),
                    _AmortCell(
                        CurrencyFormatter.formatNoDecimal(row.principal),
                        c.income),
                    _AmortCell(
                        CurrencyFormatter.formatNoDecimal(row.interest),
                        c.expense),
                    _AmortCell(
                        CurrencyFormatter.formatNoDecimal(row.balance),
                        c.textSecondary),
                  ],
                ),
              )),
          if (step > 1)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                '${schedule.length} aydan ${displayRows.length} tanesi gösteriliyor',
                style: AppTypography.caption.copyWith(color: c.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _AmortHeader extends StatelessWidget {
  final String text;
  const _AmortHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(text,
          style: AppTypography.labelSmall.copyWith(
              color: AppColors.of(context).textTertiary,
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
    );
  }
}

class _AmortCell extends StatelessWidget {
  final String text;
  final Color color;
  const _AmortCell(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(text,
          style: AppTypography.caption
              .copyWith(color: color, fontWeight: FontWeight.w500, fontSize: 10),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis),
    );
  }
}
