<script setup>
import { onMounted, ref } from 'vue'

const colors = ['#7c3aed', '#ec4899', '#f59e0b', '#0ea5e9', '#10b981', '#f43f5e']
const pieces = Array.from({ length: 48 }, (_, i) => ({
  left: (i * 37 + 11) % 100,
  delay: ((i * 7) % 12) * 0.1,
  dur: 3.2 + (i % 5) * 0.55,
  size: 7 + (i % 4) * 3,
  color: colors[i % colors.length],
  round: i % 3 === 0,
  drift: ((i % 7) - 3) * 22,
}))

const visible = ref(true)
onMounted(() => setTimeout(() => (visible.value = false), 7500))
</script>

<template>
  <div v-if="visible" class="confetti" aria-hidden="true">
    <i
      v-for="(p, i) in pieces"
      :key="i"
      :style="{
        left: p.left + '%',
        width: p.size + 'px',
        height: (p.round ? p.size : p.size * 1.6) + 'px',
        background: p.color,
        borderRadius: p.round ? '50%' : '2px',
        animationDelay: p.delay + 's',
        animationDuration: p.dur + 's',
        '--drift': p.drift + 'px',
      }"
    />
  </div>
</template>

<style scoped>
.confetti { position: fixed; inset: 0; z-index: 5; pointer-events: none; overflow: hidden; }
i { position: absolute; top: -20px; opacity: 0; animation: fall linear forwards; }
@keyframes fall {
  0% { opacity: 1; transform: translate(0, -10vh) rotate(0deg); }
  100% { opacity: 0.9; transform: translate(var(--drift), 108vh) rotate(760deg); }
}
@media print { .confetti { display: none; } }
</style>
