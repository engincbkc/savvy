// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tüm işlemleri person alanına göre gruplar.
/// person == null olanlar "Ortak" grubuna girer.

@ProviderFor(personContributions)
final personContributionsProvider = PersonContributionsProvider._();

/// Tüm işlemleri person alanına göre gruplar.
/// person == null olanlar "Ortak" grubuna girer.

final class PersonContributionsProvider
    extends
        $FunctionalProvider<
          Map<String, ({double expense, double income})>,
          Map<String, ({double expense, double income})>,
          Map<String, ({double expense, double income})>
        >
    with $Provider<Map<String, ({double expense, double income})>> {
  /// Tüm işlemleri person alanına göre gruplar.
  /// person == null olanlar "Ortak" grubuna girer.
  PersonContributionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personContributionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personContributionsHash();

  @$internal
  @override
  $ProviderElement<Map<String, ({double expense, double income})>>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Map<String, ({double expense, double income})> create(Ref ref) {
    return personContributions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<String, ({double expense, double income})> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, ({double expense, double income})>>(
            value,
          ),
    );
  }
}

String _$personContributionsHash() =>
    r'af620add41c8ce1d096499fa0339b12d77665381';
