import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/widgets/simulation_hat_clippers.dart';

// ─── Front Card — "Şapkalı Kart" Tasarımı ──────────────────────
class SimCardFront extends StatelessWidget {
  final SimulationEntry sim;
  final VoidCallback onToggleInclude;
  final VoidCallback onDelete;

  static const _hatHeight = 78.0;

  const SimCardFront({
    super.key,
    required this.sim,
    required this.onToggleInclude,
    required this.onDelete,
  });

  /// Extract a short summary line from the changes list.
  String _changeSummary() {
    if (sim.changes.isEmpty) {
      // Legacy sim — show from parameters
      final p = sim.parameters;
      final monthly = (p['monthlyPayment'] as num?)?.toDouble();
      if (monthly != null) return '${CurrencyFormatter.formatNoDecimal(monthly)}/ay';
      return '';
    }
    return sim.changes
        .take(3)
        .map((c) => c.label)
        .join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeColor = sim.template?.color ?? const Color(0xFF6B7280);
    final summary = _changeSummary();
    final changeCount = sim.changes.length;

    // Green glow when included
    const includedGlow = Color(0xFF22C55E);
    final hatGradient = [typeColor, typeColor.withValues(alpha: 0.7)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardLg,
        color: c.surfaceCard,
        border: Border.all(
          color: sim.isIncluded
              ? includedGlow.withValues(alpha: 0.5)
              : c.borderDefault.withValues(alpha: 0.4),
          width: sim.isIncluded ? 2 : 1,
        ),
        boxShadow: [
          if (sim.isIncluded)
            BoxShadow(
              color: includedGlow.withValues(alpha: 0.20),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Hat Section (~35%) — category silhouette ──
            ClipPath(
              clipper: getSimulationClipper(sim.type?.name ?? 'custom'),
              child: Container(
                height: _hatHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hatGradient,
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark icon — large, faded
                    Positioned(
                      right: 16,
                      top: 8,
                      child: Icon(
                        sim.type?.icon ?? LucideIcons.sparkles,
                        size: 52,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    // Category label on hat
                    Positioned(
                      left: AppSpacing.lg,
                      top: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sim.type?.icon ?? LucideIcons.sparkles,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              sim.type?.label ?? 'Özel',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content Section (~65%) — fully opaque ──
            Container(
              width: double.infinity,
              color: c.surfaceCard,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Dahil Et toggle (sol üst) + Sil + Özet
                  Row(
                    children: [
                      // Include toggle — sol üst
                      GestureDetector(
                        onTap: onToggleInclude,
                        child: AnimatedContainer(
                          duration: AppDuration.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: sim.isIncluded
                                ? includedGlow.withValues(alpha: 0.12)
                                : c.surfaceOverlay,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: sim.isIncluded
                                  ? includedGlow.withValues(alpha: 0.4)
                                  : c.borderDefault
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                sim.isIncluded
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 14,
                                color: sim.isIncluded
                                    ? includedGlow
                                    : c.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sim.isIncluded ? 'Dahil' : 'Dahil Et',
                                style: AppTypography.caption.copyWith(
                                  color: sim.isIncluded
                                      ? includedGlow
                                      : c.textTertiary,
                                  fontWeight: sim.isIncluded
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sim.template?.icon ?? LucideIcons.sparkles,
                                size: 11, color: typeColor),
                            const SizedBox(width: 4),
                            Text(
                              sim.template?.label ?? 'Özel',
                              style: AppTypography.caption.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Özet flip hint
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.rotateCcw,
                              size: 11, color: c.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Özet',
                            style: AppTypography.caption.copyWith(
                              color: c.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Delete button
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c.expense.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.trash2,
                              size: 13, color: c.expense),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Title
                  Text(
                    sim.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Changes summary
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // Bottom row: change count + long-press hint
                  Row(
                    children: [
                      if (changeCount > 0)
                        Text(
                          '$changeCount değişiklik',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.chevronRight,
                              size: 14, color: c.textTertiary),
                        ],
                      ),
                    ],
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
