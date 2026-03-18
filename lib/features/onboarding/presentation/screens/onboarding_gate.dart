import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:savvy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';

/// Wraps the DashboardScreen. Shows onboarding if user hasn't completed it yet.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingCompletedProvider);

    return onboardingAsync.when(
      data: (completed) {
        if (completed) return const DashboardScreen();
        return const OnboardingScreen();
      },
      loading: () => const Scaffold(
        body: Padding(
          padding: AppSpacing.screenH,
          child: Center(
            child: SavvyShimmer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(height: 170),
                  SizedBox(height: AppSpacing.base),
                  ShimmerBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      error: (_, _) => const DashboardScreen(),
    );
  }
}
