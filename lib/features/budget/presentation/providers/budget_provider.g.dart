// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams all active (non-deleted) budget limits from Firestore.

@ProviderFor(budgetLimits)
final budgetLimitsProvider = BudgetLimitsProvider._();

/// Streams all active (non-deleted) budget limits from Firestore.

final class BudgetLimitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetLimit>>,
          List<BudgetLimit>,
          Stream<List<BudgetLimit>>
        >
    with
        $FutureModifier<List<BudgetLimit>>,
        $StreamProvider<List<BudgetLimit>> {
  /// Streams all active (non-deleted) budget limits from Firestore.
  BudgetLimitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetLimitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetLimitsHash();

  @$internal
  @override
  $StreamProviderElement<List<BudgetLimit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BudgetLimit>> create(Ref ref) {
    return budgetLimits(ref);
  }
}

String _$budgetLimitsHash() => r'99731022e65522119ccc38bb8f3ab9727ad527f1';

/// Notifier for CRUD operations on budget limits.

@ProviderFor(BudgetLimitNotifier)
final budgetLimitProvider = BudgetLimitNotifierProvider._();

/// Notifier for CRUD operations on budget limits.
final class BudgetLimitNotifierProvider
    extends $AsyncNotifierProvider<BudgetLimitNotifier, void> {
  /// Notifier for CRUD operations on budget limits.
  BudgetLimitNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetLimitNotifierHash();

  @$internal
  @override
  BudgetLimitNotifier create() => BudgetLimitNotifier();
}

String _$budgetLimitNotifierHash() =>
    r'e759dfa44443ea4e18751c1d2d0e66d63f919522';

/// Notifier for CRUD operations on budget limits.

abstract class _$BudgetLimitNotifier extends $AsyncNotifier<void> {
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

/// Computes total spending per category for a given yearMonth.
/// Returns Map of ExpenseCategory to total spent amount.

@ProviderFor(budgetUsage)
final budgetUsageProvider = BudgetUsageFamily._();

/// Computes total spending per category for a given yearMonth.
/// Returns Map of ExpenseCategory to total spent amount.

final class BudgetUsageProvider
    extends
        $FunctionalProvider<
          Map<ExpenseCategory, double>,
          Map<ExpenseCategory, double>,
          Map<ExpenseCategory, double>
        >
    with $Provider<Map<ExpenseCategory, double>> {
  /// Computes total spending per category for a given yearMonth.
  /// Returns Map of ExpenseCategory to total spent amount.
  BudgetUsageProvider._({
    required BudgetUsageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetUsageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetUsageHash();

  @override
  String toString() {
    return r'budgetUsageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<ExpenseCategory, double>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<ExpenseCategory, double> create(Ref ref) {
    final argument = this.argument as String;
    return budgetUsage(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<ExpenseCategory, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<ExpenseCategory, double>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetUsageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetUsageHash() => r'f9c6548d68daae371a89059570fffc06fa938910';

/// Computes total spending per category for a given yearMonth.
/// Returns Map of ExpenseCategory to total spent amount.

final class BudgetUsageFamily extends $Family
    with $FunctionalFamilyOverride<Map<ExpenseCategory, double>, String> {
  BudgetUsageFamily._()
    : super(
        retry: null,
        name: r'budgetUsageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Computes total spending per category for a given yearMonth.
  /// Returns Map of ExpenseCategory to total spent amount.

  BudgetUsageProvider call(String yearMonth) =>
      BudgetUsageProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'budgetUsageProvider';
}
