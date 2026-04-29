# SAVVY - Faz 2 Geliştirme Planı

> Hedef: Excel'den daha efektif bir uygulama yapmak

---

## Ana Vizyon

Kullanıcı şu ana kadar gelir/giderlerini Excel'de takip ediyordu. SAVVY'nin amacı:
- Excel'den **daha hızlı** veri girişi
- **Tek tıkla** düzenleme
- **Otomatik** hesaplamalar ve projeksiyonlar
- **Akıllı** öneriler ve uyarılar

---

## Öncelikli Geliştirmeler

### 1. Excel-Benzeri Hızlı Düzenleme (EN ÖNEMLİ)

**Problem:** Aylık akışa baktığında bir alana tıklayıp hemen düzeltmek istiyor ama şu an bottom sheet açılıyor, form doluyor vs. Excel'de direkt hücreye tıklayıp yazabiliyorsun.

**Çözüm Önerileri:**

#### A. Inline Editing Mode
```
┌─────────────────────────────────────────┐
│  Ocak 2026                              │
├─────────────────────────────────────────┤
│  💰 Maaş                    ₺45.000  ✏️ │  ← Tıkla, yerinde düzenle
│  🏠 Kira                    ₺12.000  ✏️ │
│  🛒 Market                   ₺8.500  ✏️ │
│  ⚡ Faturalar                ₺2.300  ✏️ │
└─────────────────────────────────────────┘
```

- Satıra tıkla → tutar alanı editable olsun
- Enter/blur → kaydet
- Swipe left → sil
- Long press → detaylı düzenleme (bottom sheet)

#### B. Quick Edit Popup
```
┌─────────────────────────────┐
│  🏠 Kira                    │
│  ┌─────────────────────┐   │
│  │ 12.000              │ ₺ │  ← Küçük popup, sadece tutar
│  └─────────────────────┘   │
│  [İptal]        [Kaydet]   │
└─────────────────────────────┘
```

- Satıra tıkla → mini popup aç
- Sadece tutar değiştir
- 2 tık ile işlem tamam

#### C. Spreadsheet View (Tam Excel Modu)
```
┌────────────┬─────────┬─────────┬─────────┐
│            │  Oca    │  Şub    │  Mar    │
├────────────┼─────────┼─────────┼─────────┤
│ Maaş       │ 45.000  │ 45.000  │ 47.000  │
│ Kira       │ 12.000  │ 12.000  │ 12.500  │
│ Market     │  8.500  │  7.200  │  9.100  │
├────────────┼─────────┼─────────┼─────────┤
│ TOPLAM     │ +24.500 │ +25.800 │ +25.400 │
└────────────┴─────────┴─────────┴─────────┘
```

- Yatay scroll ile aylar arası geçiş
- Herhangi hücreye tıkla → düzenle
- Formüller otomatik güncellenir

**Öneri:** Önce B (Quick Edit Popup) yap, sonra C (Spreadsheet View) ekle.

---

### 2. Ay Karşılaştırması

**Amaç:** İki ayı yan yana koyup farkları görmek

```
┌─────────────────────────────────────────────────┐
│         Ocak 2026    vs    Şubat 2026          │
├──────────────┬──────────────┬───────────────────┤
│              │     Oca      │    Şub    │ Fark  │
├──────────────┼──────────────┼───────────────────┤
│ Gelir        │   ₺45.000    │  ₺45.000  │   -   │
│ Gider        │   ₺32.500    │  ₺28.200  │ -13%  │
│ Birikim      │    ₺5.000    │   ₺8.000  │ +60%  │
├──────────────┼──────────────┼───────────────────┤
│ Net          │    ₺7.500    │   ₺8.800  │ +17%  │
└──────────────┴──────────────┴───────────────────┘

Kategori Bazlı Değişimler:
🔴 Market:      ₺8.500 → ₺9.200  (+8%)
🟢 Faturalar:   ₺2.300 → ₺1.800  (-22%)
🟡 Ulaşım:      ₺1.200 → ₺1.250  (+4%)
```

**Özellikler:**
- [ ] Ay seçici (2 ay seç)
- [ ] Yüzde değişim göstergesi
- [ ] Renk kodlu artış/azalış
- [ ] Kategori bazlı drill-down
- [ ] Trend grafiği (son 6 ay)

