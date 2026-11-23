-- ============================================================
-- IURAN KOMPLEK — SETUP DATABASE (jalankan 1x di SQL Editor)
-- Cara: supabase.com/dashboard/project/kkakdfnuibxcaifyhgil
--       → SQL Editor → New query → paste SEMUA → Run
-- ============================================================

-- 1. TABEL MASTER RUMAH
create table if not exists public.rumah (
  id uuid primary key default gen_random_uuid(),
  no integer not null unique check (no between 1 and 99),
  pemilik text not null,
  dihuni boolean not null default true,
  pakai_air boolean not null default false,
  aktif boolean not null default true,
  created_at timestamptz default now()
);

-- 2. ITEM IURAN per rumah (label bebas: Keamanan/Air/Sampah/dll)
create table if not exists public.iuran_item (
  id uuid primary key default gen_random_uuid(),
  rumah_id uuid not null references public.rumah(id) on delete cascade,
  label text not null,
  nominal integer not null check (nominal >= 0),
  aktif boolean not null default true,
  created_at timestamptz default now()
);

-- 3. TAGIHAN per bulan (auto-generate dari iuran_item)
create table if not exists public.tagihan (
  id uuid primary key default gen_random_uuid(),
  rumah_id uuid not null references public.rumah(id) on delete cascade,
  bulan text not null, -- 'YYYY-MM'
  total integer not null default 0,
  status text not null default 'BELUM' check (status in ('BELUM','LUNAS')),
  unique (rumah_id, bulan)
);

-- 4. PEMBAYARAN (multi-bulan: bulan_dari s/d bulan_sampai)
create table if not exists public.pembayaran (
  id uuid primary key default gen_random_uuid(),
  rumah_id uuid not null references public.rumah(id) on delete cascade,
  nominal integer not null check (nominal > 0),
  tgl_transfer date not null default current_date,
  bulan_dari text,  -- opsional: alokasi otomatis isi saat verifikasi
  bulan_sampai text,
  bukti_url text,
  keterangan text,
  status text not null default 'PENDING' check (status in ('PENDING','VERIFIED','REJECTED')),
  verified_by text,
  verified_at timestamptz,
  created_at timestamptz default now()
);

-- 5. PENGELUARAN (satpam, listrik, dll + foto nota)
create table if not exists public.pengeluaran (
  id uuid primary key default gen_random_uuid(),
  tanggal date not null default current_date,
  kategori text not null default 'Lain-lain',
  keterangan text,
  nominal integer not null check (nominal > 0),
  nota_url text,
  created_at timestamptz default now()
);

-- 6. KONFIG (nama komplek, no rek, QRIS url, pin opsional)
create table if not exists public.konfig (
  key text primary key,
  value text
);
insert into public.konfig (key, value) values
  ('nama_komplek', 'Komplek Kita'),
  ('rekening', '-'),
  ('qris_url', '-')
on conflict (key) do nothing;

-- ============================================================
-- ROW LEVEL SECURITY — publik: baca + kirim bukti; admin: full
-- ============================================================
alter table public.rumah        enable row level security;
alter table public.iuran_item   enable row level security;
alter table public.tagihan      enable row level security;
alter table public.pembayaran   enable row level security;
alter table public.pengeluaran  enable row level security;
alter table public.konfig       enable row level security;

-- publik (anon): BACA semua data + KIRIM pembayaran (status PENDING paksa)
create policy "publik baca rumah"       on public.rumah       for select to anon, authenticated using (true);
create policy "publik baca iuran"       on public.iuran_item  for select to anon, authenticated using (true);
create policy "publik baca tagihan"     on public.tagihan     for select to anon, authenticated using (true);
create policy "publik baca pembayaran"  on public.pembayaran  for select to anon, authenticated using (true);
create policy "publik baca pengeluaran" on public.pengeluaran for select to anon, authenticated using (true);
create policy "publik baca konfig"      on public.konfig      for select to anon, authenticated using (true);

create policy "publik kirim pembayaran" on public.pembayaran
  for insert to anon, authenticated
  with check (status = 'PENDING');

-- publik GAK boleh: update apapun, delete apapun, insert rumah/tagihan/pengeluaran

-- admin (authenticated = yang login): full CRUD
create policy "admin kelola rumah"       on public.rumah       for all to authenticated using (true) with check (true);
create policy "admin kelola iuran"       on public.iuran_item  for all to authenticated using (true) with check (true);
create policy "admin kelola tagihan"     on public.tagihan     for all to authenticated using (true) with check (true);
create policy "admin verifikasi bayar"   on public.pembayaran  for all to authenticated using (true) with check (true);
create policy "admin kelola pengeluaran" on public.pengeluaran for all to authenticated using (true) with check (true);
create policy "admin kelola konfig"      on public.konfig      for all to authenticated using (true) with check (true);

-- ============================================================
-- SEED: 38 rumah dummy (ganti nama asli lewat app admin nanti)
-- + contoh iuran seragam: Keamanan 50rb semua rumah
-- ============================================================
insert into public.rumah (no, pemilik, dihuni, pakai_air)
select g, 'Rumah ' || g,
       (g % 10 <> 0),      -- rumah ke-10,20,30 dummy kosong
       (g % 2 = 0)         -- separuh pakai air (contoh)
from generate_series(1, 38) g
on conflict (no) do nothing;

insert into public.iuran_item (rumah_id, label, nominal)
select r.id, 'Keamanan', 50000
from public.rumah r
on conflict do nothing;
