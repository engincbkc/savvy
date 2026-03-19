# Brütten Nete Maaş Hesaplama — 2026 Türkiye

> Kaynak: GİB Gelir Vergisi Tarifesi 2026 (Tebliğ Seri No: 332, 31.12.2025 Resmi Gazete)
> Doğrulama: verginet.net brüt-net tablosuyla ay ay karşılaştırılıp onaylanmıştır.

---

## SABİTLER

```
BRUT_ASGARI_UCRET        = 33_030.00    // 2026 aylık brüt asgari ücret
SGK_ISCI_ORANI           = 0.14         // %14
ISSIZLIK_ISCI_ORANI      = 0.01         // %1
DAMGA_VERGISI_ORANI      = 0.00759      // %0,759 (binde 7,59)
SGK_TAVAN_KATSAYI         = 9           // SGK tavan = asgari ücret × 9
SGK_TAVAN                 = 297_270.00  // 33.030 × 9

// Asgari ücret istisna matrahı (aylık, sabit)
ASGARI_UCRET_GV_MATRAHI  = 28_075.50   // 33.030 - (33.030 × 0.14) - (33.030 × 0.01)
```

---

## GELİR VERGİSİ DİLİMLERİ (ÜCRET GELİRLERİ — 2026)

> ÖNEMLİ: Bu dilimler YILLIK KÜMÜLATİF matrah üzerinden uygulanır.
> Ücret dışı gelirler için 3. dilim farklıdır (1.000.000 TL). Biz sadece ücret geliri kullanıyoruz.

```
VERGI_DILIMLERI = [
  { alt:         0,  ust:    190_000,  oran: 0.15 },  // %15
  { alt:   190_000,  ust:    400_000,  oran: 0.20 },  // %20
  { alt:   400_000,  ust:  1_500_000,  oran: 0.27 },  // %27  ← ücret gelirlerinde
  { alt: 1_500_000,  ust:  5_300_000,  oran: 0.35 },  // %35  ← ücret gelirlerinde
  { alt: 5_300_000,  ust:  Infinity,   oran: 0.40 },  // %40
]
```

Doğrulama tablosu (kümülatif vergi):

```
Matrah 190.000   → Vergi: 28.500
Matrah 400.000   → Vergi: 70.500
Matrah 1.500.000 → Vergi: 367.500
Matrah 5.300.000 → Vergi: 1.697.500
```

---

## ANA HESAPLAMA ALGORİTMASI

Her ay için sırayla hesapla. Önceki ayların kümülatif değerlerini taşı.

### Girdi

```
brutMaas: number          // Aylık brüt maaş (her ay farklı olabilir, zam vb.)
ayIndex: number           // 0 = Ocak, 1 = Şubat, ... 11 = Aralık
oncekiKumulatifMatrah: number  // Bir önceki ayın sonundaki kümülatif GV matrahı (Ocak için 0)
oncekiKumulatifVergi: number   // Bir önceki ayın sonundaki kümülatif GV tutarı (Ocak için 0)
oncekiKumulatifAsgariMatrah: number  // Asgari ücret kümülatif matrahı (Ocak için 0)
oncekiKumulatifAsgariVergi: number   // Asgari ücret kümülatif vergisi (Ocak için 0)
```

### Adım 1: SGK ve İşsizlik Kesintisi

```
sgkMatrahi = min(brutMaas, SGK_TAVAN)
sgkIsci    = sgkMatrahi × SGK_ISCI_ORANI       // brüt × %14 (tavan ile sınırlı)
issizlikIsci = sgkMatrahi × ISSIZLIK_ISCI_ORANI // brüt × %1  (tavan ile sınırlı)
```

### Adım 2: Gelir Vergisi Matrahı (aylık)

```
aylikGvMatrahi = brutMaas - sgkIsci - issizlikIsci
```

### Adım 3: Kümülatif Matrah ve Kümülatif Gelir Vergisi

```
yeniKumulatifMatrah = oncekiKumulatifMatrah + aylikGvMatrahi
yeniKumulatifVergi  = kumulatifVergiHesapla(yeniKumulatifMatrah)  // fonksiyon aşağıda
aylikGelirVergisi   = yeniKumulatifVergi - oncekiKumulatifVergi
```

### Adım 4: Damga Vergisi

```
// Asgari ücrete isabet eden kısım istisna
damgaMatrahi = max(brutMaas - BRUT_ASGARI_UCRET, 0)
damgaVergisi = damgaMatrahi × DAMGA_VERGISI_ORANI
```

### Adım 5: Net Maaş (istisna öncesi)

```
netMaas = brutMaas - sgkIsci - issizlikIsci - aylikGelirVergisi - damgaVergisi
```

### Adım 6: Asgari Ücret Gelir Vergisi İstisnası

