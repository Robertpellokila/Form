<script setup>
import { ref } from 'vue'
import { SECTIONS, TOTAL_QUESTIONS } from '../data/questions.js'

const props = defineProps({
  identity: { type: Object, required: true },
  sectionsCount: { type: Number, default: 8 },
})
const emit = defineEmits(['start'])

const MIN_AGE = 7
const error = ref('')

function start() {
  error.value = ''
  const { parent, name, gender, age, grade } = props.identity
  if (!parent.trim() || !name.trim() || !gender || !age || !String(grade).trim()) {
    error.value = 'Mohon lengkapi semua data terlebih dahulu ya.'
    return
  }
  const n = Number(age)
  if (!Number.isFinite(n) || n < MIN_AGE) {
    error.value = `Tes ini untuk anak usia ${MIN_AGE} tahun ke atas.`
    return
  }
  emit('start')
}
</script>

<template>
  <section class="card intro">
    <div class="hero">
      <div class="emojis" aria-hidden="true">
        <span v-for="(s, i) in SECTIONS" :key="s.code" :style="{ animationDelay: i * 0.15 + 's', background: s.color + '26', borderColor: s.color + '66' }">{{ s.emoji }}</span>
      </div>
      <h1>Selamat datang, Ayah &amp; Bunda! <span class="wave">👋</span></h1>
      <p>Mari kenali minat dan bakat si kecil lewat {{ sectionsCount }} bagian singkat. Jawab sesuai kondisi anak Anda saat ini.</p>
      <div class="chips">
        <span>📝 {{ TOTAL_QUESTIONS }} pernyataan</span>
        <span>⏱️ ± 10 menit</span>
        <span>✅ Tanpa benar/salah</span>
      </div>
    </div>

    <form class="form" @submit.prevent="start">
      <div class="grid-2">
        <div class="field rise" style="--i: 0">
          <label for="parent">Nama Orang Tua / Wali</label>
          <input id="parent" v-model="identity.parent" class="input" placeholder="Contoh: Bunda Sari" autocomplete="off" />
        </div>
        <div class="field rise" style="--i: 1">
          <label for="name">Nama Anak</label>
          <input id="name" v-model="identity.name" class="input" placeholder="Nama lengkap anak" autocomplete="off" />
        </div>
      </div>

      <div class="grid-2">
        <div class="field rise" style="--i: 2">
          <label>Jenis Kelamin Anak</label>
          <div class="seg" role="group" aria-label="Jenis kelamin anak">
            <button type="button" :class="{ on: identity.gender === 'L' }" @click="identity.gender = 'L'">Laki-laki</button>
            <button type="button" :class="{ on: identity.gender === 'P' }" @click="identity.gender = 'P'">Perempuan</button>
          </div>
        </div>
        <div class="field rise" style="--i: 3">
          <label for="age">Usia Anak</label>
          <input id="age" v-model="identity.age" type="number" :min="MIN_AGE" inputmode="numeric" class="input" placeholder="Minimal 7 tahun" />
        </div>
      </div>

      <div class="grid-2">
        <div class="field rise" style="--i: 4">
          <label for="grade">Kelas</label>
          <input id="grade" v-model="identity.grade" class="input" placeholder="Contoh: Kelas 2" autocomplete="off" />
        </div>
        <div class="field rise" style="--i: 5">
          <label for="date">Tanggal Pengisian</label>
          <input id="date" v-model="identity.date" type="date" class="input" />
        </div>
      </div>

      <p v-if="error" class="error" role="alert">{{ error }}</p>
      <button type="submit" class="btn btn-primary btn-block rise" style="--i: 6">Mulai Petualangan →</button>
    </form>
  </section>
</template>

<style scoped>
.intro { padding: 0; overflow: hidden; }
.hero {
  position: relative;
  text-align: center;
  padding: 34px 24px 28px;
  background:
    radial-gradient(circle at 90% 0%, rgba(14, 165, 233, 0.28), transparent 50%),
    radial-gradient(circle at 5% 100%, rgba(245, 158, 11, 0.3), transparent 50%),
    radial-gradient(circle at 50% 0%, rgba(236, 72, 153, 0.2), transparent 55%),
    linear-gradient(135deg, #f5f0ff, #fff1f8);
  border-bottom: 2px dashed #f0dff5;
}
.emojis { display: flex; justify-content: center; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
.emojis span {
  width: 42px; height: 42px; display: grid; place-items: center; font-size: 1.35rem;
  border-radius: 14px; border: 2px solid; animation: bob 2.4s ease-in-out infinite;
}
.hero h1 { font-size: clamp(1.55rem, 5vw, 2.1rem); line-height: 1.2; }
.wave { display: inline-block; transform-origin: 70% 80%; animation: wave 2.2s ease-in-out infinite; }
@keyframes wave { 0%, 60%, 100% { transform: rotate(0); } 10%, 30% { transform: rotate(16deg); } 20%, 40% { transform: rotate(-10deg); } 50% { transform: rotate(10deg); } }
.hero p { margin: 10px auto 0; color: var(--muted); max-width: 500px; line-height: 1.55; font-weight: 600; }
.chips { display: flex; flex-wrap: wrap; justify-content: center; gap: 8px; margin-top: 16px; }
.chips span { background: #fff; border: 2px solid #f0e6ff; border-radius: 999px; padding: 6px 13px; font-size: 0.8rem; font-weight: 800; color: var(--violet); }

.form { padding: 24px 26px 28px; display: flex; flex-direction: column; gap: 16px; }
.seg { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.seg button {
  height: 50px; border-radius: 14px; border: 2px solid var(--line); background: #fff;
  font: inherit; font-weight: 700; color: var(--text); cursor: pointer;
  transition: transform 0.2s cubic-bezier(0.3, 1.5, 0.5, 1), border-color 0.2s, background 0.2s;
}
.seg button:hover { border-color: #c4b0ff; transform: translateY(-1px); }
.seg button.on { border-color: var(--violet); background: var(--primary-soft); color: var(--violet); font-weight: 900; transform: scale(1.03); }
</style>
