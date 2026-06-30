# Vakitli — Play Console "Veri Güvenliği" (Data Safety) Cevapları

Koddaki gerçek veri akışına göre hazırlandı. Play Console formundaki sıraya göre.

## Genel
- **Reklam SDK'sı / üçüncü taraf reklam?** Hayır
- **Analitik / izleme SDK'sı?** Hayır (Firebase Analytics yok)
- **Üçüncü taraflarla veri paylaşımı?** Evet — yalnızca aşağıdakiler:
  - Google Firebase (kimlik doğrulama, bulut yedek)
  - Aladhan API (konum → vakit hesabı)
  - Diğer kullanıcılar (yalnızca paylaşılan dua metni)
- **Veriler aktarımda şifreleniyor mu?** Evet (HTTPS / TLS)
- **Kullanıcı veri silme talep edebilir mi?** Evet (e-posta ile)

## Toplanan veri türleri (Data collected)

| Play kategorisi | Veri | Toplanıyor? | Paylaşılıyor? | Zorunlu? | Amaç |
|---|---|---|---|---|---|
| Konum | Yaklaşık konum | Evet | Evet (Aladhan) | İsteğe bağlı | Uygulama işlevi |
| Konum | Kesin konum | Evet | Evet (Aladhan) | İsteğe bağlı | Uygulama işlevi |
| Kişisel | E-posta adresi | Evet (giriş yapılırsa) | Hayır | İsteğe bağlı | Hesap yönetimi |
| Kişisel | Ad (görünen ad) | Evet (giriş yapılırsa) | Evet (dua paylaşımı) | İsteğe bağlı | Hesap, uygulama işlevi |
| Kişisel | Kullanıcı ID | Evet (giriş yapılırsa) | Hayır | İsteğe bağlı | Hesap yönetimi |
| Uygulama içi | Kullanıcı içeriği (dua metni) | Evet | Evet (diğer kullanıcılar) | İsteğe bağlı | Uygulama işlevi |
| Uygulama içi | Diğer (cinsiyet, şehir) | Evet (giriş yapılırsa) | Hayır | İsteğe bağlı | Kişiselleştirme |

> Not: "Kesin konum" topluyorsan formda hem yaklaşık hem kesin işaretle.

## Toplanmayan / saklanmayan
- Kamera görüntüsü: kullanılır (AR kıble) ama **saklanmaz/gönderilmez** → "toplanan veri" DEĞİL.
- Kişiler, fotoğraf galerisi, SMS, çağrı kaydı, sağlık verisi: hiçbiri.
- Reklam kimliği (AAID): kullanılmıyor.

## Her veri için işleme amacı (Purpose)
- Konum → "App functionality" (Uygulama işlevselliği)
- Hesap bilgileri → "Account management"
- Dua metni → "App functionality"
- Cinsiyet/şehir → "Personalization" (Kişiselleştirme)

## Güvenlik uygulamaları (Security practices)
- ✅ Aktarımda şifreleme (in transit) — Firebase/HTTPS
- ✅ Kullanıcı silme talep edebilir
- ⬜ Bağımsız güvenlik denetimi — Hayır (varsa işaretle)

## Eşleşme uyarısı
Bu form Gizlilik Politikası ile **tutarlı olmalı**. `docs/privacy-policy.html`
aynı veri listesini içeriyor — ikisini birlikte güncelle.
