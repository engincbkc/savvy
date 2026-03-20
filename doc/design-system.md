# Savvy Design System v2.0

> Kişisel finans uygulaması için tasarım dili.
> Her widget bu dosyayı referans alır. Hardcoded değer yasaktır — her zaman token kullan.

---

## 1. Tasarım Felsefesi

```
CLARITY FIRST       Kullanıcı bir bakışta gelir/gider/birikim durumunu görür
DATA HIERARCHY      Önemli rakamlar büyük ve belirgin, destekleyici bilgi küçük
CALM & CONFIDENT    Finans stres yaratmamalı — sakin, güven veren palette
MOTION WITH PURPOSE Animasyon dikkat dağıtmaz, anlam katar
ZERO CLUTTER        Her piksel değer taşır, dekoratif element yasak
PREMIUM FEEL        Glass effect, gradient border, soft shadow ile modern hissi
BREATHABLE          Beyaz alan bolca kullan, öğeler arası boşluk yeterli olmalı
```

### Token Hiyerarşisi

```
Primitive Tokens   →  ColorPrimitives.green500
    ↓
Semantic Tokens    →  AppColors.income, AppColors.textPrimary
    ↓
Component Tokens   →  FinancialCard renk mapping'i

Widget'lar sadece Semantic veya Component token kullanır.
Primitive token doğrudan widget'ta KULLANILMAZ.
```

---

## 2. Renk Sistemi

### 2.1 Brand Palette

| Token | Hex | Kullanım |
|-------|-----|----------|
| `brandPrimary` | `#1A56DB` | Ana marka rengi, CTA butonları, seçili tab |
| `brandPrimaryDim` | `#1E429F` | Hover/pressed state |
| `brandAccent` | `#3F83F8` | Linkler, secondary accent |
| `brandLight` | `#EBF5FF` | Brand surface, info banner |

### 2.2 Financial Semantic Colors

Her finansal kavram kendi renk ailesine sahiptir. 5 kademe: strong → base → muted → surface → surfaceDim.

**Gelir (Income) — Yeşil**

| Kademe | Token | Hex | Kullanım |
|--------|-------|-----|----------|
| Strong | `incomeStrong` | `#046C4E` | Vurgulu rakamlar, hero tutar |
| Base | `income` | `#0E9F6E` | İkonlar, chip, aktif state |
| Muted | `incomeMuted` | `#31C48D` | İkincil göstergeler |
| Surface | `incomeSurface` | `#DEF7EC` | Kart arka planı |
| SurfaceDim | `incomeSurfaceDim` | `#F3FAF7` | Input arka planı, hafif tint |

**Gider (Expense) — Kırmızı**

| Kademe | Token | Hex | Kullanım |
|--------|-------|-----|----------|
| Strong | `expenseStrong` | `#9B1C1C` | Vurgulu rakamlar |
| Base | `expense` | `#E02424` | İkonlar, chip |
| Muted | `expenseMuted` | `#F05252` | İkincil göstergeler |
| Surface | `expenseSurface` | `#FDE8E8` | Kart arka planı |
| SurfaceDim | `expenseSurfaceDim` | `#FDF2F2` | Input arka planı |

**Birikim (Savings) — Altın**

| Kademe | Token | Hex | Kullanım |
|--------|-------|-----|----------|
| Strong | `savingsStrong` | `#8E4B10` | Vurgulu rakamlar |
| Base | `savings` | `#D97706` | İkonlar, chip |
| Muted | `savingsMuted` | `#FBBF24` | İkincil göstergeler |
| Surface | `savingsSurface` | `#FDE8C8` | Kart arka planı |
| SurfaceDim | `savingsSurfaceDim` | `#FFF8EE` | Input arka planı |

### 2.3 Vergi Dilimi Renkleri

Brüt-net hesaplamada kümülatif matrah dilimine göre renk kodlaması:

| Dilim | Renk | Hex | Anlam |
|-------|------|-----|-------|
| %15 | Yeşil | `#10B981` | Düşük vergi yükü |
| %20 | Teal | `#14B8A6` | Orta-düşük |
| %27 | Amber | `#F59E0B` | Orta |
| %35 | Turuncu | `#F97316` | Yüksek |
| %40 | Kırmızı | `#EF4444` | En yüksek dilim |

### 2.4 Neutral & Surface

