// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionFormNotifier)
final transactionFormProvider = TransactionFormNotifierProvider._();

final class TransactionFormNotifierProvider
    extends $AsyncNotifierProvider<TransactionFormNotifier, void> {
  TransactionFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionFormNotifierHash();

  @$internal
  @override
  TransactionFormNotifier create() => TransactionFormNotifier();
}

String _$transactionFormNotifierHash() =>
    r'0a36f72b86dd0999bd944ecfe96d533240d5b958';

abstract class _$TransactionFormNotifier extends $AsyncNotifier<void> {
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
