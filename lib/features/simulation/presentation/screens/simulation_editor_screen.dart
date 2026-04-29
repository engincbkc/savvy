import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/simulation/presentation/screens/change_sheets.dart';
import 'package:savvy/features/simulation/presentation/widgets/budget_snapshot_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_editor_change_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_editor_results.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_empty_changes.dart';
import 'package:savvy/shared/widgets/savvy_dialog.dart';

class SimulationEditorScreen extends ConsumerStatefulWidget {
  final String simulationId;

  const SimulationEditorScreen({super.key, required this.simulationId});

  @override
  ConsumerState<SimulationEditorScreen> createState() =>
      _SimulationEditorScreenState();
}

class _SimulationEditorScreenState
    extends ConsumerState<SimulationEditorScreen> {
  SimulationEntry? _entry;
  List<SimulationChange> _changes = [];
  SimulationResult? _result;
  bool _loaded = false;
  final bool _advancedMode = false;
  bool _calculating = false;
  bool _hasUnsavedChanges = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadEntry(SimulationEntry entry) {
    if (_loaded) return;
    _loaded = true;
    _entry = entry;
    _changes = List.from(entry.changes);
    _recalculate();
  }

  MonthSummary? get _currentBudget {
    final summaries = ref.read(allMonthSummariesProvider);
    return summaries.isNotEmpty ? summaries.first : null;
  }

  void _recalculate() {
    final budget = _currentBudget;
    if (budget == null) return;

    setState(() {
      _result = SimulationCalculator.calculateScenario(
        changes: _changes,
        currentBudget: budget,
        baseItems: ref.read(projectionBaseItemsProvider),
      );
      _calculating = false;
      _hasUnsavedChanges = true;
    });
  }

  void _debouncedRecalculate() {
    _debounceTimer?.cancel();
    setState(() => _calculating = true);
    _debounceTimer = Timer(const Duration(milliseconds: 300), _recalculate);
  }

  Future<void> _save() async {
    final entry = _entry;
    if (entry == null) return;
    HapticFeedback.mediumImpact();

    final updated = entry.copyWith(
      changes: _changes,
      updatedAt: DateTime.now(),
    );
    await ref.read(simulationProvider.notifier).updateSimulation(updated);
    _entry = updated;

    setState(() {
      _hasUnsavedChanges = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Simülasyon kaydedildi'),
          backgroundColor: AppColors.of(context).income,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        ),
      );
    }
  }

  Future<void> _addChange() async {
    // Step 1: Pick type
    final type = await showModalBottomSheet<ChangeType>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangeTypePicker(),
    );
    if (type == null || !mounted) return;

    // Step 2: Edit the new change
    final change = await showModalBottomSheet<SimulationChange>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeEditorSheet(changeType: type),
    );
    if (change != null) {
      setState(() => _changes.add(change));
      _debouncedRecalculate();
    }
  }

  Future<void> _editChange(int index) async {
    final current = _changes[index];
    final updated = await showModalBottomSheet<SimulationChange>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeEditorSheet(change: current),
    );
    if (updated != null) {
      setState(() => _changes[index] = updated);
      _debouncedRecalculate();
    }
  }

  void _removeChange(int index) {
    HapticFeedback.mediumImpact();
    final removed = _changes[index];
    setState(() => _changes.removeAt(index));
    _debouncedRecalculate();

    final snackBar = SnackBar(
      content: const Text('Değişiklik silindi'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      action: SnackBarAction(
        label: 'Geri Al',
        onPressed: () {
          setState(() => _changes.insert(index, removed));
          _debouncedRecalculate();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showUnsavedChangesDialog() {
    SavvyDialog.tripleAction(
      context: context,
      title: 'Kaydedilmemiş Değişiklikler',
      message:
          'Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?',
      confirmLabel: 'Kaydet ve Çık',
      destructiveLabel: 'Kaydetmeden Çık',
      cancelLabel: 'İptal',
      onConfirm: () async {
        await _save();
        if (mounted) context.go('/simulate');
      },
      onDestructive: () => context.go('/simulate'),
    );
  }

  Color get _themeColor {
    final entry = _entry;
    if (entry == null) return const Color(0xFF3F83F8);
    try {
      final hex = entry.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return entry.template?.color ?? const Color(0xFF3F83F8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final simulationsAsync = ref.watch(allSimulationsProvider);

    return simulationsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Hata: $e')),
      ),
      data: (simulations) {
        final entry = simulations
            .where((s) => s.id == widget.simulationId)
            .firstOrNull;
        if (entry == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.alertTriangle,
                      size: 48, color: c.textTertiary),
                  const SizedBox(height: AppSpacing.base),
                  Text('Simülasyon bulunamadı',
                      style: AppTypography.titleMedium
                          .copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          );
        }

        _loadEntry(entry);
        final color = _themeColor;
        final budget = _currentBudget;
        final result = _result;

        return Scaffold(
          backgroundColor: c.surfaceBackground,
          body: SafeArea(
            child: Column(
              children: [
                // App bar - temiz başlık
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.chevronLeft,
                            color: c.textPrimary),
                        onPressed: () {
                          if (_hasUnsavedChanges) {
                            _showUnsavedChangesDialog();
                          } else {
                            context.go('/simulate');
                          }
                        },
                      ),
                      Expanded(
                        child: Text(entry.title,
                            style: AppTypography.titleLarge
                                .copyWith(color: c.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      // Kaydedilmemiş değişiklik göstergesi
                      if (_hasUnsavedChanges)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.warning.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.pencil,
                                  size: 12, color: c.warning),
                              const SizedBox(width: 4),
                              Text('Düzenleniyor',
                                  style: AppTypography.caption.copyWith(
                                    color: c.warning,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: AppSpacing.screenH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget snapshot
                        if (budget != null) ...[
                          BudgetSnapshotCard(budget: budget),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Changes section
                        Row(
                          children: [
                            Icon(LucideIcons.layers,
                                size: 18, color: color),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Değişiklikler',
                                style: AppTypography.titleMedium
                                    .copyWith(color: c.textPrimary)),
                            const Spacer(),
                            Text('${_changes.length}',
                                style: AppTypography.numericSmall
                                    .copyWith(color: c.textTertiary)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Change cards
                        if (_changes.isEmpty)
                          SimEmptyChanges(color: color, onAdd: _addChange)
                        else
                          ..._changes.asMap().entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: SimChangeCard(
                                change: e.value,
                                index: e.key,
                                color: color,
                                result: result?.changeResults
                                    .elementAtOrNull(e.key),
                                advancedMode: _advancedMode,
                                onTap: () => _editChange(e.key),
                                onDelete: () => _removeChange(e.key),
                              ),
                            );
                          }),

                        // Add change button
                        if (_changes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: GestureDetector(
                              onTap: _addChange,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.pill,
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.3)),
                                  color: color.withValues(alpha: 0.05),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.plus,
                                        size: 16, color: color),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text('Değişiklik Ekle',
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                                color: color,
                                                fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Calculation loading indicator
                        if (_calculating && _changes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ClipRRect(
                            borderRadius: AppRadius.pill,
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: color,
                              backgroundColor:
                                  color.withValues(alpha: 0.12),
                            ),
                          ),
                        ],

                        // Results section
                        if (result != null &&
                            _changes.isNotEmpty &&
                            budget != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          SimResultsSection(
                            result: result,
                            budget: budget,
                            color: color,
                            advancedMode: _advancedMode,
                            onViewCashFlow: () {
                              context.go(
                                  '/simulate/${widget.simulationId}/cashflow');
                            },
                          ),
                        ],

                        // Kaydet butonu - sayfanın altında
                        if (_changes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xl2),
                          _SaveButton(
                            hasChanges: _hasUnsavedChanges,
                            color: color,
                            onSave: _save,
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xl5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Büyük kaydet butonu - sayfanın altında
class _SaveButton extends StatelessWidget {
  final bool hasChanges;
  final Color color;
  final VoidCallback onSave;

  const _SaveButton({
    required this.hasChanges,
    required this.color,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      children: [
        // Ayraç
        Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          height: 1,
          color: c.borderDefault.withValues(alpha: 0.3),
        ),

        // Kaydet butonu
        GestureDetector(
          onTap: hasChanges ? onSave : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: hasChanges
                  ? LinearGradient(
                      colors: [color, color.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasChanges ? null : c.surfaceCard,
              borderRadius: AppRadius.card,
              border: hasChanges
                  ? null
                  : Border.all(color: c.borderDefault),
              boxShadow: hasChanges
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasChanges ? LucideIcons.save : LucideIcons.checkCircle,
                  size: 20,
                  color: hasChanges ? Colors.white : c.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  hasChanges ? 'Simülasyonu Kaydet' : 'Kaydedildi',
                  style: AppTypography.labelLarge.copyWith(
                    color: hasChanges ? Colors.white : c.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bilgilendirme metni
        if (hasChanges)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Değişiklikler henüz kaydedilmedi',
              style: AppTypography.caption.copyWith(
                color: c.warning,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