| Token | Light | Dark | Kullanım |
|-------|-------|------|----------|
| `textPrimary` | gray900 `#111827` | gray50 `#F9FAFB` | Başlıklar, ana rakamlar |
| `textSecondary` | gray600 `#4B5563` | gray400 `#9CA3AF` | Etiketler, alt başlıklar |
| `textTertiary` | gray400 `#9CA3AF` | gray500 `#6B7280` | Placeholder, disabled |
| `surfaceBackground` | gray50 `#F9FAFB` | dark900 `#0F172A` | Sayfa arka planı |
| `surfaceCard` | white `#FFFFFF` | dark800 `#1E293B` | Kart arka planı |
| `surfaceOverlay` | gray100 `#F3F4F6` | dark700 `#253347` | Toggle, chip inactive |
| `surfaceInput` | gray50 `#F9FAFB` | dark700 `#253347` | Input arka planı |
| `borderDefault` | gray200 `#E5E7EB` | dark600 `#334155` | Kart border, divider |

### 2.5 Renk Kuralları

```
DOĞRU   → color: AppColors.of(context).income      // Dark mode aware
DOĞRU   → color: c.textPrimary                      // c = AppColors.of(context)
YANLIŞ  → color: ColorPrimitives.green500            // Primitive direkt kullanımı
YANLIŞ  → color: Color(0xFF0E9F6E)                   // Hardcoded hex
YANLIŞ  → color: Colors.green.withOpacity(0.1)       // Framework rengi
```

---

## 3. Typography

### 3.1 Font

**Inter** — Tüm UI metinleri. Tabular figures ile para tutarları monospace hizalanır.

### 3.2 Type Scale

**Para Tutarları (tabular figures zorunlu)**

| Token | Size | Weight | Kullanım |
|-------|------|--------|----------|
| `numericHero` | 44px | w800 | Dashboard net bakiye |
| `numericLarge` | 28px | w700 | Gelir/Gider/Birikim kartları |
| `numericMedium` | 20px | w600 | İşlem listesi tutarları, breakdown net |
| `numericSmall` | 14px | w500 | Küçük tutarlar, breakdown satırları |

**Başlıklar**

| Token | Size | Weight | Kullanım |
|-------|------|--------|----------|
| `headlineLarge` | 26px | w700 | Sayfa başlıkları |
| `headlineMedium` | 22px | w700 | Section başlıkları |
| `headlineSmall` | 18px | w600 | Kart başlıkları, sheet header |

**İçerik**

| Token | Size | Weight | Kullanım |
|-------|------|--------|----------|
| `titleLarge` | 16px | w600 | Kart başlıkları, section header |
| `titleMedium` | 15px | w500 | Alt başlıklar |
| `titleSmall` | 13px | w600 | Toggle label, küçük başlık |
| `bodyLarge` | 16px | w400 | Uzun açıklama metinleri |
| `bodyMedium` | 14px | w400 | Genel metin, hint text |
| `bodySmall` | 12px | w400 | Yardımcı metin |

**Etiketler**

| Token | Size | Weight | Kullanım |
|-------|------|--------|----------|
| `labelLarge` | 14px | w600 | Buton metinleri |
| `labelMedium` | 12px | w600 | Chip, badge, tag |
| `labelSmall` | 11px | w500 | Tab bar, ikon altı etiket |
| `caption` | 11px | w400 | Tarih, yardımcı bilgi, breakdown row |

### 3.3 Okunabilirlik Kuralları

```
1. Para tutarları HER ZAMAN numericX token ile gösterilir (tabular figures)
2. Bir ekranda en fazla 3 farklı font boyutu olmalı
3. En küçük okunabilir boyut 11px (caption) — bunun altı yasak
4. Letter-spacing: başlıklarda negatif (-0.8 ile -0.2), body'de nötr/pozitif
5. Line height: başlıklarda sıkı (1.0-1.3), body'de geniş (1.4-1.55)
```

---

## 4. Spacing

4px grid sistemi. Tüm değerler 4'ün katıdır.

| Token | Değer | Kullanım |
|-------|-------|----------|
| `xs` | 4px | İkon-metin arası, chip iç padding |
| `sm` | 8px | Küçük boşluklar, chip gap |
| `md` | 12px | Form field iç boşluk |
| `base` | 16px | Standart padding, kart içi |
| `lg` | 20px | Ekran yatay padding |
| `xl` | 24px | Section arası, büyük kart padding |
| `xl2` | 32px | Büyük section arası |
| `xl3` | 40px | Sayfa üst boşluk |

### Hazır Padding Setleri

```dart
AppSpacing.screenH  → EdgeInsets.symmetric(horizontal: 20)
AppSpacing.screen   → EdgeInsets.symmetric(horizontal: 20, vertical: 16)
AppSpacing.card     → EdgeInsets.all(16)
AppSpacing.cardLg   → EdgeInsets.all(24)
```

---

