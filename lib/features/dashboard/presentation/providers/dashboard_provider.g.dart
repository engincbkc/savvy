// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectedYearMonth)
final selectedYearMonthProvider = SelectedYearMonthProvider._();

final class SelectedYearMonthProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
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
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return selectedYearMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedYearMonthHash() => r'b9db096aa2355ebf85b7d1610d73bd28d90cdd48';

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

@ProviderFor(monthSummary)
final monthSummaryProvider = MonthSummaryFamily._();

final class MonthSummaryProvider
    extends $FunctionalProvider<MonthSummary?, MonthSummary?, MonthSummary?>
    with $Provider<MonthSummary?> {
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

String _$monthSummaryHash() => r'8b5785bd300bb528d8f06813e553cec4e6372d72';

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

  MonthSummaryProvider call(String yearMonth) =>
      MonthSummaryProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthSummaryProvider';
}
