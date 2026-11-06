<script setup>
// Bentuk geometris netral (bukan karakter) yang melayang pelan di latar belakang.
const shapes = [
  { t: 'circle', x: 5, y: 14, s: 26, c: '#f9a8d4', d: 9, dl: 0, dx: 24, r: 0 },
  { t: 'ring', x: 90, y: 9, s: 40, c: '#a78bfa', d: 12, dl: 1, dx: -30, r: 90 },
  { t: 'star', x: 12, y: 62, s: 34, c: '#fcd34d', d: 10, dl: 2, dx: 20, r: 180 },
  { t: 'tri', x: 93, y: 58, s: 32, c: '#6ee7b7', d: 11, dl: 0.5, dx: -22, r: 140 },
  { t: 'plus', x: 78, y: 82, s: 28, c: '#7dd3fc', d: 8, dl: 1.5, dx: 18, r: 90 },
  { t: 'squiggle', x: 22, y: 90, s: 56, c: '#fdba74', d: 13, dl: 2.5, dx: -26, r: 20 },
  { t: 'circle', x: 70, y: 28, s: 16, c: '#6ee7b7', d: 7, dl: 3, dx: 14, r: 0 },
  { t: 'star', x: 50, y: 6, s: 22, c: '#f9a8d4', d: 10, dl: 1, dx: -16, r: 120 },
  { t: 'ring', x: 3, y: 38, s: 24, c: '#fcd34d', d: 9, dl: 2, dx: 16, r: 60 },
  { t: 'tri', x: 36, y: 78, s: 20, c: '#a78bfa', d: 12, dl: 0, dx: 20, r: 200 },
  { t: 'plus', x: 60, y: 94, s: 20, c: '#f9a8d4', d: 9, dl: 3, dx: -14, r: 90 },
  { t: 'circle', x: 96, y: 36, s: 22, c: '#fdba74', d: 8, dl: 1.2, dx: -18, r: 0 },
]
</script>

<template>
  <div class="bg" aria-hidden="true">
    <span class="blob b1" />
    <span class="blob b2" />
    <span class="blob b3" />
    <span class="blob b4" />
    <span
      v-for="(s, i) in shapes"
      :key="i"
      class="shape"
      :style="{ left: s.x + '%', top: s.y + '%', width: s.s + 'px', height: s.s + 'px', animationDuration: s.d + 's', animationDelay: -s.dl + 's', '--dx': s.dx + 'px', '--rot': s.r + 'deg' }"
    >
      <svg viewBox="0 0 24 24" width="100%" height="100%">
        <circle v-if="s.t === 'circle'" cx="12" cy="12" r="10" :fill="s.c" />
        <circle v-else-if="s.t === 'ring'" cx="12" cy="12" r="8.5" fill="none" :stroke="s.c" stroke-width="3.5" />
        <path v-else-if="s.t === 'star'" d="m12 2 2.9 6.6 7.1.7-5.3 4.8 1.5 7L12 17.4 5.8 21l1.5-7L2 9.3l7.1-.7z" :fill="s.c" stroke-linejoin="round" />
        <path v-else-if="s.t === 'tri'" d="M12 3 22 20H2z" :fill="s.c" stroke-linejoin="round" />
        <path v-else-if="s.t === 'plus'" d="M10 3h4v7h7v4h-7v7h-4v-7H3v-4h7z" :fill="s.c" />
        <path v-else d="M1 12c3-6 5-6 7 0s4 6 7 0 5-6 8 0" fill="none" :stroke="s.c" stroke-width="3" stroke-linecap="round" />
      </svg>
    </span>
  </div>
</template>

<style scoped>
.bg { position: fixed; inset: 0; z-index: 0; overflow: hidden; pointer-events: none; }
.blob { position: absolute; border-radius: 50%; filter: blur(60px); will-change: transform; }
.b1 { width: 480px; height: 480px; left: -140px; top: -120px; background: #fbcfe8; opacity: 0.7; animation: d1 22s ease-in-out infinite alternate; }
.b2 { width: 440px; height: 440px; right: -140px; top: 10%; background: #bae6fd; opacity: 0.65; animation: d2 28s ease-in-out infinite alternate; }
.b3 { width: 420px; height: 420px; left: 20%; bottom: -180px; background: #fde68a; opacity: 0.65; animation: d3 26s ease-in-out infinite alternate; }
.b4 { width: 360px; height: 360px; right: 10%; bottom: -120px; background: #d9c8ff; opacity: 0.55; animation: d1 30s ease-in-out infinite alternate-reverse; }
@keyframes d1 { to { transform: translate(120px, 90px) scale(1.18); } }
@keyframes d2 { to { transform: translate(-110px, 130px) scale(1.12); } }
@keyframes d3 { to { transform: translate(150px, -90px) scale(1.2); } }

.shape { position: absolute; opacity: 0.75; animation: floaty ease-in-out infinite alternate; }
@keyframes floaty {
  from { transform: translate(0, 0) rotate(0deg); }
  to { transform: translate(var(--dx), -42px) rotate(var(--rot)); }
}
@media print { .bg { display: none; } }
</style>