## 5. Border Radius

| Token | Değer | Kullanım |
|-------|-------|----------|
| `xs` | 4px | Küçük tag |
| `sm` / `chip` | 8px | Chip, badge, toggle icon container |
| `md` / `input` | 12px | Input, küçük kart |
| `lg` / `card` | 16px | Standart kart |
| `xl` / `cardLg` | 20px | Hero kart, büyük kart |
| `xl2` / `bottomSheet` | 24px | Bottom sheet üst köşeler |
| `xl3` / `modal` | 32px | Modal |
| `full` / `pill` | 9999px | Pill buton, avatar, tam yuvarlak |

---

## 6. Shadow & Elevation

### Genel Gölgeler

| Token | Kullanım |
|-------|----------|
| `AppShadow.none` | Flat elementler |
| `AppShadow.xs` | Input hover |
| `AppShadow.sm` | Kart default |
| `AppShadow.md` | Kart hover, elevated |
| `AppShadow.lg` | Modal, floating element |
| `AppShadow.xl` | Hero card |

### Finansal Renkli Gölgeler

```dart
AppShadow.income   → Yeşil gölge (gelir kartları)
AppShadow.expense  → Kırmızı gölge (gider kartları)
AppShadow.savings  → Altın gölge (birikim kartları)
AppShadow.hero     → Mavi gölge (dashboard hero)
```

### Dark Mode Gölge Kuralı

Dark mode'da gölge opacity %50 azaltılır. Gölge yerine border ile derinlik hissi verilir.

---

## 7. Glass Morphism

Savvy'nin premium hissini yaratan temel görsel dil. Bottom sheet detayları, breakdown kartları ve overlay'lerde kullanılır.

### 7.1 Glass Card Pattern

```dart
// Light mode
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.9),    // Üst sol: daha opak
        Colors.white.withValues(alpha: 0.7),    // Alt sağ: daha transparan
      ],
    ),
    borderRadius: AppRadius.card,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.6),  // Işık kenarı
    ),
  ),
)

// Dark mode
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.06),
        Colors.white.withValues(alpha: 0.02),
      ],
    ),
    borderRadius: AppRadius.card,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.08),
    ),
  ),
)
```

### 7.2 Backdrop Blur

```dart
// Sadece detay kartlarında, overlay'lerde kullan
// Performans: sigma 8-12 arasında tut (yüksek blur GPU'yu yorar)
ClipRRect(
  borderRadius: AppRadius.card,
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: glassContainer,
  ),
)
```

### 7.3 Accent Glow

Finansal renklerin soft glow efekti. Aktif/seçili state'lerde kullanılır.

```dart
BoxShadow(
  color: accentColor.withValues(alpha: 0.15),
  blurRadius: 12,
  offset: const Offset(0, 4),
)
```

### 7.4 Gradient Divider

Klasik düz çizgi yerine gradient divider kullanılır — uçları kaybolur:

```dart
Container(
  height: 0.5,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        color.withValues(alpha: 0),       // Sol: transparan
        color,                             // Orta: tam renk
        color.withValues(alpha: 0),       // Sağ: transparan
      ],
    ),
  ),
)
```

### 7.5 Glass Kullanım Kuralları

```
KULLAN     → Breakdown detay kartı, salary month card, overlay panel
KULLAN     → Bottom sheet iç kart, info tooltip
KULLANMA   → Ana sayfa kartları (bunlar solid surfaceCard kalmalı)
KULLANMA   → Liste öğeleri (performans riski)
KULLANMA   → Çok katmanlı iç içe glass (okunabilirlik bozulur)
```

---

## 8. Animasyon

### 8.1 Duration Tokens

| Token | Süre | Kullanım |
|-------|------|----------|
| `instant` | 80ms | Micro interaction, toggle |
| `fast` | 150ms | Chip select, color change |
| `normal` | 250ms | Kart girişi, tab geçişi |
| `moderate` | 350ms | Bottom sheet, modal |
| `slow` | 500ms | Hero animasyonu, page transition |
| `verySlow` | 750ms | Onboarding, first-time reveal |
| `countUp` | 900ms | Para tutarı sayaç animasyonu |

### 8.2 Curve Tokens

| Token | Curve | Kullanım |
|-------|-------|----------|
| `standard` | easeInOut | Genel geçiş |
| `enter` | easeOutCubic | Ekrana giriş |
| `exit` | easeInCubic | Ekrandan çıkış |
| `spring` | elasticOut | Overshoot efekti |
| `overshoot` | easeOutBack | Scale-in animasyonu |
| `decelerate` | decelerate | Sayaç yavaşlaması |

