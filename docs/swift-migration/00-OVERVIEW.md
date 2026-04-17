# Savvy — Flutter'dan Native Swift/SwiftUI'a Gecis

## Proje Ozeti

Savvy, Turkiye pazarina yonelik kisisel butce yonetimi ve finansal simulasyon uygulamasidir. Gelir/gider/birikim takibi, Turk vergi sistemiyle brut-net maas hesaplama, 8 farkli senaryo tipiyle finansal simulasyon ve butce limitleri gibi ozellikleri icerir.

## Neden Native Swift?

| Kriter | Flutter (Mevcut) | Swift/SwiftUI (Hedef) |
|--------|------------------|-----------------------|
| UI Performansi | Skia render engine, 60fps hedef | Metal-backed, native 120fps ProMotion |
| Animasyonlar | Manuel AnimationController | Spring physics, PhaseAnimator, contentTransition |
| Platform Entegrasyonu | Plugin bagimli | WidgetKit, Live Activities, Siri Shortcuts, watchOS |
| Form & Input | Custom bottom sheets | Native Form, DatePicker, presentationDetents |
| Charts | fl_chart (3rd party) | Swift Charts (1st party, VoiceOver destekli) |
| Code Generation | freezed + build_runner | Sifir — native enum, struct, Codable |
| Concurrency | Dart isolates | Swift Concurrency (async/await, actor, Sendable) |
| Accessibility | Manuel | Otomatik VoiceOver, Dynamic Type, Reduce Motion |
| Haptics | HapticFeedback.lightImpact | sensoryFeedback modifier (contextual) |
| Shimmer/Loading | 3rd party package | Native .redacted + PhaseAnimator |
| Dark Mode | ThemeExtension + lerp | Asset Catalog ile otomatik |

## Mimari Karsilastirma

```
Flutter (Mevcut)                    Swift (Hedef)
─────────────────                   ─────────────
Riverpod Provider          →        @Observable ViewModel
Freezed Models             →        Swift struct/enum (Codable)
GoRouter                   →        NavigationStack + TabView
Stream<List<T>>            →        AsyncStream<[T]>
ThemeExtension             →        @Environment + Asset Catalog
fl_chart                   →        Swift Charts
HapticFeedback             →        sensoryFeedback modifier
DraggableScrollableSheet   →        .sheet(presentationDetents:)
Dismissible                →        .swipeActions + .contextMenu
build_runner               →        Sifir code generation
```

## Hedefler

1. **Premium iOS Deneyimi**: Top-tier finans uygulamasi hissi (Copilot Money, Buddy kalitesinde)
2. **Moduler Mimari**: SPM paketleri ile feature-based ayrim, bagimsiz build/test
3. **Sifir 3rd-Party UI**: Tamamen native component'lar (Swift Charts, SF Symbols, system fonts)
4. **iOS Exclusive Ozellikler**: Home screen widgets, Live Activities, Siri Shortcuts, watchOS
5. **Finansal Hassasiyet**: Double yerine Decimal kullanimi
6. **Tam Erisilebilirlik**: VoiceOver, Dynamic Type, Reduce Motion destegi
7. **Test Odakli**: Unit, snapshot ve UI testleriyle tam kapsam

## Zaman Cizelgesi

| Faz | Sure | Kapsam |
|-----|------|--------|
| Faz 1: Foundation | Hafta 1-2 | Design tokens, modeller, FinancialCalculator, Firebase service |
| Faz 2: Core Screens | Hafta 3-4 | Auth, dashboard, transactions, form sheets |
| Faz 3: Advanced | Hafta 5-6 | Wallet animasyonlari, charts, simulasyon, butce, hedefler |
| Faz 4: iOS Exclusive | Hafta 7-8 | Widgets, Live Activities, Siri, Watch, notifications |
| Faz 5: Polish | Hafta 9-10 | Migration, testing, accessibility, performance, App Store |

## Dosya Indeksi

| # | Dosya | Icerik |
|---|-------|--------|
| 01 | [ARCHITECTURE](01-ARCHITECTURE.md) | MVVM + @Observable, SPM modulleri, DI, navigation |
| 02 | [DESIGN-SYSTEM](02-DESIGN-SYSTEM.md) | Renkler, tipografi, spacing, animasyonlar, component'lar |
| 03 | [DATA-MODELS](03-DATA-MODELS.md) | Tum Swift struct/enum tanimlari |
| 04 | [BUSINESS-LOGIC](04-BUSINESS-LOGIC.md) | Calculator, aggregator, formatter portlari |
| 05 | [SCREENS](05-SCREENS.md) | Her ekranin native iOS karsiligi |
| 06 | [IOS-EXCLUSIVE](06-IOS-EXCLUSIVE.md) | Widget, Live Activity, Siri, Watch |
| 07 | [FIREBASE](07-FIREBASE.md) | Firestore service, auth, data access |
| 08 | [TESTING](08-TESTING.md) | Test stratejisi ve ornekleri |
| 09 | [PHASES](09-PHASES.md) | Detayli implementasyon fazlari |
| 10 | [ENUM-MAPPING](10-ENUM-MAPPING.md) | Flutter enum → Swift enum + SF Symbol |

## Teknik Gereksinimler

- **Xcode**: 16.0+
- **Swift**: 6.0+
- **iOS Minimum**: 17.0
- **Firebase iOS SDK**: 11.x
- **SPM**: Tum dependency'ler SPM ile
- **CI**: Xcode Cloud veya GitHub Actions
