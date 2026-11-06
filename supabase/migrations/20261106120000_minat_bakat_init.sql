-- Tes Minat & Bakat Anak (8 kecerdasan, usia 7+)
-- Semua tabel berawalan "mb_" agar tidak bentrok dengan tabel lama
-- (answers, questions, sections, submissions) di project yang sama.

-- ============ TABEL ============

create table if not exists public.mb_sections (
  code        text primary key,
  key         text not null unique,
  title       text not null,
  short_title text not null,
  sort_order  smallint not null
);

create table if not exists public.mb_questions (
  code         text primary key,
  section_code text not null references public.mb_sections(code) on delete cascade,
  position     smallint not null,
  text         text not null,
  unique (section_code, position)
);

create table if not exists public.mb_submissions (
  id             uuid primary key default gen_random_uuid(),
  child_name     text not null check (char_length(trim(child_name)) between 1 and 100),
  gender         text not null check (gender in ('L', 'P')),
  age            int  not null check (age >= 7 and age <= 100),
  grade          text not null check (char_length(trim(grade)) between 1 and 50),
  test_date      date not null default current_date,
  section_scores jsonb not null,
  top_codes      text[] not null,
  created_at     timestamptz not null default now()
);

create table if not exists public.mb_answers (
  id            bigint generated always as identity primary key,
  submission_id uuid not null references public.mb_submissions(id) on delete cascade,
  question_code text not null references public.mb_questions(code),
  score         smallint not null check (score between 1 and 5),
  unique (submission_id, question_code)
);

create index if not exists mb_answers_submission_idx on public.mb_answers (submission_id);
create index if not exists mb_submissions_created_idx on public.mb_submissions (created_at desc);

-- ============ RLS ============

alter table public.mb_sections    enable row level security;
alter table public.mb_questions   enable row level security;
alter table public.mb_submissions enable row level security;
alter table public.mb_answers     enable row level security;

-- Bank soal: boleh dibaca publik
drop policy if exists "mb_sections_read" on public.mb_sections;
create policy "mb_sections_read" on public.mb_sections
  for select to anon, authenticated using (true);

drop policy if exists "mb_questions_read" on public.mb_questions;
create policy "mb_questions_read" on public.mb_questions
  for select to anon, authenticated using (true);

-- Hasil tes: publik hanya boleh MENGIRIM, tidak boleh membaca (data anak).
-- Pembacaan dilakukan lewat dashboard Supabase / service role / admin.
drop policy if exists "mb_submissions_insert" on public.mb_submissions;
create policy "mb_submissions_insert" on public.mb_submissions
  for insert to anon, authenticated with check (true);

drop policy if exists "mb_answers_insert" on public.mb_answers;
create policy "mb_answers_insert" on public.mb_answers
  for insert to anon, authenticated with check (true);

-- ============ SEED BANK SOAL ============

insert into public.mb_sections (code, key, title, short_title, sort_order) values
  ('VB', 'verbal', 'Kecerdasan Bahasa', 'Bahasa', 1),
  ('LM', 'logical', 'Kecerdasan Logika & Matematika', 'Logika', 2),
  ('VS', 'visual', 'Kecerdasan Visual & Ruang', 'Visual', 3),
  ('BK', 'bodily', 'Kecerdasan Gerak Tubuh', 'Gerak', 4),
  ('MS', 'musical', 'Kecerdasan Musik', 'Musik', 5),
  ('IR', 'interpersonal', 'Kecerdasan Sosial', 'Sosial', 6),
  ('IA', 'intrapersonal', 'Kecerdasan Diri', 'Diri', 7),
  ('NT', 'naturalistic', 'Kecerdasan Alam', 'Alam', 8)
on conflict (code) do update set
  key = excluded.key, title = excluded.title,
  short_title = excluded.short_title, sort_order = excluded.sort_order;

