-- Data asli warga PNM Residence 2 (dari Google Sheets, 19 Nov 2026)
alter table public.rumah drop constraint if exists rumah_no_check;
alter table public.rumah alter column no type text;
delete from public.rumah;
delete from public.iuran_item;
delete from public.tagihan;
delete from public.pembayaran;
delete from public.pengeluaran;
insert into public.rumah (no, pemilik, dihuni, pakai_air) values
  ('1', 'Pak Dede', true, true),
  ('2', 'Dinny', true, false),
  ('3', 'David', true, false),
  ('4', 'Milik MNM', true, false),
  ('5', 'Solihin', true, false),
  ('6', 'Rodi', true, false),
  ('7', 'Ibu HErning', true, false),
  ('8', 'Zafura', true, false),
  ('9', 'Aldi', true, false),
  ('10', 'Pak Satya', true, true),
  ('11', 'Demis', true, false),
  ('12', 'Roy', true, false),
  ('12A', 'Neneng', false, false),
  ('14', 'Dandi', true, false),
  ('15', 'Diki', true, false),
  ('16', 'Uci / Pak Budi', true, false),
  ('17', 'Bu Penny', true, true),
  ('18', 'Hilmy', true, false),
  ('19', 'Agus Hanafiah', true, true),
  ('20', 'Rizki', false, false),
  ('21', 'Dika', true, false),
  ('22', 'Arbi', true, false),
  ('23', 'Andi', true, false),
  ('24', 'Faisal', true, false),
  ('25', 'Harry', true, false),
  ('26', 'Nina', true, false),
  ('27', 'Riki', true, false),
  ('28', 'Belum ada data', false, false),
  ('29', 'Yogas', true, false),
  ('30', 'Pak Sapta', true, true),
  ('31', 'Yoga', true, false),
  ('32', 'Heri', true, false),
  ('33', 'Zaenal', true, false),
  ('34', 'Ratna', true, false),
  ('35', 'Rahayu', true, false),
  ('36', 'Hendi', true, false),
  ('37', 'Pak Sapri', true, false),
  ('38', 'Ocid', true, false);

insert into public.iuran_item (rumah_id, label, nominal)
select r.id, 'Sumur Bor', 320000 from public.rumah r where r.dihuni;

insert into public.tagihan (rumah_id, bulan, total, status)
select r.id, '2026-11', 320000,
  case when r.no in ('1','2','3','5','6','9','11','12','12A','14','15','16','18','20','21','22','23','24','25','26','27','29','31','32','33','34','35','36','38') then 'LUNAS' else 'BELUM' end
from public.rumah r where r.dihuni
on conflict (rumah_id, bulan) do nothing;

insert into public.pembayaran (rumah_id, nominal, tgl_transfer, bulan_dari, bulan_sampai, status, verified_by, verified_at)
select r.id, 320000, '2026-11-05', '2026-11', '2026-11', 'VERIFIED', 'admin', now()
from public.rumah r
where r.dihuni and r.no in ('1','2','3','5','6','9','11','12','12A','14','15','16','18','20','21','22','23','24','25','26','27','29','31','32','33','34','35','36','38');

insert into public.pengeluaran (tanggal, kategori, keterangan, nominal) values
 ('2026-11-05','Perawatan','Pembayaran tukang bor + perawatan pompa', 2500000),
 ('2026-11-10','Listrik','Token listrik pompa air', 300000);
