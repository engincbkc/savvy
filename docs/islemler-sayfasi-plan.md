# İşlemler Sayfası — Geliştirme Planı

## Mevcut Durum
- 3 tab var: Gelir / Gider / Birikim
- Her tab'da özet kart + kategori gruplama + işlem listesi
- Veri ekleme çalışıyor (bottom sheet)
- **Eksikler:** Düzenleme yok, silme yok, ay filtresi yok

## Yapılacaklar

### 1. Ay Seçici (Month Picker)
- Tab bar'ın üstüne yatay ay scroll'u ekle
- "Tümü" + aylar listesi (Mart 2026, Şubat 2026, ...)
- Seçilen aya göre veri filtrele
- Her ay chip'inde o ayın toplamı görünsün

### 2. İşlem Düzenleme (Edit)
- İşlem kartına tıklayınca düzenleme bottom sheet açılsın
- Mevcut verileri form'a doldur (tutar, kategori, tarih, not, kişi, periyodik)
- Kaydet → Firestore update çağır
- TransactionFormProvider'a `updateIncome`, `updateExpense`, `updateSavings` ekle

### 3. İşlem Silme (Delete)
- Sola kaydırma (swipe-to-dismiss) ile silme aksiyonu
- Kırmızı silme arka planı + çöp kutusu ikonu
- Silmeden önce onay dialogu göster
- Soft-delete (isDeleted: true) — zaten repo'da var
- Haptic feedback

### 4. İşlem Detay Bottom Sheet
- Tıklayınca detay göster: tüm bilgiler
- Alt kısımda "Düzenle" ve "Sil" butonları
- Periyodik işlemlerde bitiş tarihi bilgisi

### 5. Görünüm Modu
- Aylık bazda: Gelir vs Gider karşılaştırma
- Kategoriye göre: Pasta chart veya bar chart
- Son işlemler: Kronolojik liste (mevcut)

### 6. Türkçe Karakter Düzeltmeleri
- Tüm UI metinlerinde doğru Türkçe kullan
- İşlemler, Aylık Özet, Tüm Gelirler, Kategorilere Göre, vb.

## Teknik Notlar
- Repo'larda `update()` metodu zaten var
- Soft-delete `softDelete()` metodu zaten var
- Provider'a update metodları eklenmeli
- freezed model'lerde `copyWith` kullanılabilir (düzenleme için)
- Ay filtresi için mevcut `monthIncomes/monthExpenses/monthSavings` provider'ları kullanılabilir
