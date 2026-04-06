import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:savvy/shared/widgets/salary_breakdown_panel.dart';

class EditIncomeSheet extends ConsumerStatefulWidget {
  final Income income;
  const EditIncomeSheet({super.key, required this.income});

  @override
  ConsumerState<EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends ConsumerState<EditIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _grossController;
  late final TextEditingController _noteController;
  late final TextEditingController _personController;
  late IncomeCategory _category;
  late DateTime _date;
  late bool _isRecurring;
  DateTime? _recurringEndDate;

  // Brüt → Net
  late bool _useGrossCalc;
  AnnualSalaryBreakdown? _annualBreakdown;
  late int _selectedMonthIndex;

  // Original values for change detection
  late final String _origAmount;
  late final String _origGross;
  late final String _origNote;
  late final String _origPerson;
  late final IncomeCategory _origCategory;
  late final DateTime _origDate;
  late final bool _origIsRecurring;
  late final DateTime? _origRecurringEndDate;
  late final bool _origIsGross;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final i = widget.income;

    _useGrossCalc = i.isGross;
    _selectedMonthIndex = i.date.month - 1;

    if (i.isGross) {
      // Brüt kayıt: amount = brüt tutar
      _grossController = TextEditingController(
          text: _formatThousands(i.amount.round()));
      final breakdown = FinancialCalculator.calculateAnnualNetSalary(
          grossMonthly: i.amount);
      _annualBreakdown = breakdown;
      final netInt = breakdown.months[_selectedMonthIndex].netTakeHome.round();
      _amountController = TextEditingController(
          text: _formatThousands(netInt));
    } else {
      _grossController = TextEditingController();
      _amountController = TextEditingController(
          text: i.amount.toStringAsFixed(0));
    }

    _noteController = TextEditingController(text: i.note ?? '');
    _personController = TextEditingController(text: i.person ?? '');
    _category = i.category;
    _date = i.date;
    _isRecurring = i.isRecurring;
    _recurringEndDate = i.recurringEndDate;

    // Store originals
    _origAmount = _amountController.text;
    _origGross = _grossController.text;
    _origNote = _noteController.text;
    _origPerson = _personController.text;
    _origCategory = i.category;
    _origDate = i.date;
    _origIsRecurring = i.isRecurring;
    _origRecurringEndDate = i.recurringEndDate;
    _origIsGross = i.isGross;

    _amountController.addListener(_checkChanges);
    _grossController.addListener(_onGrossChanged);
    _noteController.addListener(_checkChanges);
    _personController.addListener(_checkChanges);
  }

  void _onGrossChanged() {
    final text = _grossController.text;
    if (text.isEmpty) {
      setState(() => _annualBreakdown = null);
      _checkChanges();
      return;
    }
    final cleaned =
        text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
    final gross = double.tryParse(cleaned);
    if (gross == null || gross <= 0) {
      setState(() => _annualBreakdown = null);
      _checkChanges();
      return;
    }

    final breakdown =
        FinancialCalculator.calculateAnnualNetSalary(grossMonthly: gross);
    setState(() => _annualBreakdown = breakdown);
    _syncNetAmount();
    _checkChanges();
  }

  void _syncNetAmount() {
    if (_annualBreakdown == null) return;
    final netInt =
        _annualBreakdown!.months[_selectedMonthIndex].netTakeHome.round();
    _amountController.removeListener(_checkChanges);
    _amountController.text = _formatThousands(netInt);
    _amountController.addListener(_checkChanges);
  }

  void _onMonthSelected(int index) {
    setState(() => _selectedMonthIndex = index);
    final newMonth = index + 1;
    final maxDay = DateUtils.getDaysInMonth(_date.year, newMonth);
    final day = _date.day > maxDay ? maxDay : _date.day;
    _date = DateTime(_date.year, newMonth, day);
    _syncNetAmount();
    _checkChanges();
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

  void _checkChanges() {
    final changed = _amountController.text != _origAmount ||
        _grossController.text != _origGross ||
        _noteController.text != _origNote ||
        _personController.text != _origPerson ||
        _category != _origCategory ||
        _date != _origDate ||
        _isRecurring != _origIsRecurring ||
        _recurringEndDate != _origRecurringEndDate ||
        _useGrossCalc != _origIsGross;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _grossController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount;
    final bool isGross;

    if (_useGrossCalc && _annualBreakdown != null) {
      amount = _annualBreakdown!.grossMonthly;
      isGross = true;
    } else {
      amount = parseAmount(_amountController.text);
      isGross = false;
    }

    final updated = widget.income.copyWith(
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _useGrossCalc ? true : _isRecurring,
      recurringEndDate: _recurringEndDate,
      isGross: isGross,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateIncome(updated);
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
              ? 'Brüt maaş güncellendi (${CurrencyFormatter.formatNoDecimal(displayAmount)} net)'
              : 'Gelir güncellendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).income,
        );
      }
    }
  }

  void _pickEndDate() {
    showMonthDurationPicker(
      context: context,
      startDate: _date,
      currentEndDate: _recurringEndDate,
      onSelected: (date) {
        setState(() => _recurringEndDate = date);
        _checkChanges();
      },
    );
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: AppSpacing.lg),

                SheetHeader(
                  icon: AppIcons.edit,
                  gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                  title: _useGrossCalc ? 'Brüt Maaş Düzenle' : 'Gelir Düzenle',
                  subtitle: _useGrossCalc
                      ? 'Brüt maaş kaydını güncelle'
                      : 'Mevcut gelir kaydını güncelle',
                ),
                const SizedBox(height: AppSpacing.xl),

                // Başlık
                TextFormField(
                  controller: _personController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Başlık (opsiyonel)',
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(
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
                    _checkChanges();
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
                      _checkChanges();
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
                    onChanged: (v) {
                      setState(() {
                        _isRecurring = v;
                        if (!v) _recurringEndDate = null;
                      });
                      _checkChanges();
                    },
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

                // Date & Note
                FormSectionLabel(text: 'Detaylar', icon: AppIcons.info),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showSavvyDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                          );
                          if (picked != null) {
                            setState(() {
                              _date = picked;
                              if (_useGrossCalc) {
                                _selectedMonthIndex = picked.month - 1;
                                _syncNetAmount();
                              }
                            });
                            _checkChanges();
                          }
                        },
                        child: FieldChip(
                          icon: AppIcons.calendar,
                          label: formatDateTR(_date),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                TextFormField(
                  controller: _noteController,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Not',
                    prefixIcon: Icon(AppIcons.note, size: 18),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_hasChanges) ...[
                  const SizedBox(height: AppSpacing.base),
                  FormSubmitButton(
                    isLoading: formState.isLoading,
                    label: _useGrossCalc ? 'Brüt Maaş Kaydet' : 'Kaydet',
                    color: c.income,
                    onPressed: _submit,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
