import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:savvy/shared/widgets/salary_breakdown_panel.dart';
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
  AnnualSalaryBreakdown? _annualBreakdown;
  int _selectedMonthIndex = 0;
  Timer? _grossDebounce;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _grossController.addListener(_onGrossChanged);
    _selectedMonthIndex = _date.month - 1;
  }

  void _onAmountChanged() {
    final ok = isAmountValid(_amountController.text);
    if (ok != _amountOk) setState(() => _amountOk = ok);
  }

  void _onGrossChanged() {
    _grossDebounce?.cancel();
    final text = _grossController.text;

    if (text.isEmpty) {
      setState(() => _annualBreakdown = null);
      return;
    }

    _grossDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final cleaned =
          text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
      final gross = double.tryParse(cleaned);
      if (gross == null || gross <= 0) {
        setState(() => _annualBreakdown = null);
        return;
      }
      final breakdown =
          FinancialCalculator.calculateAnnualNetSalary(grossMonthly: gross);
      setState(() => _annualBreakdown = breakdown);
      _syncNetAmount();
    });
  }

  void _syncNetAmount() {
    if (_annualBreakdown == null) return;
    final netInt =
        _annualBreakdown!.months[_selectedMonthIndex].netTakeHome.round();
    _amountController.removeListener(_onAmountChanged);
    _amountController.text = _formatThousands(netInt);
    _amountController.addListener(_onAmountChanged);
    _onAmountChanged();
  }

  void _onMonthSelected(int index) {
    setState(() => _selectedMonthIndex = index);
    _syncNetAmount();
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
    _grossDebounce?.cancel();
    _amountController.dispose();
    _grossController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showSavvyDatePicker(
      context: context,
      initialDate: _date,
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        if (_useGrossCalc) {
          _selectedMonthIndex = picked.month - 1;
          _syncNetAmount();
        }
      });
    }
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

    final double amount;
    final bool isGross;

    if (_useGrossCalc && _annualBreakdown != null) {
      // Brüt maaş: tek kayıt, amount = brüt, isGross = true
      amount = _annualBreakdown!.grossMonthly;
      isGross = true;
    } else {
      amount = parseAmount(_amountController.text);
      isGross = false;
    }

    final income = Income(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _useGrossCalc ? true : _isRecurring,
      recurringEndDate: _recurringEndDate,
      isGross: isGross,
      createdAt: DateTime.now(),
      isSettled: !_date.isAfter(DateTime.now()),
    );

    final success =
        await ref.read(transactionFormProvider.notifier).addIncome(income);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        final displayAmount = isGross
            ? FinancialCalculator.resolveNetForMonth(
                amount: amount, isGross: true, month: _date.month)
            : amount;
        showSuccessSnackbar(
          context,
          isGross
              ? 'Brüt maaş eklendi (${CurrencyFormatter.formatNoDecimal(displayAmount)} net)'
              : 'Gelir eklendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).income,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      transactionFormProvider.select((s) => s.isLoading),
    );
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
                    prefixIcon:
                        const Icon(Icons.label_outline_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Tutar veya Brüt giriş
                if (_useGrossCalc)
                  GrossAmountInput(
                    controller: _grossController,
                    accentColor: c.income,
                    strongColor: c.incomeStrong,
                    bgColor: c.incomeSurfaceDim,
                  )
                else
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
                        _annualBreakdown = null;
                        _grossController.clear();
                      }
                    });
                  },
                ),

                // Brütten Hesapla toggle — only when Maaş
                if (isSalary) ...[
                  const SizedBox(height: AppSpacing.base),
                  GrossCalcToggle(
                    value: _useGrossCalc,
                    activeColor: c.income,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _useGrossCalc = v;
                        if (!v) {
                          _annualBreakdown = null;
                          _grossController.clear();
                        } else {
                          _selectedMonthIndex = _date.month - 1;
                          if (_grossController.text.isNotEmpty) {
                            _onGrossChanged();
                          }
                        }
                      });
                    },
                  ),
                ],

                // Salary Breakdown Panel
                if (_useGrossCalc && _annualBreakdown != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  SalaryBreakdownPanel(
                    breakdown: _annualBreakdown!,
                    selectedMonthIndex: _selectedMonthIndex,
                    onMonthSelected: _onMonthSelected,
                    accentColor: c.income,
                  ),
                ],
                const SizedBox(height: AppSpacing.base),

                // Brüt modda: otomatik periyodik bilgi göster
                if (_useGrossCalc && _annualBreakdown != null) ...[
                  GrossIncomeInfo(
                    breakdown: _annualBreakdown!,
                    currentMonth: _date.month,
                    accentColor: c.income,
                  ),
                ] else ...[
                  // Normal modda: periyodik toggle
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
                ],
                const SizedBox(height: AppSpacing.xl),

                // Date
                FormSectionLabel(text: 'Başlangıç Tarihi', icon: AppIcons.calendar),
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
                  decoration: InputDecoration(
                    hintText: 'Not (opsiyonel)',
                    prefixIcon: const Icon(AppIcons.note, size: 18),
                    counterStyle: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                FormSubmitButton(
                  isLoading: isLoading,
                  label: _useGrossCalc
                      ? 'Brüt Maaş Ekle'
                      : 'Gelir Ekle',
                  color: c.income,
                  enabled: _useGrossCalc
                      ? _annualBreakdown != null
                      : _amountOk,
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

