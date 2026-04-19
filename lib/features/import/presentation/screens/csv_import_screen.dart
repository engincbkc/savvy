import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/import/data/csv_import_service.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class CsvImportScreen extends ConsumerStatefulWidget {
  const CsvImportScreen({super.key});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  // Wizard step: 1 = file pick, 2 = preview, 3 = result
  int _step = 1;

  String? _fileName;
  List<ImportRow> _rows = [];
  bool _isPicking = false;

  // Step 3 results
  int _importedCount = 0;
  int _skippedCount = 0;
  bool _isSaving = false;
  String? _saveError;

  List<ImportRow> get _validRows => _rows.where((r) => r.isValid).toList();
  List<ImportRow> get _invalidRows => _rows.where((r) => !r.isValid).toList();

  // ─── File Pick ────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final file = result.files.first;
      String content;

      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        throw Exception('Dosya okunamadı');
      }

      final parsed = CsvImportService.parse(content);
      setState(() {
        _fileName = file.name;
        _rows = parsed;
        _isPicking = false;
      });
    } on CsvParseException catch (e) {
      setState(() => _isPicking = false);
      if (mounted) {
        _showError('CSV Format Hatası: ${e.message}');
      }
    } catch (e) {
      setState(() => _isPicking = false);
      if (mounted) {
        _showError('Dosya açılamadı: $e');
      }
    }
  }

  // ─── Template Share ───────────────────────────────────────────────────────

  Future<void> _shareTemplate() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/savvy_sablon.csv');
      await file.writeAsString(CsvImportService.templateCsv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Savvy CSV İçe Aktarma Şablonu',
        ),
      );
    } catch (e) {
      if (mounted) _showError('Şablon paylaşılamadı: $e');
    }
  }

  // ─── Import / Save ────────────────────────────────────────────────────────

  Future<void> _runImport() async {
    setState(() {
      _step = 3;
      _isSaving = true;
      _importedCount = 0;
      _skippedCount = 0;
      _saveError = null;
    });

    final incomeRepo = ref.read(incomeRepositoryProvider);
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final savingsRepo = ref.read(savingsRepositoryProvider);
    const uuid = Uuid();

    // Fetch existing records for duplicate check (first() from streams)
    List<Income> existingIncomes = [];
    List<Expense> existingExpenses = [];
    List<Savings> existingSavings = [];

    try {
      existingIncomes = await incomeRepo.watchAll().first;
      existingExpenses = await expenseRepo.watchAll().first;
      existingSavings = await savingsRepo.watchAll().first;
    } catch (_) {
      // If fetch fails, proceed without duplicate checking
    }

    int imported = 0;
    int skipped = 0;

    for (final row in _validRows) {
      try {
        final date = row.date!;
        final amount = row.amount!;
        final type = row.type;
        final category = row.category;

        if (type == 'Gelir') {
          final cat = _matchIncomeCategory(category);
          // Duplicate check: same date + amount + category
          final isDuplicate = existingIncomes.any(
            (e) =>
                e.amount == amount &&
                e.category == cat &&
                _sameDay(e.date, date),
          );
          if (isDuplicate) {
            skipped++;
            continue;
          }
          await incomeRepo.add(Income(
            id: uuid.v4(),
            amount: amount,
            category: cat,
            note: row.note,
            date: date,
            createdAt: DateTime.now(),
          ));
          imported++;
        } else if (type == 'Gider') {
          final cat = _matchExpenseCategory(category);
          final isDuplicate = existingExpenses.any(
            (e) =>
                e.amount == amount &&
                e.category == cat &&
                _sameDay(e.date, date),
          );
          if (isDuplicate) {
            skipped++;
            continue;
          }
          await expenseRepo.add(Expense(
            id: uuid.v4(),
            amount: amount,
            category: cat,
            note: row.note,
            date: date,
            createdAt: DateTime.now(),
          ));
          imported++;
        } else if (type == 'Birikim') {
          final cat = _matchSavingsCategory(category);
          final isDuplicate = existingSavings.any(
            (e) =>
                e.amount == amount &&
                e.category == cat &&
                _sameDay(e.date, date),
          );
          if (isDuplicate) {
            skipped++;
            continue;
          }
          await savingsRepo.add(Savings(
            id: uuid.v4(),
            amount: amount,
            category: cat,
            note: row.note,
            date: date,
            createdAt: DateTime.now(),
          ));
          imported++;
        }
      } catch (_) {
        skipped++;
      }
    }

    setState(() {
      _isSaving = false;
      _importedCount = imported;
      _skippedCount = skipped;
    });
  }

  // ─── Category Matching ────────────────────────────────────────────────────

  IncomeCategory _matchIncomeCategory(String label) {
    final lower = label.toLowerCase().trim();
    for (final cat in IncomeCategory.values) {
      if (cat.label.toLowerCase() == lower) return cat;
    }
    return IncomeCategory.other;
  }

  ExpenseCategory _matchExpenseCategory(String label) {
    final lower = label.toLowerCase().trim();
    for (final cat in ExpenseCategory.values) {
      if (cat.label.toLowerCase() == lower) return cat;
    }
    return ExpenseCategory.other;
  }

  SavingsCategory _matchSavingsCategory(String label) {
    final lower = label.toLowerCase().trim();
    for (final cat in SavingsCategory.values) {
      if (cat.label.toLowerCase() == lower) return cat;
    }
    return SavingsCategory.other;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        margin: const EdgeInsets.all(AppSpacing.base),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).surfaceBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (_step > 1 && _step < 3) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'CSV İçe Aktar',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(currentStep: _step),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (_step) {
          1 => _buildStep1(),
          2 => _buildStep2(),
          _ => _buildStep3(),
        },
      ),
    );
  }

  // ─── Step 1: Dosya Seç ────────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Upload zone
          GestureDetector(
            onTap: _isPicking ? null : _pickFile,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl3,
                horizontal: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: _fileName != null
                    ? AppColors.of(context).income.withValues(alpha: 0.06)
                    : AppColors.of(context).surfaceCard,
                borderRadius: AppRadius.cardLg,
                border: Border.all(
                  color: _fileName != null
                      ? AppColors.of(context).income.withValues(alpha: 0.5)
                      : AppColors.of(context).borderDefault,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _fileName != null
                          ? AppColors.of(context).income.withValues(alpha: 0.12)
                          : AppColors.of(context).brandPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _fileName != null
                          ? LucideIcons.fileCheck2
                          : LucideIcons.fileSpreadsheet,
                      size: 30,
                      color: _fileName != null
                          ? AppColors.of(context).income
                          : AppColors.of(context).brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_fileName != null) ...[
                    Text(
                      _fileName!,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.of(context).income,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_rows.length} satır okundu',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'CSV dosyası seçin',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Dokunarak dosya seçici açın',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.of(context).textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Pick button
          FilledButton.icon(
            onPressed: _isPicking ? null : _pickFile,
            icon: _isPicking
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  )
                : const Icon(AppIcons.upload, size: 18),
            label: Text(_isPicking ? 'Yükleniyor...' : 'Dosya Seç'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(context).brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Template button
          OutlinedButton.icon(
            onPressed: _shareTemplate,
            icon: const Icon(AppIcons.download, size: 18),
            label: const Text('Şablon İndir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.of(context).brandPrimary,
              side: BorderSide(
                color: AppColors.of(context).brandPrimary.withValues(alpha: 0.4),
              ),
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl2),

          // Format info card
          _FormatInfoCard(),

          const SizedBox(height: AppSpacing.xl),

          // Continue button
          if (_fileName != null)
            FilledButton(
              onPressed: _rows.isEmpty
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      setState(() => _step = 2);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.of(context).income,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
              child: const Text('Devam'),
            ),
        ],
      ),
    );
  }

  // ─── Step 2: Önizleme & Doğrulama ────────────────────────────────────────

  Widget _buildStep2() {
    final valid = _validRows.length;
    final invalid = _invalidRows.length;

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          color: AppColors.of(context).surfaceCard,
          child: Row(
            children: [
              _SummaryChip(
                label: '$valid geçerli',
                color: AppColors.of(context).income,
              ),
              const SizedBox(width: AppSpacing.sm),
              if (invalid > 0)
                _SummaryChip(
                  label: '$invalid hatalı',
                  color: AppColors.of(context).expense,
                ),
            ],
          ),
        ),

        // Warning if no valid rows
        if (valid == 0)
          Padding(
            padding: AppSpacing.screen,
            child: _ErrorBanner(
              message:
                  'Geçerli satır bulunamadı. Lütfen CSV formatını kontrol edin.',
            ),
          ),

        // Table
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            itemCount: _rows.length.clamp(0, 10),
            separatorBuilder: (context, i) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final row = _rows[index];
              return _PreviewRow(row: row);
            },
          ),
        ),

        // Bottom action
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.sm,
            AppSpacing.base,
            AppSpacing.xl,
          ),
          child: FilledButton(
            onPressed: valid == 0
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    _runImport();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(context).brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
            ),
            child: Text('İçe Aktar ($valid satır)'),
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Sonuç ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Center(
      key: const ValueKey(3),
      child: Padding(
        padding: AppSpacing.screen,
        child: _isSaving
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.of(context).brandPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Veriler kaydediliyor...',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Result icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _saveError != null
                          ? AppColors.of(context).expense.withValues(alpha: 0.1)
                          : AppColors.of(context).income.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _saveError != null
                          ? LucideIcons.alertCircle
                          : LucideIcons.checkCircle2,
                      size: 40,
                      color: _saveError != null
                          ? AppColors.of(context).expense
                          : AppColors.of(context).income,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (_saveError != null) ...[
                    Text(
                      'İçe Aktarma Hatası',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _saveError!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.of(context).expense,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      'Tamamlandı!',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ResultStatRow(
                      icon: LucideIcons.checkCircle2,
                      color: AppColors.of(context).income,
                      label: 'Başarıyla içe aktarıldı',
                      count: _importedCount,
                    ),
                    if (_skippedCount > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ResultStatRow(
                        icon: LucideIcons.skipForward,
                        color: AppColors.of(context).textTertiary,
                        label: 'Atlandı (tekrar)',
                        count: _skippedCount,
                      ),
                    ],
                  ],

                  const SizedBox(height: AppSpacing.xl2),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.of(context).brandPrimary,
                        foregroundColor: Colors.white,
                        minimumSize:
                            const Size.fromHeight(AppSpacing.minTouchTarget),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.input,
                        ),
                      ),
                      child: const Text('Tamamla'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i + 1 <= currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
            color: active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Preview Row ──────────────────────────────────────────────────────────────

class _PreviewRow extends StatelessWidget {
  final ImportRow row;
  const _PreviewRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isValid = row.isValid;

    Color typeColor;
    IconData typeIcon;
    switch (row.type) {
      case 'Gelir':
        typeColor = colors.income;
        typeIcon = LucideIcons.trendingUp;
      case 'Gider':
        typeColor = colors.expense;
        typeIcon = LucideIcons.trendingDown;
      case 'Birikim':
        typeColor = colors.savings;
        typeIcon = LucideIcons.coins;
      default:
        typeColor = colors.textTertiary;
        typeIcon = LucideIcons.helpCircle;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isValid
            ? colors.surfaceCard
            : colors.expense.withValues(alpha: 0.05),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isValid
              ? colors.borderDefault.withValues(alpha: 0.3)
              : colors.expense.withValues(alpha: 0.4),
        ),
      ),
      child: isValid
          ? Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(typeIcon, size: 16, color: typeColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${row.date!.day.toString().padLeft(2, '0')}.${row.date!.month.toString().padLeft(2, '0')}.${row.date!.year}',
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(row.amount!),
                  style: AppTypography.labelMedium.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  size: 18,
                  color: colors.expense,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satır ${row.rawLine}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        row.error ?? 'Bilinmeyen hata',
                        style: AppTypography.caption.copyWith(
                          color: colors.expense.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.of(context).expense.withValues(alpha: 0.08),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.of(context).expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 18,
            color: AppColors.of(context).expense,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.of(context).expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Format Info Card ─────────────────────────────────────────────────────────

class _FormatInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.of(context).brandPrimary.withValues(alpha: 0.06),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.of(context).brandPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 16,
                color: AppColors.of(context).brandPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Beklenen Format',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.of(context).brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Sütunlar', value: 'Tarih, Tür, Tutar, Kategori, Not'),
          _InfoRow(label: 'Tarih', value: 'YYYY-AA-GG veya GG.AA.YYYY (örn: 2026-01-15)'),
          _InfoRow(label: 'Tür', value: 'Gelir · Gider · Birikim'),
          _InfoRow(label: 'Tutar', value: 'Sayı (örn: 5000 veya 1250.50)'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result Stat Row ──────────────────────────────────────────────────────────

class _ResultStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  const _ResultStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$count kayıt',
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
