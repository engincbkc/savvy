# Savvy — Gelistirme Yol Haritasi

> **AI Kullanim Notu:** Bu dokuman Savvy uygulamasinin gelecek ozelliklerini,
> oncelik sirasini ve teknik tasarim kararlarini icerir. Yeni ozellik gelistirirken
> bu dosyayi referans al. Her ozellik icin amac, kullanici hikayesi, teknik tasarim
> ve kabul kriterleri tanimlanmistir.

---

## Mevcut Durum Ozeti

### Tamamlanan Ozellikler
- Gelir/Gider/Birikim CRUD (Firestore, soft-delete, periyodik destek)
- Brut→Net maas hesaplama (2026 Turkiye vergi sistemi, kumulatif vergi dilimi)
- Dashboard: cuzdan, aylik akis tablosu, trend grafik, hedef ozeti
- Islemler ekrani: 3 tab (Gelir/Gider/Birikim), aylik dagilim tablosu, filtreler
- Simulasyon: hesap motoru (kredi, ev, araba, kira, maas, yatirim) + editor UI
- Birikim Hedefleri: CRUD, ilerleme takibi
- Onboarding: cok adimli ilk kurulum (maas, giderler, hedefler)
- Ayarlar: tema, cuzdan rengi, CSV export, profil, cikis
- Auth: email/sifre, Google, Apple sign-in
- **[1.1] Periyodik Islem Yonetim Ekrani** — `/transactions/recurring` rotasi, ozet karti, yaklasan bitis uyarisi, durdur/duzenle
- **[SIM-1 S1]** annualNetImpact maas degisikligi icin 12 ayin gercek toplamı
- **[SIM-1 S3]** InvestmentImpact vade sonu degeri (maturityValue / totalValue)
- **[SIM-1 S4]** Legacy kod temizligi — 3 deprecated sinif + ekran + rota kaldirildi
- **[Modularizasyon]** 5 buyuk dosya parcalandi, 13 yeni widget dosyasi olusturuldu
- **[Hesaplama]** "Tumu" modunda brut gelir toplamı duzeltmesi, MonthSummaryAggregator periyodik destek, salary cache

### Tamamlanan (Bu Oturum)
- **[SIM-1 S5]** Kira yillik artis orani (annualIncreaseRate, projeksiyon her yil guncellenir)
- **[SIM-2 U1/U3/U4/U5/U7/U8]** Swipe-delete, undo snackbar, loading indicator, cashflow ozet, template onizleme, toplam maliyet
- **[SIM-3]** Senaryo karsilastirma ekrani (/simulate/compare)
- **[SIM-4]** KKDF/BSMV gercek maliyet hesaplama
- **[SIM-5]** Interaktif slider widget (kredi/ev/araba formlarinda)
- **[SIM-6]** "Ya Olursa?" hizli senaryolar (template screen)
- **[SIM-7]** Dahil edilen simulasyonlar banner (bilesik etki ozeti)
- **[Faz 1.2]** PlannedChange modeli + bottom sheet (periyodik degisiklik planlama)
- **[Faz 1.3]** Borc Takip Modulu (/debt — DebtDashboardScreen, takvim, sayac)
- **[Faz 1.4]** Butce/Kategori Limitleri (/budget — BudgetLimit model, repo, provider, UI)
- **[Faz 2.1]** Nakit Akis Tahmini (/dashboard/forecast — 12 ay projeksiyon, ozet kart)
- **[Faz 2.2]** Bildirim altyapisi (NotificationPreferences, NotificationChecker, ayarlar UI)
- **[Faz 2.3]** Ay vs ay karsilastirma (/dashboard/compare — MonthCompareScreen)
- **[Faz 2.4]** CSV import sihirbazi (/settings/import — 3 adim wizard, dublike kontrol)
- **[Faz 2.5]** Vergi Raporu (/settings/tax-report — brut/net, aylik vergi tablosu)
- **[Faz 3.1]** AI Advisor (/ai-advisor — Gemini chat, hizli sorular, context builder)

### Tamamlanan (Faz 3)
- **[Faz 3.2]** Aile Butcesi (/family — kisi bazli katki kartlari, genisletilebilir islem listesi)
- **[Faz 3.3]** Hedef Bazli Akilli Planlama (requiredMonthlySaving, monthsToGoal, GoalCard on-track banner, GoalAddSheet oneri)
- **[Faz 3.4]** Hizli Giris & Sablonlar (QuickExpenseSheet, 5 sablon, son 5 islem + tekrarla, AddExpenseSheet pre-fill)

