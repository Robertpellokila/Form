# Petualangan Bakat — Tes Minat & Bakat Anak (7+)

Aplikasi Vue 3 + Vite untuk tes minat dan bakat berbasis 8 kecerdasan majemuk.
Diisi oleh **orang tua**, hasil tersimpan di Supabase, dan dilihat admin di `/admin`.

## Menjalankan

```bash
npm install
cp .env.example .env     # lalu isi VITE_SUPABASE_ANON_KEY
npm run dev
```

## Supabase

Terapkan migration **berurutan** (SQL Editor atau `supabase db push`):

1. `supabase/migrations/20261106120000_minat_bakat_init.sql` — tabel `mb_*`, RLS, bank soal
2. `supabase/migrations/20261106130000_admin_dan_orang_tua.sql` — kolom nama orang tua, fungsi admin, redaksi soal untuk orang tua

Semua tabel berawalan `mb_` sehingga tidak menyentuh tabel lama
(`answers`, `questions`, `sections`, `submissions`).

### Kode akses admin

Setelah migration, tentukan kode akses **sekali** lewat SQL Editor:

```sql
select public.mb_admin_set_code('kode-rahasia-kamu');   -- minimal 6 karakter
```

Untuk mengganti kode, jalankan perintah yang sama dengan kode baru.
Kode disimpan sebagai hash (bcrypt) dan diperiksa di database; salah kode ditunda 1 detik.

## Halaman admin

Buka manual: `https://domain-kamu/admin` (tidak ada tombol/link ke sana dari halaman publik).
Masuk dengan kode akses. Fitur: ringkasan, sebaran bakat, tabel laporan (cari, filter, urutkan,
paginasi), detail jawaban per anak, hapus data, dan unduh CSV.

Data hasil tes **tidak bisa dibaca** dari aplikasi publik; hanya lewat fungsi admin yang
memverifikasi kode di database.

## Deploy

Aplikasi memakai routing history, jadi hosting perlu mengarahkan semua path ke `index.html`
(agar `/admin` bisa dibuka langsung). Sudah disiapkan `public/_redirects` (Netlify/Cloudflare Pages)
dan `vercel.json` (Vercel).

## Struktur

- `src/data/questions.js` — 8 bagian x 7 pernyataan, skala 5 skor, fungsi hitung skor
- `src/views/TestView.vue` — alur untuk orang tua; `src/views/AdminView.vue` — laporan admin
- `src/components/` — IdentityStep, InstructionStep, QuestionStep, ResultStep, FloatingShapes, Confetti
- `src/lib/supabase.js` — simpan hasil + pemanggilan fungsi admin

## Skala skor

| Skor | Label | Arti |
| ---- | ----- | ---- |
| 1 | STS | Sangat Tidak Setuju |
| 2 | TS | Tidak Setuju |
| 3 | AS | Agak Setuju |
| 4 | S | Setuju |
| 5 | SS | Sangat Setuju |

Skor maksimal per bagian: 7 x 5 = 35.
