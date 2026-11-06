<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  open: { type: Boolean, default: false },
  question: { type: Object, default: null }, // null = tambah baru
  sections: { type: Array, default: () => [] },
  defaultSection: { type: String, default: "" },
  saving: { type: Boolean, default: false },
  error: { type: String, default: "" },
});
const emit = defineEmits(["close", "save"]);

const form = ref({ section_code: "", text: "", active: true });
const isEdit = computed(() => !!props.question);
const valid = computed(
  () => form.value.section_code && form.value.text.trim().length >= 5,
);

watch(
  () => props.open,
  (o) => {
    if (!o) return;
    form.value = props.question
      ? {
          section_code: props.question.section_code,
          text: props.question.text,
          active: props.question.active !== false,
        }
      : {
          section_code: props.defaultSection || props.sections[0]?.code || "",
          text: "",
          active: true,
        };
  },
  { immediate: true },
);

function submit() {
  if (!valid.value || props.saving) return;
  emit("save", {
    ...(props.question || {}),
    section_code: form.value.section_code,
    text: form.value.text.trim(),
    active: form.value.active,
  });
}
</script>

<template>
  <Transition name="fade">
    <div v-if="open" class="overlay" @click.self="emit('close')">
      <form class="modal" role="dialog" aria-modal="true" @submit.prevent="submit">
        <button type="button" class="x" aria-label="Tutup" @click="emit('close')">
          ✕
        </button>
        <h2>{{ isEdit ? "Ubah Pertanyaan" : "Tambah Pertanyaan" }}</h2>
        <p class="sub">
          Pertanyaan dijawab orang tua dengan skala 1–5.
        </p>

        <label class="field">
          <span>Bagian</span>
          <select v-model="form.section_code" class="f-input">
            <option v-for="s in sections" :key="s.code" :value="s.code">
              {{ s.emoji }} {{ s.title }}
            </option>
          </select>
        </label>

        <label class="field">
          <span>Teks pertanyaan</span>
          <textarea
            v-model="form.text"
            class="f-input area"
            rows="3"
            placeholder="Contoh: Anak senang menggambar atau mewarnai"
          />
        </label>

        <label class="check">
          <input v-model="form.active" type="checkbox" />
          <span>Tampilkan di kuesioner (aktif)</span>
        </label>

        <p v-if="error" class="err">{{ error }}</p>

        <div class="actions">
          <button type="button" class="btn-s" @click="emit('close')">
            Batal
          </button>
          <button class="btn-p" :disabled="!valid || saving">
            {{ saving ? "Menyimpan..." : "Simpan" }}
          </button>
        </div>
      </form>
    </div>
  </Transition>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  background: rgba(31, 27, 58, 0.55);
  backdrop-filter: blur(3px);
  display: grid;
  place-items: center;
  padding: 16px;
  overflow-y: auto;
}
.modal {
  position: relative;
  background: #fff;
  width: 100%;
  max-width: 520px;
  border-radius: 22px;
  padding: 26px 24px;
  display: grid;
  gap: 14px;
  animation: pop 0.35s cubic-bezier(0.2, 1.2, 0.4, 1);
}
@keyframes pop {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.96);
  }
}
.modal h2 {
  font-size: 1.4rem;
  padding-right: 36px;
}
.sub {
  margin: -8px 0 0;
  color: #6b6a86;
  font-weight: 600;
  font-size: 0.88rem;
}
.x {
  position: absolute;
  top: 14px;
  right: 14px;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  border: 0;
  background: #f3f0fa;
  cursor: pointer;
  font-size: 0.9rem;
}
.x:hover {
  background: #e9e2f8;
}
.field {
  display: grid;
  gap: 6px;
}
.field > span {
  font-size: 0.8rem;
  font-weight: 800;
  color: #4b4868;
}
.f-input {
  border: 1.5px solid #e4def2;
  border-radius: 10px;
  padding: 0 12px;
  height: 42px;
  font: inherit;
  font-size: 0.9rem;
  background: #fff;
  width: 100%;
}
.f-input.area {
  height: auto;
  padding: 10px 12px;
  resize: vertical;
  line-height: 1.5;
}
.f-input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 4px rgba(124, 58, 237, 0.12);
}
.check {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  font-size: 0.88rem;
  cursor: pointer;
}
.check input {
  width: 18px;
  height: 18px;
  accent-color: #7c3aed;
}
.err {
  margin: 0;
  color: #e11d48;
  font-weight: 700;
  font-size: 0.88rem;
}
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 4px;
}
.btn-s {
  font: inherit;
  font-weight: 700;
  font-size: 0.85rem;
  background: #fff;
  border: 1.5px solid #e4def2;
  color: #34304f;
  border-radius: 10px;
  padding: 8px 16px;
  cursor: pointer;
}
.btn-s:hover {
  border-color: #a78bfa;
  background: #faf5ff;
}
.btn-p {
  font: inherit;
  font-weight: 800;
  font-size: 0.85rem;
  color: #fff;
  border: 0;
  border-radius: 10px;
  padding: 8px 20px;
  cursor: pointer;
  background: linear-gradient(120deg, #7c3aed, #ec4899);
}
.btn-p:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>