### 8.3 Animasyon Kuralları

```
COUNT-UP SAYAÇ       → TweenAnimationBuilder<double>, countUp duration, decelerate curve
                       Her sayısal değer ilk gösterimde veya değişimde animate eder

KART GİRİŞİ         → Scale 0.95→1.0 + Fade 0→1, normal duration, enter curve
                       Veya Slide Offset(0, 0.04)→zero

STAGGER              → Liste öğeleri 30-60ms arayla sırayla girer
                       CategoryChipSelector: 30ms delay
                       Dashboard cards: 60ms delay

MONTH STRIP SELECT   → AnimatedContainer 250ms, border + shadow + scale geçişi
                       ScrollController.animateTo ile otomatik kaydırma

BOTTOM SHEET         → Platform default material motion, moderate duration

LOADING              → Shimmer skeleton — ASLA spinner/progress indicator kullanma

HAPTIC               → selectionClick: chip/tab seçimi
                       mediumImpact: form submit başarılı
                       lightImpact: buton dokunuşu
```

---

## 9. İkon Sistemi

**Paket:** `lucide_icons` — Consistent stroke width, clean geometry.

### Boyutlar

| Token | Değer | Kullanım |
|-------|-------|----------|
| `AppIconSize.xs` | 14px | Inline metin yanı, chip içi |
| `AppIconSize.sm` | 16px | Input prefix, caption yanı |
| `AppIconSize.md` | 20px | Standart liste ikonu |
| `AppIconSize.lg` | 24px | Nav bar, büyük buton |
| `AppIconSize.xl` | 32px | Header ikonu, action |
| `AppIconSize.xl2` | 48px | Empty state, onboarding |

### Renk Kuralları

```
Aktif ikon       → İlgili semantic renk (income/expense/savings)
İnaktif ikon     → textTertiary
Beyaz ikon       → Renkli container üzerinde (gradient card, chip active)
```

---

## 10. Component Patterns

### 10.1 Financial Card

3 varyant: income (yeşil), expense (kırmızı), savings (altın).
Her biri kendi renk ailesinden surface + renkli gölge + ikon kullanır.

```
┌─────────────────┐
│ ↑ Gelir         │  ← ikon + label (renk)
│ ₺12.500         │  ← numericLarge (incomeStrong)
│ +₺2.300 (%22)   │  ← caption (incomeMuted)
└─────────────────┘
```

### 10.2 Hero Card

Dashboard'un ana kartı. Gradient arka plan + count-up animasyonlu tutar.

```
Pozitif bakiye → gradient: incomeStrong → income
Negatif bakiye → gradient: expenseStrong → expense
Nötr (₺0)     → gradient: brandPrimaryDim → brandPrimary
```

### 10.3 SalaryBreakdownPanel

Premium, reusable brüt→net dağılım paneli. Glass morphism + animasyonlu ay strip.

```
┌─────────────────────────────────────────┐
│  12 Aylık Maaş Dağılımı          %27 ● │
│                                         │
│  [Oca] [Şub] [MAR] [Nis] [May] →       │
│   86K   103K  ▼98K   94K   90K          │
│   ─●─   ─●─   ═●═   ─●─   ─●─         │
│                                         │
│  ┌─ Glass Card ──────────────────────┐  │
│  │ Mart                  Dilim %27   │  │
│  │ ───────────────────────────────── │  │
│  │ Brüt Maaş              ₺140.000  │  │
│  │ SGK İşçi Payı (%14)    −₺19.600  │  │
│  │ İşsizlik Sig. (%1)     −₺1.400   │  │
│  │ Gelir Vergisi           −₺23.800  │  │
│  │ Damga Vergisi           −₺1.063   │  │
│  │ GV İstisnası            +₺4.211   │  │
│  │ DV İstisnası            +₺251     │  │
│  │ ═════════════════════════════════ │  │
│  │ Net Ele Geçen           ₺98.599   │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [Yıllık Net ₺1.1M] [Eff.%32.7] [Aralık]│
└─────────────────────────────────────────┘
```

**Ay Chip States:**
- Default: muted text, no border, bracket dot küçük
- Selected: accent border, glow shadow, bold text, bracket dot genişler

### 10.4 Amount Input Field

Büyük, merkezi tutar girişi. Gradient tint arka plan + büyük numericHero font.

```
┌────────────────────────────────┐
│           BRÜT MAAŞ           │  ← caption, accent %60
│                                │
│         140.000 ₺              │  ← numericHero 36px
│                                │
└────────────────────────────────┘
```

### 10.5 Toggle Row

Açma/kapama için kullanılan satır bileşeni. İkon + başlık + açıklama + switch.