> Bu istisna da KÜMÜLATİF hesaplanır! Asgari ücret matrahı vergi dilimine girdiğinde
> istisna tutarı da değişir. (Verginet tablosunda Temmuz ve Ağustos'ta değiştiği görülür.)

```
yeniKumulatifAsgariMatrah = oncekiKumulatifAsgariMatrah + ASGARI_UCRET_GV_MATRAHI
yeniKumulatifAsgariVergi  = kumulatifVergiHesapla(yeniKumulatifAsgariMatrah)
aylikGvIstisnasi          = yeniKumulatifAsgariVergi - oncekiKumulatifAsgariVergi
```

### Adım 7: Asgari Ücret Damga Vergisi İstisnası

```
// Sabit, her ay aynı
damgaIstisnasi = BRUT_ASGARI_UCRET × DAMGA_VERGISI_ORANI  // 33.030 × 0.00759 = 250.70
```

### Adım 8: Toplam Net Ele Geçen

```
toplamNetEleGecen = netMaas + aylikGvIstisnasi + damgaIstisnasi
```

### Adım 9: Sonraki Aya Taşı

```
oncekiKumulatifMatrah       = yeniKumulatifMatrah
oncekiKumulatifVergi        = yeniKumulatifVergi
oncekiKumulatifAsgariMatrah = yeniKumulatifAsgariMatrah
oncekiKumulatifAsgariVergi  = yeniKumulatifAsgariVergi
```

---

## YARDIMCI FONKSİYON: kumulatifVergiHesapla

```
function kumulatifVergiHesapla(kumulatifMatrah: number): number {
  let vergi = 0;

  for (const dilim of VERGI_DILIMLERI) {
    if (kumulatifMatrah <= dilim.alt) break;

    const dilimdeMatrah = min(kumulatifMatrah, dilim.ust) - dilim.alt;
    vergi += dilimdeMatrah × dilim.oran;
  }

  return vergi;  // kuruş yuvarlamasını sonra yap
}
```

---

## DOĞRULAMA: VERGİNET TABLOSUYLA KARŞILAŞTIRMA

Girdi: Ocak brüt 115.000, Şubat-Aralık brüt 140.000

```
Ay       | Brüt    | SGK İşçi | İşsizlik | GV Matrahı | Küm.Matrah | Küm.GV     | Aylık GV    | Damga     | Net         | GV İstisna | DV İst. | Ele Geçen
---------|---------|----------|----------|------------|------------|------------|-------------|-----------|-------------|------------|---------|----------
Ocak     | 115.000 | 16.100   | 1.150    | 97.750     | 97.750     | 14.662,50  | 14.662,50   | 872,85    | 82.214,65   | 4.211,33   | 250,70  | 86.676,68
Şubat    | 140.000 | 19.600   | 1.400    | 119.000    | 216.750    | 33.850,00  | 19.187,50   | 1.062,60  | 98.749,90   | 4.211,33   | 250,70  | 103.211,93
Mart     | 140.000 | 19.600   | 1.400    | 119.000    | 335.750    | 57.650,00  | 23.800,00   | 1.062,60  | 94.137,40   | 4.211,33   | 250,70  | 98.599,43
Nisan    | 140.000 | 19.600   | 1.400    | 119.000    | 454.750    | 85.282,50  | 27.632,50   | 1.062,60  | 90.304,90   | 4.211,33   | 250,70  | 94.766,93
Mayıs    | 140.000 | 19.600   | 1.400    | 119.000    | 573.750    | 117.412,50 | 32.130,00   | 1.062,60  | 85.807,40   | 4.211,33   | 250,70  | 90.269,43
Haziran  | 140.000 | 19.600   | 1.400    | 119.000    | 692.750    | 149.542,50 | 32.130,00   | 1.062,60  | 85.807,40   | 4.211,33   | 250,70  | 90.269,43
Temmuz   | 140.000 | 19.600   | 1.400    | 119.000    | 811.750    | 181.672,50 | 32.130,00   | 1.062,60  | 85.807,40   | 4.537,75   | 250,70  | 90.595,85
Ağustos  | 140.000 | 19.600   | 1.400    | 119.000    | 930.750    | 213.802,50 | 32.130,00   | 1.062,60  | 85.807,40   | 5.615,10   | 250,70  | 91.673,20
Eylül    | 140.000 | 19.600   | 1.400    | 119.000    | 1.049.750  | 245.932,50 | 32.130,00   | 1.062,60  | 85.807,40   | 5.615,10   | 250,70  | 91.673,20
Ekim     | 140.000 | 19.600   | 1.400    | 119.000    | 1.168.750  | 278.062,50 | 32.130,00   | 1.062,60  | 85.807,40   | 5.615,10   | 250,70  | 91.673,20
Kasım    | 140.000 | 19.600   | 1.400    | 119.000    | 1.287.750  | 310.192,50 | 32.130,00   | 1.062,60  | 85.807,40   | 5.615,10   | 250,70  | 91.673,20
Aralık   | 140.000 | 19.600   | 1.400    | 119.000    | 1.406.750  | 342.322,50 | 32.130,00   | 1.062,60  | 85.807,40   | 5.615,10   | 250,70  | 91.673,20
---------|---------|----------|----------|------------|------------|------------|-------------|-----------|-------------|------------|---------|----------
TOPLAM   |1.655.000| 231.700  | 16.550   |            | 1.406.750  | 342.322,50 | 342.322,50  | 12.561,45 |1.051.866,05 | 57.881,23  |3.008,40 |1.112.755,68
```

> Tüm satırlar verginet.net tablosuyla birebir eşleşmektedir. ✅

---

## DİLİM GEÇİŞ NOKTALARININ AÇIKLAMASI

Bu tabloda neden bazı aylarda GV değişiyor?

```
Ocak: Küm.matrah 97.750 < 190.000      → tamamen %15 diliminde
Şubat: Küm.matrah 216.750 > 190.000    → dilim geçişi! Bir kısmı %15, kalanı %20
Nisan: Küm.matrah 454.750 > 400.000    → dilim geçişi! Bir kısmı %20, kalanı %27
Mayıs-Aralık: Küm.matrah hep %27 içinde → aylık GV sabitlenir (119.000 × 0.27 = 32.130)
```

Asgari ücret istisnasında da dilim geçişi var:

```
Temmuz: Küm.asgari matrah 196.528,50 > 190.000 → istisna vergi oranı %15→%20 geçişi (4.537,75)
Ağustos: Küm.asgari matrah 224.604 → tamamen %20 diliminde (5.615,10)
```

---

## EDGE CASE'LER

### 1. Brüt maaş asgari ücretten düşük veya eşitse

```
if (brutMaas <= BRUT_ASGARI_UCRET) {
  // Gelir vergisi = 0 (tamamen istisna)
  // Damga vergisi = 0 (tamamen istisna)
  // Sadece SGK ve İşsizlik kesilir
  // Net = Brüt - SGK - İşsizlik
}
```

### 2. Brüt maaş SGK tavanını aşıyorsa

```
if (brutMaas > SGK_TAVAN) {
  // SGK ve İşsizlik matrahı SGK_TAVAN ile sınırlandırılır
  // Ama GV matrahı brüt üzerinden hesaplanır (tavan yok)
  // sgkIsci = SGK_TAVAN × 0.14 (brüt × 0.14 değil!)
}
```

### 3. Yıl içinde zam (brüt değişikliği)

- Her ay farklı brüt girilebilir
- Kümülatif değerler doğru taşındığı sürece hesap otomatik doğru çalışır
- Ocak-Haziran 100K, Temmuz-Aralık 140K gibi senaryolar desteklenmeli

### 4. Yıl ortasında işe başlama

- oncekiKumulatifMatrah = 0 olarak başla (önceki işverendeki matrah bilinmiyorsa)
- İdeal: "Önceki işverenden kümülatif matrah" girişi opsiyonel sunulabilir

### 5. Negatif değer kontrolü

```
aylikGelirVergisi = max(aylikGelirVergisi, 0)
damgaVergisi      = max(damgaVergisi, 0)
aylikGvIstisnasi  = min(aylikGvIstisnasi, aylikGelirVergisi) // istisna vergiden fazla olamaz
```

### 6. Kuruş yuvarlaması

- Tüm ara hesaplamalar kuruş hassasiyetinde yapılır (2 decimal)
- Son değer gösteriminde 2 ondalık basamak

---

## UYGULAMA İÇİN ÖNERİLEN KULLANIM

### Senaryo A: Gelir ekleme formunda hızlı hesaplama

- Kullanıcı brüt girer → anlık net gösterilir
- "Gelir olarak ekle" → NET tutar periyodik gelir olarak kaydedilir
- Default ay: Ocak (ilk dilim, en yüksek net)
- Opsiyonel: ay seçimi ile farklı aylardaki neti göster

### Senaryo B: Maaş Hesaplama aracı (ayrı sayfa)

- Brüt maaş girişi
- 12 aylık tablo gösterimi (yukarıdaki doğrulama tablosu gibi)
- Hangi ayda hangi dilime girildiği renkli olarak vurgulansın
- Yıllık toplam net, toplam vergi, efektif vergi oranı göster

### Senaryo C: Simülasyona entegrasyon

- Kullanıcının periyodik geliri brütten hesaplanıyorsa
- Her ay farklı net geleceğini simülasyona yansıt (dilim geçişleri)
- "Zam senaryosu": Temmuz'da %30 zam gelirse yılın kalanı nasıl değişir?
