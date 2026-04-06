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
/// If [isRecurring] and [getRecurringEndDate] are provided, recurring items
/// are projected into future months.
MonthlyCategoryData buildMonthlyCategoryData<T>(
  List<T> items,
  String Function(T) getCategory,
  IconData Function(T) getIcon,
  DateTime Function(T) getDate,
  double Function(T) getAmount, {
  bool Function(T)? isRecurring,
  DateTime? Function(T)? getRecurringEndDate,
  double Function(T, int month)? getAmountForMonth,
  bool Function(T)? isYearBounded, // true = yıl sonuna kadar (brüt maaş gibi)
  /// Returns per-month override map (yearMonth → amount).
  Map<String, double> Function(T)? getMonthlyOverrides,
  int maxProjectionMonths = 240,
}) {
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

  void addEntry(String ym, String cat, double amount, IconData icon) {
    months.add(ym);
    catMap.putIfAbsent(cat, () => {});
    catMap[cat]![ym] = (catMap[cat]![ym] ?? 0) + amount;
    catIcons[cat] = icon;
    monthTotals[ym] = (monthTotals[ym] ?? 0) + amount;
  }

  for (final item in items) {
    final itemDate = getDate(item);
    final ym = itemDate.toYearMonth();
    final cat = getCategory(item);
    final icon = getIcon(item);
    final overrides = getMonthlyOverrides?.call(item) ?? const {};

    // Add the actual transaction — prefer override, then month-specific, then default
    double resolveAmount(String yearMonth, int month) {
      if (overrides.containsKey(yearMonth)) return overrides[yearMonth]!;
      if (getAmountForMonth != null) return getAmountForMonth(item, month);
      return getAmount(item);
    }

    addEntry(ym, cat, resolveAmount(ym, itemDate.month), icon);

    // Project recurring items into future months
    if (isRecurring != null && isRecurring(item)) {
      final endDate = getRecurringEndDate?.call(item);
      final isGross = isYearBounded != null && isYearBounded(item);
      final defaultLimit = isGross ? 60 : 12;
      final projLimit = endDate != null
          ? ((endDate.year - itemDate.year) * 12 + endDate.month - itemDate.month).clamp(1, maxProjectionMonths)
          : defaultLimit;
      for (int m = 1; m <= projLimit; m++) {
        final futureDate = DateTime(itemDate.year, itemDate.month + m, 1);
        if (endDate != null && futureDate.isAfter(endDate)) break;
        final futureYm = futureDate.toYearMonth();
        addEntry(futureYm, cat, resolveAmount(futureYm, futureDate.month), icon);
      }
    }
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
/// Supports tappable cells and resizable columns for Excel-like UX.
class MonthlyCategoryTable extends StatefulWidget {
  final MonthlyCategoryData data;
  final Color color;
  /// Called when a cell is tapped: (category label, yearMonth, current value)
  final void Function(String category, String yearMonth, double value)? onCellTap;

  const MonthlyCategoryTable({
    super.key,
    required this.data,
    required this.color,
    this.onCellTap,
  });

  @override
  State<MonthlyCategoryTable> createState() => _MonthlyCategoryTableState();
}

class _MonthlyCategoryTableState extends State<MonthlyCategoryTable> {
  late ScrollController _scrollController;
  bool _collapsed = false;
  int _visibleMonths = 12; // kullanıcının seçtiği görüntüleme aralığı

  static const _rangeOptions = [6, 12, 24, 60, 0]; // 0 = tümü
  static const _defaultColW = 72.0;
  static const _minColW = 52.0;
  static const _maxColW = 140.0;
  static const _labelW = 80.0;
  static const _labelCollapsedW = 36.0;
  static const _headerH = 36.0;
  static const _rowH = 32.0;
  static const _totalH = 36.0;
  static const _dividerH = 1.0;

  double _colW = _defaultColW;
  // Tracks currently tapped cell for highlight
  String? _tappedCellKey; // "category|yearMonth"

  @override
  void initState() {
    super.initState();
    final len = widget.data.months.length;
    final initialOffset = len > 3 ? (len - 3) * _defaultColW : 0.0;
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

  List<String> _filterMonths(List<String> allMonths) {
    if (_visibleMonths == 0) return allMonths; // tümü
    if (allMonths.length <= _visibleMonths) return allMonths;
    return allMonths.take(_visibleMonths).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.months.isEmpty || data.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleMonths = _filterMonths(data.months);

    // Recalc categories & totals for visible months only
    final filteredCategories = data.categories.map((cat) {
      final filtered = Map<String, double>.fromEntries(
        cat.monthAmounts.entries.where((e) => visibleMonths.contains(e.key)),
      );
      return CategoryRowData(
        label: cat.label,
        icon: cat.icon,
        monthAmounts: filtered,
        grandTotal: filtered.values.fold(0.0, (s, v) => s + v),
      );
    }).where((c) => c.grandTotal > 0).toList();

    final filteredTotals = Map<String, double>.fromEntries(
      data.monthTotals.entries.where((e) => visibleMonths.contains(e.key)),
    );

    if (filteredCategories.isEmpty) return const SizedBox.shrink();

    final tableH = _headerH +
        _dividerH +
        (filteredCategories.length * _rowH) +
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
            // Range selector
            ...(_rangeOptions.map((opt) {
              final isActive = _visibleMonths == opt;
              final label = opt == 0 ? 'Tümü' : opt >= 12 ? '${opt ~/ 12}y' : '${opt}ay';
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _visibleMonths = opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? widget.color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: isActive ? widget.color : AppColors.of(context).textTertiary,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              );
            })),
            const SizedBox(width: 4),
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
                      ...filteredCategories.map((cat) => SizedBox(
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
                  child: GestureDetector(
                    onScaleUpdate: (details) {
                      if (details.pointerCount >= 2) {
                        setState(() {
                          _colW = (_colW * details.scale).clamp(_minColW, _maxColW);
                        });
                      }
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: visibleMonths.map((ym) {
                          final monthTotal = filteredTotals[ym] ?? 0;
                          return SizedBox(
                            width: _colW,
                            child: Column(
                              children: [
                                // Month header
                                SizedBox(
                                  height: _headerH,
                                  child: Center(
                                    child: Text(
                                      MonthLabels.short(ym),
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
                                // Category values — tappable
                                ...filteredCategories.map((cat) {
                                  final val = cat.monthAmounts[ym] ?? 0;
                                  final cellKey = '${cat.label}|$ym';
                                  final isTapped = _tappedCellKey == cellKey;
                                  return GestureDetector(
                                    onTap: widget.onCellTap != null && val > 0
                                        ? () {
                                            setState(() => _tappedCellKey =
                                                isTapped ? null : cellKey);
                                            widget.onCellTap!(cat.label, ym, val);
                                          }
                                        : null,
                                    child: Container(
                                      color: isTapped
                                          ? widget.color.withValues(alpha: 0.08)
                                          : null,
                                      child: DataTableCellValue(
                                        value: val,
                                        color: widget.color,
                                        height: _rowH,
                                      ),
                                    ),
                                  );
                                }),
                                const Divider(height: _dividerH),
                                // Monthly total
                                DataTableCellValue(
                                  value: monthTotal,
                                  color: widget.color,
                                  height: _totalH,
                                  bold: true,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
