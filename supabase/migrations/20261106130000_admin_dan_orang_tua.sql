-- Tahap 2: form diisi orang tua + halaman admin (/admin) dengan kode akses.
-- Aman dijalankan setelah migration pertama.

-- ============ KOLOM BARU ============
alter table public.mb_submissions add column if not exists parent_name text;

-- ============ KODE AKSES ADMIN ============
create extension if not exists pgcrypto with schema extensions;

-- Hanya menyimpan HASH kode. RLS aktif tanpa policy => tidak bisa dibaca dari aplikasi.
create table if not exists public.mb_admin_config (
  id        smallint primary key default 1 check (id = 1),
  code_hash text not null
);
alter table public.mb_admin_config enable row level security;
revoke all on public.mb_admin_config from anon, authenticated;

-- Dipakai SEKALI lewat SQL Editor untuk menentukan kode akses:
--   select public.mb_admin_set_code('kode-rahasia-kamu');
create or replace function public.mb_admin_set_code(p_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  if char_length(coalesce(p_code, '')) < 6 then
    raise exception 'Kode minimal 6 karakter';
  end if;
  insert into public.mb_admin_config (id, code_hash)
  values (1, crypt(p_code, gen_salt('bf')))
  on conflict (id) do update set code_hash = excluded.code_hash;
end;
$$;
revoke all on function public.mb_admin_set_code(text) from public, anon, authenticated;

-- Internal: cek kode. Jeda 1 detik saat salah untuk memperlambat tebak-tebakan.
create or replace function public.mb_admin_verify(p_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
begin
  select code_hash into v_hash from public.mb_admin_config where id = 1;
  if v_hash is null or p_code is null or crypt(p_code, v_hash) <> v_hash then
    perform pg_sleep(1);
    raise exception 'KODE_SALAH';
  end if;
end;
$$;
revoke all on function public.mb_admin_verify(text) from public, anon, authenticated;

-- ============ FUNGSI ADMIN (dipanggil lewat supabase.rpc) ============

create or replace function public.mb_admin_login(p_code text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform public.mb_admin_verify(p_code);
  return true;
end;
$$;

create or replace function public.mb_admin_report(p_code text)
returns table (
  id             uuid,
  created_at     timestamptz,
  child_name     text,
  parent_name    text,
  gender         text,
  age            int,
  grade          text,
  test_date      date,
  section_scores jsonb,
  top_codes      text[]
)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform public.mb_admin_verify(p_code);
  return query
    select s.id, s.created_at, s.child_name, s.parent_name, s.gender, s.age,
           s.grade, s.test_date, s.section_scores, s.top_codes
    from public.mb_submissions s
    order by s.created_at desc;
end;
$$;

create or replace function public.mb_admin_answers(p_code text, p_id uuid)
returns table (
  question_code text,
  section_code  text,
  question_text text,
  score         smallint
)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform public.mb_admin_verify(p_code);
  return query
    select a.question_code, q.section_code, q.text, a.score
    from public.mb_answers a
    join public.mb_questions q on q.code = a.question_code
    where a.submission_id = p_id
    order by q.section_code, q.position;
end;
$$;

create or replace function public.mb_admin_delete(p_code text, p_id uuid)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform public.mb_admin_verify(p_code);
  delete from public.mb_submissions where id = p_id;
end;
$$;

revoke all on function public.mb_admin_login(text)             from public;
revoke all on function public.mb_admin_report(text)            from public;
revoke all on function public.mb_admin_answers(text, uuid)     from public;
revoke all on function public.mb_admin_delete(text, uuid)      from public;
grant execute on function public.mb_admin_login(text)          to anon, authenticated;
grant execute on function public.mb_admin_report(text)         to anon, authenticated;
grant execute on function public.mb_admin_answers(text, uuid)  to anon, authenticated;
grant execute on function public.mb_admin_delete(text, uuid)   to anon, authenticated;

-- ============ PERBARUI REDAKSI SOAL (sudut pandang orang tua) ============
insert into public.mb_questions (code, section_code, position, text) values
  ('VB-1', 'VB', 1, 'Anak saya sangat suka membaca buku.'),
  ('VB-2', 'VB', 2, 'Anak saya suka bercerita, termasuk cerita dongeng dan cerita yang lucu.'),
  ('VB-3', 'VB', 3, 'Anak saya memiliki ingatan yang baik untuk hal-hal yang sepele.'),
  ('VB-4', 'VB', 4, 'Anak saya menyukai permainan kata (seperti teka-teki silang, scrabble, atau puzzle).'),
  ('VB-5', 'VB', 5, 'Anak saya suka menyatakan atau menuliskan ide-idenya.'),
  ('VB-6', 'VB', 6, 'Di waktu luang, anak saya sering membaca buku.'),
  ('VB-7', 'VB', 7, 'Anak saya suka berdiskusi dan bertukar pikiran dengan teman.'),
  ('LM-1', 'LM', 1, 'Anak saya sangat menikmati pelajaran matematika.'),
  ('LM-2', 'LM', 2, 'Anak saya menyukai permainan yang menggunakan angka.'),
  ('LM-3', 'LM', 3, 'Pelajaran IPA menyenangkan bagi anak saya.'),
  ('LM-4', 'LM', 4, 'Anak saya menyukai permainan yang membutuhkan strategi untuk menang.'),
  ('LM-5', 'LM', 5, 'Anak saya senang mencari tahu bagaimana cara kerja setiap benda.'),
  ('LM-6', 'LM', 6, 'Anak saya menyukai komputer dan berbagai permainan angka.'),
  ('LM-7', 'LM', 7, 'Anak saya suka bermain catur, checkers, atau monopoli.'),
  ('VS-1', 'VS', 1, 'Anak saya lebih suka dijelaskan dengan gambar daripada secara lisan atau mendengarkan.'),
  ('VS-2', 'VS', 2, 'Anak saya lebih memilih peta daripada petunjuk tertulis untuk mencari sebuah alamat.'),
  ('VS-3', 'VS', 3, 'Anak saya senang menggambar.'),
  ('VS-4', 'VS', 4, 'Anak saya senang membuat coretan di kertas kapan pun ia bisa.'),
  ('VS-5', 'VS', 5, 'Ketika membaca majalah, anak saya lebih suka melihat gambar daripada membaca teksnya.'),
  ('VS-6', 'VS', 6, 'Jika sesuatu rusak dan tidak berfungsi, anak saya cenderung mempelajari cara kerjanya.'),
  ('VS-7', 'VS', 7, 'Dalam kerja kelompok, anak saya lebih memilih menggambar hal-hal yang penting.'),
  ('BK-1', 'BK', 1, 'Anak saya suka pelajaran olahraga.'),
  ('BK-2', 'BK', 2, 'Anak saya lebih banyak melakukan aktivitas daripada berbicara saja.'),
  ('BK-3', 'BK', 3, 'Anak saya suka aktivitas di luar rumah.'),
  ('BK-4', 'BK', 4, 'Anak saya mudah mempelajari olahraga atau tarian baru.'),
  ('BK-5', 'BK', 5, 'Anak saya suka membuat prakarya (membuat patung, menjahit, memahat kayu).'),
  ('BK-6', 'BK', 6, 'Bila melihat sesuatu yang menarik, anak saya ingin memegangnya.'),
  ('BK-7', 'BK', 7, 'Anak saya tidak suka duduk diam terlalu lama.'),
  ('MS-1', 'MS', 1, 'Anak saya suka mendengarkan musik.'),
  ('MS-2', 'MS', 2, 'Anak saya bersenandung saat melakukan sesuatu.'),
  ('MS-3', 'MS', 3, 'Anak saya bisa bernyanyi atau memainkan alat musik dengan baik.'),
  ('MS-4', 'MS', 4, 'Anak saya bisa menghafal nada dari banyak lagu.'),
  ('MS-5', 'MS', 5, 'Di waktu santai, anak saya sering mendengarkan musik.'),
  ('MS-6', 'MS', 6, 'Jika harus mengingat sesuatu, anak saya mencoba membuat irama tentang hal tersebut.'),
  ('MS-7', 'MS', 7, 'Anak saya tahu banyak mengenai musik.'),
  ('IR-1', 'IR', 1, 'Anak saya merasa sedih apabila ada teman yang sedang kesusahan.'),
  ('IR-2', 'IR', 2, 'Anak saya mempunyai banyak teman baik.'),
  ('IR-3', 'IR', 3, 'Anak saya lebih suka bermain dengan kelompok daripada bermain sendiri.'),
  ('IR-4', 'IR', 4, 'Jika harus mengingat sesuatu, anak saya meminta seseorang untuk mengetes apakah ia sudah memahaminya.'),
  ('IR-5', 'IR', 5, 'Anak saya senang berkumpul dengan teman.'),
  ('IR-6', 'IR', 6, 'Teman-temannya sering meminta saran atau ide dari anak saya.'),
  ('IR-7', 'IR', 7, 'Anak saya mudah menyelesaikan permasalahan antara dirinya dengan teman-temannya.'),
  ('IA-1', 'IA', 1, 'Anak saya suka bekerja sendirian tanpa gangguan orang lain.'),
  ('IA-2', 'IA', 2, 'Anak saya suka menulis buku harian.'),
  ('IA-3', 'IA', 3, 'Anak saya tidak suka keramaian.'),
  ('IA-4', 'IA', 4, 'Anak saya tahu kelebihan dan kekurangan dirinya.'),
  ('IA-5', 'IA', 5, 'Anak saya lebih suka menyelesaikan sendiri masalah yang sedang dihadapinya.'),
  ('IA-6', 'IA', 6, 'Bila sedang banyak masalah, anak saya lebih suka menyendiri.'),
  ('IA-7', 'IA', 7, 'Anak saya tidak mudah terpengaruh atau ikut-ikutan dengan orang lain.'),
  ('NT-1', 'NT', 1, 'Anak saya suka memperhatikan kehidupan alam semesta.'),
  ('NT-2', 'NT', 2, 'Anak saya menyukai binatang.'),
  ('NT-3', 'NT', 3, 'Anak saya suka berkebun.'),
  ('NT-4', 'NT', 4, 'Anak saya suka membaca tentang dunia binatang.'),
  ('NT-5', 'NT', 5, 'Anak saya suka mempelajari nama-nama makhluk hidup (seperti bunga, pohon, binatang).'),
  ('NT-6', 'NT', 6, 'Anak saya sangat memperhatikan sekeliling dan apa yang sedang terjadi di sekitarnya.'),
  ('NT-7', 'NT', 7, 'Anak saya senang berjalan-jalan di taman dan melihat pohon serta bunga.')
on conflict (code) do update set
  section_code = excluded.section_code, position = excluded.position, text = excluded.text;
