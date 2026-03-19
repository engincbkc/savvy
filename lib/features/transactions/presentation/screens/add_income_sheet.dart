import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddIncomeSheet extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  const AddIncomeSheet({super.key, this.scrollController});

  @override
  ConsumerState<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _grossController = TextEditingController();
  final _noteController = TextEditingController();
  final _personController = TextEditingController();
  IncomeCategory _category = IncomeCategory.salary;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  DateTime? _recurringEndDate;
  bool _amountOk = false;

  // Brüt → Net
  bool _useGrossCalc = false;
  SalaryBreakdown? _breakdown;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _grossController.addListener(_onGrossChanged);
  }

  void _onAmountChanged() {
    final ok = isAmountValid(_amountController.text);
    if (ok != _amountOk) setState(() => _amountOk = ok);
  }

  void _onGrossChanged() {
    final text = _grossController.text;
    if (text.isEmpty) {
      setState(() => _breakdown = null);
      return;
    }
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
    final gross = double.tryParse(cleaned);
    if (gross == null || gross <= 0) {
      setState(() => _breakdown = null);
      return;
    }
    final bd = FinancialCalculator.grossToNet(grossMonthly: gross);
    setState(() => _breakdown = bd);

    // Net tutarı ana tutar alanına yaz
    final netInt = bd.netMonthly.round();
    _amountController.removeListener(_onAmountChanged);
    _amountController.text = _formatThousands(netInt);
    _amountController.addListener(_onAmountChanged);
    _onAmountChanged();
  }

  String _formatThousands(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _grossController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _pickEndDate() {
    showMonthDurationPicker(
      context: context,
      startDate: _date,
      currentEndDate: _recurringEndDate,
      onSelected: (date) => setState(() => _recurringEndDate = date),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseAmount(_amountController.text);
    final income = Income(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
      createdAt: DateTime.now(),
    );

    final success =
        await ref.read(transactionFormProvider.notifier).addIncome(income);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gelir eklendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).income,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final c = AppColors.of(context);
    final isSalary = _category == IncomeCategory.salary;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: AppSpacing.lg),

                // Header
                const SheetHeader(
                  icon: AppIcons.income,
                  gradient: [Color(0xFF059669), Color(0xFF10B981)],
                  title: 'Gelir Ekle',
                  subtitle: 'Yeni bir gelir kaydı oluştur',
                ),
                const SizedBox(height: AppSpacing.xl),

                // Başlık
                TextFormField(
                  controller: _personController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Başlık (opsiyonel)',
                    prefixIcon: const Icon(Icons.label_outline_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Amount (readonly when using gross calc)
                AmountInputField(
                  controller: _amountController,
                  color: c.income,
                  strongColor: c.incomeStrong,
                  bgColor: c.incomeSurfaceDim,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Category
                FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
                const SizedBox(height: AppSpacing.sm),
                CategoryChipSelector<IncomeCategory>(
                  values: IncomeCategory.values,
                  selected: _category,
                  labelOf: (cat) => cat.label,
                  iconOf: (cat) => cat.icon,
                  activeColor: c.income,
                  onSelected: (cat) {
                    setState(() {
                      _category = cat;
                      if (cat != IncomeCategory.salary) {
                        _useGrossCalc = false;
                        _breakdown = null;
                      }
                    });
                  },
                ),

                // Brütten Hesapla toggle — only when Maaş
                if (isSalary) ...[
                  const SizedBox(height: AppSpacing.base),
                  _GrossCalcToggle(
                    value: _useGrossCalc,
                    activeColor: c.income,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _useGrossCalc = v;
                        if (!v) {
                          _breakdown = null;
                          _grossController.clear();
                        }
                      });
                    },
                  ),
                  if (_useGrossCalc) ...[
                    const SizedBox(height: AppSpacing.md),
                    _GrossInputSection(
                      controller: _grossController,
                      breakdown: _breakdown,
                      color: c.income,
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.base),

                // Recurring
                RecurringToggle(
                  label: 'Periyodik Gelir',
                  value: _isRecurring,
                  activeColor: c.income,
                  onChanged: (v) => setState(() {
                    _isRecurring = v;
                    if (!v) _recurringEndDate = null;
                  }),
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _pickEndDate,
                    child: FieldChip(
                      icon: Icons.event_busy_rounded,
                      label: _recurringEndDate != null
                          ? 'Bitiş: ${formatDateTR(_recurringEndDate!)}'
                          : 'Bitiş Tarihi (opsiyonel)',
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),

                // Date
                FormSectionLabel(text: 'Tarih', icon: AppIcons.calendar),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickDate,
                  child: FieldChip(
                    icon: AppIcons.calendar,
                    label: formatDateTR(_date),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Note
                TextFormField(
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Not (opsiyonel)',
                    prefixIcon: Icon(AppIcons.note, size: 18),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                FormSubmitButton(
                  isLoading: formState.isLoading,
                  label: 'Gelir Ekle',
                  color: c.income,
                  enabled: _amountOk,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Brütten Hesapla Toggle
// ═══════════════════════════════════════════════════════════════════

class _GrossCalcToggle extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _GrossCalcToggle({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.08)
            : AppColors.of(context).surfaceOverlay,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.15)
                  : AppColors.of(context).surfaceInput,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              Icons.calculate_rounded,
              size: 16,
              color: value ? activeColor : AppColors.of(context).textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brütten Hesapla',
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.of(context).textPrimary)),
                Text(
                  value
                      ? 'SGK, vergi otomatik hesaplanır'
                      : 'Brüt maaş girip net tutarı hesapla',
                  style: AppTypography.caption.copyWith(
                    color: value
                        ? activeColor
                        : AppColors.of(context).textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Brüt Maaş Giriş + Breakdown
// ═══════════════════════════════════════════════════════════════════

class _GrossInputSection extends StatelessWidget {
  final TextEditingController controller;
  final SalaryBreakdown? breakdown;
  final Color color;

  const _GrossInputSection({
    required this.controller,
    required this.breakdown,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brüt tutar girişi
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ThousandFormatter(),
            ],
            textInputAction: TextInputAction.done,
            style: AppTypography.numericMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Brüt maaş girin',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: c.textTertiary,
              ),
              prefixIcon: Icon(Icons.account_balance_rounded,
                  size: 18, color: c.textTertiary),
              suffixText: '₺',
              suffixStyle: AppTypography.numericMedium.copyWith(
                color: color.withValues(alpha: 0.4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
          ),

          // Breakdown
          if (breakdown != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            _BreakdownRow(
              label: 'Brüt Maaş',
              value: breakdown!.grossMonthly,
              color: c.textPrimary,
              bold: true,
            ),
            const SizedBox(height: AppSpacing.xs),
            _BreakdownRow(
              label: 'SGK İşçi Payı (%14)',
              value: -breakdown!.sgk,
              color: c.expense,
            ),
            _BreakdownRow(
              label: 'İşsizlik Sigortası (%1)',
              value: -breakdown!.unemploymentInsurance,
              color: c.expense,
            ),
            _BreakdownRow(
              label: 'Gelir Vergisi',
              value: -breakdown!.incomeTax,
              color: c.expense,
            ),
            _BreakdownRow(
              label: 'Damga Vergisi (%0,759)',
              value: -breakdown!.stampTax,
              color: c.expense,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),
            _BreakdownRow(
              label: 'Net Maaş',
              value: breakdown!.netMonthly,
              color: color,
              bold: true,
              large: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;
  final bool large;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (large ? AppTypography.labelMedium : AppTypography.caption)
                .copyWith(
              color: bold
                  ? AppColors.of(context).textPrimary
                  : AppColors.of(context).textSecondary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            CurrencyFormatter.formatNoDecimal(value.abs()),
            style:
                (large ? AppTypography.numericSmall : AppTypography.caption)
                    .copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
