// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_change_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(plannedChangeRepository)
final plannedChangeRepositoryProvider = PlannedChangeRepositoryProvider._();

final class PlannedChangeRepositoryProvider
    extends
        $FunctionalProvider<
          PlannedChangeRepository,
          PlannedChangeRepository,
          PlannedChangeRepository
        >
    with $Provider<PlannedChangeRepository> {
  PlannedChangeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plannedChangeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plannedChangeRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlannedChangeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlannedChangeRepository create(Ref ref) {
    return plannedChangeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlannedChangeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlannedChangeRepository>(value),
    );
  }
}

String _$plannedChangeRepositoryHash() =>
    r'6d05b976e1fc25097e0e5f4bd2da414119028e6a';

@ProviderFor(allPlannedChanges)
final allPlannedChangesProvider = AllPlannedChangesProvider._();

final class AllPlannedChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlannedChange>>,
          List<PlannedChange>,
          Stream<List<PlannedChange>>
        >
    with
        $FutureModifier<List<PlannedChange>>,
        $StreamProvider<List<PlannedChange>> {
  AllPlannedChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allPlannedChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allPlannedChangesHash();

  @$internal
  @override
  $StreamProviderElement<List<PlannedChange>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PlannedChange>> create(Ref ref) {
    return allPlannedChanges(ref);
  }
}

String _$allPlannedChangesHash() => r'f60a0e5f487cc0110661c4a0c8c2663218b2f927';

@ProviderFor(plannedChangesForParent)
final plannedChangesForParentProvider = PlannedChangesForParentFamily._();

final class PlannedChangesForParentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlannedChange>>,
          List<PlannedChange>,
          Stream<List<PlannedChange>>
        >
    with
        $FutureModifier<List<PlannedChange>>,
        $StreamProvider<List<PlannedChange>> {
  PlannedChangesForParentProvider._({
    required PlannedChangesForParentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'plannedChangesForParentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$plannedChangesForParentHash();

  @override
  String toString() {
    return r'plannedChangesForParentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PlannedChange>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PlannedChange>> create(Ref ref) {
    final argument = this.argument as String;
    return plannedChangesForParent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlannedChangesForParentProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plannedChangesForParentHash() =>
    r'7e43cbdc019ed465fc38f36c7a0c577afc78c7e9';

final class PlannedChangesForParentFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PlannedChange>>, String> {
  PlannedChangesForParentFamily._()
    : super(
        retry: null,
        name: r'plannedChangesForParentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlannedChangesForParentProvider call(String parentId) =>
      PlannedChangesForParentProvider._(argument: parentId, from: this);

  @override
  String toString() => r'plannedChangesForParentProvider';
}
