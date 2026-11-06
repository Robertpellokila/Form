<script setup>
import { SCALE } from '../data/questions.js'
defineEmits(['next'])

const tips = [
  { e: '🎈', c: '#ec4899', t: 'Ini bukan ujian', d: 'Tidak ada jawaban benar atau salah. Nikmati prosesnya.' },
  { e: '🎯', c: '#7c3aed', t: 'Jawab sesuai kondisi saat ini', d: 'Pilih yang paling menggambarkan anak Anda sekarang, bukan yang diharapkan.' },
  { e: '👨‍👩‍👧', c: '#0ea5e9', t: 'Boleh ditemani anak', d: 'Anda dapat mengisi bersama anak, terutama untuk hal-hal yang ia sukai.' },
  { e: '⏱️', c: '#f59e0b', t: 'Tanpa batas waktu', d: 'Kerjakan dengan santai agar hasilnya akurat.' },
]
</script>

<template>
  <section class="card">
    <div class="head">
      <div class="bulb">💡</div>
      <h2>Panduan Pengisian</h2>
      <p>Baca sebentar ya, Ayah &amp; Bunda.</p>
    </div>

    <ul class="tips">
      <li v-for="(tip, i) in tips" :key="tip.t" class="rise" :style="{ '--i': i, '--c': tip.c }">
        <span class="ico">{{ tip.e }}</span>
        <div>
          <strong>{{ tip.t }}</strong>
          <span>{{ tip.d }}</span>
        </div>
      </li>
    </ul>

    <p class="label">5 pilihan jawaban</p>
    <div class="scale">
      <div v-for="(s, i) in SCALE" :key="s.v" class="scale-item rise" :style="{ '--i': i + 4, '--c': s.color }">
        <span class="emoji">{{ s.emoji }}</span>
        <span class="lbl">{{ s.label }}</span>
        <span class="full">{{ s.full }}</span>
        <span class="v">Skor {{ s.v }}</span>
      </div>
    </div>

    <button class="btn btn-primary btn-block" @click="$emit('next')">Saya Mengerti, Lanjut →</button>
  </section>
</template>

<style scoped>
.head { text-align: center; }
.bulb { font-size: 2.6rem; animation: bob 2.4s ease-in-out infinite; display: inline-block; }
.head h2 { font-size: 1.7rem; }
.head p { color: var(--muted); margin: 4px 0 0; font-weight: 600; }
.tips { list-style: none; padding: 0; margin: 20px 0; display: grid; gap: 10px; }
.tips li { display: flex; gap: 14px; align-items: center; padding: 12px 14px; border-radius: 16px; background: color-mix(in srgb, var(--c) 9%, #fff); border: 2px solid color-mix(in srgb, var(--c) 25%, #fff); }
.ico { flex-shrink: 0; width: 44px; height: 44px; border-radius: 14px; background: #fff; display: grid; place-items: center; font-size: 1.4rem; box-shadow: 0 6px 14px -6px var(--c); }
.tips li:hover .ico { animation: wiggle 0.5s; }
.tips strong { display: block; color: var(--ink); }
.tips span:not(.ico) { color: var(--muted); font-size: 0.9rem; font-weight: 600; }
.label { font-family: 'Fredoka', sans-serif; font-weight: 600; font-size: 1.05rem; color: var(--ink); margin: 0 0 10px; }
.scale { display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px; margin-bottom: 22px; }
.scale-item { border: 2px solid color-mix(in srgb, var(--c) 45%, #fff); background: color-mix(in srgb, var(--c) 10%, #fff); border-radius: 16px; padding: 10px 4px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 2px; transition: transform 0.2s cubic-bezier(0.3, 1.5, 0.5, 1); }
.scale-item:hover { transform: translateY(-4px) scale(1.04); }
.emoji { font-size: 1.8rem; }
.lbl { font-weight: 900; color: var(--ink); }
.full { font-size: 0.66rem; color: var(--muted); line-height: 1.25; min-height: 2.5em; font-weight: 700; }
.v { font-size: 0.66rem; font-weight: 800; color: var(--ink); background: #fff; border-radius: 999px; padding: 2px 8px; }
@media (max-width: 460px) { .full { font-size: 0.58rem; } .emoji { font-size: 1.5rem; } }
</style>