insert into public.mb_questions (code, section_code, position, text) values
  ('VB-1', 'VB', 1, 'Aku sangat suka membaca buku.'),
  ('VB-2', 'VB', 2, 'Aku suka bercerita, termasuk cerita dongeng dan cerita yang lucu.'),
  ('VB-3', 'VB', 3, 'Aku punya ingatan yang baik untuk hal-hal yang sepele.'),
  ('VB-4', 'VB', 4, 'Aku menyukai permainan kata-kata (seperti teka-teki silang, scrabble, atau puzzle).'),
  ('VB-5', 'VB', 5, 'Aku suka menyatakan atau menuliskan ide-ide.'),
  ('VB-6', 'VB', 6, 'Waktu luang, aku sering gunakan untuk membaca buku.'),
  ('VB-7', 'VB', 7, 'Aku suka berdiskusi dan bertukar pikiran dengan teman.'),
  ('LM-1', 'LM', 1, 'Aku sangat menikmati pelajaran matematika.'),
  ('LM-2', 'LM', 2, 'Aku menyukai permainan yang menggunakan angka.'),
  ('LM-3', 'LM', 3, 'Pelajaran IPA menyenangkan bagiku.'),
  ('LM-4', 'LM', 4, 'Aku menyukai permainan yang membutuhkan strategi untuk menang.'),
  ('LM-5', 'LM', 5, 'Aku senang mencari tahu bagaimana cara kerja setiap benda.'),
  ('LM-6', 'LM', 6, 'Aku menyukai komputer dan berbagai permainan angka-angka.'),
  ('LM-7', 'LM', 7, 'Aku suka bermain catur, checkers, atau monopoli.'),
  ('VS-1', 'VS', 1, 'Aku lebih memilih dijelaskan dengan gambar daripada lisan atau mendengarkan.'),
  ('VS-2', 'VS', 2, 'Aku lebih memilih peta daripada petunjuk tertulis dalam mencari sebuah alamat.'),
  ('VS-3', 'VS', 3, 'Aku senang menggambar.'),
  ('VS-4', 'VS', 4, 'Aku senang membuat coretan di kertas kapan pun aku bisa.'),
  ('VS-5', 'VS', 5, 'Ketika membaca majalah, aku lebih suka melihat gambar daripada membaca teksnya.'),
  ('VS-6', 'VS', 6, 'Jika sesuatu rusak dan tidak berfungsi, aku cenderung mempelajari mengenai cara kerjanya.'),
  ('VS-7', 'VS', 7, 'Dalam kerja kelompok, aku lebih memilih menggambar hal-hal yang penting.'),
  ('BK-1', 'BK', 1, 'Aku suka pelajaran olahraga.'),
  ('BK-2', 'BK', 2, 'Aku lebih banyak melakukan aktivitas daripada berbicara saja.'),
  ('BK-3', 'BK', 3, 'Aku suka aktivitas di luar rumah.'),
  ('BK-4', 'BK', 4, 'Aku mudah mempelajari suatu olahraga atau tarian baru.'),
  ('BK-5', 'BK', 5, 'Aku suka aktivitas seperti membuat prakarya (membuat patung, menjahit, memahat kayu).'),
  ('BK-6', 'BK', 6, 'Bila melihat sesuatu yang menarik, aku ingin memegangnya.'),
  ('BK-7', 'BK', 7, 'Aku tidak suka duduk diam terlalu lama.'),
  ('MS-1', 'MS', 1, 'Aku suka mendengarkan musik.'),
  ('MS-2', 'MS', 2, 'Aku bersenandung bila melakukan sesuatu.'),
  ('MS-3', 'MS', 3, 'Aku bisa bernyanyi atau memainkan alat musik dengan baik.'),
  ('MS-4', 'MS', 4, 'Aku bisa menghafal nada-nada dari banyak lagu.'),
  ('MS-5', 'MS', 5, 'Waktu santai, aku sering gunakan waktu untuk mendengarkan musik.'),
  ('MS-6', 'MS', 6, 'Jika aku harus mengingat sesuatu, aku mencoba untuk membuat irama tentang hal tersebut.'),
  ('MS-7', 'MS', 7, 'Aku tahu banyak mengenai musik.'),
  ('IR-1', 'IR', 1, 'Aku merasa sedih apabila ada teman yang sedang kesusahan.'),
  ('IR-2', 'IR', 2, 'Aku mempunyai banyak teman baik.'),
  ('IR-3', 'IR', 3, 'Aku menyukai bermain dengan kelompok daripada bermain sendiri.'),
  ('IR-4', 'IR', 4, 'Jika aku harus mengingat sesuatu, aku meminta seseorang untuk mengetes apakah aku sudah memahaminya.'),
  ('IR-5', 'IR', 5, 'Aku senang berkumpul dengan teman.'),
  ('IR-6', 'IR', 6, 'Teman-teman sering meminta saran atau ide dariku.'),
  ('IR-7', 'IR', 7, 'Aku mudah menyelesaikan suatu permasalahan antara aku dengan teman-teman.'),
  ('IA-1', 'IA', 1, 'Aku suka bekerja sendirian tanpa ada gangguan orang lain.'),
  ('IA-2', 'IA', 2, 'Aku suka menulis buku harian.'),
  ('IA-3', 'IA', 3, 'Aku tidak suka keramaian.'),
  ('IA-4', 'IA', 4, 'Aku tahu kelebihan dan kekurangan diriku.'),
  ('IA-5', 'IA', 5, 'Aku lebih suka menyelesaikan sendiri masalah yang sedang dihadapi.'),
  ('IA-6', 'IA', 6, 'Bila aku sedang banyak masalah, aku lebih suka menyendiri.'),
  ('IA-7', 'IA', 7, 'Aku tidak mudah terpengaruh atau ikut-ikutan dengan orang lain.'),
  ('NT-1', 'NT', 1, 'Aku suka memperhatikan kehidupan alam semesta.'),
  ('NT-2', 'NT', 2, 'Aku menyukai binatang.'),
  ('NT-3', 'NT', 3, 'Aku suka berkebun.'),
  ('NT-4', 'NT', 4, 'Aku suka membaca tentang dunia binatang.'),
  ('NT-5', 'NT', 5, 'Aku suka mempelajari nama-nama sesuatu yang hidup (seperti bunga, pohon, binatang).'),
  ('NT-6', 'NT', 6, 'Aku sangat memperhatikan sekeliling dan apa yang sedang terjadi di sekitarku.'),
  ('NT-7', 'NT', 7, 'Aku senang berjalan-jalan di taman dan melihat-lihat pohon serta bunga.')
on conflict (code) do update set
  section_code = excluded.section_code, position = excluded.position, text = excluded.text;
