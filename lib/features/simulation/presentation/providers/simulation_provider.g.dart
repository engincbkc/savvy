// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allSimulations)
final allSimulationsProvider = AllSimulationsProvider._();

final class AllSimulationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SimulationEntry>>,
          List<SimulationEntry>,
          Stream<List<SimulationEntry>>
        >
    with
        $FutureModifier<List<SimulationEntry>>,
        $StreamProvider<List<SimulationEntry>> {
  AllSimulationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSimulationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSimulationsHash();

  @$internal
  @override
  $StreamProviderElement<List<SimulationEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SimulationEntry>> create(Ref ref) {
    return allSimulations(ref);
  }
}

String _$allSimulationsHash() => r'3d09af415fc2ea6b0b8da8418c1ee2df6439f9fe';

@ProviderFor(SimulationNotifier)
final simulationProvider = SimulationNotifierProvider._();

final class SimulationNotifierProvider
    extends $AsyncNotifierProvider<SimulationNotifier, void> {
  SimulationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulationNotifierHash();

  @$internal
  @override
  SimulationNotifier create() => SimulationNotifier();
}

String _$simulationNotifierHash() =>
    r'c840b92b2457430df62c06ac931594898377808c';

abstract class _$SimulationNotifier extends $AsyncNotifier<void> {
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

/// Future projections that include "included" simulations.
/// Adds each included simulation's monthly payment as an extra expense.

@ProviderFor(simulationAwareProjections)
final simulationAwareProjectionsProvider =
    SimulationAwareProjectionsProvider._();

/// Future projections that include "included" simulations.
/// Adds each included simulation's monthly payment as an extra expense.

final class SimulationAwareProjectionsProvider
    extends
        $FunctionalProvider<
          List<MonthSummary>,
          List<MonthSummary>,
          List<MonthSummary>
        >
    with $Provider<List<MonthSummary>> {
  /// Future projections that include "included" simulations.
  /// Adds each included simulation's monthly payment as an extra expense.
  SimulationAwareProjectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulationAwareProjectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulationAwareProjectionsHash();

  @$internal
  @override
  $ProviderElement<List<MonthSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MonthSummary> create(Ref ref) {
    return simulationAwareProjections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MonthSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MonthSummary>>(value),
    );
  }
}

String _$simulationAwareProjectionsHash() =>
    r'38b3cd42049f44eff2f0e4e8aef2c9657ee8814a';
