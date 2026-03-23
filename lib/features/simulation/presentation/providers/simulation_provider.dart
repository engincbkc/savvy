import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';

part 'simulation_provider.g.dart';

@riverpod
Stream<List<SimulationEntry>> allSimulations(Ref ref) {
  return ref.watch(simulationRepositoryProvider).watchAll();
}

@riverpod
class SimulationNotifier extends _$SimulationNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).add(simulation);
    });
    return !state.hasError;
  }

  Future<bool> updateSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).update(simulation);
    });
    return !state.hasError;
  }

  Future<bool> deleteSimulation(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }
}
