<script setup>
import { computed, onMounted, ref } from 'vue'
import Confetti from './Confetti.vue'

const props = defineProps({
  result: { type: Object, required: true },
  identity: { type: Object, required: true },
  saveStatus: { type: String, default: 'idle' },
})
defineEmits(['reset', 'retry'])

const ready = ref(false)
const counts = ref(props.result.scores.map(() => 0)) // angka persen naik bertahap
const print = () => window.print()

onMounted(() => {
  window.scrollTo({ top: 0 })
  setTimeout(() => (ready.value = true), 150)
  const start = performance.now()
  const dur = 1100
  const tick = (now) => {
    const t = Math.min(1, (now - start) / dur)
    const e = 1 - Math.pow(1 - t, 3)
    counts.value = props.result.scores.map((s) => Math.round(s.percent * e))
    if (t < 1) requestAnimationFrame(tick)
  }
  requestAnimationFrame(tick)
})

const sorted = computed(() =>
  props.result.scores.map((s, i) => ({ ...s, idx: i })).sort((a, b) => b.total - a.total),
)
const topCodes = computed(() => new Set(props.result.tops.map((t) => t.code)))
const isTie = computed(() => props.result.tops.length > 1)

// Radar chart (SVG)
const SIZE = 300
const C = SIZE / 2
const R = 100
const n = computed(() => props.result.scores.length)
const angle = (i) => (Math.PI * 2 * i) / n.value - Math.PI / 2
const point = (i, ratio) => [C + Math.cos(angle(i)) * R * ratio, C + Math.sin(angle(i)) * R * ratio]
const ring = (ratio) => props.result.scores.map((_, i) => point(i, ratio).join(',')).join(' ')
const shape = computed(() => props.result.scores.map((s, i) => point(i, s.total / s.max).join(',')).join(' '))
const labelPos = (i) => point(i, 1.3)
const anchor = (i) => {
  const x = Math.cos(angle(i))
  return Math.abs(x) < 0.2 ? 'middle' : x > 0 ? 'start' : 'end'
}
</script>

<template>
  <div class="wrap">
    <Confetti />

    <section class="card top">
      <div class="medal rise" style="--i: 0" aria-hidden="true">🏆</div>
      <p class="kicker rise" style="--i: 1">{{ isTie ? `${result.tops.length} bakat menonjol` : 'Bakat paling menonjol' }}</p>
      <h1 class="rise" style="--i: 2">
        <template v-for="(t, i) in result.tops" :key="t.code">
          <span class="grad">{{ t.emoji }} {{ t.title }}</span><span v-if="i < result.tops.length - 1" class="amp"> &amp; </span>
        </template>
      </h1>
      <p v-if="isTie" class="note rise" style="--i: 3">Skornya seri, jadi si kecil unggul di beberapa bidang sekaligus.</p>
      <p class="hello rise" style="--i: 3">
        Terima kasih, <strong>{{ identity.parent }}</strong>! Berikut hasil untuk <strong>{{ identity.name }}</strong> 💖
      </p>
      <p v-for="t in result.tops" :key="'tl' + t.code" class="talent rise" style="--i: 4">{{ t.talent }}</p>
    </section>

    <section class="card rise" style="--i: 2">
      <h3 class="title">🕸️ Peta Kecerdasan</h3>
      <svg :viewBox="`-30 -10 ${SIZE + 60} ${SIZE + 20}`" class="radar" role="img" aria-label="Diagram radar skor kecerdasan">
        <polygon v-for="r in [0.25, 0.5, 0.75, 1]" :key="r" :points="ring(r)" fill="none" stroke="#eadff7" />
        <line v-for="(s, i) in result.scores" :key="s.code" :x1="C" :y1="C" :x2="point(i, 1)[0]" :y2="point(i, 1)[1]" stroke="#eadff7" />
        <polygon :points="shape" class="shape" :class="{ in: ready }" />
        <circle
          v-for="(s, i) in result.scores"
          :key="'c' + s.code"
          :cx="point(i, s.total / s.max)[0]"
          :cy="point(i, s.total / s.max)[1]"
          r="5.5"
          :fill="s.color"
          stroke="#fff"
          stroke-width="2"
          class="pt"
          :class="{ in: ready }"
        />
        <text
          v-for="(s, i) in result.scores"
          :key="'t' + s.code"
          :x="labelPos(i)[0]"
          :y="labelPos(i)[1]"
          :text-anchor="anchor(i)"
          dominant-baseline="middle"
          font-size="12"
          font-weight="800"
          :fill="topCodes.has(s.code) ? s.color : '#4b4868'"
        >
          {{ s.emoji }} {{ s.short }}
        </text>
      </svg>
    </section>

    <section class="card rise" style="--i: 3">
      <h3 class="title">📊 Skor per Bagian</h3>
      <div class="rows">
        <div v-for="(s, i) in sorted" :key="s.code" class="row rise" :class="{ top: topCodes.has(s.code) }" :style="{ '--c': s.color, '--i': i + 3 }">
          <div class="row-head">
            <span class="code">{{ s.emoji }}</span>
            <div class="info">
              <strong>{{ s.title }}</strong>
              <small>{{ s.total }} dari {{ s.max }} poin</small>
            </div>
            <span v-if="topCodes.has(s.code)" class="tag">⭐ Teratas</span>
            <span class="pct">{{ counts[s.idx] }}%</span>
          </div>
          <div class="bar">
            <div class="fill" :style="{ width: ready ? s.percent + '%' : '0%', transitionDelay: i * 90 + 'ms' }" />
          </div>
        </div>
      </div>

      <p v-if="saveStatus === 'saving'" class="save">⏳ Menyimpan hasil...</p>
      <p v-else-if="saveStatus === 'saved'" class="save ok">✅ Hasil tersimpan</p>
      <p v-else-if="saveStatus === 'error'" class="save bad">
        Hasil belum tersimpan.
        <button class="link" @click="$emit('retry')">Coba lagi</button>
      </p>

      <div class="actions">
        <button class="btn btn-ghost grow" @click="print">🖨️ Cetak</button>
        <button class="btn btn-primary grow" @click="$emit('reset')">Isi Lagi</button>
      </div>
    </section>
  </div>
