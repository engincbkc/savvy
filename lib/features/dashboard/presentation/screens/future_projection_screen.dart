import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/widgets/projection_info_card.dart';
import 'package:savvy/features/dashboard/presentation/widgets/projection_trend_card.dart';
import 'package:savvy/features/dashboard/presentation/widgets/projection_card.dart';

class FutureProjectionScreen extends ConsumerWidget {
  const FutureProjectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projections = ref.watch(futureProjectionsProvider);
    final summaries = ref.watch(allMonthSummariesProvider);
    final currentBalance =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'Gelecek Tahminim',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.of(context).textPrimary,
              ),
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.sm),

                // Info card
                ProjectionInfoCard(currentBalance: currentBalance),

                const SizedBox(height: AppSpacing.lg),

                if (projections.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xl2),
                  const ProjectionEmptyState(),
                ] else ...[
                  // Projection trend chart
                  ProjectionTrendCard(
                    projections: projections,
                    currentBalance: currentBalance,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section title
                  Text(
                    'Aylık Projeksiyon',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Month projection cards
                  ...projections.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ProjectionCard(
                          summary: p,
                          label: MonthLabels.full(p.yearMonth),
                        ),
                      )),
                ],

                const SizedBox(height: AppSpacing.xl5),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
