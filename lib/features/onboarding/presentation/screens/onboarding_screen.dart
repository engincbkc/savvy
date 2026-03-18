import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 2 — Gelir
  final _incomeController = TextEditingController();
  final _grossController = TextEditingController();
  bool _useGross = false;
  SalaryBreakdown? _breakdown;

  // Step 3 — Giderler
  final _rentController = TextEditingController();
  final _billsController = TextEditingController();
  final _transportController = TextEditingController();
  final _marketController = TextEditingController();

  // Step 4 — Hedef
  String? _goalType; // 'ev', 'araba', 'birikim'
  final _goalAmountController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _grossController.addListener(_onGrossChanged);
  }

  void _onGrossChanged() {
    final text = _grossController.text;
    if (text.isEmpty) {
      setState(() => _breakdown = null);
      return;
    }
    final cleaned =
        text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
    final gross = double.tryParse(cleaned);
    if (gross == null || gross <= 0) {
      setState(() => _breakdown = null);
      return;
    }
    final bd = FinancialCalculator.grossToNet(grossMonthly: gross);
    setState(() => _breakdown = bd);
    _incomeController.text = _formatThousands(bd.netMonthly.round());
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
    _pageController.dispose();
    _incomeController.dispose();
    _grossController.dispose();
    _rentController.dispose();
    _billsController.dispose();
    _transportController.dispose();
    _marketController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      HapticFeedback.selectionClick();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  double _parseField(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return 0;
    return double.tryParse(
            text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '')) ??
        0;
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final notifier = ref.read(transactionFormProvider.notifier);
    final now = DateTime.now();
    final uuid = const Uuid();

    // Save income
    final incomeAmount = _parseField(_incomeController);
    if (incomeAmount > 0) {
      await notifier.addIncome(Income(
        id: uuid.v4(),
        amount: incomeAmount,
        category: IncomeCategory.salary,
        date: now,
        isRecurring: true,
        createdAt: now,
      ));
    }

    // Save expenses
    final expenses = <MapEntry<ExpenseCategory, double>>[
      MapEntry(ExpenseCategory.rent, _parseField(_rentController)),
      MapEntry(ExpenseCategory.bills, _parseField(_billsController)),
      MapEntry(ExpenseCategory.transport, _parseField(_transportController)),
      MapEntry(ExpenseCategory.market, _parseField(_marketController)),
    ];
    for (final e in expenses) {
      if (e.value > 0) {
        await notifier.addExpense(Expense(
          id: uuid.v4(),
          amount: e.value,
          category: e.key,
          expenseType: ExpenseType.fixed,
          date: now,
          isRecurring: true,
          createdAt: now,
        ));
      }
    }

    // Mark onboarding completed
    await completeOnboarding();

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.base, AppSpacing.xl, 0),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                          right: i < 3 ? AppSpacing.xs : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? c.brandPrimary
                            : c.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(colors: c),
                  _IncomePage(
                    colors: c,
                    incomeController: _incomeController,
                    grossController: _grossController,
                    useGross: _useGross,
                    breakdown: _breakdown,
                    onGrossToggle: (v) =>
                        setState(() {
                          _useGross = v;
                          if (!v) {
                            _breakdown = null;
                            _grossController.clear();
                          }
                        }),
                  ),
                  _ExpensePage(
                    colors: c,
                    rentController: _rentController,
                    billsController: _billsController,
                    transportController: _transportController,
                    marketController: _marketController,
                  ),
                  _GoalPage(
                    colors: c,
                    goalType: _goalType,
                    goalAmountController: _goalAmountController,
                    onGoalTypeChanged: (t) =>
                        setState(() => _goalType = t),
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _prevPage,
                      child: Text('Geri',
                          style: TextStyle(color: c.textSecondary)),
                    ),
                  const Spacer(),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.brandPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.input),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_currentPage == 0 ? 'Başlayalım' : 'Devam',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _saving ? null : _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.income,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.input),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Tamamla',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.check_rounded, size: 18),
                              ],
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Step 1: Hoş Geldin
// ═══════════════════════════════════════════════════════════════════

