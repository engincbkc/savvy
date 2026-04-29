// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SecuritySettingsNotifier)
final securitySettingsProvider = SecuritySettingsNotifierProvider._();

final class SecuritySettingsNotifierProvider
    extends $NotifierProvider<SecuritySettingsNotifier, SecuritySettings> {
  SecuritySettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securitySettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securitySettingsNotifierHash();

  @$internal
  @override
  SecuritySettingsNotifier create() => SecuritySettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecuritySettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecuritySettings>(value),
    );
  }
}

String _$securitySettingsNotifierHash() =>
    r'4b4d34e88016af2b910315e05dea1bea7a978864';

abstract class _$SecuritySettingsNotifier extends $Notifier<SecuritySettings> {
  SecuritySettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SecuritySettings, SecuritySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SecuritySettings, SecuritySettings>,
              SecuritySettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