</template>

<style scoped>
.wrap { display: grid; gap: 14px; }
.top {
  text-align: center; padding: 34px 24px;
  background:
    radial-gradient(circle at 90% 0%, rgba(14, 165, 233, 0.28), transparent 50%),
    radial-gradient(circle at 0% 100%, rgba(245, 158, 11, 0.3), transparent 50%),
    radial-gradient(circle at 50% 0%, rgba(236, 72, 153, 0.2), transparent 55%),
    linear-gradient(135deg, #f5f0ff, #fff1f8);
}
.medal { font-size: 3.6rem; display: inline-block; animation: bob 2.2s ease-in-out infinite, glow 2.2s ease-in-out infinite; }
@keyframes glow { 50% { filter: drop-shadow(0 8px 14px rgba(245, 158, 11, 0.7)); } }
.kicker { text-transform: uppercase; letter-spacing: 0.16em; font-size: 0.74rem; font-weight: 900; margin: 6px 0; color: var(--violet); }
h1 { font-size: clamp(1.55rem, 5vw, 2.2rem); line-height: 1.25; }
.grad { background: var(--brand); -webkit-background-clip: text; background-clip: text; color: transparent; }
.amp { color: var(--muted); font-weight: 600; }
.note, .hello { margin: 10px 0 0; color: var(--text); font-weight: 600; }
.talent { margin: 10px auto 0; max-width: 480px; color: var(--muted); line-height: 1.55; font-weight: 600; }

.title { font-size: 1.15rem; margin-bottom: 8px; }
.radar { width: 100%; max-width: 460px; display: block; margin: 0 auto; overflow: visible; }
.shape { fill: rgba(124, 58, 237, 0.2); stroke: #7c3aed; stroke-width: 2.5; stroke-linejoin: round; transform-origin: 150px 150px; transform: scale(0) rotate(-40deg); opacity: 0; transition: transform 1.1s cubic-bezier(0.2, 1.1, 0.3, 1), opacity 0.5s; }
.shape.in { transform: scale(1) rotate(0); opacity: 1; }
.pt { opacity: 0; transition: opacity 0.4s 0.8s; }
.pt.in { opacity: 1; }

.rows { display: grid; gap: 10px; }
.row { border: 2px solid color-mix(in srgb, var(--c) 25%, #fff); border-radius: 16px; padding: 12px 14px; background: color-mix(in srgb, var(--c) 6%, #fff); }
.row.top { border-color: var(--c); box-shadow: 0 10px 20px -12px var(--c); }
.row-head { display: flex; align-items: center; gap: 12px; }
.code { width: 40px; height: 40px; border-radius: 13px; display: grid; place-items: center; font-size: 1.25rem; flex-shrink: 0; background: #fff; box-shadow: 0 6px 12px -6px var(--c); }
.info { display: flex; flex-direction: column; flex: 1; min-width: 0; }
.info strong { color: var(--ink); font-size: 0.93rem; }
.info small { color: var(--muted); font-weight: 600; }
.pct { font-family: 'Fredoka', sans-serif; font-weight: 600; font-size: 1.15rem; color: var(--c); min-width: 3ch; text-align: right; }
.tag { font-size: 0.66rem; font-weight: 900; color: #b45309; background: #fef3c7; border-radius: 999px; padding: 3px 9px; white-space: nowrap; }
.bar { height: 10px; background: #fff; border-radius: 999px; margin-top: 10px; overflow: hidden; border: 1px solid color-mix(in srgb, var(--c) 18%, #fff); }
.fill { height: 100%; border-radius: 999px; background: linear-gradient(90deg, var(--c), color-mix(in srgb, var(--c) 60%, #fff)); transition: width 1.1s cubic-bezier(0.2, 1, 0.3, 1); }

.save { text-align: center; margin: 16px 0 0; font-size: 0.86rem; color: var(--muted); font-weight: 700; }
.save.ok { color: #059669; }
.save.bad { color: #e11d48; }
.link { background: none; border: none; color: var(--violet); font: inherit; font-weight: 900; text-decoration: underline; cursor: pointer; }
.actions { display: flex; gap: 12px; margin-top: 20px; }
.grow { flex: 1; }
@media print { .actions, .save { display: none; } }
</style>
