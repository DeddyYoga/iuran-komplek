# BRD — Aplikasi Iuran Komplek (38 Rumah)
**Versi:** v1 · 18 Nov 2026 · Status: DRAFT untuk review

---

## 1. Ringkasan

Aplikasi web responsive untuk pencatatan iuran komplek 38 rumah. Pemilik rumah **tanpa login** bisa lihat tagihan, status iuran tetangga, saldo kas, dan konfirmasi bayar dengan upload bukti transfer. Admin (2–3 orang) mengelola master rumah, iuran, verifikasi pembayaran, dan pengeluaran (gaji satpam, token listrik, dll).

**Biaya operasional: Rp 0/bulan** (Vercel + Supabase free tier).

---

## 2. Aktor & Model Akses

| Aktor | Akses | Cara masuk |
|---|---|---|
| **Pemilik rumah** (38) | Lihat tagihan sendiri + status tetangga + kas + konfirmasi bayar | Buka link publik, pilih nomor rumah — **tanpa login** |
| **Admin** (2–3) | Full: master, iuran, verifikasi, pengeluaran, export | Login email + password |

> ⚠️ Konsekuensi tanpa login: siapa pun yang punya link bisa lihat data. Untuk konteks komplek ini acceptable. (Opsi proteksi: 1 PIN bersama — default OFF, bisa dinyalakan nanti.)

---

## 3. Struktur Data

| Entitas | Field kunci | Keterangan |
|---|---|---|
| **rumah** | no (1–38), pemilik, dihuni (Y/N), pakai_air (Y/N), aktif | Master, hanya admin bisa edit |
| **iuran_item** | rumah_id, label (mis. "Keamanan", "Air"), nominal | **Per rumah beda-beda** — ada yang sama, ada yang beda nominal |
| **tagihan** | rumah_id, bulan (YYYY-MM), total, status (BELUM/LUNAS) | Auto-generate tiap bulan dari iuran_item; admin bisa override nominal |
| **pembayaran** | rumah_id, nominal, tgl_transfer, bulan_dari, bulan_sampai, bukti_foto, status (PENDING/VERIFIED/REJECTED), verified_by | Owner submit tanpa login; admin verifikasi. **Multi-bulan:** satu pembayaran bisa mencakup beberapa bulan (mis. Des 2026 – Feb 2027); tagihan future auto-generate saat verifikasi, lalu dilunasi berurutan |
| **pengeluaran** | tanggal, kategori (satpam/listrik/kebersihan/lain), keterangan, nominal, nota_foto | Hanya admin |
| **kas** | (derived) saldo = Σ verified pembayaran − Σ pengeluaran | Tidak perlu tabel, dihitung |

---

## 4. Fitur — Halaman Pemilik (tanpa login)

**P1. Beranda publik** — pilih nomor rumah (grid 38) → masuk ke halaman rumah.

**P2. Halaman rumah**:
- Tagihan bulan ini (rincian item + total) + status LUNAS/BELUM
- **Cicilan/tunggakan view**: kalau ada bulan lalu belum lunas, muncul daftar "belum dibayar: Okt, Nov" dengan total gabungan
- Riwayat 12 bulan terakhir (bayar/tidak, tanggal, nominal)
- Tombol **"Saya Sudah Bayar"** → form: nominal + tanggal transfer + **pilihan periode** (1 bulan / beberapa bulan ke depan — sistem hitung otomatis: lunasi tunggakan dulu → sisanya untuk bulan ke depan berurutan) + foto bukti → masuk antrian admin
  - Auto-match: sistem cek nominal vs tagihan terbuka → info "kemungkinan untuk tagihan [bulan s/d bulan]" (bantu admin, keputusan tetap di admin)

**Contoh multi-bulan:** tunggakan Okt+Nov (2×75rb) + warga bayar 300rb = lunas Okt, Nov, Des, Jan. Sistem yang alokasikan otomatis, admin cuma tap ✓.

**P3. Rekap komplek** (transparansi):
- Tabel 38 rumah × status bulan ini (LUNAS/BELUM) — siapa yang belum kelihatan
- Saldo kas + daftar pengeluaran bulan berjalan (kategori + nominal + bisa buka foto nota)

---