---

### 3. Bildirimler & Hatırlatıcılar

**Bildirim Türleri:**

| Tür | Açıklama | Örnek |
|-----|----------|-------|
| Fatura Hatırlatma | Yaklaşan fatura | "Elektrik faturası 3 gün sonra" |
| Bütçe Uyarısı | Limit aşımı | "Market harcaman limitin %90'ına ulaştı" |
| Hedef İlerlemesi | Birikim hedefi | "Tatil fonuna bu ay ₺2.000 ekledin" |
| Maaş Günü | Gelir beklentisi | "Yarın maaş günü" |
| Özet | Haftalık/aylık | "Bu hafta ₺3.200 harcadın" |

**Teknik:**
- [ ] Firebase Cloud Messaging entegrasyonu
- [ ] Local notifications (flutter_local_notifications)
- [ ] Bildirim tercihleri ayarları
- [ ] Scheduled notifications

---

### 4. AI Entegrasyonu (Gemini)

**Kullanım Alanları:**

#### A. Akıllı Kategorizasyon
```
"Migros'ta 342₺ harcama" → Otomatik olarak Market kategorisi
"Netflix" → Otomatik olarak Abonelik kategorisi
```

#### B. Harcama Analizi
```
"Bu ay market harcamalarım nasıl?"
→ "Bu ay markete ₺8.500 harcadın, geçen aya göre %12 artış var.
   En çok Migros'ta (₺4.200) alışveriş yaptın."
```

#### C. Tasarruf Önerileri
```
"Nasıl tasarruf edebilirim?"
→ "Aboneliklerine bakarsak, Netflix + Spotify + YouTube = ₺450/ay.
   Aile planlarına geçersen aylık ₺150 tasarruf edebilirsin."
```

#### D. Bütçe Planlama
```
"Gelecek ay için bütçe öner"
→ "Geçmiş 3 ayına bakarak:
   - Market: ₺8.000 (ortalamanın biraz altı)
   - Faturalar: ₺2.500 (yaz ayı, AC için fazla)
   - Eğlence: ₺2.000 (hedefin için %10 azaltabilirsin)"
```

**Teknik:**
- [ ] Gemini API entegrasyonu
- [ ] Chat interface
- [ ] Context-aware responses (kullanıcı verileriyle)
- [ ] Öneri sistemi

---

### 5. Borç Takibi

**Mevcut Durum:** Expense'te `loanInstallment` kategorisi var ama detaylı borç takibi yok.

**Yeni Özellikler:**

```
┌─────────────────────────────────────────┐
│  📊 Borç Durumu                         │
├─────────────────────────────────────────┤
│  Toplam Borç:           ₺245.000       │
│  Aylık Ödeme:            ₺12.500       │
│  Borçsuz Kalma:         18 ay sonra    │
└─────────────────────────────────────────┘

Aktif Borçlar:
┌─────────────────────────────────────────┐
│ 🚗 Araç Kredisi                         │
│    Kalan: ₺180.000  │  Taksit: ₺8.500  │
│    ████████████░░░░░░░  48/60 ay       │
├─────────────────────────────────────────┤
│ 💳 Kredi Kartı                          │
│    Kalan: ₺15.000   │  Min: ₺750       │
│    Faiz: %4.5/ay                        │
├─────────────────────────────────────────┤
│ 👤 Arkadaştan Borç                      │
│    Kalan: ₺5.000    │  Vade: Yok       │
└─────────────────────────────────────────┘
```

**Özellikler:**
- [ ] Borç ekleme (kredi, kredi kartı, kişisel)
- [ ] Taksit takvimi
- [ ] "Ne zaman borçsuz" projeksiyonu
- [ ] Faiz hesaplama
- [ ] Erken ödeme simülasyonu
- [ ] Borç önceliklendirme (snowball vs avalanche)

---

### 6. Bütçe Limitleri

**Mevcut Durum:** `BudgetLimit` modeli var ama UI yok.

**Yeni Özellikler:**