class _WelcomePage extends StatelessWidget {
  final SavvyColors colors;
  const _WelcomePage({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(LucideIcons.wallet,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: AppSpacing.xl2),
          Text(
            'Savvy\'ye Hoş Geldin!',
            style: AppTypography.headlineLarge.copyWith(
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Gelir ve giderlerini takip et, birikimlerini yönet, '
            'finansal hedeflerine ulaş.',
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeatureChip(
                  icon: LucideIcons.trendingUp,
                  label: 'Gelir/Gider',
                  colors: colors),
              const SizedBox(width: AppSpacing.sm),
              _FeatureChip(
                  icon: LucideIcons.piggyBank,
                  label: 'Birikim',
                  colors: colors),
              const SizedBox(width: AppSpacing.sm),
              _FeatureChip(
                  icon: LucideIcons.target,
                  label: 'Hedefler',
                  colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final SavvyColors colors;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.pill,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.brandPrimary),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Step 2: Aylık Net Gelir
// ═══════════════════════════════════════════════════════════════════

class _IncomePage extends StatelessWidget {
  final SavvyColors colors;
  final TextEditingController incomeController;
  final TextEditingController grossController;
  final bool useGross;
  final SalaryBreakdown? breakdown;
  final ValueChanged<bool> onGrossToggle;

  const _IncomePage({
    required this.colors,
    required this.incomeController,
    required this.grossController,
    required this.useGross,
    required this.breakdown,
    required this.onGrossToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl2),
          Icon(LucideIcons.banknote,
              size: 40, color: colors.income),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Aylık net geliriniz nedir?',
            style: AppTypography.headlineSmall
                .copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Maaş veya ana gelir kaynağınızı girin.',
            style: AppTypography.bodyMedium
                .copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Net tutar girişi
          _OnboardingAmountField(
            controller: incomeController,
            hint: 'Aylık net gelir',
            color: colors.income,
            readOnly: useGross,
          ),
          const SizedBox(height: AppSpacing.base),

          // Brütten hesapla toggle
          _GrossToggleCompact(
            value: useGross,
            color: colors.income,
            onChanged: onGrossToggle,
          ),

          if (useGross) ...[
            const SizedBox(height: AppSpacing.md),
            _OnboardingAmountField(
              controller: grossController,
              hint: 'Brüt maaş',
              color: colors.income,
            ),
            if (breakdown != null) ...[
              const SizedBox(height: AppSpacing.md),
              _MiniBreakdown(breakdown: breakdown!, colors: colors),
            ],
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Step 3: Sabit Giderler
// ═══════════════════════════════════════════════════════════════════

class _ExpensePage extends StatelessWidget {
  final SavvyColors colors;
  final TextEditingController rentController;
  final TextEditingController billsController;
  final TextEditingController transportController;
  final TextEditingController marketController;

  const _ExpensePage({
    required this.colors,
    required this.rentController,
    required this.billsController,
    required this.transportController,
    required this.marketController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl2),
          Icon(LucideIcons.receipt,
              size: 40, color: colors.expense),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Sabit aylık giderleriniz?',
            style: AppTypography.headlineSmall
                .copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bildiğiniz kadarıyla girin, sonra değiştirebilirsiniz.',
            style: AppTypography.bodyMedium
                .copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _ExpenseField(
            controller: rentController,
            icon: LucideIcons.building2,
            label: 'Kira',
            color: colors.expense,
          ),
          const SizedBox(height: AppSpacing.md),
          _ExpenseField(
            controller: billsController,
            icon: LucideIcons.zap,
            label: 'Faturalar',
            color: colors.expense,
          ),
          const SizedBox(height: AppSpacing.md),
          _ExpenseField(
            controller: transportController,
            icon: LucideIcons.car,
            label: 'Ulaşım',
            color: colors.expense,
          ),
          const SizedBox(height: AppSpacing.md),
          _ExpenseField(
            controller: marketController,
            icon: LucideIcons.shoppingCart,
            label: 'Market',
            color: colors.expense,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Step 4: Hedef
// ═══════════════════════════════════════════════════════════════════

class _GoalPage extends StatelessWidget {
  final SavvyColors colors;
  final String? goalType;
  final TextEditingController goalAmountController;
  final ValueChanged<String?> onGoalTypeChanged;

  const _GoalPage({
    required this.colors,
    required this.goalType,
    required this.goalAmountController,
    required this.onGoalTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl2),
          Icon(LucideIcons.target,
              size: 40, color: colors.savings),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Bir hedefiniz var mı?',
            style: AppTypography.headlineSmall
                .copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Opsiyonel — sonra da ekleyebilirsiniz.',
            style: AppTypography.bodyMedium
                .copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _GoalChip(
                icon: LucideIcons.home,
                label: 'Ev',
                isSelected: goalType == 'ev',
                color: colors.savings,
                onTap: () => onGoalTypeChanged(
                    goalType == 'ev' ? null : 'ev'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _GoalChip(
                icon: LucideIcons.car,
                label: 'Araba',
                isSelected: goalType == 'araba',
                color: colors.savings,
                onTap: () => onGoalTypeChanged(
                    goalType == 'araba' ? null : 'araba'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _GoalChip(
                icon: LucideIcons.piggyBank,
                label: 'Birikim',
                isSelected: goalType == 'birikim',
                color: colors.savings,
                onTap: () => onGoalTypeChanged(
                    goalType == 'birikim' ? null : 'birikim'),
              ),
            ],
          ),
          if (goalType != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _OnboardingAmountField(
              controller: goalAmountController,
              hint: 'Hedef tutarı',
              color: colors.savings,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shared Onboarding Widgets
// ═══════════════════════════════════════════════════════════════════

class _OnboardingAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color color;
  final bool readOnly;

  const _OnboardingAmountField({
    required this.controller,
    required this.hint,
    required this.color,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ThousandFormatter(),
      ],
      style: AppTypography.numericMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.of(context).textTertiary,
        ),
        suffixText: '₺',
        suffixStyle: AppTypography.numericMedium.copyWith(
          color: color.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: color.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: color.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.base),
      ),
    );
  }
}

class _ExpenseField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final Color color;

  const _ExpenseField({
    required this.controller,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ThousandFormatter(),
      ],
      style: AppTypography.numericSmall.copyWith(color: color),
      decoration: InputDecoration(
        hintText: '$label tutarı',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.of(context).textTertiary,
        ),
        prefixIcon: Icon(icon, size: 18, color: color),
        suffixText: '₺',
        suffixStyle: AppTypography.bodyMedium.copyWith(
          color: color.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: color.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: color.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: color.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: color),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GoalChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : AppColors.of(context).surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isSelected ? color : AppColors.of(context).borderDefault,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 28,
                  color: isSelected
                      ? Colors.white
                      : AppColors.of(context).textSecondary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.of(context).textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrossToggleCompact extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _GrossToggleCompact({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate_rounded,
              size: 16,
              color: value ? color : AppColors.of(context).textTertiary),
          const SizedBox(width: 6),
          Text(
            'Brütten hesapla',
            style: AppTypography.labelSmall.copyWith(
              color: value ? color : AppColors.of(context).textTertiary,
              fontWeight: value ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            height: 24,
            child: Switch.adaptive(
              value: value,
              activeTrackColor: color,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBreakdown extends StatelessWidget {
  final SalaryBreakdown breakdown;
  final SavvyColors colors;

  const _MiniBreakdown({required this.breakdown, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.input,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        children: [
          _Row('SGK (%14)', breakdown.sgk, colors.expense),
          _Row('İşsizlik (%1)', breakdown.unemploymentInsurance, colors.expense),
          _Row('Gelir Vergisi', breakdown.incomeTax, colors.expense),
          _Row('Damga Vergisi', breakdown.stampTax, colors.expense),
          const Divider(height: 12),
          _Row('Net Maaş', breakdown.netMonthly, colors.income, bold: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;

  const _Row(this.label, this.value, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(
                color: bold
                    ? AppColors.of(context).textPrimary
                    : AppColors.of(context).textSecondary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              )),
          Text(
            bold
                ? CurrencyFormatter.formatNoDecimal(value)
                : '-${CurrencyFormatter.formatNoDecimal(value)}',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
