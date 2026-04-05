// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_expense_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lastExpense)
final lastExpenseProvider = LastExpenseProvider._();

final class LastExpenseProvider
    extends $FunctionalProvider<Expense?, Expense?, Expense?>
    with $Provider<Expense?> {
  LastExpenseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastExpenseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastExpenseHash();

  @$internal
  @override
  $ProviderElement<Expense?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Expense? create(Ref ref) {
    return lastExpense(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Expense? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Expense?>(value),
    );
  }
}

String _$lastExpenseHash() => r'a3226f2e6e1eb752ba87e6bb83ee366cf2749337';
