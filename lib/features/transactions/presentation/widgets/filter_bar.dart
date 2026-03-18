import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

class TransactionFilters {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<String> categories;
  final double? amountMin;
  final double? amountMax;
  final String searchQuery;

  const TransactionFilters({
    this.dateFrom,
    this.dateTo,
    this.categories = const {},
    this.amountMin,
    this.amountMax,
    this.searchQuery = '',
  });

  bool get isActive =>
      dateFrom != null ||
      dateTo != null ||
      categories.isNotEmpty ||
      amountMin != null ||
      amountMax != null ||
      searchQuery.isNotEmpty;

  int get activeCount {
    int c = 0;
    if (dateFrom != null || dateTo != null) c++;
    if (categories.isNotEmpty) c++;
    if (amountMin != null || amountMax != null) c++;
    if (searchQuery.isNotEmpty) c++;
    return c;
  }

  TransactionFilters copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    Set<String>? categories,
    double? amountMin,
    double? amountMax,
    String? searchQuery,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearAmountMin = false,
    bool clearAmountMax = false,
  }) {
    return TransactionFilters(
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      categories: categories ?? this.categories,
      amountMin: clearAmountMin ? null : (amountMin ?? this.amountMin),
      amountMax: clearAmountMax ? null : (amountMax ?? this.amountMax),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  TransactionFilters clear() => const TransactionFilters();
}

class FilterBar extends StatefulWidget {
  final TransactionFilters filters;
  final ValueChanged<TransactionFilters> onChanged;
  final int activeTabIndex; // 0=income, 1=expense, 2=savings

  const FilterBar({
    super.key,
    required this.filters,
    required this.onChanged,
    required this.activeTabIndex,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final TextEditingController _searchController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.filters.searchQuery);
    _minController = TextEditingController(
        text: widget.filters.amountMin?.toStringAsFixed(0) ?? '');
    _maxController = TextEditingController(
        text: widget.filters.amountMax?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  List<String> get _availableCategories {
    return switch (widget.activeTabIndex) {
      0 => IncomeCategory.values.map((c) => c.label).toList(),
      1 => ExpenseCategory.values.map((c) => c.label).toList(),
      2 => SavingsCategory.values.map((c) => c.label).toList(),
      _ => [],
    };
  }

  void _update(TransactionFilters f) => widget.onChanged(f);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final f = widget.filters;

    return Column(
      children: [
        // Toggle bar
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _expanded = !_expanded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: f.isActive
                  ? c.brandPrimary.withValues(alpha: 0.06)
                  : c.surfaceCard,
              borderRadius: AppRadius.input,
              border: Border.all(
                color: f.isActive
                    ? c.brandPrimary.withValues(alpha: 0.2)
                    : c.borderDefault,
              ),
            ),
            child: Row(
              children: [
                Icon(AppIcons.filter,
                    size: 16,
                    color:
                        f.isActive ? c.brandPrimary : c.textTertiary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  f.isActive
                      ? 'Filtreler (${f.activeCount})'
                      : 'Filtreler',
                  style: AppTypography.labelSmall.copyWith(
                    color:
                        f.isActive ? c.brandPrimary : c.textSecondary,
                    fontWeight:
                        f.isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (f.isActive)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _minController.clear();
                      _maxController.clear();
                      _update(f.clear());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Text('Temizle',
                          style: AppTypography.caption.copyWith(
                            color: c.expense,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: c.textTertiary),
                ),
              ],
            ),
          ),
        ),

        // Expanded filters
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedFilters(c, f),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildExpandedFilters(dynamic c, TransactionFilters f) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search
          TextFormField(
            controller: _searchController,
            onChanged: (v) => _update(f.copyWith(searchQuery: v)),
            decoration: InputDecoration(
              hintText: 'Not veya açıklamada ara...',
              prefixIcon:
                  Icon(AppIcons.search, size: 16, color: c.textTertiary),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date range
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: f.dateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 366)),
                    );
                    if (picked != null) _update(f.copyWith(dateFrom: picked));
                  },
                  child: FieldChip(
                    icon: AppIcons.calendar,
                    label: f.dateFrom != null
                        ? formatDateTR(f.dateFrom!)
                        : 'Başlangıç',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: f.dateTo ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 366)),
                    );
                    if (picked != null) _update(f.copyWith(dateTo: picked));
                  },
                  child: FieldChip(
                    icon: AppIcons.calendar,
                    label: f.dateTo != null
                        ? formatDateTR(f.dateTo!)
                        : 'Bitiş',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandFormatter(),
                  ],
                  onChanged: (v) {
                    final cleaned = v.replaceAll('.', '');
                    final val = double.tryParse(cleaned);
                    _update(val != null && val > 0
                        ? f.copyWith(amountMin: val)
                        : f.copyWith(clearAmountMin: true));
                  },
                  decoration: InputDecoration(
                    hintText: 'Min ₺',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandFormatter(),
                  ],
                  onChanged: (v) {
                    final cleaned = v.replaceAll('.', '');
                    final val = double.tryParse(cleaned);
                    _update(val != null && val > 0
                        ? f.copyWith(amountMax: val)
                        : f.copyWith(clearAmountMax: true));
                  },
                  decoration: InputDecoration(
                    hintText: 'Max ₺',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Category multi-select
          Text('Kategori',
              style: AppTypography.labelSmall.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _availableCategories.map((cat) {
              final isSelected = f.categories.contains(cat);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final newCats = Set<String>.from(f.categories);
                  isSelected ? newCats.remove(cat) : newCats.add(cat);
                  _update(f.copyWith(categories: newCats));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? c.brandPrimary
                        : c.surfaceOverlay,
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                      color:
                          isSelected ? c.brandPrimary : c.borderDefault,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? Colors.white : c.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