```
┌─────────────────────────────────────────┐
│  📊 Bütçe Limitleri - Ocak 2026        │
├─────────────────────────────────────────┤
│ 🛒 Market         ₺7.200 / ₺8.000      │
│    ████████████████████░░  90%  ⚠️     │
├─────────────────────────────────────────┤
│ 🎮 Eğlence        ₺1.500 / ₺3.000      │
│    ██████████░░░░░░░░░░░  50%          │
├─────────────────────────────────────────┤
│ 🍔 Yeme-İçme      ₺2.800 / ₺2.500      │
│    ████████████████████████  112% 🔴   │
└─────────────────────────────────────────┘
```

**Özellikler:**
- [ ] Kategori bazlı limit belirleme
- [ ] Görsel progress bar
- [ ] %80, %100 uyarıları
- [ ] Ay bazlı limit geçmişi
- [ ] Önerilen limitler (geçmiş verilere göre)

---

### 7. Aile Bütçesi

**Amaç:** Birden fazla kişinin ortak bütçe yönetimi

```
┌─────────────────────────────────────────┐
│  👨‍👩‍👧 Kıcıkoğlu Ailesi                   │
├─────────────────────────────────────────┤
│  Toplam Gelir:         ₺95.000         │
│  Toplam Gider:         ₺62.000         │
│  Aile Birikimi:        ₺18.000         │
└─────────────────────────────────────────┘

Üyeler:
┌──────────────┬───────────┬─────────────┐
│ Üye          │ Gelir     │ Harcama     │
├──────────────┼───────────┼─────────────┤
│ 👨 Zeynep    │ ₺55.000   │ ₺28.000     │
│ 👩 Partner   │ ₺40.000   │ ₺24.000     │
├──────────────┼───────────┼─────────────┤
│ 🏠 Ortak     │     -     │ ₺10.000     │
└──────────────┴───────────┴─────────────┘
```

**Özellikler:**
- [ ] Aile oluşturma (davet linki)
- [ ] Üye ekleme/çıkarma
- [ ] Ortak harcamalar
- [ ] Kişisel vs aile bütçesi ayrımı
- [ ] Harcama görünürlük ayarları
- [ ] Aile hedefleri

---

## Öncelik Sıralaması

| # | Özellik | Öncelik | Zorluk | Etki |
|---|---------|---------|--------|------|
| 1 | Excel-Benzeri Düzenleme | 🔴 Kritik | Orta | Çok Yüksek |
| 2 | Bütçe Limitleri | 🟠 Yüksek | Düşük | Yüksek |
| 3 | Ay Karşılaştırması | 🟠 Yüksek | Orta | Yüksek |
| 4 | Borç Takibi | 🟡 Orta | Orta | Orta |
| 5 | Bildirimler | 🟡 Orta | Orta | Orta |
| 6 | AI Entegrasyonu | 🟢 Düşük | Yüksek | Yüksek |
| 7 | Aile Bütçesi | 🟢 Düşük | Yüksek | Orta |

---

## Teknik Notlar

### Excel-Benzeri Düzenleme İçin
```dart
// Quick edit için kullanılabilecek yaklaşım:
// 1. InlineEditableRow widget
// 2. showDialog yerine Overlay kullan (daha hızlı)
// 3. Optimistic update (önce UI güncelle, sonra Firebase)
```

### AI İçin
```dart
// Gemini API entegrasyonu
// lib/features/ai_advisor/ altında
// - ai_chat_screen.dart
// - ai_provider.dart
// - gemini_service.dart
```

---

## Kullanıcı Hikayesi

> "Ben normalde gelir giderlerimi Excel'den hesaplardım hep. Bu uygulamayı yapma sebebim işimi kolaylaştırmak. Ama Excel bile bana şu an daha kolay geliyor. Mesela ben aylık akışıma baktığımda bir alana tıkladığımda onu düzeltebilmek isterim. Yani Excel'den daha efektif bir uygulama olmalı."

**Sonuç:** Öncelik #1, inline/quick editing olmalı. Kullanıcı bir tutarı değiştirmek için 3-4 tık yapmamalı, 1-2 tık ile işi halletmeli.

---

## Sonraki Adımlar

1. [ ] Quick Edit Popup tasarımı
2. [ ] InlineEditableRow widget geliştirme
3. [ ] BudgetLimit UI oluşturma
4. [ ] Ay karşılaştırma ekranı
5. [ ] Borç modeli genişletme
6. [ ] Notification service kurulumu
7. [ ] Gemini API test entegrasyonu
