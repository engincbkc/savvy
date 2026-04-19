import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:uuid/uuid.dart';

class SimulationTemplateScreen extends ConsumerStatefulWidget {
  const SimulationTemplateScreen({super.key});

  @override
  ConsumerState<SimulationTemplateScreen> createState() =>
      _SimulationTemplateScreenState();
}

class _SimulationTemplateScreenState
    extends ConsumerState<SimulationTemplateScreen> {
  final _nameCtrl = TextEditingController();
  SimulationTemplate _selected = SimulationTemplate.credit;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<SimulationChange> _defaultChanges(SimulationTemplate t) {
    return switch (t) {
      SimulationTemplate.credit => [
          const SimulationChange.credit(
            principal: 0,
            annualRate: 0,
            termMonths: 12,
          ),
        ],
      SimulationTemplate.housing => [
          const SimulationChange.housing(
            price: 0,
            annualRate: 0,
            termMonths: 120,
          ),
        ],
      SimulationTemplate.car => [
          const SimulationChange.car(
            price: 0,
            annualRate: 0,
            termMonths: 48,
          ),
        ],
      SimulationTemplate.rentChange => [
          const SimulationChange.rentChange(
            currentRent: 0,
            newRent: 0,
          ),
        ],
      SimulationTemplate.salaryChange => [
          const SimulationChange.salaryChange(
            currentGross: 0,
            newGross: 0,
          ),
        ],
      SimulationTemplate.investment => [
          const SimulationChange.investment(
            principal: 0,
            annualReturnRate: 0,
            termMonths: 12,
          ),
        ],
      SimulationTemplate.custom => [],
    };
  }

  String _templatePreview(SimulationTemplate t) => switch (t) {
        SimulationTemplate.housing =>
          'Konut fiyatı, peşinat, faiz oranı, vade',
        SimulationTemplate.car =>
          'Araç fiyatı, peşinat, faiz, aylık giderler',
        SimulationTemplate.credit => 'Kredi tutarı, faiz oranı, vade',
        SimulationTemplate.salaryChange => 'Mevcut ve yeni brüt maaş',
        SimulationTemplate.rentChange =>
          'Mevcut kira, yeni kira, yıllık artış',
        SimulationTemplate.investment =>
          'Yatırım tutarı, yıllık getiri, vade',
        SimulationTemplate.custom => 'Serbest gelir veya gider tutarı',
      };

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Simülasyon adı gerekli'),
          backgroundColor: AppColors.of(context).expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final entry = SimulationEntry(
      id: const Uuid().v4(),
      title: name,
      template: _selected,
      colorHex: _selected.color
          .toARGB32()
          .toRadixString(16)
          .substring(2)
          .toUpperCase(),
      changes: _defaultChanges(_selected),
      createdAt: DateTime.now(),
    );

    final ok = await ref.read(simulationProvider.notifier).addSimulation(entry);
    if (mounted && ok) {
      context.go('/simulate/${entry.id}');
    } else if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
          onPressed: () => context.go('/simulate'),
        ),
        title: Text('Yeni Simülasyon',
            style: AppTypography.titleLarge.copyWith(color: c.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name input
                  TextFormField(
                    controller: _nameCtrl,
                    style: AppTypography.headlineSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Simülasyon adı...',
                      hintStyle: AppTypography.headlineSmall.copyWith(
                        color: c.textTertiary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  Divider(color: c.borderDefault.withValues(alpha: 0.3)),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Simülasyon Örnekleri ─────────────────────
                  ...SimulationTemplate.values.map((t) {
                    final isSelected = t == _selected;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = t);
                        },
                        child: AnimatedContainer(
                          duration: AppDuration.fast,
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? t.color.withValues(alpha: 0.08)
                                : c.surfaceCard,
                            borderRadius: AppRadius.card,
                            border: Border.all(
                              color: isSelected
                                  ? t.color
                                  : c.borderDefault.withValues(alpha: 0.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: t.color.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.card,
                                ),
                                child: Icon(t.icon,
                                    color: t.color, size: 22),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.label,
                                      style: AppTypography.titleMedium
                                          .copyWith(
                                        color: isSelected
                                            ? t.color
                                            : c.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.subtitle,
                                      style: AppTypography.caption
                                          .copyWith(
                                              color: c.textTertiary),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _templatePreview(t),
                                      style: AppTypography.caption
                                          .copyWith(
                                        color: isSelected
                                            ? t.color.withValues(alpha: 0.8)
                                            : c.textTertiary.withValues(alpha: 0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(LucideIcons.checkCircle2,
                                    color: t.color, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Sticky save button
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: c.surfaceBackground,
              border: Border(
                top: BorderSide(
                    color: c.borderDefault.withValues(alpha: 0.2)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _create,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                label: Text(
                  _saving ? 'Oluşturuluyor...' : 'Oluştur ve Düzenle',
                  style: AppTypography.labelLarge
                      .copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
