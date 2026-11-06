<script setup>
import { computed, reactive, ref } from 'vue'
import { SECTIONS, TOTAL_QUESTIONS, calculateResult } from '../data/questions.js'
import { saveSubmission, supabaseEnabled } from '../lib/supabase.js'
import FloatingShapes from '../components/FloatingShapes.vue'
import IdentityStep from '../components/IdentityStep.vue'
import InstructionStep from '../components/InstructionStep.vue'
import QuestionStep from '../components/QuestionStep.vue'
import ResultStep from '../components/ResultStep.vue'

const step = ref('intro') // intro | instruction | form | done
const sectionIdx = ref(0)
const answers = reactive({})
const today = () => {
  const d = new Date()
  const p = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`
}
const blank = () => ({ parent: '', name: '', gender: '', age: '', grade: '', date: today() })
const identity = reactive(blank())
const result = ref(null)
const saveStatus = ref('idle') // idle | saving | saved | error | disabled

const answeredCount = computed(() => Object.keys(answers).length)
const progress = computed(() => Math.round((answeredCount.value / TOTAL_QUESTIONS) * 100))
const currentSection = computed(() => SECTIONS[sectionIdx.value])
const viewKey = computed(() => (step.value === 'form' ? `form-${currentSection.value.code}` : step.value))

function setAnswer(id, value) {
  answers[id] = value
}

async function finish() {
  result.value = calculateResult(answers)
  step.value = 'done'
  await save()
}

async function save() {
  if (!supabaseEnabled) {
    saveStatus.value = 'disabled'
    return
  }
  saveStatus.value = 'saving'
  try {
    await saveSubmission({ identity, answers, result: result.value })
    saveStatus.value = 'saved'
  } catch (e) {
    console.error(e)
    saveStatus.value = 'error'
  }
}

function reset() {
  Object.keys(answers).forEach((k) => delete answers[k])
  Object.assign(identity, blank())
  sectionIdx.value = 0
  result.value = null
  saveStatus.value = 'idle'
  step.value = 'intro'
  window.scrollTo({ top: 0 })
}
</script>

<template>
  <FloatingShapes />

  <div class="container">
    <header class="brand">
      <div class="logo">
        <svg viewBox="0 0 24 24" width="26" height="26" fill="#fff" stroke="#fff" stroke-width="1.2" stroke-linejoin="round">
          <path d="m12 2.5 2.8 6.2 6.7.7-5 4.5 1.4 6.6L12 17.2 6.1 20.5l1.4-6.6-5-4.5 6.7-.7z" />
        </svg>
      </div>
      <div>
        <div class="brand-title">Petualangan Bakat</div>
        <div class="brand-sub">Tes minat &amp; bakat anak usia 7 tahun ke atas</div>
      </div>
    </header>

    <Transition name="step" mode="out-in">
      <IdentityStep
        v-if="step === 'intro'"
        :key="viewKey"
        :identity="identity"
        :sections-count="SECTIONS.length"
        @start="step = 'instruction'"
      />
      <InstructionStep v-else-if="step === 'instruction'" :key="viewKey" @next="step = 'form'" />
      <QuestionStep
        v-else-if="step === 'form'"
        :key="viewKey"
        :section="currentSection"
        :section-idx="sectionIdx"
        :total-sections="SECTIONS.length"
        :answers="answers"
        :progress="progress"
        @answer="setAnswer"
        @prev="sectionIdx = Math.max(0, sectionIdx - 1)"
        @next="sectionIdx++"
        @submit="finish"
      />
      <ResultStep
        v-else-if="step === 'done' && result"
        :key="viewKey"
        :result="result"
        :identity="identity"
        :save-status="saveStatus"
        @retry="save"
        @reset="reset"
      />
    </Transition>
  </div>
</template>

<style scoped>
.brand { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
.logo {
  width: 50px; height: 50px; display: grid; place-items: center; border-radius: 17px;
  background: var(--brand); box-shadow: 0 10px 22px -6px rgba(236, 72, 153, 0.6);
  animation: bob 3s ease-in-out infinite;
}
.logo svg { animation: spin 9s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.brand-title {
  font-family: 'Fredoka', sans-serif; font-size: 1.35rem; font-weight: 700; line-height: 1.1;
  background: var(--brand); -webkit-background-clip: text; background-clip: text; color: transparent;
}
.brand-sub { font-size: 0.8rem; color: var(--muted); font-weight: 600; margin-top: 2px; }
</style>
