<script setup>
import { computed, onMounted } from 'vue'
import { SCALE } from '../data/questions.js'

const props = defineProps({
  section: { type: Object, required: true },
  sectionIdx: { type: Number, required: true },
  totalSections: { type: Number, required: true },
  answers: { type: Object, required: true },
  progress: { type: Number, default: 0 },
})
const emit = defineEmits(['answer', 'prev', 'next', 'submit'])

const isLast = computed(() => props.sectionIdx === props.totalSections - 1)
const allAnswered = computed(() => props.section.questions.every((q) => props.answers[q.id]))
const answeredHere = computed(() => props.section.questions.filter((q) => props.answers[q.id]).length)
const fullLabel = (v) => SCALE.find((s) => s.v === v)?.full

onMounted(() => window.scrollTo({ top: 0, behavior: 'smooth' }))
</script>

<template>
  <div class="wrap">
    <div class="progress card">
      <div class="meta">
        <span>Bagian <strong>{{ sectionIdx + 1 }}</strong> dari {{ totalSections }}</span>
        <span class="pct">{{ progress }}% selesai</span>
      </div>
      <div class="track">
        <div class="fill" :style="{ width: progress + '%' }" />
        <span class="rider" :style="{ left: progress + '%' }">⭐</span>
      </div>
      <div class="steps" aria-hidden="true">
        <i v-for="n in totalSections" :key="n" :class="{ done: n - 1 < sectionIdx, now: n - 1 === sectionIdx }" />
      </div>
    </div>

    <section class="card sec" :style="{ '--sec': section.color }">
      <div class="banner">
        <span class="deco d1" /><span class="deco d2" /><span class="deco d3" />
        <div class="big">{{ section.emoji }}</div>
        <div class="bt">
          <h2>{{ section.title }}</h2>
          <p>{{ section.description }}</p>
        </div>
      </div>

      <div class="questions">
        <div v-for="(q, i) in section.questions" :key="q.id" class="q rise" :class="{ done: answers[q.id] }" :style="{ '--i': i }">
          <div class="q-text">
            <span class="n">{{ answers[q.id] ? '✓' : i + 1 }}</span>
            <p>{{ q.text }}</p>
          </div>
          <div class="opts" role="radiogroup" :aria-label="q.text">
            <button
              v-for="o in SCALE"
              :key="o.v"
              type="button"
              role="radio"
              class="opt"
              :class="{ active: answers[q.id] === o.v }"
              :style="{ '--c': o.color }"
              :aria-checked="answers[q.id] === o.v"
              :aria-label="o.full"
              @click="emit('answer', q.id, o.v)"
            >
              <span class="emoji">{{ o.emoji }}</span>
              <span class="lbl">{{ o.label }}</span>
            </button>
          </div>
          <p class="picked" :class="{ show: answers[q.id] }">{{ answers[q.id] ? fullLabel(answers[q.id]) : ' ' }}</p>
        </div>
      </div>

      <p class="hint">Terjawab {{ answeredHere }} dari {{ section.questions.length }} pernyataan</p>

      <div class="nav">
        <button class="btn btn-ghost" :disabled="sectionIdx === 0" @click="emit('prev')">← Kembali</button>
        <button v-if="isLast" class="btn btn-success grow" :disabled="!allAnswered" @click="emit('submit')">Lihat Hasilnya 🎉</button>
        <button v-else class="btn btn-primary grow" :disabled="!allAnswered" @click="emit('next')">Lanjut →</button>
      </div>
    </section>
  </div>
</template>

