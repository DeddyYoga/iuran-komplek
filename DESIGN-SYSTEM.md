# Design System — Iuran Komplek (mengikuti pnm.co.id)

Sumber: pnm.co.id (di-scrape 19 Nov 2026 — app.css + homepage)

## Brand Colors

| Token | Nilai | Pemakaian |
|---|---|---|
| `--c-primary` | `#014a94` | **Biru PNM** — header, tombol utama, link aktif (41x di homepage = warna dominan) |
| `--c-primary-hover` | `#0066b3` | Hover tombol |
| `--c-primary-light` | `#7bc1fd` | Badge info, highlight |
| `--c-accent` | `#82c467` | **Hijau PNM** — status LUNAS, sukses, aksen positif |
| `--c-accent-dark` | `#4c860b` | Hover/teks di atas hijau muda |
| `--c-dark` | `#053356` | Navy gelap — footer, judul section |
| `--c-text` | `#484848` | Body text |
| `--c-text-muted` | `#6b7280` | Secondary text (gray-500) |
| `--c-border` | `#e5e7eb` | Border input/tabel |
| `--c-bg` | `#f9f9f9` | Background section |
| `--c-white` | `#ffffff` | Card background |
| `--c-danger` | `#dc2626` | Status BELUM/tunggakan (standar merah Tailwind, PNM gak punya merah brand) |

## Typography

- **Font: Montserrat** (400 / 700) — via Google Fonts
- H1: 24–28px/700 · H2: 20px/700 · Body: 14–16px/400 · Caption: 12px
- Warna heading: `--c-dark`; body: `--c-text`

## Bentuk & Komponen

- **Radius:** tombol & input = `0.375rem` (6px) · card = `0.5rem` (8px) · badge pill = `9999px`
- **Shadow:** soft minimal (Tailwind-style ring/shadow tipis)
- **Icon:** Font Awesome 6 (PNM pakai ini) — atau inline SVG stroke biar gak nambah dependency
- **Button primary:** bg `#014a94`, teks putih, radius 6px, hover `#0066b3`
- **Button success:** bg `#82c467`, teks putih/hover `#4c860b`
- **Badge LUNAS:** bg `#82c467` putih, pill · **Badge BELUM:** bg `#dc2626` putih, pill
- **Card:** putih, border `#e5e7eb` 1px, radius 8px, shadow tipis
- **Layout:** max-width 1100px center, mobile-first (PNM responsive)

## Nuansa

- Header app: putih dengan aksen garis biru `#014a94` (atau header solid biru di mobile)
- Footer mini: navy `#053356`
- Bahasa UI: Indonesia santai ("Rumah Anda", "Sudah Bayar", "Rekap Komplek")
