import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  // Original values for change detection
  late final String _origAmount;
  late final String _origTitle;
  late final String _origNote;

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
    _titleController = TextEditingController(text: s.title ?? '');
    _noteController = TextEditingController(text: s.note ?? '');

    _origAmount = _amountController.text;
    _origTitle = _titleController.text;
    _origNote = _noteController.text;

    _amountController.addListener(_checkChanges);
    _titleController.addListener(_checkChanges);
    _noteController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _amountController.text != _origAmount ||
        _titleController.text != _origTitle ||
        _noteController.text != _origNote;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text);

    final updated = widget.savings.copyWith(
      amount: amount,
      title: _titleController.text.isEmpty ? null : _titleController.text,
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

                // Title
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Başlık',
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                AmountInputField(
                  controller: _amountController,
                  color: c.savings,
                  strongColor: c.savingsStrong,
                  bgColor: c.savingsSurfaceDim,
                ),
                const SizedBox(height: AppSpacing.base),

                TextFormField(
                  controller: _noteController,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Not (opsiyonel)',
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
