<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  open: { type: Boolean, default: false },
  section: { type: Object, default: null }, // null = tambah baru
  questionCount: { type: Number, default: 0 },
  saving: { type: Boolean, default: false },
  error: { type: String, default: "" },
});
const emit = defineEmits(["close", "save", "delete"]);

const COLORS = [
  "#7c3aed",
  "#ec4899",
  "#0ea5e9",
  "#10b981",
  "#f59e0b",
  "#f43f5e",
  "#6366f1",
  "#14b8a6",
];

const form = ref({ code: "", title: "", short: "", emoji: "⭐", color: COLORS[0] });
const confirmDelete = ref(false);
const isEdit = computed(() => !!props.section);
const valid = computed(
  () =>
    form.value.code.trim() &&
    form.value.title.trim() &&
    form.value.short.trim() &&
    form.value.emoji.trim(),
);

watch(
  () => props.open,
  (o) => {
    if (!o) return;
    confirmDelete.value = false;
    form.value = props.section
      ? {
          code: props.section.code,
          title: props.section.title,
          short: props.section.short,
          emoji: props.section.emoji,
          color: props.section.color,
        }
      : { code: "", title: "", short: "", emoji: "⭐", color: COLORS[0] };
  },
  { immediate: true },
);

function submit() {
  if (!valid.value || props.saving) return;
  emit("save", {
    code: form.value.code.trim().toUpperCase(),
    title: form.value.title.trim(),
    short: form.value.short.trim(),
    emoji: form.value.emoji.trim(),
    color: form.value.color,
    isNew: !isEdit.value,
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
        <h2>{{ isEdit ? "Ubah Bagian" : "Tambah Bagian" }}</h2>

        <div class="row">
          <label class="field">
            <span>Kode</span>
            <input
              v-model="form.code"
              class="f-input"
              maxlength="6"
              placeholder="A"
              :disabled="isEdit"
            />
          </label>
          <label class="field emoji">
            <span>Emoji</span>
            <input v-model="form.emoji" class="f-input" maxlength="4" />
          </label>
        </div>

        <label class="field">
          <span>Judul bagian</span>
          <input
            v-model="form.title"
            class="f-input"
            placeholder="Contoh: Kecerdasan Visual & Seni"
          />
        </label>

        <label class="field">
          <span>Nama singkat (untuk grafik &amp; tabel)</span>
          <input
            v-model="form.short"
            class="f-input"
            maxlength="14"
            placeholder="Contoh: Seni"
          />
        </label>

        <div class="field">
          <span>Warna</span>
          <div class="colors">
            <button
              v-for="c in COLORS"
              :key="c"
              type="button"
              class="dot"
              :class="{ on: form.color === c }"
              :style="{ background: c }"
              :aria-label="c"
              @click="form.color = c"
            />
            <input v-model="form.color" type="color" class="picker" />
          </div>
        </div>

        <p v-if="error" class="err">{{ error }}</p>

        <div class="actions">
          <div v-if="isEdit" class="danger">
            <template v-if="!confirmDelete">
              <button
                type="button"
                class="btn-s del"
                @click="confirmDelete = true"
              >
                Hapus bagian
              </button>
            </template>
            <template v-else>
              <span class="warn">
                {{ questionCount }} pertanyaan ikut terhapus. Yakin?
              </span>
              <button
                type="button"
                class="btn-s del solid"
                :disabled="saving"
                @click="emit('delete', section)"
              >
                Ya, hapus
              </button>
              <button type="button" class="btn-s" @click="confirmDelete = false">
                Batal
              </button>
            </template>
          </div>
          <span v-else />
          <div class="right">
            <button type="button" class="btn-s" @click="emit('close')">
              Tutup
            </button>
            <button class="btn-p" :disabled="!valid || saving">
              {{ saving ? "Menyimpan..." : "Simpan" }}
            </button>
          </div>
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
.row {
  display: grid;
  grid-template-columns: 1fr 100px;
  gap: 12px;
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
.f-input:disabled {
  background: #f8f6fc;
  color: #9a97b3;
}
.f-input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 4px rgba(124, 58, 237, 0.12);
}
.emoji .f-input {
  text-align: center;
  font-size: 1.2rem;
}
.colors {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.dot {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 3px solid #fff;
  box-shadow: 0 0 0 1.5px #e4def2;
  cursor: pointer;
  transition: transform 0.15s;
}
.dot:hover {
  transform: scale(1.12);
}
.dot.on {
  box-shadow: 0 0 0 2.5px #1f1b3a;
}
.picker {
  width: 34px;
  height: 30px;
  border: 0;
  padding: 0;
  background: none;
  cursor: pointer;
}
.err {
  margin: 0;
  color: #e11d48;
  font-weight: 700;
  font-size: 0.88rem;
}
.actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 4px;
}
.right,
.danger {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.warn {
  font-weight: 700;
  font-size: 0.82rem;
  color: #be123c;
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
.btn-s:hover:not(:disabled) {
  border-color: #a78bfa;
  background: #faf5ff;
}
.btn-s.del {
  color: #be123c;
  border-color: #fecdd3;
}
.btn-s.del.solid {
  background: #e11d48;
  color: #fff;
  border-color: #e11d48;
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