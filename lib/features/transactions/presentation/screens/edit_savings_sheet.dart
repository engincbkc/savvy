import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

class EditSavingsSheet extends ConsumerStatefulWidget {
  final Savings savings;
  final ScrollController? scrollController;

  const EditSavingsSheet({
    super.key,
    required this.savings,
    this.scrollController,
  });

  @override
  ConsumerState<EditSavingsSheet> createState() => _EditSavingsSheetState();
}

class _EditSavingsSheetState extends ConsumerState<EditSavingsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late SavingsCategory _category;
  late DateTime _date;

  // Original values for change detection
  late final String _origAmount;
  late final String _origNote;
  late final SavingsCategory _origCategory;
  late final DateTime _origDate;

  bool _hasChanges = false;

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
  void initState() {
    super.initState();
    final s = widget.savings;
    _amountController = TextEditingController(text: _formatThousands(s.amount.round()));
    _noteController = TextEditingController(text: s.note ?? '');
    _category = s.category;
    _date = s.date;

    _origAmount = _amountController.text;
    _origNote = _noteController.text;
    _origCategory = s.category;
    _origDate = s.date;

    _amountController.addListener(_checkChanges);
    _noteController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _amountController.text != _origAmount ||
        _noteController.text != _origNote ||
        _category != _origCategory ||
        _date != _origDate;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text);

    final updated = widget.savings.copyWith(
      amount: amount,
      category: _category,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateSavings(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Birikim güncellendi: ${CurrencyFormatter.formatNoDecimal(amount)}',
          AppColors.of(context).savings,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final c = AppColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.base,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: bottomInset + AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: AppSpacing.lg),

                const SheetHeader(
                  icon: AppIcons.edit,
                  gradient: [Color(0xFFB45309), Color(0xFFD97706)],
                  title: 'Birikim Düzenle',
                  subtitle: 'Mevcut birikim kaydını güncelle',
                ),
                const SizedBox(height: AppSpacing.xl),

                AmountInputField(
                  controller: _amountController,
                  color: c.savings,
                  strongColor: c.savingsStrong,
                  bgColor: c.savingsSurfaceDim,
                ),
                const SizedBox(height: AppSpacing.xl),

                FormSectionLabel(text: 'Kategori', icon: AppIcons.category),
                const SizedBox(height: AppSpacing.sm),
                CategoryChipSelector<SavingsCategory>(
                  values: SavingsCategory.values,
                  selected: _category,
                  labelOf: (cat) => cat.label,
                  iconOf: (cat) => cat.icon,
                  activeColor: c.savings,
                  onSelected: (cat) {
                    setState(() => _category = cat);
                    _checkChanges();
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                FormSectionLabel(text: 'Başlangıç Tarihi', icon: AppIcons.calendar),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () async {
                    final picked = await showSavvyDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                      _checkChanges();
                    }
                  },
                  child: FieldChip(icon: AppIcons.calendar, label: formatDateTR(_date)),
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
                    label: 'Kaydet',
                    color: c.savings,
                    onPressed: _submit,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
