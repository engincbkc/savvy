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
import 'package:savvy/core/design/tokens/app_animation.dart';
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
  bool _advancedMode = false;
  bool _calculating = false;
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kaydedildi'),
          backgroundColor: AppColors.of(context).income,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        ),
      );
    }
  }

  Future<void> _addChange() async {
    // Step 1: Pick type
    final type = await showModalBottomSheet<ChangeType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangeTypePicker(),
    );
    if (type == null || !mounted) return;

    // Step 2: Edit the new change
    final change = await showModalBottomSheet<SimulationChange>(
      context: context,
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

    bool undone = false;
    final snackBar = SnackBar(
      content: const Text('Değişiklik silindi'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      action: SnackBarAction(
        label: 'Geri Al',
        onPressed: () {
          undone = true;
          setState(() => _changes.insert(index, removed));
          _debouncedRecalculate();
        },
      ),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((_) async {
      if (!undone) {
        await _save();
      }
    });
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
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.chevronLeft,
                            color: c.textPrimary),
                        onPressed: () => context.go('/simulate'),
                      ),
                      Expanded(
                        child: Text(entry.title,
                            style: AppTypography.titleLarge
                                .copyWith(color: c.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      // Advanced mode toggle
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _advancedMode = !_advancedMode);
                        },
                        child: AnimatedContainer(
                          duration: AppDuration.fast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: _advancedMode
                                ? color.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: _advancedMode
                                  ? color
                                  : c.borderDefault,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.settings2,
                                  size: 14,
                                  color: _advancedMode
                                      ? color
                                      : c.textTertiary),
                              const SizedBox(width: 4),
                              Text('Detay',
                                  style: AppTypography.caption.copyWith(
                                    color: _advancedMode
                                        ? color
                                        : c.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Save button
                      IconButton(
                        icon: Icon(LucideIcons.save,
                            color: color, size: 22),
                        onPressed: _save,
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
