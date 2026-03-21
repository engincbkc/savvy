// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_color_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletColorNotifier)
final walletColorProvider = WalletColorNotifierProvider._();

final class WalletColorNotifierProvider
    extends $NotifierProvider<WalletColorNotifier, WalletColor> {
  WalletColorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletColorNotifierHash();

  @$internal
  @override
  WalletColorNotifier create() => WalletColorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletColor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletColor>(value),
    );
  }
}

String _$walletColorNotifierHash() =>
    r'0301d6726658272d6fe84da0bdfa950a70f8d707';

abstract class _$WalletColorNotifier extends $Notifier<WalletColor> {
  WalletColor build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WalletColor, WalletColor>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WalletColor, WalletColor>,
              WalletColor,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