<style scoped>
.wrap { display: grid; gap: 14px; }
.progress { padding: 14px 18px 12px; }
.meta { display: flex; justify-content: space-between; font-size: 0.82rem; color: var(--muted); font-weight: 700; margin-bottom: 10px; }
.meta strong { color: var(--ink); }
.pct { color: var(--violet); font-weight: 900; }
.track { position: relative; height: 12px; background: #f3ecff; border-radius: 999px; }
.fill {
  height: 100%; border-radius: 999px; transition: width 0.7s cubic-bezier(0.2, 1, 0.3, 1);
  background: repeating-linear-gradient(115deg, rgba(255,255,255,.28) 0 10px, transparent 10px 20px), linear-gradient(90deg, #7c3aed, #ec4899, #f59e0b);
  background-size: 40px 100%, 100% 100%;
  animation: stripes 1.2s linear infinite;
}
@keyframes stripes { to { background-position: 40px 0, 0 0; } }
.rider { position: absolute; top: 50%; font-size: 1.3rem; transform: translate(-50%, -50%); transition: left 0.7s cubic-bezier(0.2, 1, 0.3, 1); filter: drop-shadow(0 2px 4px rgba(245, 158, 11, 0.6)); animation: tw 1.6s ease-in-out infinite; }
@keyframes tw { 50% { transform: translate(-50%, -62%) rotate(20deg) scale(1.15); } }
.steps { display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; gap: 5px; margin-top: 12px; }
.steps i { height: 5px; border-radius: 3px; background: #ece4f7; transition: background 0.3s; }
.steps i.done { background: #a78bfa; }
.steps i.now { background: var(--pink); animation: blink 1.2s ease-in-out infinite; }
@keyframes blink { 50% { opacity: 0.45; } }

.sec { padding: 0; overflow: hidden; }
.banner {
  position: relative; overflow: hidden; display: flex; align-items: center; gap: 16px; padding: 22px 24px; color: #fff;
  background: linear-gradient(135deg, var(--sec), color-mix(in srgb, var(--sec) 60%, #1e1b4b));
}
.banner h2 { color: #fff; font-size: 1.4rem; line-height: 1.15; }
.banner p { margin: 4px 0 0; font-size: 0.9rem; opacity: 0.95; font-weight: 600; }
.big { flex-shrink: 0; width: 64px; height: 64px; border-radius: 20px; background: rgba(255,255,255,.22); display: grid; place-items: center; font-size: 2.1rem; animation: bob 2.2s ease-in-out infinite; backdrop-filter: blur(2px); }
.bt { position: relative; z-index: 1; }
.deco { position: absolute; border-radius: 50%; background: rgba(255,255,255,.14); }
.d1 { width: 120px; height: 120px; right: -30px; top: -40px; animation: bob 5s ease-in-out infinite; }
.d2 { width: 60px; height: 60px; right: 80px; bottom: -26px; animation: bob 4s ease-in-out infinite reverse; }
.d3 { width: 26px; height: 26px; right: 30px; bottom: 26px; background: rgba(255,255,255,.22); animation: bob 3s ease-in-out infinite; }

.questions { display: grid; gap: 12px; padding: 20px 20px 0; }
.q { border: 2px solid var(--line); border-radius: 18px; padding: 14px; background: #fff; transition: border-color 0.25s, background 0.25s, box-shadow 0.25s; }
.q.done { border-color: color-mix(in srgb, var(--sec) 50%, #fff); background: color-mix(in srgb, var(--sec) 5%, #fff); }
.q-text { display: flex; gap: 10px; }
.q-text p { margin: 0; font-weight: 700; line-height: 1.45; color: var(--ink); }
.n { flex-shrink: 0; width: 26px; height: 26px; border-radius: 9px; background: color-mix(in srgb, var(--sec) 16%, #fff); color: var(--sec); font-weight: 900; display: grid; place-items: center; font-size: 0.8rem; transition: all 0.3s cubic-bezier(0.3, 1.8, 0.5, 1); }
.q.done .n { background: var(--sec); color: #fff; transform: rotate(360deg) scale(1.08); }

.opts { display: grid; grid-template-columns: repeat(5, 1fr); gap: 6px; margin-top: 12px; }
.opt {
  border: 2px solid var(--line); border-radius: 14px; background: #fff; padding: 8px 2px 6px;
  display: flex; flex-direction: column; align-items: center; gap: 1px; cursor: pointer; font: inherit; color: var(--muted);
  transition: transform 0.2s cubic-bezier(0.3, 1.6, 0.5, 1), border-color 0.2s, background 0.2s, box-shadow 0.2s;
}
.opt .emoji { font-size: 1.55rem; filter: grayscale(0.7); opacity: 0.75; transition: all 0.2s; }
.opt .lbl { font-size: 0.72rem; font-weight: 900; }
.opt:hover { border-color: var(--c); transform: translateY(-3px); }
.opt:hover .emoji { filter: none; opacity: 1; transform: scale(1.15); }
.opt.active { border-color: var(--c); background: color-mix(in srgb, var(--c) 18%, #fff); color: var(--ink); box-shadow: 0 8px 18px -8px var(--c); transform: translateY(-3px) scale(1.05); }
.opt.active .emoji { filter: none; opacity: 1; animation: wiggle 0.5s; }

.picked { margin: 8px 0 0; font-size: 0.8rem; font-weight: 800; color: var(--sec); text-align: right; opacity: 0; transform: translateY(-4px); transition: all 0.25s; }
.picked.show { opacity: 1; transform: none; }

.hint { text-align: center; color: var(--muted); font-size: 0.82rem; font-weight: 700; margin: 18px 0 0; }
.nav { display: flex; gap: 12px; padding: 12px 20px 22px; }
.grow { flex: 1; }
@media (max-width: 460px) { .banner { padding: 18px; } .questions { padding: 16px 12px 0; } .nav { padding: 12px 12px 18px; } }
</style>