```
Active:   [●] Brütten Hesapla          [■■■]
              SGK, vergi otomatik hesaplanır

Inactive: [○] Brütten Hesapla          [   ]
              Brüt maaş girip net tutarı gör
```

### 10.6 Transaction Tile

```
[CategoryIcon 40×40]  Başlık          +₺12.500
                      Kişi • 15.03.2026
```

---

## 11. Dark Mode

### Renk Dönüşümleri

| Light | Dark | Açıklama |
|-------|------|----------|
| white surface | dark800 | Kart arka planı |
| gray50 bg | dark900 | Sayfa arka planı |
| gray900 text | gray50 text | Birincil metin |
| green500 income | green400 income | Hafifletilmiş gelir rengi |
| Gölge opacity %100 | Gölge opacity %50 | Gölge azaltma |
| Glass white 90% | Glass white 6% | Glass opaklık adaptasyonu |

### Dark Mode Kuralları

```
1. Tüm renkler AppColors.of(context) üzerinden — ASLA static AppColors kullanma
2. Glass card'larda isDark kontrolü ile farklı opacity
3. Financial renkler dark'ta 400 tona çekilir (500 çok parlak)
4. Border ile derinlik hissi ver (gölge dark'ta kaybolur)
5. Shimmer: dark700 → dark600 → dark700
```

---

## 12. UX Prensipleri

### Bilgi Hiyerarşisi

```
1. RAKAM     → En büyük, en belirgin. numericHero/Large. Her zaman CurrencyFormatter
2. ETİKET    → Rakamın ne olduğunu anlatır. titleSmall/labelMedium. Semantic renk
3. BAĞLAM    → Değişim, yüzde, tarih. caption. textTertiary
4. DETAY     → Breakdown satırları, alt bilgi. caption. textSecondary
```

### Boğmama Kuralları

```
1. Bir ekranda en fazla 3 ana rakam göster (gelir/gider/birikim)
2. Detay her zaman katlanabilir/expand olmalı — varsayılan kapalı
3. Breakdown en fazla 8-10 satır — daha fazla zaten bilişsel yük
4. Renk kodlaması tutarlı: yeşil=olumlu, kırmızı=olumsuz, amber=nötr
5. Her aksiyona max 3 dokunuş ile ulaşılmalı
6. Boş state her zaman anlamlı mesaj + CTA göstermeli
```

### Kullanıcıyı Yönlendirme

```
1. Aktif state her zaman belirgin (glow, border, bold)
2. Disabled state soluk (%50 opacity)
3. Loading state shimmer skeleton (ASLA spinner değil)
4. Success → haptic + snackbar + geçiş
5. Error → shake + kırmızı vurgu + anlaşılır mesaj
```

---

## 13. Erişilebilirlik

```
KONTRAST    → WCAG AA minimum (4.5:1 normal metin, 3:1 büyük metin)
TOUCH       → Minimum 48×48dp touch target
SEMANTICS   → Her ikonun Semantics etiketi var
FONT SCALE  → %150 font scale'de test edilir
RENK TEK    → Bilgi ASLA sadece renkle verilmez
              income  → yeşil + ↑ ikon + '+' işareti
              expense → kırmızı + ↓ ikon + '−' işareti
```

---

## 14. Dosya Yapısı

```
lib/core/design/
├── app_theme.dart           ← Light + Dark tema konfigürasyonu
└── tokens/
    ├── color_primitives.dart ← Ham renk değerleri (direkt kullanılmaz)
    ├── savvy_colors.dart     ← ThemeExtension, dark mode aware
    ├── app_colors.dart       ← Semantic renk token'ları
    ├── app_typography.dart   ← Font scale
    ├── app_spacing.dart      ← 4px grid spacing
    ├── app_radius.dart       ← Border radius
    ├── app_shadow.dart       ← Gölge setleri
    ├── app_animation.dart    ← Duration + Curve token'ları
    └── app_icons.dart        ← Lucide icon mapping + boyutlar

lib/shared/widgets/
├── salary_breakdown_panel.dart ← Glass-effect maaş dağılım paneli
├── financial_card.dart         ← Gelir/Gider/Birikim kartı
├── transaction_tile.dart       ← İşlem listesi öğesi
├── loading_shimmer.dart        ← Skeleton loading
├── empty_state.dart            ← Boş state + CTA
├── info_tooltip.dart           ← Bilgi tooltip
└── fab_radial_menu.dart        ← FAB menüsü
```

---

*Savvy Design System v2.0 — Mart 2026*
*Bu dosya tüm UI kararlarının tek kaynağıdır.*
