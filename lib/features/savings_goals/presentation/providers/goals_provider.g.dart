// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allGoals)
final allGoalsProvider = AllGoalsProvider._();

final class AllGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavingsGoal>>,
          List<SavingsGoal>,
          Stream<List<SavingsGoal>>
        >
    with
        $FutureModifier<List<SavingsGoal>>,
        $StreamProvider<List<SavingsGoal>> {
  AllGoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allGoalsHash();

  @$internal
  @override
  $StreamProviderElement<List<SavingsGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavingsGoal>> create(Ref ref) {
    return allGoals(ref);
  }
}

String _$allGoalsHash() => r'28cf67946b9bbbf8badcccebd4bbbcab147ecb1b';

@ProviderFor(GoalsNotifier)
final goalsProvider = GoalsNotifierProvider._();

final class GoalsNotifierProvider
    extends $AsyncNotifierProvider<GoalsNotifier, void> {
  GoalsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsNotifierHash();

  @$internal
  @override
  GoalsNotifier create() => GoalsNotifier();
}

String _$goalsNotifierHash() => r'752a0806ed3511e9a74a71ef1c3469826d02b465';

abstract class _$GoalsNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