### Devam Eden / Kaldir
- Faz 3.4 widget (iOS/Android home screen widget — platform-specific, en dusuk oncelik, scope disinda)

---

## Faz 1: Temel Fonksiyonalite (Oncelik: Yuksek)

> Amac: Excel bilancosunu tamamen ikame edecek temel ozellikleri tamamla.

### 1.1 Periyodik Islem Yonetim Ekrani

**Amac:** Kullanicinin tum tekrar eden gelir ve giderlerini tek ekranda gormesi, yonetmesi.

**Kullanici Hikayesi:**
- "Aylik sabit giderlerimi tek ekranda gormek istiyorum"
- "Taksitimin ne zaman bitecegini gormek istiyorum"
- "Periyodik gelirimi durdurmak/uzatmak istiyorum"

**Teknik Tasarim:**
- Yeni ekran: `lib/features/transactions/presentation/screens/recurring_management_screen.dart`
- Route: `/transactions/recurring` (app_router.dart'a ekle)
- Veri: Mevcut `allIncomesProvider` ve `allExpensesProvider`'dan `isRecurring == true` filtrele
- Gruplama: Gelirler / Giderler ayri section
- Her kalem icin: isim, tutar, kategori, baslangic, bitis (varsa), aylik net etki
- Aksiyonlar: durdur (endDate = now), uzat (endDate guncelle), duzenle, sil

**UI Bilesenleri:**
- `RecurringItemTile`: ikon, baslik, tutar, kalan ay sayisi badge, bitis tarihi
- `RecurringSummaryCard`: toplam aylik periyodik gelir, toplam aylik periyodik gider, net
- Bitis tarihi yaklasanlar (< 2 ay) icin uyari badge

**Kabul Kriterleri:** ✅ TAMAMLANDI
- [x] Tum periyodik gelir/giderler listelenir
- [x] Bitis tarihi yaklasanlar vurgulanir
- [x] Durdur/uzat/duzenle/sil aksiyonlari calisir
- [x] Toplam aylik periyodik ozeti dogru hesaplanir
- [x] Brut maas kalemleri net olarak gosterilir

---

### 1.2 Gelir/Gider Adim Degisikligi (Step Changes)

**Amac:** Ayni gelir/gider kaleminin farkli tarihlerde farkli tutarlar almasini modellemek.

**Kullanici Hikayesi:**
- "Maasim Subat'tan itibaren 115K olacak, bunu projeksiyona yansitmak istiyorum"
- "Kiram Mart'ta 36K'dan 45K'ya cikacak"

**Teknik Tasarim:**

Yeni model: `PlannedChange`
```
PlannedChange {
  String id
  String parentId        // bagli oldugu Income/Expense id
  double newAmount       // yeni tutar
  DateTime effectiveDate // gecerlilik baslangici
  bool isGross           // brut mu (gelir icin)
  String? note
}
```

Firestore: `users/{uid}/planned_changes` collection

Hesaplama entegrasyonu:
- `FinancialCalculator`'a `resolveAmountForDate(baseAmount, plannedChanges, targetDate)` ekle
- Projeksiyon ve aggregator bu metodu kullansın
- Aylik dagilim tablosu adim degisikliklerini yansitsin

**UI:**
- Periyodik islem detayinda "Planlı Degisiklik Ekle" butonu
- Tarih + yeni tutar giris formu
- Timeline gorunumu: hangi tarihte ne degisiyor

**Kabul Kriterleri:**
- [ ] Periyodik gelir/gidere planlı degisiklik eklenebilir
- [ ] Projeksiyon degisikligi dogru yansitir
- [ ] Aylik dagilim tablosu degisiklik noktasinda tutar degisir
- [ ] Dashboard ozeti dogru hesaplanir

---

### 1.3 Borc Takip Modulu

**Amac:** Taksitli borcları ozel ekranda takip etme, ne zaman borcdan kurtulacagini gosterme.

**Kullanici Hikayesi:**
- "Toplam ne kadar borcum var gormek istiyorum"
- "Hangi taksitim ne zaman bitiyor?"
- "Ne zaman borcsuz olacagim?"

**Teknik Tasarim:**

Mevcut modelin uzantisi — Expense modelinde:
- `isInstallment: bool` (taksitli mi)
- `totalInstallments: int?` (toplam taksit sayisi)
- `remainingInstallments: int?` (kalan taksit)
- `installmentStartDate: DateTime?`

Veya mevcut `isRecurring + recurringEndDate` ile hesaplanabilir:
- Kalan taksit = recurringEndDate - now (ay farkı)
- Toplam maliyet = amount * toplam taksit sayisi

Yeni ekran: `lib/features/debt/presentation/screens/debt_dashboard_screen.dart`
Route: `/debt` veya transactions icinde tab/section

**UI Bilesenleri:**
- `DebtSummaryCard`: toplam kalan borc, aylik toplam taksit, tahmini bitis
- `DebtTimelineWidget`: taksit bitiş tarihleri timeline (milestone gorunumu)
- `DebtFreeCountdown`: "X ay sonra borcsuz!" motivasyon karti
- Her borc icin: ilerleme cubugu (odenen / toplam)

**Hesaplama:**
- `FinancialCalculator.debtFreeDate(debts)`: tum taksitler bitince tarih
- `FinancialCalculator.totalRemainingDebt(debts)`: kalan toplam
- `FinancialCalculator.monthlyDebtPayment(debts)`: aylik toplam taksit

**Kabul Kriterleri:**
- [ ] Tum taksitli giderler listelenir
- [ ] Toplam kalan borc dogru hesaplanir
- [ ] Bitis tarihi projeksiyonu dogru
- [ ] Timeline gorunumu acik ve anlasilir

---

### 1.4 Butce / Kategori Limitleri

**Amac:** Kategori bazli aylik harcama limiti belirleme ve takip.

**Kullanici Hikayesi:**
- "Market harcamam aylik 25K'yi gecmesin"
- "Keyfi harcama limitimi 10K olarak belirlemek istiyorum"
- "Limitime ne kadar yaklastigimi gormek istiyorum"

**Teknik Tasarim:**

Yeni model: `BudgetLimit`
```
BudgetLimit {
  String id
  ExpenseCategory category
  double monthlyLimit
  bool isActive
  DateTime createdAt
}
```

Firestore: `users/{uid}/budget_limits` collection

Provider: `budgetLimitsProvider` — tum limitleri izle
Helper: `budgetUsageProvider(category, yearMonth)` — kategori bazli harcama / limit orani

**UI Bilesenleri:**
- `BudgetSetupSheet`: kategori sec + limit gir (bottom sheet)
- `BudgetProgressBar`: harcama/limit orani gorsel (yesil→sari→kirmizi)
- `BudgetOverviewCard`: dashboard'da veya transactions'da ozet
- Limit asildiginda veya %80'e geldiginde uyari banner

**Entegrasyon Noktalari:**
- Expense eklerken ilgili kategorinin kalan butcesini goster
- Dashboard'da "Bu Ayin Butcesi" ozet karti
- ExpenseTab'da kategori basina butce ilerleme cubugu

**Kabul Kriterleri:**
- [ ] Kategori bazli limit belirlenebilir
- [ ] Harcama/limit orani dogru hesaplanir
- [ ] %80 ve %100 esiklerinde gorsel uyari
- [ ] Gider eklerken kalan butce gosterilir

---

## Simulasyon: Hesaplama Duzeltmeleri, UX/UI & Yeni Ozellikler

> Amac: Simulasyon motorunu hesaplama dogrulugu, kullanilabilirlik ve
> yeni yetenekler acisindan best-practices seviyesine cikarmak.

### Mevcut Durum & Tespit Edilen Sorunlar

**Hesaplama sorunlari:**

| # | Sorun | Dosya | Aciklama |
|---|-------|-------|----------|
| S1 | Yillik etki ortalama bazli | `simulation_calculator.dart:75` | `annualNetImpact = monthlyNetImpact * 12` — maas degisikliginde ay bazli vergi farki var, 12 ayin toplamini almak yerine ortalama*12 kullaniliyor |
| S2 | Projeksiyon statik baz | `simulation_calculator.dart:271` | Her ay `currentBudget.totalIncome` ile basliyor — periyodik gelir/gider bitis/degisikliklerini yansitmiyor |
| S3 | Yatirim getirisi yaniltici | `simulation_calculator.dart:236` | `monthlyReturn = totalReturn / termMonths` — cogu yatirimda aylik odeme yok, vade sonunda toplu getiri gosterilmeli |
| S4 | Legacy kod karisikligi | `simulation_calculator.dart:406-587` | 3 deprecated result sinifi + 3 deprecated metot — gereksiz karmasiklik |
| S5 | Kira degisimi tek yonlu | `_calcRentChange` | Sadece eski→yeni fark hesabi, kira artis tarihi/yillik artis orani modellenmemiyor |

**UX/UI sorunlari:**

| # | Sorun | Ekran | Aciklama |
|---|-------|-------|----------|
| U1 | Gizli etkilesimler | List screen | Long-press flip → aksiyonlar gizli, kullanici kesfedemiyor |
| U2 | 2 adimli degisiklik ekleme | Editor | Tip sec → form doldur — gereksiz friction |
| U3 | Geri alinamaz silme | Editor | Swipe-delete aninda, undo yok |
| U4 | Hesaplama gecikmesi | Editor | 300ms debounce, kullanici "hesaplaniyor" geri bildirimi gormuyor |
| U5 | Cashflow 12 kart | Cashflow | 12 expandable kart — ozet yok, karsilastirma yok |
| U6 | Legacy/Yeni ikili paradigma | Detail vs Editor | 2 farkli ekran, 2 farkli deneyim |
| U7 | Template onizleme yok | Template | Kullanici hangi alanlari dolduracagini onceden goremiyor |
| U8 | Toplam maliyet gizli | Editor | Normal modda sadece aylik etki, toplam faiz/maliyet advanced'da |

---

### SIM-1: Hesaplama Dogruluk Duzeltmeleri

**Amac:** Simulasyon hesaplamalarini kesin dogru hale getirmek.

**Degisiklikler:**

1. **Yillik etki gercek toplam** (S1)
   - `annualNetImpact`: Maas degisikligi icin 12 ayin bireysel delta toplamini kullan
   - Diger degisiklikler icin mevcut `*12` yeterli
   ```
   annualNetImpact = salaryChanges.isEmpty
     ? monthlyNetImpact * 12
     : projection.fold(0, (s, m) => s + m.net) - currentBudget.netBalance * 12
   ```

2. **Dinamik projeksiyon bazı** (S2)
   - `_buildProjection` icinde her ay icin mevcut periyodik gelir/giderleri de hesaba kat
   - `currentBudget` yerine `futureProjections` provider'indan gelen ay bazli veriyi kullan
   - Boylece taksit bitisleri, maas degisiklikleri projeksiyona yansir

3. **Yatirim modeli iyilestirmesi** (S3)
   - Yatirim getirisi 2 modda gosterilsin:
     - `monthlyEquivalent`: Mevcut (aylik esit dagilim) — projeksiyon icin
     - `maturityValue`: Vade sonu toplam deger — sonuc kartinda
   - UI'da her iki bilgi ayri gosterilsin

4. **Legacy kod temizligi** (S4)
   - Deprecated sinif ve metotlari kaldir
   - `simulation_detail_screen.dart` (legacy ekran) kaldır veya yeni modele migre et
   - Tek paradigma: composable changes modeli

5. **Kira artis modeli** (S5)
   - `RentChangeChange`'e `annualIncreaseRate` alani ekle
   - Projeksiyon her yil kira artisini otomatik uygulasın
   - UI'da "Yillik artis orani" alani ekle

**Kabul Kriterleri:**
- [x] Maas degisikligi yillik etkisi 12 ayin bireysel toplamıyla eslesir (S1 ✅)
- [x] Projeksiyon periyodik bitis tarihlerini yansitir (S2 ✅)
- [x] Yatirim vade sonu degeri acikca gosterilir (S3 ✅)
- [x] Legacy kod kaldirilmis, tek model calisir (S4 ✅)
- [x] Kira yillik artis oraniyla projeksiyon dogru (S5 ✅)

---

### SIM-2: UX/UI Iyilestirmeleri

**Amac:** Simulasyon deneyimini sezgisel, kesfedilebilir ve akici hale getirmek.

**Degisiklikler:**

1. **Kart aksiyonlari gorunur** (U1)
   - Long-press flip yerine: swipe-left ile aksiyon panel goster (dahil et toggle + sil)
   - Veya kart ustunde kucuk toggle/menu ikonu
   - Tip: iOS Mail swipe pattern

2. **Tek adimda degisiklik ekleme** (U2)
   - Template'e gore otomatik ilk degisiklik ekle (bos formla)
   - "Degisiklik Ekle" butonunda tip secimi inline dropdown olsun
   - Veya: Sık kullanilan tipleri direkt buton olarak goster

3. **Undo snackbar** (U3)
   - Swipe-delete sonrasi 5sn undo snackbar goster
   - Kalıcı silme ancak snackbar kapaninca

4. **Hesaplama geri bildirimi** (U4)
   - Debounce sirasinda sonuc alaninda kucuk loading indicator
   - Veya: Sonuclari aninda guncelle, debounce sadece Firestore save icin

5. **Cashflow ozet gorünümü** (U5)
   - 12 kart ustune ozet satiri: toplam gelir, toplam gider, final kumulatif
   - "En iyi ay" / "En kotu ay" vurgulama
   - Mini sparkline grafik (12 ay trend)
   - Ay secici: tek tikla ilgili aya scroll

6. **Tek paradigma** (U6)
   - Legacy detail screen'i kaldir
   - Tum simulasyonlar editor screen'den acsın
   - Eski parameter-bazli simulasyonlari changes modeline otomatik migre et

7. **Template onizleme** (U7)
   - Template seciminde altına 2-3 satirlik "Bu formu dolduracaksiniz:" aciklamasi
   - Veya: Template kartinda ornek degerler goster

8. **Toplam maliyet her zaman gorunur** (U8)
   - Normal modda da kredi toplam maliyeti ve toplam faizi goster
   - Advanced mod: amortizasyon tablosu, ay bazli vergi etkisi gibi detaylar

**Kabul Kriterleri:**
- [ ] Kart aksiyonlari kesfedilebilir (long-press gerekmiyor)
- [ ] Degisiklik ekleme max 2 tap
- [ ] Silme geri alinabilir (undo)
- [ ] Hesaplama gecikmesinde gorsel feedback
- [ ] Cashflow ekraninda 12 ay ozeti tek bakista

---

### SIM-3: Senaryo Karsilastirma

**Amac:** Birden fazla simulasyonu yan yana karsilastirma.

**Kullanici Hikayesi:**
- "Ev alsam mi kiraya devam mi? Hangisi daha mantikli?"
- "48 ay taksit mi 36 ay taksit mi? Toplam maliyeti karsilastirmak istiyorum"

**Teknik Tasarim:**
- `SimulationEntry.compareWithId` alani zaten mevcut (kullanilmiyor)
- Karsilastirma ekrani: 2 simulasyon sec → yan yana sonuc goster
- Karsilastirma metrikleri:
  - Aylik etki farki
  - Toplam maliyet farki
  - Kumulatif 12 ay net farki
  - Affordability karsilastirmasi

**UI:**
- `/simulate/compare` route
- Iki simulasyon sec (dropdown veya kart secimi)
- Yan yana Before/After kartlari
- Delta gosterimi (yesil = daha iyi, kirmizi = daha kotu)
- 12 ay trend karsilastirma grafigi

**Kabul Kriterleri:**
- [ ] 2 simulasyon secilebilir
- [ ] Aylik, yillik ve toplam maliyet farki gosterilir
- [ ] Gorsel karsilastirma grafigi

---

### SIM-4: Gelismis Kredi Ozellikleri

**Amac:** Kredi simulasyonunu gercek hayat senaryolarina yakinlastirmak.

**Yeni Yetenekler:**

1. **Erken odeme simulasyonu**
   - "X. ayda Y TL erken odeme yaparsam ne olur?"
   - Yeni vade veya yeni taksit hesabi
   - Faiz tasarrufu gosterimi

2. **Degisken faiz**
   - Baslangic faizi + belirli aydan itibaren yeni faiz
   - Veya: Enflasyona endeksli artis orani

3. **KKDF + BSMV dahil gercek maliyet**
   - Turkiye'de kredi maliyeti: faiz + KKDF (%15) + BSMV (%10)
   - `realAnnualRate = annualRate * (1 + kkdfRate + bsmvRate)` hesabi

4. **Kredi karsilastirma**
   - Farkli bankalardan teklif karsilastirma
   - Ayni anapara, farkli faiz/vade → en uygun secim

**Teknik:**
- `CreditChange` modeline `earlyPayments: List<EarlyPayment>?` ekle
- `EarlyPayment { int month, double amount }`
- Amortizasyon tablosunda erken odeme noktalarini isaretle
- KKDF/BSMV: `FinancialCalculator`'a opsiyonel parametre

---

### SIM-5: Interaktif Slider Modu

**Amac:** Kullanicinin parametreleri slider ile oynayarak anlik sonuc gormesi.

**Kullanici Hikayesi:**
- "Faiz oranini 15-25 arasinda kaydirarak aylik taksiti canli gormek istiyorum"
- "Vadeyi uzatinca toplam faiz nasil degisiyor?"

**Teknik Tasarim:**
- Kredi/ev/araba editor'unde slider widget'lar (text input yerine veya yaninda)
- Slider hareket ettikce sonuc aninda guncellenir (debounce yok, hesaplama ucuz)
- Range slider: min-max belirlenebilir
- Haptic feedback her adimda

**UI:**
- `SimSlider`: Labeled slider widget (min, max, step, current, format)
- Sonuc karti slider'in hemen altinda (gorsel baglanti)
- Opsiyonel: Slider + text input toggle (hassas giris icin)

---

### SIM-6: "Ya Olursa?" Hizli Senaryolar

**Amac:** Tek tikla sik sorulan finansal sorulari cevaplama.

**Hazir Senaryolar:**
- "Maasim %20 artarsa?" → SalaryChange quick-fill
- "50.000 TL kredi ceksem?" → CreditChange quick-fill
- "Kiram 10.000 artarsa?" → RentChange quick-fill
- "Isten cikarsam?" → Income = 0 simulasyonu (acil fon yeterliligi)
- "Araba alsam aylık ne kadar gider?" → CarChange quick-fill

**Teknik:**
- Template screen'e "Hızlı Senaryolar" section ekle
- Her senaryo: 1 tap ile onceden doldurulmus editor ac
- Kullanici sadece rakamlari degistirsin

**UI:**
- Kucuk horizontal scroll kartlar (ikon + baslik)
- Tap → editor acilir, alanlar onceden dolu
- Kaydet opsiyonel (sadece gormek icin de kullanilabilir)

---

### SIM-7: Simulasyonu Butceye Yansitma Iyilestirmesi

**Amac:** "Dahil Et" toggle'ini daha anlasilir ve guclu yapmak.

**Mevcut Sorun:**
- Kullanici "Dahil Et"in ne yaptigini anlamiyor (ilk seferde info sheet cikiyor ama sonra unutuluyor)
- Dahil edilen simulasyonlarin butceye etkisi dashboard'da yeterince gorunur degil

**Iyilestirmeler:**

1. **Dashboard'da simulasyon etkisi gorsel**
   - Projeksiyon tablosunda "simulasyon dahil" satirlari farkli renkle isaretle
   - "Simulasyonsuz" vs "simulasyonlu" toggle (tek tikla karsilastir)

2. **Dahil Et onizleme**
   - Toggle'a basmadan once: "Bu simulasyon aylik giderinizi +7.200 TL artiracak" onizleme
   - Onaylama sonrasi: dashboard'da canli guncelleme animasyonu

3. **Coklu simulasyon bilesik etki**
   - Birden fazla simulasyon dahil edildiginde toplam bilesik etkiyi goster
   - "3 simulasyon dahil: aylik +12.500 TL gider" ozet karti

---

### Simulasyon Uygulama Sirasi

| Sira | Ozellik | Bagimlılık | Karmasiklik |
|------|---------|-----------|-------------|
| 1 | SIM-1: Hesaplama duzeltmeleri | Yok | Orta |
| 2 | SIM-2: UX/UI iyilestirmeleri | SIM-1 | Orta |
| 3 | SIM-6: Hizli senaryolar | SIM-2 | Dusuk |
| 4 | SIM-4: Gelismis kredi | SIM-1 | Orta |
| 5 | SIM-5: Slider modu | SIM-2 | Dusuk |
| 6 | SIM-3: Senaryo karsilastirma | SIM-2 | Orta |
| 7 | SIM-7: Butceye yansitma | SIM-2 | Dusuk |

---

## Faz 2: Akilli Ozellikler (Oncelik: Orta)

> Amac: Uygulamayi "sadece kayit" aracından "akilli finansal asistan"a donustur.

### 2.1 Nakit Akis Tahmini (Cash Flow Forecast)

**Amac:** 12 ay ileriye detayli projeksiyon — Excel Ozet sayfasinin guclu versiyonu.

**Kullanici Hikayesi:**
- "Gelecek 6 ayda en sikisik oldugum ay hangisi?"
- "Taksitler bitince ne kadar rahatlarim?"
- "Kumulatif birikimim 6 ay sonra ne olur?"

**Teknik Tasarim:**
- Mevcut `futureProjections` provider'ini genislet
- `PlannedChange` desteği ekle (Faz 1.2)
- Taksit bitis milestone'lari isaretle
- Senaryo karsilastirma: "simdi vs taksitler bittikten sonra"

**UI:**
- 12 aylik kart listesi (her ay: gelir, gider, net, kumulatif)
- Milestone isaretleri (taksit bitisleri, maas artisi vb.)
- Mini grafik: kumulatif trend cizgisi
- "En sikisik ay" ve "en rahat ay" vurgulama

**Farkı (Excel'den ustun yanlari):**
- Otomatik periyodik projeksiyon (Excel'de elle girilir)
- Brut→net otomatik hesaplama (Excel'de yok)
- Taksit bitis etkileri otomatik yansir
- Planlı degisiklikler otomatik dahil

---

### 2.2 Bildirimler & Hatirlaticilar

**Amac:** Proaktif finansal farkindaliklarla kullaniciyi bilgilendirmek.

**Kullanici Hikayesi:**
- "Taksitim bitmek uzere, hatirlatilsin"
- "Bu ay fazla harcadigimda uyarılayım"
- "Haftalik ozet gormek istiyorum"

**Teknik Tasarim:**
- `flutter_local_notifications` paketi
- Bildirim turleri:
  - Taksit bitis yaklasma (< 2 ay)
  - Butce %80 asim uyarisi
  - Haftalik/aylik ozet
  - Periyodik islem hatirlatma
- Ayarlar ekraninda bildirim tercihleri

**Entegrasyon:**
- `NotificationService` sinifi olustur
- Periyodik kontrol: `workmanager` veya `cron` bazli
- Ayarlar ekraninda toggle'lar

---

### 2.3 Karsilastirma Modu

**Amac:** Ay vs ay veya gerceklesen vs planlanan karsilastirma.

**Kullanici Hikayesi:**
- "Bu ay gecen aya gore ne degisti?"
- "Planlanan butcemle gerceklesen arasindaki fark ne?"

**UI:**
- Yan yana iki ay secimi
- Fark gosterimi: yesil (iyilesme) / kirmizi (kotuleme)
- Kategori bazli breakdown: hangi kalemde artis/azalis var
- "Bu ay neden daha az kaldi?" drill-down

---

### 2.4 CSV/Excel Import

**Amac:** Mevcut Excel verilerini uygulamaya aktarma, banka ekstresi import.

**Teknik Tasarim:**
- CSV parser: `csv` paketi
- Sablon formatı: Tarih, Tur (Gelir/Gider/Birikim), Tutar, Kategori, Not
- Banka ekstresi formatlari: Is Bankasi, Garanti, Yapi Kredi (her birinin CSV formati farkli)
- Import wizard: dosya sec → onizleme → eslestirme → onayla → kaydet
- Dublike kontrol: ayni tarih + tutar + kategori varsa uyar

---

### 2.5 Vergi Raporu / Yillik Ozet

**Amac:** Yillik vergi, SGK, damga vergisi ozetini raporlama.

**Hesaplama (mevcut altyapi var):**
- `calculateAnnualNetSalary` zaten 12 aylik detay donuyor
- Toplam gelir vergisi, SGK, damga vergisi mevcut
- Yillik efektif vergi orani mevcut

**UI:**
- Yillik ozet ekrani: toplam brut, toplam net, toplam vergi, toplam SGK
- Aylik vergi dilimi gecis grafigi
- PDF cikti (rapor formati)
- Dashboard'da "Bu yil ne kadar vergi odedin?" karti

---

## Faz 3: Ileri Ozellikler (Oncelik: Dusuk)

> Amac: Rakiplerden ayiran, kullaniciyi baglayan ozellikler.

### 3.1 AI Advisor (Gemini Entegrasyonu)

**Amac:** Dogal dilde finansal soru-cevap ve oneri.

**Yetenekler:**
- "Bu ay nereye fazla harcadim?"
- "6 ay icinde araba alabilir miyim?"
- "Tasarruf oranımı artirmak icin ne yapmaliyim?"
- Dogal dille simulasyon olusturma

**Teknik Tasarim:**
- `google_generative_ai` paketi (mevcut, pubspec'te var)
- Gemini'ye gonderilecek context: son 3 ayin ozeti, periyodik kalemler, hedefler
- Prompt muhendisligi: Turkce, finansal terminoloji, kisisel veri gizliligi
- Rate limiting: gunluk max 20 sorgu (Spark plan)

### 3.2 Aile / Coklu Kisi Destegi

**Amac:** Birden fazla kisinin gelir/giderini takip etme.

**Model Uzantisi:**
- `Income.person` ve `Expense.person` alanlari zaten var
- Kisi bazli filtreleme ve raporlama ekle
- "Ev butcesine herkes ne kadar katki yapiyor?" gorunumu
- Ortak vs kisisel gider ayrimi

### 3.3 Hedef Bazli Akilli Planlama

**Amac:** Birikim hedeflerine ulasma plani ve takibi.

**Ozellikler:**
- "Ev almak istiyorum, ne kadar biriktirmeliyim?"
- Hedefe ulasma suresi projeksiyonu
- Aylik otomatik birikim onerisi
- Hedef ilerleme bildirimleri
- Hedefi simulasyonla birlestirme

### 3.4 Hizli Giris & Widget

**Amac:** Islem girme suresini minimuma indirme.

**Ozellikler:**
- Son eklenen islemi tek tikla tekrarla
- Sık kullanilan gider sablonlari (market, benzin, yemek)
- iOS/Android home screen widget'i: hizli gider ekleme
- "Bugun ne kadar harcadim?" widget'i

---

## Teknik Borc & Iyilestirmeler

### Performans
- [x] ~~`calculateAnnualNetSalary` cache mekanizmasi~~ (tamamlandi)
- [ ] Firestore sorgularini optimize et (gereksiz re-fetch onleme)
- [ ] Buyuk listelerde lazy loading / pagination
- [ ] Provider state'lerini minimize et (computed vs stored)

### Kod Kalitesi
- [ ] Tum provider'larda error handling standardize et
- [ ] Repository katmaninda retry mekanizmasi
- [ ] Integration testleri ekle (ozellikle hesaplama zincirleri)
- [ ] Widget testleri ekle (form validasyon, tab gecisleri)

### Test Kapsami
- Mevcut: 9 test (FinancialCalculator temelleri)
- Hedef: MonthSummaryAggregator testleri
- Hedef: Periyodik projeksiyon testleri
- Hedef: PlannedChange entegrasyon testleri
- Hedef: BudgetLimit hesaplama testleri

---

## Uygulama Sirasi (Onerilen)

### Faz 1 — Temel Fonksiyonalite
| Sira | Ozellik | Kod | Bagimlilık | Karmasiklik |
|------|---------|-----|-----------|-------------|
| 1 | Periyodik Islem Yonetimi | 1.1 | Yok | Dusuk |
| 2 | Adim Degisikligi | 1.2 | Yok | Orta |
| 3 | Borc Takip | 1.3 | 1.1 | Orta |
| 4 | Butce/Limit | 1.4 | Yok | Orta |

### Simulasyon Iyilestirmeleri
| Sira | Ozellik | Kod | Bagimlilık | Karmasiklik |
|------|---------|-----|-----------|-------------|
| 5 | Hesaplama duzeltmeleri | SIM-1 | Yok | Orta |
| 6 | UX/UI iyilestirmeleri | SIM-2 | SIM-1 | Orta |
| 7 | Hizli senaryolar | SIM-6 | SIM-2 | Dusuk |
| 8 | Gelismis kredi | SIM-4 | SIM-1 | Orta |
| 9 | Slider modu | SIM-5 | SIM-2 | Dusuk |
| 10 | Senaryo karsilastirma | SIM-3 | SIM-2 | Orta |
| 11 | Butceye yansitma | SIM-7 | SIM-2 | Dusuk |

### Faz 2 — Akilli Ozellikler
| Sira | Ozellik | Kod | Bagimlilık | Karmasiklik |
|------|---------|-----|-----------|-------------|
| 12 | Nakit Akis Tahmini | 2.1 | 1.2 | Orta |
| 13 | Bildirimler | 2.2 | 1.3, 1.4 | Orta |
| 14 | Karsilastirma Modu | 2.3 | Yok | Dusuk |
| 15 | CSV/Excel Import | 2.4 | Yok | Orta |
| 16 | Vergi Raporu | 2.5 | Yok | Dusuk |

### Faz 3 — Ileri Ozellikler
| Sira | Ozellik | Kod | Bagimlilık | Karmasiklik |
|------|---------|-----|-----------|-------------|
| 17 | AI Advisor | 3.1 | Yok | Yuksek |
| 18 | Coklu Kisi | 3.2 | Yok | Orta |
| 19 | Hedef Planlama | 3.3 | Yok | Orta |
| 20 | Hizli Giris/Widget | 3.4 | Yok | Orta |

---

## Referans: Excel Bilancosu ile Karsilastirma

| Ozellik | Excel | Savvy (Mevcut) | Savvy (Hedef) |
|---------|-------|----------------|---------------|
| Gelir/gider satir girisi | Elle | Formla | Formla + Otomatik |
| Brut→Net hesaplama | Yok | Var (2026 vergi) | Var + cache |
| Aylik net hesaplama | Formul | Otomatik | Otomatik |
| Kumulatif devir | Formul | Otomatik | Otomatik |
| Periyodik projeksiyon | Elle | 12 ay otomatik | Otomatik + adim degisikligi |
| Taksit bitis takibi | Elle | Yok | Otomatik + uyari |
| Adim degisikligi | Elle | Yok | Otomatik |
| Butce limiti | Yok | Yok | Kategori bazli |
| Gorsellik | Tablo | Grafik + kart | Grafik + kart + timeline |
| Erisilebilirlik | Masaustu | Mobil | Mobil + widget |
| Paylasim | Dosya | CSV export | CSV + PDF + import |
| Akilli oneri | Yok | Yok | AI Advisor |
