import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/shared/widgets/data_table_cells.dart';


// ─── Data Models ─────────────────────────────────────────────────────────

/// Data model for monthly category breakdown.
class MonthlyCategoryData {
  final List<String> months; // sorted chronologically
  final List<CategoryRowData> categories;
  final Map<String, double> monthTotals; // yearMonth → total

  const MonthlyCategoryData({
    required this.months,
    required this.categories,
    required this.monthTotals,
  });
}

class CategoryRowData {
  final String label;
  final IconData icon;
  final Map<String, double> monthAmounts; // yearMonth → amount
  final double grandTotal;

  const CategoryRowData({
    required this.label,
    required this.icon,
    required this.monthAmounts,
    required this.grandTotal,
  });
}

// ─── Builder Function ────────────────────────────────────────────────────

/// Builds monthly category data from a list of transactions.
MonthlyCategoryData buildMonthlyCategoryData<T>(
  List<T> items,
  String Function(T) getCategory,
  IconData Function(T) getIcon,
  DateTime Function(T) getDate,
  double Function(T) getAmount,
) {
  if (items.isEmpty) {
    return const MonthlyCategoryData(
      months: [],
      categories: [],
      monthTotals: {},
    );
  }

  // Collect all months and group by category + month
  final months = <String>{};
  final catMap = <String, Map<String, double>>{}; // label → {ym → sum}
  final catIcons = <String, IconData>{};
  final monthTotals = <String, double>{};

  for (final item in items) {
    final ym = getDate(item).toYearMonth();
    final cat = getCategory(item);
    final amount = getAmount(item);

    months.add(ym);
    catMap.putIfAbsent(cat, () => {});
    catMap[cat]![ym] = (catMap[cat]![ym] ?? 0) + amount;
    catIcons[cat] = getIcon(item);
    monthTotals[ym] = (monthTotals[ym] ?? 0) + amount;
  }

  final sortedMonths = months.toList()..sort();

  // Build category rows sorted by grand total desc
  final categories = catMap.entries.map((e) {
    final grandTotal = e.value.values.fold(0.0, (s, v) => s + v);
    return CategoryRowData(
      label: e.key,
      icon: catIcons[e.key]!,
      monthAmounts: e.value,
      grandTotal: grandTotal,
    );
  }).toList()
    ..sort((a, b) => b.grandTotal.compareTo(a.grandTotal));

  return MonthlyCategoryData(
    months: sortedMonths,
    categories: categories,
    monthTotals: monthTotals,
  );
}

// ─── Table Widget ────────────────────────────────────────────────────────

/// Horizontally scrollable category × month breakdown table.
class MonthlyCategoryTable extends StatefulWidget {
  final MonthlyCategoryData data;
  final Color color;
  final String prefix;

  const MonthlyCategoryTable({
    super.key,
    required this.data,
    required this.color,
    this.prefix = '',
  });

  @override
  State<MonthlyCategoryTable> createState() => _MonthlyCategoryTableState();
}

class _MonthlyCategoryTableState extends State<MonthlyCategoryTable> {
  late ScrollController _scrollController;
  bool _collapsed = false;

  static const _colW = 72.0;
  static const _labelW = 80.0;
  static const _labelCollapsedW = 36.0;
  static const _headerH = 36.0;
  static const _rowH = 32.0;
  static const _totalH = 36.0;
  static const _dividerH = 1.0;

  @override
  void initState() {
    super.initState();
    final len = widget.data.months.length;
    final initialOffset = len > 3 ? (len - 3) * _colW : 0.0;
    _collapsed = initialOffset > 20;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldCollapse = _scrollController.offset > 20;
    if (_collapsed != shouldCollapse) {
      setState(() => _collapsed = shouldCollapse);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.months.isEmpty || data.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final tableH = _headerH +
        _dividerH +
        (data.categories.length * _rowH) +
        _dividerH +
        _totalH;
    final labelW = _collapsed ? _labelCollapsedW : _labelW;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Aylık Dağılım',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.of(context).textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.swipe_rounded,
                size: 12, color: AppColors.of(context).textTertiary),
            const SizedBox(width: 4),
            Text(
              'Kaydır',
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.of(context).borderDefault.withValues(alpha: 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: tableH,
            child: Row(
              children: [
                // Left labels
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: labelW,
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: _headerH),
                      const Divider(height: _dividerH),
                      ...data.categories.map((cat) => SizedBox(
                            height: _rowH,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _collapsed
                                  ? Tooltip(
                                      key: const ValueKey('icon'),
                                      message: cat.label,
                                      child: Center(
                                        child: Icon(cat.icon,
                                            size: 13,
                                            color: widget.color),
                                      ),
                                    )
                                  : Align(
                                      key: const ValueKey('text'),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        cat.label,
                                        style:
                                            AppTypography.caption.copyWith(
                                          color: AppColors.of(context).textSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                            ),
                          )),
                      const Divider(height: _dividerH),
                      SizedBox(
                        height: _totalH,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _collapsed
                              ? Tooltip(
                                  key: const ValueKey('icon'),
                                  message: 'Toplam',
                                  child: Center(
                                    child: Icon(AppIcons.balance,
                                        size: 14,
                                        color: widget.color),
                                  ),
                                )
                              : Align(
                                  key: const ValueKey('text'),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Toplam',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: widget.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable month columns
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: data.months.map((ym) {
                        final monthTotal = data.monthTotals[ym] ?? 0;
                        return SizedBox(
                          width: _colW,
                          child: Column(
                            children: [
                              // Month header
                              SizedBox(
                                height: _headerH,
                                child: Center(
                                  child: Text(
                                    MonthLabels.shortName(ym),
                                    style:
                                        AppTypography.labelSmall.copyWith(
                                      color: AppColors.of(context).textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: _dividerH),
                              // Category values
                              ...data.categories.map((cat) {
                                final val = cat.monthAmounts[ym] ?? 0;
                                return DataTableCellValue(
                                  value: val,
                                  color: widget.color,
                                  height: _rowH,
                                  prefix: val > 0 ? widget.prefix : null,
                                );
                              }),
                              const Divider(height: _dividerH),
                              // Monthly total
                              DataTableCellValue(
                                value: monthTotal,
                                color: widget.color,
                                height: _totalH,
                                prefix: widget.prefix,
                                bold: true,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
