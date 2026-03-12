# Savvy — Design System
## DS v1.0 | Flutter / Material 3

> **AI Kullanım Notu:** Bu dosya Savvy uygulamasının tek görsel referansıdır.
> Herhangi bir widget yazarken önce bu dosyayı oku.
> Hardcoded renk, sayı veya font kullanımı **yasaktır** — her zaman token kullan.

---

## 📋 İçindekiler

1. [Prensipler](#1-prensipler)
2. [Renk Sistemi](#2-renk-sistemi)
3. [Typography](#3-typography)
4. [Spacing & Sizing](#4-spacing--sizing)
5. [Border Radius](#5-border-radius)
6. [Shadow & Elevation](#6-shadow--elevation)
7. [İkon Sistemi](#7-i̇kon-sistemi)
8. [Animasyon Sistemi](#8-animasyon-sistemi)
9. [Tema Konfigürasyonu](#9-tema-konfigürasyonu)
10. [Component Library](#10-component-library)
11. [Dark Mode Kuralları](#11-dark-mode-kuralları)
12. [Erişilebilirlik](#12-erişilebilirlik)

---

## 1. Prensipler

### 1.1 Tasarım Felsefesi

```
CLARITY FIRST     → Kullanıcı bakışta ne kadar kazandı/harcadı/biriktirdi görür
DATA HIERARCHY    → Önemli rakamlar büyük, destekleyici bilgi küçük
CALM & CONFIDENT  → Finans stres yaratmamalı — sakin, güven veren palette
MOTION WITH PURPOSE → Animasyon dikkat dağıtmaz, anlam katar
ZERO CLUTTER      → Her px değer taşır, dekoratif element yasak
```

### 1.2 Tasarım Token Hiyerarşisi

```
Primitive Tokens   →  AppColors.gray900, AppColors.incomeGreen
Semantic Tokens    →  AppColors.textPrimary, AppColors.surfaceCard
Component Tokens   →  FinancialCard.incomeBackground

Her widget sadece Semantic veya Component token kullanır.
Primitive token direkt widget'ta kullanılamaz.
```

---

## 2. Renk Sistemi

### 2.1 Primitive Palette

```dart
// lib/core/design/tokens/color_primitives.dart
// Bu sınıf dışarıdan direkt kullanılmaz — sadece semantic token'lar bunu referans alır

abstract class ColorPrimitives {
  // Blue
  static const blue900 = Color(0xFF1E3A5F);
  static const blue800 = Color(0xFF1E429F);
  static const blue700 = Color(0xFF1A56DB);
  static const blue600 = Color(0xFF1C64F2);
  static const blue500 = Color(0xFF3F83F8);
  static const blue400 = Color(0xFF76A9FA);
  static const blue100 = Color(0xFFE1EFFE);
  static const blue50  = Color(0xFFEBF5FF);

  // Green
  static const green900 = Color(0xFF014737);
  static const green800 = Color(0xFF03543F);
  static const green700 = Color(0xFF046C4E);
  static const green600 = Color(0xFF057A55);
  static const green500 = Color(0xFF0E9F6E);
  static const green400 = Color(0xFF31C48D);
  static const green200 = Color(0xFFBCF0DA);
  static const green100 = Color(0xFFDEF7EC);
  static const green50  = Color(0xFFF3FAF7);

  // Red
  static const red900 = Color(0xFF771D1D);
  static const red700 = Color(0xFF9B1C1C);
  static const red600 = Color(0xFFC81E1E);
  static const red500 = Color(0xFFE02424);
  static const red400 = Color(0xFFF05252);
  static const red100 = Color(0xFFFDE8E8);
  static const red50  = Color(0xFFFDF2F2);

  // Amber / Gold
  static const amber900 = Color(0xFF633112);
  static const amber700 = Color(0xFF8E4B10);
  static const amber600 = Color(0xFFD97706);
  static const amber500 = Color(0xFFF59E0B);
  static const amber400 = Color(0xFFFBBF24);
  static const amber100 = Color(0xFFFDE8C8);
  static const amber50  = Color(0xFFFFF8EE);

  // Neutral
  static const gray950 = Color(0xFF030712);
  static const gray900 = Color(0xFF111827);
  static const gray800 = Color(0xFF1F2937);
  static const gray700 = Color(0xFF374151);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50  = Color(0xFFF9FAFB);
  static const white   = Color(0xFFFFFFFF);

  // Dark surfaces
  static const dark950 = Color(0xFF0A0F1E);
  static const dark900 = Color(0xFF0F172A);
  static const dark800 = Color(0xFF1E293B);
  static const dark700 = Color(0xFF253347);
  static const dark600 = Color(0xFF334155);
  static const dark500 = Color(0xFF475569);
}
```

### 2.2 Semantic Color Tokens

```dart
// lib/core/design/tokens/app_colors.dart
// KULLANILACAK OLAN BU SINIF — widget'lar sadece buradan renk alır

abstract class AppColors {

  // ─── Brand ───────────────────────────────────────────────────────
  static const brandPrimary    = ColorPrimitives.blue700;
  static const brandPrimaryDim = ColorPrimitives.blue800;
  static const brandAccent     = ColorPrimitives.blue500;
  static const brandLight      = ColorPrimitives.blue50;

  // ─── Financial Semantic ──────────────────────────────────────────
  // Gelir (Income) — Yeşil
  static const income           = ColorPrimitives.green500;
  static const incomeStrong     = ColorPrimitives.green700;
  static const incomeMuted      = ColorPrimitives.green400;
  static const incomeSurface    = ColorPrimitives.green100;
  static const incomeSurfaceDim = ColorPrimitives.green50;

  // Gider (Expense) — Kırmızı
  static const expense           = ColorPrimitives.red500;
  static const expenseStrong     = ColorPrimitives.red700;
  static const expenseMuted      = ColorPrimitives.red400;
  static const expenseSurface    = ColorPrimitives.red100;
  static const expenseSurfaceDim = ColorPrimitives.red50;

  // Birikim (Savings) — Altın
  static const savings           = ColorPrimitives.amber600;
  static const savingsStrong     = ColorPrimitives.amber700;
  static const savingsMuted      = ColorPrimitives.amber400;
  static const savingsSurface    = ColorPrimitives.amber100;
  static const savingsSurfaceDim = ColorPrimitives.amber50;

  // ─── Status ──────────────────────────────────────────────────────
  static const success      = ColorPrimitives.green500;
  static const successLight = ColorPrimitives.green50;
  static const warning      = ColorPrimitives.amber500;
  static const warningLight = ColorPrimitives.amber50;
  static const error        = ColorPrimitives.red500;
  static const errorLight   = ColorPrimitives.red50;
  static const info         = ColorPrimitives.blue500;
  static const infoLight    = ColorPrimitives.blue50;

  // ─── Text ────────────────────────────────────────────────────────
  static const textPrimary   = ColorPrimitives.gray900;  // Başlıklar, ana rakamlar
  static const textSecondary = ColorPrimitives.gray600;  // Alt başlıklar, etiketler
  static const textTertiary  = ColorPrimitives.gray400;  // Placeholder, devre dışı
  static const textInverse   = ColorPrimitives.white;    // Koyu arka plan üzeri
  static const textLink      = ColorPrimitives.blue700;

  // ─── Surface ─────────────────────────────────────────────────────
  static const surfaceBackground  = ColorPrimitives.gray50;   // Ana arka plan
  static const surfaceCard        = ColorPrimitives.white;    // Kart arka planı
  static const surfaceElevated    = ColorPrimitives.white;    // Yükseltilmiş kart
  static const surfaceOverlay     = ColorPrimitives.gray100;  // Modal altı
  static const surfaceInput       = ColorPrimitives.gray50;   // Input arka planı

  // ─── Border ──────────────────────────────────────────────────────
  static const borderDefault = ColorPrimitives.gray200;
  static const borderStrong  = ColorPrimitives.gray300;
  static const borderFocus   = ColorPrimitives.blue700;

  // ─── Dark Mode Overrides ─────────────────────────────────────────
  // dark() factory ile ThemeExtension olarak kullanılır
  static const darkSurfaceBackground = ColorPrimitives.dark900;
  static const darkSurfaceCard       = ColorPrimitives.dark800;
  static const darkSurfaceElevated   = ColorPrimitives.dark700;
  static const darkTextPrimary       = ColorPrimitives.gray50;
  static const darkTextSecondary     = ColorPrimitives.gray400;
  static const darkBorder            = ColorPrimitives.dark600;
}
```

### 2.3 Renk Kullanım Kuralları

```
✅ DOĞRU
  color: AppColors.income
  color: AppColors.textPrimary
  backgroundColor: AppColors.surfaceCard

❌ YANLIŞ — Primitive direkt kullanımı
  color: ColorPrimitives.green500

❌ YANLIŞ — Hardcoded hex
  color: Color(0xFF0E9F6E)

❌ YANLIŞ — Hardcoded opacity (token kullan)
  color: Colors.green.withOpacity(0.1)
  // → AppColors.incomeSurface kullan
```

---

## 3. Typography

### 3.1 Font Ailesi

```dart
// pubspec.yaml
// google_fonts: ^6.2.1

// Kullanılan fontlar:
// - Inter          → Tüm UI metinleri (body, label, headline)
// - Inter (tabular) → Tüm para tutarları (monospace figures)
//
// Fallback sırası: Inter → SF Pro (iOS) → Roboto (Android)
```

### 3.2 Type Scale

```dart
// lib/core/design/tokens/app_typography.dart

abstract class AppTypography {

  static const String _fontFamily = 'Inter';

  // ─── Display — Para Tutarları (Hero Sayılar) ─────────────────────
  static const numericHero = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  ); // Dashboard net bakiye → "₺16.500"

  static const numericLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  ); // Gelir / Gider / Birikim kartları

  static const numericMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  ); // İşlem listesi tutarları

  static const numericSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  ); // Küçük tutar gösterimleri

  // ─── Headline ────────────────────────────────────────────────────
  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ─── Title ───────────────────────────────────────────────────────
  static const titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  ); // Kart başlıkları, section header

  static const titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ─── Body ────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.55,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ─── Label ───────────────────────────────────────────────────────
  static const labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  ); // Buton metinleri

  static const labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ); // Chip, badge, tag

  static const labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  ); // İkon altı etiket, tab bar

  // ─── Caption ─────────────────────────────────────────────────────
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
  ); // Tarih, yardımcı bilgi
}
```

### 3.3 Typography Kullanım Kuralları

```
Para tutarları      → numericHero / numericLarge / numericMedium / numericSmall
Ekran başlıkları    → headlineLarge / headlineMedium
Kart başlıkları     → titleLarge / titleMedium
Açıklama metni      → bodyMedium / bodySmall
Butonlar            → labelLarge
Chip / tag / badge  → labelMedium
Tarih / yardımcı    → caption

❌ YANLIŞ — Hardcoded fontSize
  Text('₺1.250', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))

✅ DOĞRU
  Text('₺1.250', style: AppTypography.numericHero)
```

---

## 4. Spacing & Sizing

```dart
// lib/core/design/tokens/app_spacing.dart

abstract class AppSpacing {
  // 4px Base Grid — tüm değerler 4'ün katıdır
  static const double _base = 4.0;

  static const double xs    = _base * 1;   //  4px
  static const double sm    = _base * 2;   //  8px
  static const double md    = _base * 3;   // 12px
  static const double base  = _base * 4;   // 16px  ← standart padding
  static const double lg    = _base * 5;   // 20px  ← ekran yatay padding
  static const double xl    = _base * 6;   // 24px
  static const double xl2   = _base * 8;   // 32px
  static const double xl3   = _base * 10;  // 40px
  static const double xl4   = _base * 12;  // 48px
  static const double xl5   = _base * 16;  // 64px

  // Hazır padding setleri
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: lg);          // Ekran yatay boşluk
  static const EdgeInsets screen =
      EdgeInsets.symmetric(horizontal: lg, vertical: base); // Ekran genel
  static const EdgeInsets card =
      EdgeInsets.all(base);                          // Kart içi padding
  static const EdgeInsets cardLg =
      EdgeInsets.all(xl);                            // Büyük kart padding
  static const EdgeInsets section =
      EdgeInsets.symmetric(horizontal: lg, vertical: xl); // Section boşluk
  static const EdgeInsets listTile =
      EdgeInsets.symmetric(horizontal: base, vertical: md); // Liste öğesi

  // Touch target — minimum 48x48
  static const double minTouchTarget = 48.0;

  // Kart minimum yükseklik
  static const double cardMinHeight = 80.0;

  // Bottom nav height
  static const double bottomNavHeight = 64.0;

  // FAB boyutları
  static const double fabSize   = 56.0;
  static const double fabSizeSm = 40.0;
}
```

---

## 5. Border Radius

```dart
// lib/core/design/tokens/app_radius.dart

abstract class AppRadius {
  static const double xs   = 4.0;    // Input, small tag
  static const double sm   = 8.0;    // Chip, badge
  static const double md   = 12.0;   // Small card
  static const double lg   = 16.0;   // Standard card
  static const double xl   = 20.0;   // Large card, hero card
  static const double xl2  = 24.0;   // Bottom sheet
  static const double xl3  = 32.0;   // Modal
  static const double full = 9999.0; // Pill button, avatar

  // Hazır BorderRadius
  static const BorderRadius card       = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardLg     = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius chip       = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius pill       = BorderRadius.all(Radius.circular(full));
  static const BorderRadius bottomSheet =
      BorderRadius.vertical(top: Radius.circular(xl2));
  static const BorderRadius modal      =
      BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius input      =
      BorderRadius.all(Radius.circular(md));

  // Yönlü
  static const BorderRadius topOnly =
      BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius bottomOnly =
      BorderRadius.vertical(bottom: Radius.circular(lg));
}
```

---

## 6. Shadow & Elevation

```dart
// lib/core/design/tokens/app_shadow.dart

abstract class AppShadow {

  static const List<BoxShadow> none = [];

  // Genel gölgeler
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 6,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2,  offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x18000000), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8,  offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x1E000000), blurRadius: 48, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  // Finansal kart renklı gölgeler
  static const List<BoxShadow> income = [
    BoxShadow(color: Color(0x330E9F6E), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x150E9F6E), blurRadius: 6,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> expense = [
    BoxShadow(color: Color(0x33E02424), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x15E02424), blurRadius: 6,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> savings = [
    BoxShadow(color: Color(0x33D97706), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x15D97706), blurRadius: 6,  offset: Offset(0, 2)),
  ];

  // Hero card gölgesi (net bakiye)
  static const List<BoxShadow> hero = [
    BoxShadow(color: Color(0x1A1A56DB), blurRadius: 40, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0C000000), blurRadius: 8,  offset: Offset(0, 4)),
  ];

  // Bottom sheet / modal gölgesi
  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, -4)),
  ];
}
```

---

## 7. İkon Sistemi

```dart
// lib/core/design/tokens/app_icons.dart
// Paket: lucide_icons ^0.0.4

abstract class AppIcons {

  // ─── Navigation ──────────────────────────────────────────────────
  static const home      = LucideIcons.house;
  static const analytics = LucideIcons.chartBar;
  static const simulate  = LucideIcons.sparkles;
  static const settings  = LucideIcons.settings;

  // ─── Financial Fields ────────────────────────────────────────────
  static const income    = LucideIcons.trendingUp;
  static const expense   = LucideIcons.trendingDown;
  static const savings   = LucideIcons.piggyBank;
  static const balance   = LucideIcons.wallet;
  static const networth  = LucideIcons.landmark;

  // ─── Gider Kategorileri ──────────────────────────────────────────
  static const rent       = LucideIcons.building2;
  static const market     = LucideIcons.shoppingCart;
  static const transport  = LucideIcons.car;
  static const bills      = LucideIcons.zap;
  static const health     = LucideIcons.heartPulse;
  static const education  = LucideIcons.graduationCap;
  static const food       = LucideIcons.utensils;
  static const fun        = LucideIcons.gamepad2;
  static const clothing   = LucideIcons.shirt;
  static const subscription = LucideIcons.rss;
  static const loan       = LucideIcons.banknote;
  static const tax        = LucideIcons.receipt;
  static const ad         = LucideIcons.megaphone;

  // ─── Gelir Kategorileri ──────────────────────────────────────────
  static const salary     = LucideIcons.briefcase;
  static const freelance  = LucideIcons.laptop;
  static const transfer   = LucideIcons.arrowLeftRight;
  static const investment = LucideIcons.chartLine;
  static const gift       = LucideIcons.gift;

  // ─── Birikim Kategorileri ────────────────────────────────────────
  static const emergency  = LucideIcons.shieldCheck;
  static const goal       = LucideIcons.target;
  static const gold       = LucideIcons.coins;
  static const stock      = LucideIcons.chartCandlestick;
  static const retirement = LucideIcons.sunMedium;

  // ─── Actions ─────────────────────────────────────────────────────
  static const add        = LucideIcons.plus;
  static const edit       = LucideIcons.pencil;
  static const delete     = LucideIcons.trash2;
  static const search     = LucideIcons.search;
  static const filter     = LucideIcons.filter;
  static const sort       = LucideIcons.arrowUpDown;
  static const share      = LucideIcons.share2;
  static const download   = LucideIcons.download;
  static const upload     = LucideIcons.upload;
  static const copy       = LucideIcons.copy;
  static const check      = LucideIcons.check;
  static const close      = LucideIcons.x;
  static const back       = LucideIcons.chevronLeft;
  static const forward    = LucideIcons.chevronRight;
  static const expand     = LucideIcons.chevronDown;
  static const info       = LucideIcons.info;
  static const warning    = LucideIcons.triangleAlert;
  static const ai         = LucideIcons.bot;
  static const recurring  = LucideIcons.repeat;
  static const calendar   = LucideIcons.calendar;
  static const note       = LucideIcons.fileText;
  static const person     = LucideIcons.user;
  static const darkMode   = LucideIcons.moon;
  static const lightMode  = LucideIcons.sun;
  static const lock       = LucideIcons.lock;
  static const logout     = LucideIcons.logOut;
}

// İkon boyutları
abstract class AppIconSize {
  static const double xs  = 14.0;
  static const double sm  = 16.0;
  static const double md  = 20.0;  // Standart
  static const double lg  = 24.0;  // Büyük işlem
  static const double xl  = 32.0;  // Hero ikon
  static const double xl2 = 48.0;  // Empty state
}
```

---

## 8. Animasyon Sistemi

```dart
// lib/core/design/tokens/app_animation.dart

abstract class AppDuration {
  static const Duration instant  = Duration(milliseconds: 80);
  static const Duration fast     = Duration(milliseconds: 150);
  static const Duration normal   = Duration(milliseconds: 250);
  static const Duration moderate = Duration(milliseconds: 350);
  static const Duration slow     = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 750);
  static const Duration countUp  = Duration(milliseconds: 900);
}

abstract class AppCurve {
  static const Curve standard   = Curves.easeInOut;
  static const Curve enter      = Curves.easeOutCubic;
  static const Curve exit       = Curves.easeInCubic;
  static const Curve spring     = Curves.elasticOut;
  static const Curve overshoot  = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear     = Curves.linear;
}
```

### 8.1 Animasyon Kullanım Kuralları

```
COUNT-UP SAYAÇ       → TweenAnimationBuilder<double>
                       Duration: AppDuration.countUp
                       Curve: AppCurve.decelerate
                       Kullanım: Her sayısal değer ilk gösterimde count-up yapar

KART GİRİŞİ         → FadeTransition + SlideTransition
                       Duration: AppDuration.normal
                       Curve: AppCurve.enter
                       Offset: Offset(0, 0.04) → Offset.zero

TAB GEÇİŞİ          → PageView (horizontal)
                       Duration: AppDuration.normal
                       Curve: AppCurve.standard

BOTTOM SHEET         → Material motion (platform default)
                       Duration: AppDuration.moderate

SWIPE SİLME         → Dismissible, kırmızı background
                       Sonra: AnimatedList removedItem

BAŞARI              → Lottie checkmark (1x oynat, 800ms)
                       + HapticFeedback.mediumImpact

HATA                → Shake animasyon (300ms)
                       + HapticFeedback.heavyImpact

BUTON DOKUNUŞ       → Scale 0.96, 80ms, spring geri
                       + HapticFeedback.lightImpact

SAYFA GEÇİŞİ        → go_router CustomTransitionPage
                       Slide (sağdan) veya Fade

LOADING             → Shimmer skeleton — ASLA CircularProgressIndicator kullanma
                       Shimmer renk: gray100 → gray200 → gray100
```

### 8.2 Stagger Animasyonu

```dart
// Liste öğeleri sırayla girerken (dashboard kartlar gibi)
// Her öğe 60ms gecikmeli başlar

Widget _buildStaggeredItem(int index, Widget child) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: AppDuration.moderate,
    delay: const Duration(milliseconds: 60),
    child: SlideAnimation(
      verticalOffset: 24,
      child: FadeInAnimation(child: child),
    ),
  );
}
```

---

## 9. Tema Konfigürasyonu

```dart
// lib/core/design/app_theme.dart

class AppTheme {

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary:             AppColors.brandPrimary,
      primaryContainer:    AppColors.brandLight,
      surface:             AppColors.surfaceBackground,
      surfaceContainerLow: AppColors.surfaceCard,
      error:               AppColors.error,
      onPrimary:           AppColors.textInverse,
      onSurface:           AppColors.textPrimary,
      outline:             AppColors.borderDefault,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.surfaceBackground,

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.surfaceCard,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceCard,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    // Dark mode — aynı yapı, dark renk tokenları
    return light().copyWith(
      scaffoldBackgroundColor: AppColors.darkSurfaceBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.darkSurfaceBackground,
        surfaceContainerLow: AppColors.darkSurfaceCard,
        outline: AppColors.darkBorder,
        onSurface: AppColors.darkTextPrimary,
      ),
    );
  }
}
```

---

## 10. Component Library

### 10.1 FinancialCard

```dart
// lib/shared/widgets/financial_card.dart
// 3 varyant: income | expense | savings
// Her biri kendi rengi, ikonu, gölgesi ile gelir

enum FinancialCardType { income, expense, savings }

class FinancialCard extends StatelessWidget {
  final FinancialCardType type;
  final double amount;
  final double? changePercent;   // Geçen aya göre % fark (opsiyonel)
  final VoidCallback? onTap;

  // Token mapping — switch expression
  Color get _color => switch (type) {
    FinancialCardType.income  => AppColors.income,
    FinancialCardType.expense => AppColors.expense,
    FinancialCardType.savings => AppColors.savings,
  };

  Color get _surface => switch (type) {
    FinancialCardType.income  => AppColors.incomeSurface,
    FinancialCardType.expense => AppColors.expenseSurface,
    FinancialCardType.savings => AppColors.savingsSurface,
  };

  List<BoxShadow> get _shadow => switch (type) {
    FinancialCardType.income  => AppShadow.income,
    FinancialCardType.expense => AppShadow.expense,
    FinancialCardType.savings => AppShadow.savings,
  };

  IconData get _icon => switch (type) {
    FinancialCardType.income  => AppIcons.income,
    FinancialCardType.expense => AppIcons.expense,
    FinancialCardType.savings => AppIcons.savings,
  };

  String get _label => switch (type) {
    FinancialCardType.income  => 'Gelir',
    FinancialCardType.expense => 'Gider',
    FinancialCardType.savings => 'Birikim',
  };
  // UI yapısı: ikon + label üstte, tutar ortada, % değişim altta
}
```

### 10.2 NetBalanceHero

```dart
// lib/features/dashboard/widgets/net_balance_hero.dart
// Dashboard'un tam genişlikli ana kartı
//
// Layout:
//   ┌──────────────────────────────────────┐
//   │ ◀  Mart 2025  ▶          Sağlık: 72 │
//   │                                      │
//   │         NET BAKİYE                   │
//   │         ₺16.500  (count-up animasyon)│
//   │         Devir dahil: ₺19.200         │
//   └──────────────────────────────────────┘
//
// Pozitif bakiye → gradient: incomeStrong → income
// Negatif bakiye → gradient: expenseStrong → expense
// Nötr (0)       → gradient: brandPrimaryDim → brandPrimary
//
// Swipe left/right → ay değiştirme (PageView ile)
```

### 10.3 TransactionTile

```dart
// lib/shared/widgets/transaction_tile.dart
//
// Layout:
//   [CategoryIcon] [Başlık + Alt bilgi]  [Tutar]
//
// CategoryIcon: 40x40, renkli daire, beyaz ikon
// Başlık: titleMedium, textPrimary
// Alt bilgi: caption, textSecondary (kişi • tarih)
// Tutar: numericSmall, renk = type'a göre
//         income → +₺X (yeşil)
//         expense → -₺X (kırmızı)
//         savings → ◆₺X (altın)
//
// Swipe left  → Delete (kırmızı reveal)
// Swipe right → Edit (mavi reveal)
// Long press  → Context menu (düzenle / sil / kopyala)
```

### 10.4 LoadingShimmer

```dart
// lib/shared/widgets/loading_shimmer.dart
// ASLA CircularProgressIndicator veya LinearProgressIndicator kullanma
// Her skeleton gerçek widget'ın boyutunu taklit eder

// Kullanım:
SavvyShimmer(
  child: Column(
    children: [
      ShimmerBox(height: 160, radius: AppRadius.xl),  // Hero card
      const SizedBox(height: AppSpacing.base),
      Row(children: [
        Expanded(child: ShimmerBox(height: 100, radius: AppRadius.lg)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: ShimmerBox(height: 100, radius: AppRadius.lg)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: ShimmerBox(height: 100, radius: AppRadius.lg)),
      ]),
    ],
  ),
)
```

### 10.5 EmptyState

```dart
// lib/shared/widgets/empty_state.dart
// Her boş ekran için Lottie animasyon + metin + CTA
//
// Lottie dosyaları: assets/lottie/
//   empty_transactions.json
//   empty_goals.json
//   empty_analytics.json
//   success_check.json
//   error_cross.json
//   loading_coins.json   ← pull-to-refresh
```

### 10.6 FAB Radial Menu

```dart
// lib/shared/widgets/fab_radial_menu.dart
// FAB'a basınca 3 seçenek yukarı açılır
//
// Animasyon: Her seçenek 60ms arayla scale-in + fade-in
// Arka plan: Blur + dark overlay (GestureDetector ile dışına tıklayınca kapat)
//
// Seçenekler:
//   💚 Gelir Ekle   → AppColors.income arka plan
//   🔴 Gider Ekle   → AppColors.expense arka plan
//   💎 Birikim Ekle → AppColors.savings arka plan
```

---

## 11. Dark Mode Kuralları

```
KURAL 1  → Tüm renkler AppColors semantic token'larından gelir
KURAL 2  → Theme.of(context).colorScheme her zaman token ile eşleşir
KURAL 3  → Hardcoded Color() yasak — dark mode'da kırılır
KURAL 4  → Financial renkler (income/expense/savings) dark mode'da hafifletilir
            Light: AppColors.income (yeşil 500)
            Dark:  AppColors.incomeMuted (yeşil 400) — daha az parlak
KURAL 5  → Gölgeler dark mode'da opacity azaltılır (%50)
KURAL 6  → Shimmer dark mode'da dark700 → dark600 → dark700

Test: Her yeni widget light + dark mode'da ekran görüntüsü alınarak kontrol edilir.
```

---

## 12. Erişilebilirlik

```
KONTRAST    → WCAG AA minimum (4.5:1 normal metin, 3:1 büyük metin)
              AppColors tüm kombinasyonları AA geçer
              Para tutarları → numericX + textPrimary = 12.5:1 ✅

TOUCH       → Minimum 48x48dp touch target (AppSpacing.minTouchTarget)
              Tüm buton, chip, list tile bu kurala uyar

SEMANTICS   → Her ikonun Semantics(label: '...') etiketi var
              Screen reader'da anlamlı sıra
              MergeSemantics ile ilgili gruplar birleştirilir

FONT SCALE  → TextScaler desteği — tüm layout'lar %150 font scale'de test edilir
              Hardcoded height yerine intrinsic height kullan

RENK TEK   → Bilgi asla sadece renkle verilmez
              income → yeşil + ↑ ikon + '+' işareti
              expense → kırmızı + ↓ ikon + '-' işareti
```

---

*Savvy Design System v1.0 — Mart 2025*
*Bu dosya tüm UI kararlarının tek kaynağıdır. Değişiklik için PR açılır.*