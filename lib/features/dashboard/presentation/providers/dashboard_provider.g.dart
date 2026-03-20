// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedYearMonth)
final selectedYearMonthProvider = SelectedYearMonthProvider._();

final class SelectedYearMonthProvider
    extends $NotifierProvider<SelectedYearMonth, String> {
  SelectedYearMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedYearMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedYearMonthHash();

  @$internal
  @override
  SelectedYearMonth create() => SelectedYearMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedYearMonthHash() => r'cc393cd91b7c23e7f5c3673a2650cdfda186123f';

abstract class _$SelectedYearMonth extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(monthIncomes)
final monthIncomesProvider = MonthIncomesFamily._();

final class MonthIncomesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Income>>,
          List<Income>,
          Stream<List<Income>>
        >
    with $FutureModifier<List<Income>>, $StreamProvider<List<Income>> {
  MonthIncomesProvider._({
    required MonthIncomesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthIncomesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthIncomesHash();

  @override
  String toString() {
    return r'monthIncomesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Income>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Income>> create(Ref ref) {
    final argument = this.argument as String;
    return monthIncomes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthIncomesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthIncomesHash() => r'a269b657c94c686d306650dbb4133eb99dbeb1c0';

final class MonthIncomesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Income>>, String> {
  MonthIncomesFamily._()
    : super(
        retry: null,
        name: r'monthIncomesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthIncomesProvider call(String yearMonth) =>
      MonthIncomesProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthIncomesProvider';
}

@ProviderFor(monthExpenses)
final monthExpensesProvider = MonthExpensesFamily._();

final class MonthExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expense>>,
          List<Expense>,
          Stream<List<Expense>>
        >
    with $FutureModifier<List<Expense>>, $StreamProvider<List<Expense>> {
  MonthExpensesProvider._({
    required MonthExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthExpensesHash();

  @override
  String toString() {
    return r'monthExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Expense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Expense>> create(Ref ref) {
    final argument = this.argument as String;
    return monthExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthExpensesHash() => r'f0763299bb7efe85a53094638af32ce2f6fc9bcb';

final class MonthExpensesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Expense>>, String> {
  MonthExpensesFamily._()
    : super(
        retry: null,
        name: r'monthExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthExpensesProvider call(String yearMonth) =>
      MonthExpensesProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthExpensesProvider';
}

@ProviderFor(monthSavings)
final monthSavingsProvider = MonthSavingsFamily._();

final class MonthSavingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Savings>>,
          List<Savings>,
          Stream<List<Savings>>
        >
    with $FutureModifier<List<Savings>>, $StreamProvider<List<Savings>> {
  MonthSavingsProvider._({
    required MonthSavingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthSavingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthSavingsHash();

  @override
  String toString() {
    return r'monthSavingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Savings>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Savings>> create(Ref ref) {
    final argument = this.argument as String;
    return monthSavings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthSavingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthSavingsHash() => r'017c5c86b756b78e954e9b69349a127518506328';

final class MonthSavingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Savings>>, String> {
  MonthSavingsFamily._()
    : super(
        retry: null,
        name: r'monthSavingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthSavingsProvider call(String yearMonth) =>
      MonthSavingsProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthSavingsProvider';
}

@ProviderFor(allIncomes)
final allIncomesProvider = AllIncomesProvider._();

final class AllIncomesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Income>>,
          List<Income>,
          Stream<List<Income>>
        >
    with $FutureModifier<List<Income>>, $StreamProvider<List<Income>> {
  AllIncomesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allIncomesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allIncomesHash();

  @$internal
  @override
  $StreamProviderElement<List<Income>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Income>> create(Ref ref) {
    return allIncomes(ref);
  }
}

String _$allIncomesHash() => r'4ad2e7a3d58965d4eab9af8ccf87c9dc5f3f78ac';

@ProviderFor(allExpenses)
final allExpensesProvider = AllExpensesProvider._();

final class AllExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expense>>,
          List<Expense>,
          Stream<List<Expense>>
        >
    with $FutureModifier<List<Expense>>, $StreamProvider<List<Expense>> {
  AllExpensesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allExpensesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allExpensesHash();

  @$internal
  @override
  $StreamProviderElement<List<Expense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Expense>> create(Ref ref) {
    return allExpenses(ref);
  }
}

String _$allExpensesHash() => r'e333f6a5a01147dd1ee3d46f481f3f891d2f4bad';

@ProviderFor(allSavings)
final allSavingsProvider = AllSavingsProvider._();

final class AllSavingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Savings>>,
          List<Savings>,
          Stream<List<Savings>>
        >
    with $FutureModifier<List<Savings>>, $StreamProvider<List<Savings>> {
  AllSavingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSavingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSavingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Savings>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Savings>> create(Ref ref) {
    return allSavings(ref);
  }
}

String _$allSavingsHash() => r'dc44a6630f91f581d2a48e8e3faa49496f32a726';

/// All month summaries grouped by yearMonth, sorted most recent first.
/// Each summary includes carry-over from previous months.

@ProviderFor(allMonthSummaries)
final allMonthSummariesProvider = AllMonthSummariesProvider._();

/// All month summaries grouped by yearMonth, sorted most recent first.
/// Each summary includes carry-over from previous months.

final class AllMonthSummariesProvider
    extends
        $FunctionalProvider<
          List<MonthSummary>,
          List<MonthSummary>,
          List<MonthSummary>
        >
    with $Provider<List<MonthSummary>> {
  /// All month summaries grouped by yearMonth, sorted most recent first.
  /// Each summary includes carry-over from previous months.
  AllMonthSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMonthSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMonthSummariesHash();

  @$internal
  @override
  $ProviderElement<List<MonthSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MonthSummary> create(Ref ref) {
    return allMonthSummaries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MonthSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MonthSummary>>(value),
    );
  }
}

String _$allMonthSummariesHash() => r'47dd6efba1bb94db5f3fcefb3bc8e3a7ada492d9';

/// Single month summary (used in detail screen)

@ProviderFor(monthSummary)
final monthSummaryProvider = MonthSummaryFamily._();

/// Single month summary (used in detail screen)

final class MonthSummaryProvider
    extends $FunctionalProvider<MonthSummary?, MonthSummary?, MonthSummary?>
    with $Provider<MonthSummary?> {
  /// Single month summary (used in detail screen)
  MonthSummaryProvider._({
    required MonthSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthSummaryHash();

  @override
  String toString() {
    return r'monthSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MonthSummary?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthSummary? create(Ref ref) {
    final argument = this.argument as String;
    return monthSummary(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthSummary? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthSummary?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonthSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthSummaryHash() => r'979a3bb86166e245e9b20d9bb2686bf11841a396';

/// Single month summary (used in detail screen)

final class MonthSummaryFamily extends $Family
    with $FunctionalFamilyOverride<MonthSummary?, String> {
  MonthSummaryFamily._()
    : super(
        retry: null,
        name: r'monthSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single month summary (used in detail screen)

  MonthSummaryProvider call(String yearMonth) =>
      MonthSummaryProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthSummaryProvider';
}

/// Toggle: include current savings as one-time income in projections.

@ProviderFor(IncludeSavingsInProjection)
final includeSavingsInProjectionProvider =
    IncludeSavingsInProjectionProvider._();

/// Toggle: include current savings as one-time income in projections.
final class IncludeSavingsInProjectionProvider
    extends $NotifierProvider<IncludeSavingsInProjection, bool> {
  /// Toggle: include current savings as one-time income in projections.
  IncludeSavingsInProjectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'includeSavingsInProjectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$includeSavingsInProjectionHash();

  @$internal
  @override
  IncludeSavingsInProjection create() => IncludeSavingsInProjection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$includeSavingsInProjectionHash() =>
    r'c5c23f59a163688fd31d05eabba2c59b32d416f5';

/// Toggle: include current savings as one-time income in projections.

abstract class _$IncludeSavingsInProjection extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Total savings amount across all time.

@ProviderFor(totalSavingsAmount)
final totalSavingsAmountProvider = TotalSavingsAmountProvider._();

/// Total savings amount across all time.

final class TotalSavingsAmountProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Total savings amount across all time.
  TotalSavingsAmountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalSavingsAmountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalSavingsAmountHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalSavingsAmount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalSavingsAmountHash() =>
    r'389a9eed80faafc81de85fdfac8b554ed6dc59d2';

/// Future month projections based on recurring incomes/expenses.
/// Projects 12 months ahead from current month.
/// Future-dated savings are included in their respective months when
/// includeSavings toggle is on.

@ProviderFor(futureProjections)
final futureProjectionsProvider = FutureProjectionsProvider._();

/// Future month projections based on recurring incomes/expenses.
/// Projects 12 months ahead from current month.
/// Future-dated savings are included in their respective months when
/// includeSavings toggle is on.

final class FutureProjectionsProvider
    extends
        $FunctionalProvider<
          List<MonthSummary>,
          List<MonthSummary>,
          List<MonthSummary>
        >
    with $Provider<List<MonthSummary>> {
  /// Future month projections based on recurring incomes/expenses.
  /// Projects 12 months ahead from current month.
  /// Future-dated savings are included in their respective months when
  /// includeSavings toggle is on.
  FutureProjectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'futureProjectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$futureProjectionsHash();

  @$internal
  @override
  $ProviderElement<List<MonthSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MonthSummary> create(Ref ref) {
    return futureProjections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MonthSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MonthSummary>>(value),
    );
  }
}

String _$futureProjectionsHash() => r'44ec5210fb25127be1344a4e030a19c828bc2cba';
