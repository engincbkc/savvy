import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

class EditIncomeSheet extends ConsumerStatefulWidget {
  final Income income;
  const EditIncomeSheet({super.key, required this.income});

  @override
  ConsumerState<EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends ConsumerState<EditIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _personController;
  late IncomeCategory _category;
  late DateTime _date;
  late bool _isRecurring;
  DateTime? _recurringEndDate;

  @override
  void initState() {
    super.initState();
    final i = widget.income;
    _amountController = TextEditingController(text: i.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: i.note ?? '');
    _personController = TextEditingController(text: i.person ?? '');
    _category = i.category;
    _date = i.date;
    _isRecurring = i.isRecurring;
    _recurringEndDate = i.recurringEndDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text);

    final updated = widget.income.copyWith(
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateIncome(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Gelir guncellendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).income,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final c = AppColors.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.base,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),

              const SheetHeader(
                icon: AppIcons.edit,
                gradient: [Color(0xFF059669), Color(0xFF10B981)],
                title: 'Gelir Duzenle',
                subtitle: 'Mevcut gelir kaydini guncelle',
              ),
              const SizedBox(height: AppSpacing.xl),

              AmountInputField(
                controller: _amountController,
                color: c.income,
                strongColor: c.incomeStrong,
                bgColor: c.incomeSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xl),

              FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
              const SizedBox(height: AppSpacing.sm),
              CategoryChipSelector<IncomeCategory>(
                values: IncomeCategory.values,
                selected: _category,
                labelOf: (cat) => cat.label,
                iconOf: (cat) => cat.icon,
                activeColor: c.income,
                onSelected: (cat) => setState(() => _category = cat),
              ),
              const SizedBox(height: AppSpacing.xl),

              FormSectionLabel(text: 'Detaylar', icon: AppIcons.info),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 366)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: FieldChip(
                        icon: AppIcons.calendar,
                        label: formatDateTR(_date),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      decoration: InputDecoration(
                        hintText: 'Kisi',
                        prefixIcon: const Icon(AppIcons.person, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        isDense: true,
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
              const SizedBox(height: AppSpacing.base),

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
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _recurringEndDate ?? _date.add(const Duration(days: 365)),
                      firstDate: _date,
                      lastDate: DateTime.now().add(const Duration(days: 1825)),
                    );
                    if (picked != null) setState(() => _recurringEndDate = picked);
                  },
                  child: FieldChip(
                    icon: Icons.event_busy_rounded,
                    label: _recurringEndDate != null
                        ? 'Bitis: ${formatDateTR(_recurringEndDate!)}'
                        : 'Bitis Tarihi (opsiyonel)',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),


                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              FormSubmitButton(
                isLoading: formState.isLoading,
                label: 'Kaydet',
                color: c.income,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