## 5. Fitur — Halaman Admin (login)

**A1. Dashboard**: saldo kas, pending verifikasi (badge), jumlah belum bayar bulan ini.

**A2. Verifikasi pembayaran**: antrian bukti transfer → tap ✓ VERIFIED / ✗ REJECTED (+ tagihan otomatis LUNAS kalau nominal match).

**A3. Master rumah** (38): CRUD — no, pemilik, dihuni, pakai air, aktif/nonaktif (rumah kosong tetap tercatat).

**A4. Kelola iuran per rumah**: tambah/edit/hapus item per rumah (mis. rumah 12: Keamanan 50rb + Air 75rb; rumah 13: Keamanan 50rb saja). Bulk tool: "terapkan item ini ke semua rumah" untuk item yang seragam.

**A5. Generate tagihan bulanan**: auto-check saat admin buka dashboard (kalau bulan berjalan belum ada tagihan → generate dari iuran_item) + tombol manual. Override nominal per rumah per bulan possible.

**A6. Catat pengeluaran**: tanggal + kategori + keterangan + nominal + foto nota.

**A7. Export rekap bulanan**: format text siap copy-paste ke grup WA (rekap per rumah + saldo + pengeluaran) + halaman print-friendly (ctrl+P → PDF).

---

## 6. Flow Konfirmasi Bayar (Semi-Auto — Opsi A)

```
Pemilik transfer (BCA/QRIS statis komplek)
  → buka link, pilih rumah, "Saya Sudah Bayar"
  → input nominal + tanggal + foto bukti
  → status: PENDING (muncul di dashboard admin)
  → admin buka foto → tap ✓
  → pembayaran VERIFIED + tagihan LUNAS + kas updated
  → (notif pemilik: lihat sendiri di halaman rumah — status jadi LUNAS)
```

---

## 7. Tech Stack & Hosting (semua gratis)

| Layer | Pilihan | Kenapa |
|---|---|---|
| Frontend | Vue 3 (CDN, no build) — PWA responsive, mobile-first | 1 file, gampang dirawat, installable di HP |
| Hosting | **Vercel free** (atau GitHub Pages) | Online 24 jam, custom domain optional |
| Database + Auth + Storage foto | **Supabase free tier** (500MB, cukup untuk 5+ tahun foto bukti) | Postgres beneran, RLS untuk security |
| Auto-generate tagihan | Trigger saat admin buka dashboard + tombol manual | Tanpa server tambahan |

**RLS policy ringkas:** anon = read rekap + insert pembayaran(PENDING) saja; admin (auth) = full.

---

## 8. Daftar Screen

| # | Screen | Aktor |
|---|---|---|
| 1 | Beranda pilih rumah (grid 38) | Publik |
| 2 | Halaman rumah (tagihan + riwayat + tombol bayar) | Publik |
| 3 | Form konfirmasi bayar + upload bukti | Publik |
| 4 | Rekap komplek + kas + pengeluaran | Publik |
| 5 | Login admin | Admin |
| 6 | Dashboard admin | Admin |
| 7 | Antrian verifikasi pembayaran | Admin |
| 8 | Master rumah | Admin |
| 9 | Kelola iuran per rumah | Admin |
| 10 | Pengeluaran + upload nota | Admin |
| 11 | Export rekap WA / print | Admin |

---

## 9. Out of Scope (sengaja tidak dibuat)

- ❌ Denda / hitungan telat
- ❌ Payment gateway / QRIS dinamis (fee 0,7%, butuh badan usaha)
- ❌ Login untuk pemilik
- ❌ Push notification (cukup WA group oleh admin)
- ❌ Multi-komplek

---

## 10. Yang Dibutuhkan dari Mas (setup 1x, ±15 menit)

1. Buat akun **Supabase** gratis (supabase.com → sign in with GitHub) → bikin project → kirim URL + anon key ke gw
2. Nama komplek + nomor rekening/QRIS untuk ditampilkan di halaman tagihan
3. Data 38 rumah (Excel/photo juga boleh — gw inputkan; atau admin input sendiri lewat app)
4. Daftar iuran awal per rumah (yang mana sama, yang mana beda)

Setelah itu: gw setup database + deploy + tes end-to-end → link langsung bisa dipakai.
