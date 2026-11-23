-- ============================================================
-- DUMMY DATA — Iuran Komplek (jalankan 1x di SQL Editor)
-- Isi realistis biar semua fitur kelihatan: mutasi, checklist
-- tahun, tunggakan, antrian verifikasi, pengeluaran, kas.
-- ============================================================

-- 1. NAMA PEMILIK (38 rumah, beberapa kosong)
update public.rumah set pemilik = v.pemilik, dihuni = v.dihuni
from (values
 (1,'Budi Santoso',true),(2,'Siti Rahayu',true),(3,'Ahmad Hidayat',true),
 (4,'Dewi Lestari',true),(5,'Joko Prasetyo',true),(6,'Rina Wulandari',true),
 (7,'Bambang Sutrisno',true),(8,'Sri Mulyani',true),(9,'Agus Salim',true),
 (10,'Rumah Kosong — Tn. Hartono',false),(11,'Fitri Handayani',true),
 (12,'Hendra Gunawan',true),(13,'Maya Sari',true),(14,'Rudi Hartono',true),
 (15,'Lilis Suryani',true),(16,'Taufik Hidayat',true),(17,'Nur Aini',true),
 (18,'Doni Kusuma',true),(19,'Ratna Dewi',true),(20,'Rumah Kosong — Bu Ijah',false),
 (21,'Slamet Riyadi',true),(22,'Yuni Astuti',true),(23,'Eko Purnomo',true),
 (24,'Indah Permatasari',true),(25,'Fajar Nugroho',true),(26,'Sri Wahyuni',true),
 (27,'Herman Saputra',true),(28,'Dian Kartika',true),(29,'Yusuf Maulana',true),
 (30,'Rumah Dikontrak — Kel. Wirawan',true),(31,'Ani Rohayah',true),
 (32,'Budi Wibowo',true),(33,'Tuti Alawiyah',true),(34,'Rizky Ramadhan',true),
 (35,'Endang Purwanti',true),(36,'Wawan Setiawan',true),(37,'Nia Kurnia',true),
 (38,'Rumah Kosong — Tn. Darmo',false)
) as v(no, pemilik, dihuni)
where public.rumah.no = v.no;

-- 2. KONFIG komplek + rekening dummy
update public.konfig set value='PNM Residence 2 Cileunyi' where key='nama_komplek';
update public.konfig set value='BCA 1234 5678 90 — a.n. Bendahara RT (Bpk. Joko Prasetyo)' where key='rekening';

-- 3. ITEM IURAN VARIASI
-- Air 75rb utk rumah pakai_air
insert into public.iuran_item (rumah_id, label, nominal)
select r.id, 'Air', 75000 from public.rumah r
where r.pakai_air and r.no <= 25
  and not exists (select 1 from public.iuran_item i where i.rumah_id=r.id and i.label='Air');
-- Sampah 25rb utk blok A (no 1-19)
insert into public.iuran_item (rumah_id, label, nominal)
select r.id, 'Sampah', 25000 from public.rumah r
where r.no <= 19 and r.dihuni
  and not exists (select 1 from public.iuran_item i where i.rumah_id=r.id and i.label='Sampah');

-- 4. TAGIHAN Sep/Okt/Nov 2026 (total = jumlah item aktif per rumah)
insert into public.tagihan (rumah_id, bulan, total, status)
select r.id, m.bulan,
  coalesce((select sum(i.nominal) from public.iuran_item i where i.rumah_id=r.id and i.aktif),0),
  case
    when m.bulan < '2026-11' and (r.no % 5) = 0 then 'BELUM'   -- ada yang nunggak
    when m.bulan = '2026-11' and (r.no % 3) = 0 then 'BELUM'   -- bulan ini sebagian belum
    else 'LUNAS'
  end
from public.rumah r
cross join (values ('2026-09'),('2026-10'),('2026-11')) as m(bulan)
where r.aktif and r.dihuni
on conflict (rumah_id, bulan) do nothing;

-- 5. PEMBAYARAN VERIFIED (mutasi kas hidup — iuran Nov, sebagian multi-bulan)
insert into public.pembayaran (rumah_id, nominal, tgl_transfer, bulan_dari, bulan_sampai, status, verified_by, verified_at)
select r.id,
  case when (r.no % 4) = 0 then 300000 else 150000 end,   -- sebagian bayar 2 bulan
  ('2026-11-' || lpad((3 + (r.no % 12))::text, 2, '0'))::date,
  '2026-11', '2026-11', 'VERIFIED', 'admin@pnm2.id', now() - interval '1 day'
from public.rumah r
where r.dihuni and (r.no % 3) <> 0
limit 14;
-- multi-bulan (3 rumah bayar Nov-Des-Jan)
insert into public.pembayaran (rumah_id, nominal, tgl_transfer, bulan_dari, bulan_sampai, status, verified_by, verified_at)
select r.id, 450000, '2026-11-08'::date, '2026-11', '2027-01', 'VERIFIED', 'admin@pnm2.id', now() - interval '2 day'
from public.rumah r where r.no in (3, 17, 26);
-- pastikan tagihan Des & Jan utk rumah multi-bulan = LUNAS
insert into public.tagihan (rumah_id, bulan, total, status)
select r.id, m.bulan,
  coalesce((select sum(i.nominal) from public.iuran_item i where i.rumah_id=r.id and i.aktif),0), 'LUNAS'
from public.rumah r
cross join (values ('2026-12'),('2027-01')) as m(bulan)
where r.no in (3,17,26)
on conflict (rumah_id, bulan) do update set status='LUNAS';

-- pembayaran verified bulan lalu (biar mutasi panjang)
insert into public.pembayaran (rumah_id, nominal, tgl_transfer, bulan_dari, bulan_sampai, status, verified_by, verified_at)
select r.id, 150000, ('2026-10-' || lpad((2 + (r.no % 10))::text, 2, '0'))::date, '2026-10','2026-10','VERIFIED','admin@pnm2.id', now() - interval '35 day'
from public.rumah r where r.dihuni and (r.no % 3) <> 0 limit 10;

-- 6. PEMBAYARAN PENDING (antrian verifikasi admin)
insert into public.pembayaran (rumah_id, nominal, tgl_transfer, status)
select r.id, 150000, current_date, 'PENDING' from public.rumah r where r.no = 9;
insert into public.pembayaran (rumah_id, nominal, tgl_transfer, status)
select r.id, 300000, current_date, 'PENDING' from public.rumah r where r.no = 22;

-- 7. PENGELUARAN (3 bulan: satpam, listrik, kebersihan)
insert into public.pengeluaran (tanggal, kategori, keterangan, nominal) values
 ('2026-09-05','Satpam','Gaji satpam September', 600000),
 ('2026-09-05','Listrik','Token lampu jalan + pos', 150000),
 ('2026-10-05','Satpam','Gaji satpam Oktober', 600000),
 ('2026-10-05','Listrik','Token lampu jalan + pos', 150000),
 ('2026-10-18','Perawatan','Servis pompa air', 275000),
 ('2026-11-05','Satpam','Gaji satpam November', 600000),
 ('2026-11-05','Listrik','Token lampu jalan + pos', 150000),
 ('2026-11-12','Kebersihan','Upah bersih selokan', 200000);
