// Skala jawaban: 5 skor (diisi oleh orang tua)
export const SCALE = [
  { v: 1, label: 'STS', full: 'Sangat Tidak Setuju', emoji: '😟', color: '#f43f5e' },
  { v: 2, label: 'TS', full: 'Tidak Setuju', emoji: '🙁', color: '#fb923c' },
  { v: 3, label: 'AS', full: 'Agak Setuju', emoji: '😐', color: '#eab308' },
  { v: 4, label: 'S', full: 'Setuju', emoji: '🙂', color: '#22c55e' },
  { v: 5, label: 'SS', full: 'Sangat Setuju', emoji: '🤩', color: '#0ea5e9' },
]

export const QUESTIONS_PER_SECTION = 7
export const MAX_PER_SECTION = QUESTIONS_PER_SECTION * 5

// 8 jenis kecerdasan x 7 pernyataan = 56 pernyataan
export const SECTIONS = [
  {
    code: 'VB',
    key: 'verbal',
    title: 'Kecerdasan Bahasa / Verbal',
    short: 'Bahasa / Verbal',
    emoji: '📚',
    color: '#6366f1',
    description: 'Suka kata-kata, cerita, membaca, dan menulis.',
    talent: 'Ananda unggul dalam berbahasa. Cocok dikembangkan menjadi penulis, pencerita, presenter, atau jurnalis.',
    questions: [
      'Anak saya sangat suka membaca buku.',
      'Anak saya suka bercerita, termasuk cerita dongeng dan cerita yang lucu.',
      'Anak saya memiliki ingatan yang baik untuk hal-hal yang sepele.',
      'Anak saya menyukai permainan kata (seperti teka-teki silang, scrabble, atau puzzle).',
      'Anak saya suka menyatakan atau menuliskan ide-idenya.',
      'Di waktu luang, anak saya sering membaca buku.',
      'Anak saya suka berdiskusi dan bertukar pikiran dengan teman.',
    ],
  },
  {
    code: 'LM',
    key: 'logical',
    title: 'Kecerdasan Logika / Matematika',
    short: 'Logika / Matematika',
    emoji: '🔢',
    color: '#0ea5e9',
    description: 'Suka angka, berpikir runtut, dan memecahkan masalah.',
    talent: 'Ananda unggul dalam berpikir logis. Cocok dikembangkan menjadi ilmuwan, programmer, insinyur, atau ahli hitung.',
    questions: [
      'Anak saya sangat menikmati pelajaran matematika.',
      'Anak saya menyukai permainan yang menggunakan angka.',
      'Pelajaran IPA menyenangkan bagi anak saya.',
      'Anak saya menyukai permainan yang membutuhkan strategi untuk menang.',
      'Anak saya senang mencari tahu bagaimana cara kerja setiap benda.',
      'Anak saya menyukai komputer dan berbagai permainan angka.',
      'Anak saya suka bermain catur, checkers, atau monopoli.',
    ],
  },
  {
    code: 'VS',
    key: 'visual',
    title: 'Kecerdasan Visual / Ruang',
    short: 'Visual / Ruang',
    emoji: '🎨',
    color: '#a855f7',
    description: 'Suka gambar, warna, peta, dan membayangkan bentuk.',
    talent: 'Ananda unggul dalam melihat dan membayangkan bentuk. Cocok dikembangkan menjadi desainer, arsitek, pelukis, atau fotografer.',
    questions: [
      'Anak saya lebih suka dijelaskan dengan gambar daripada secara lisan atau mendengarkan.',
      'Anak saya lebih memilih peta daripada petunjuk tertulis untuk mencari sebuah alamat.',
      'Anak saya senang menggambar.',
      'Anak saya senang membuat coretan di kertas kapan pun ia bisa.',
      'Ketika membaca majalah, anak saya lebih suka melihat gambar daripada membaca teksnya.',
      'Jika sesuatu rusak dan tidak berfungsi, anak saya cenderung mempelajari cara kerjanya.',
      'Dalam kerja kelompok, anak saya lebih memilih menggambar hal-hal yang penting.',
    ],
  },
  {
    code: 'BK',
    key: 'bodily',
    title: 'Kecerdasan Kinestetik /Gerak Tubuh',
    short: 'Kinestetik / Gerak',
    emoji: '⚽',
    color: '#f97316',
    description: 'Suka bergerak, olahraga, menari, dan membuat sesuatu dengan tangan.',
    talent: 'Ananda unggul dalam menggunakan gerak tubuh. Cocok dikembangkan menjadi atlet, penari, pengrajin, atau dokter bedah.',
    questions: [
      'Anak saya suka pelajaran olahraga.',
      'Anak saya lebih banyak melakukan aktivitas daripada berbicara saja.',
      'Anak saya suka aktivitas di luar rumah.',
      'Anak saya mudah mempelajari olahraga atau tarian baru.',
      'Anak saya suka membuat prakarya (membuat patung, menjahit, memahat kayu).',
      'Bila melihat sesuatu yang menarik, anak saya ingin memegangnya.',
      'Anak saya tidak suka duduk diam terlalu lama.',
    ],
  },
  {
    code: 'MS',
    key: 'musical',
    title: 'Kecerdasan Musik',
    short: 'Musik',
    emoji: '🎵',
    color: '#f43f5e',
    description: 'Suka nada, irama, lagu, dan bunyi-bunyian.',
    talent: 'Ananda peka terhadap nada dan irama. Cocok dikembangkan menjadi penyanyi, pemusik, komposer, atau dirigen.',
    questions: [
      'Anak saya suka mendengarkan musik.',
      'Anak saya bersenandung saat melakukan sesuatu.',
      'Anak saya bisa bernyanyi atau memainkan alat musik dengan baik.',
      'Anak saya bisa menghafal nada dari banyak lagu.',
      'Di waktu santai, anak saya sering mendengarkan musik.',
      'Jika harus mengingat sesuatu, anak saya mencoba membuat irama tentang hal tersebut.',
      'Anak saya tahu banyak mengenai musik.',
    ],
  },
  {
    code: 'IR',
    key: 'interpersonal',
    title: 'Kecerdasan Interpersonal',
    short: 'Interpersonal',
    emoji: '🤝',
    color: '#10b981',
    description: 'Suka berteman, bekerja sama, dan memahami perasaan orang lain.',
    talent: 'Ananda pandai bergaul dan memahami orang lain. Cocok dikembangkan menjadi guru, pemimpin, psikolog, atau diplomat.',
    questions: [
      'Anak saya merasa sedih apabila ada teman yang sedang kesusahan.',
      'Anak saya mempunyai banyak teman baik.',
      'Anak saya lebih suka bermain dengan kelompok daripada bermain sendiri.',
      'Jika harus mengingat sesuatu, anak saya meminta seseorang untuk mengetes apakah ia sudah memahaminya.',
      'Anak saya senang berkumpul dengan teman.',
      'Teman-temannya sering meminta saran atau ide dari anak saya.',
      'Anak saya mudah menyelesaikan permasalahan antara dirinya dengan teman-temannya.',
    ],
  },
  {
    code: 'IA',
    key: 'intrapersonal',
    title: 'Kecerdasan Intrapersonal',
    short: 'Intrapersonal',
    emoji: '🧘',
    color: '#14b8a6',
    description: 'Suka merenung, mengenal diri sendiri, dan bekerja mandiri.',
    talent: 'Ananda mengenal dirinya dengan baik. Cocok dikembangkan menjadi peneliti, penulis, konselor, atau pengusaha.',
    questions: [
      'Anak saya suka bekerja sendirian tanpa gangguan orang lain.',
      'Anak saya suka menulis buku harian.',
      'Anak saya tidak suka keramaian.',
      'Anak saya tahu kelebihan dan kekurangan dirinya.',
      'Anak saya lebih suka menyelesaikan sendiri masalah yang sedang dihadapinya.',
      'Bila sedang banyak masalah, anak saya lebih suka menyendiri.',
      'Anak saya tidak mudah terpengaruh atau ikut-ikutan dengan orang lain.',
    ],
  },
  {
    code: 'NT',
    key: 'naturalistic',
    title: 'Kecerdasan Naturalistik',
    short: 'Naturalistik',
    emoji: '🌿',
    color: '#84cc16',
    description: 'Suka hewan, tumbuhan, dan alam sekitar.',
    talent: 'Ananda dekat dengan alam. Cocok dikembangkan menjadi dokter hewan, ahli biologi, petani modern, atau penjaga hutan.',
    questions: [
      'Anak saya suka memperhatikan kehidupan alam semesta.',
      'Anak saya menyukai binatang.',
      'Anak saya suka berkebun.',
      'Anak saya suka membaca tentang dunia binatang.',
      'Anak saya suka mempelajari nama-nama makhluk hidup (seperti bunga, pohon, binatang).',
      'Anak saya sangat memperhatikan sekeliling dan apa yang sedang terjadi di sekitarnya.',
      'Anak saya senang berjalan-jalan di taman dan melihat pohon serta bunga.',
    ],
  },
].map((s) => ({
  ...s,
  questions: s.questions.map((text, i) => ({ id: `${s.code}-${i + 1}`, text })),
}))

export const TOTAL_QUESTIONS = SECTIONS.reduce((n, s) => n + s.questions.length, 0)

/** Hitung skor per bagian dan bakat teratas (bisa lebih dari satu jika seri). */
export function calculateResult(answers) {
  const scores = SECTIONS.map((s) => {
    const total = s.questions.reduce((sum, q) => sum + (answers[q.id] || 0), 0)
    return {
      code: s.code,
      key: s.key,
      title: s.title,
      short: s.short,
      emoji: s.emoji,
      color: s.color,
      talent: s.talent,
      total,
      max: MAX_PER_SECTION,
      percent: Math.round((total / MAX_PER_SECTION) * 100),
    }
  })
  const best = Math.max(...scores.map((s) => s.total))
  const tops = scores.filter((s) => s.total === best)
  return { scores, tops }
}
