<script setup>
import { computed, onMounted, ref } from "vue";
import SectionSidebar from "../components/admin/SectionSidebar.vue";
import QuestionTable from "../components/admin/QuestionTable.vue";
import QuestionFormModal from "../components/admin/QuestionFormModal.vue";
import SectionFormModal from "../components/admin/SectionFormModal.vue";
import {
  adminSections,
  adminQuestions,
  adminSaveSection,
  adminDeleteSection,
  adminSaveQuestion,
  adminDeleteQuestion,
  adminReorderQuestions,
  WrongCodeError,
} from "../lib/adminQuestionsApi.js";

const props = defineProps({
  code: { type: String, required: true }, // kode akses admin
});
const emit = defineEmits(["unauthorized"]);

const sections = ref([]);
const questions = ref([]);
const loading = ref(false);
const error = ref("");
const busyId = ref(null);

const activeCode = ref("");
const search = ref("");
const onlyInactive = ref(false);

// modal pertanyaan
const qModal = ref(false);
const qEditing = ref(null);
const qSaving = ref(false);
const qError = ref("");

// modal bagian
const sModal = ref(false);
const sEditing = ref(null);
const sSaving = ref(false);
const sError = ref("");

// hapus pertanyaan
const qDeleting = ref(null);
const deletingBusy = ref(false);

const sectionByCode = computed(() =>
  Object.fromEntries(sections.value.map((s) => [s.code, s])),
);
const counts = computed(() => {
  const c = {};
  for (const q of questions.value)
    c[q.section_code] = (c[q.section_code] || 0) + 1;
  return c;
});
const activeSection = computed(() => sectionByCode.value[activeCode.value]);

const visible = computed(() => {
  const q = search.value.trim().toLowerCase();
  return questions.value
    .filter((x) => !activeCode.value || x.section_code === activeCode.value)
    .filter((x) => !q || x.text.toLowerCase().includes(q))
    .filter((x) => !onlyInactive.value || x.active === false)
    .sort((a, b) => {
      const sa = sections.value.findIndex((s) => s.code === a.section_code);
      const sb = sections.value.findIndex((s) => s.code === b.section_code);
      return sa - sb || (a.sort_order ?? 0) - (b.sort_order ?? 0);
    });
});

function handle(e, fallback) {
  if (e instanceof WrongCodeError) {
    emit("unauthorized");
    return "";
  }
  console.error(e);
  return e?.friendly || fallback;
}

async function load() {
  loading.value = true;
  error.value = "";
  try {
    const [s, q] = await Promise.all([
      adminSections(props.code),
      adminQuestions(props.code),
    ]);
    sections.value = s || [];
    questions.value = q || [];
  } catch (e) {
    error.value = handle(e, "Gagal memuat bank soal.");
  } finally {
    loading.value = false;
  }
}
onMounted(load);

/* ---------- pertanyaan ---------- */
function addQuestion() {
  qEditing.value = null;
  qError.value = "";
  qModal.value = true;
}
function editQuestion(q) {
  qEditing.value = q;
  qError.value = "";
  qModal.value = true;
}
async function saveQuestion(payload) {
  qSaving.value = true;
  qError.value = "";
  try {
    if (!payload.id) {
      const inSection = questions.value.filter(
        (x) => x.section_code === payload.section_code,
      );
      payload.sort_order =
        Math.max(0, ...inSection.map((x) => x.sort_order ?? 0)) + 1;
    }
    await adminSaveQuestion(props.code, payload);
    qModal.value = false;
    await load();
  } catch (e) {
    qError.value = handle(e, "Gagal menyimpan pertanyaan.");
  } finally {
    qSaving.value = false;
  }
}
async function toggleQuestion(q) {
  busyId.value = q.id;
  try {
    const next = { ...q, active: q.active === false };
    await adminSaveQuestion(props.code, next);
    q.active = next.active;
  } catch (e) {
    error.value = handle(e, "Gagal mengubah status.");
  } finally {
    busyId.value = null;
  }
}
async function moveQuestion(q, dir) {
  const siblings = questions.value
    .filter((x) => x.section_code === q.section_code)
    .sort((a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0));
  const i = siblings.findIndex((x) => x.id === q.id);
  const j = i + dir;
  if (j < 0 || j >= siblings.length) return;
  [siblings[i], siblings[j]] = [siblings[j], siblings[i]];
  siblings.forEach((x, n) => (x.sort_order = n + 1));
  try {
    await adminReorderQuestions(
      props.code,
      siblings.map((x) => ({ id: x.id, sort_order: x.sort_order })),
    );
  } catch (e) {
    error.value = handle(e, "Gagal mengubah urutan.");
    await load();
  }
}
async function confirmDeleteQuestion() {
  if (!qDeleting.value) return;
  deletingBusy.value = true;
  try {
    await adminDeleteQuestion(props.code, qDeleting.value.id);
    questions.value = questions.value.filter(
      (x) => x.id !== qDeleting.value.id,
    );
    qDeleting.value = null;
  } catch (e) {
    error.value = handle(e, "Gagal menghapus pertanyaan.");
  } finally {
    deletingBusy.value = false;
  }
}

/* ---------- bagian ---------- */
function addSection() {
  sEditing.value = null;
  sError.value = "";
  sModal.value = true;
}
function editSection(s) {
  sEditing.value = s;
  sError.value = "";
  sModal.value = true;
}
async function saveSection(payload) {
  if (payload.isNew && sectionByCode.value[payload.code]) {
    sError.value = "Kode bagian sudah dipakai.";
    return;
  }
  sSaving.value = true;
  sError.value = "";
  try {
    const { isNew, ...data } = payload;
    if (isNew) data.sort_order = sections.value.length + 1;
    await adminSaveSection(props.code, data);
    sModal.value = false;
    await load();
  } catch (e) {
    sError.value = handle(e, "Gagal menyimpan bagian.");
  } finally {
    sSaving.value = false;
  }
}
async function removeSection(s) {
  sSaving.value = true;
  try {
    await adminDeleteSection(props.code, s.code);
    sModal.value = false;
    if (activeCode.value === s.code) activeCode.value = "";
    await load();
  } catch (e) {
    sError.value = handle(e, "Gagal menghapus bagian.");
  } finally {
    sSaving.value = false;
  }
}
</script>

<template>
  <div class="qv">
    <p v-if="error" class="err-box">{{ error }}</p>

    <div class="layout">
      <SectionSidebar
        :sections="sections"
        :counts="counts"
        :total="questions.length"
        :active-code="activeCode"
        @select="activeCode = $event"
        @add="addSection"
        @edit="editSection"
      />

      <section class="panel">
        <div class="head">
          <div>
            <h2>
              {{
                activeSection
                  ? `${activeSection.emoji} ${activeSection.title}`
                  : "📚 Semua soal"
              }}
            </h2>
            <p class="hint">
              Skor tiap pertanyaan 1–5. Pertanyaan nonaktif tidak tampil di
              kuesioner.
            </p>
          </div>
          <button
            class="btn-p"
            :disabled="!sections.length"
            @click="addQuestion"
          >
            + Tambah pertanyaan
          </button>
        </div>

        <div class="filters">
          <input
            v-model="search"
            class="f-input"
            placeholder="Cari teks pertanyaan..."
          />
          <label class="chk">
            <input v-model="onlyInactive" type="checkbox" />
            Hanya nonaktif
          </label>
          <button class="btn-s" :disabled="loading" @click="load">
            {{ loading ? "Memuat..." : "↻ Muat ulang" }}
          </button>
          <span class="count">{{ visible.length }} pertanyaan</span>
        </div>

        <QuestionTable
          :questions="visible"
          :section-by-code="sectionByCode"
          :show-section="!activeCode"
          :busy-id="busyId"
          @edit="editQuestion"
          @delete="qDeleting = $event"
          @toggle="toggleQuestion"
          @move="moveQuestion"
        />
        <p v-if="!activeCode" class="legend">
          Pilih satu bagian di kiri untuk mengatur urutan pertanyaan.
        </p>
      </section>
    </div>

    <QuestionFormModal
      :open="qModal"
      :question="qEditing"
      :sections="sections"
      :default-section="activeCode"
      :saving="qSaving"
      :error="qError"
      @close="qModal = false"
      @save="saveQuestion"
    />
    <SectionFormModal
      :open="sModal"
      :section="sEditing"
      :question-count="sEditing ? counts[sEditing.code] || 0 : 0"
      :saving="sSaving"
      :error="sError"
      @close="sModal = false"
      @save="saveSection"
      @delete="removeSection"
    />

    <Transition name="fade">
      <div v-if="qDeleting" class="overlay" @click.self="qDeleting = null">
        <div class="modal small" role="dialog" aria-modal="true">
          <h2>Hapus pertanyaan?</h2>
          <p class="quote">“{{ qDeleting.text }}”</p>
          <p class="hint">
            Jawaban lama yang sudah tersimpan tidak berubah. Pertimbangkan
            menonaktifkan saja bila ragu.
          </p>
          <div class="actions">
            <button class="btn-s" @click="qDeleting = null">Batal</button>
            <button
              class="btn-s del solid"
              :disabled="deletingBusy"
              @click="confirmDeleteQuestion"
            >
              {{ deletingBusy ? "Menghapus..." : "Ya, hapus" }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.qv {
  display: grid;
  gap: 16px;
}
.layout {
  display: grid;
  /* Mengizinkan sidebar merenggang sesuai teks, dengan batas min 260px */
  grid-template-columns: minmax(260px, auto) 1fr; 
  gap: 16px;
  align-items: start;
}
.panel {
  background: #fff;
  border: 1px solid #ece7f7;
  border-radius: 18px;
  padding: 18px;
  min-width: 0;
}
.head {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 14px;
}
.head h2 {
  font-size: 1.15rem;
}
.hint {
  margin: 4px 0 0;
  color: #6b6a86;
  font-weight: 600;
  font-size: 0.84rem;
}
.err-box {
  background: #fff1f2;
  color: #be123c;
  border-radius: 12px;
  padding: 10px 14px;
  font-weight: 700;
  margin: 0;
}
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-bottom: 14px;
}
.f-input {
  height: 40px;
  border: 1.5px solid #e4def2;
  border-radius: 10px;
  padding: 0 12px;
  font: inherit;
  font-size: 0.88rem;
  background: #fff;
  flex: 1;
  min-width: 220px;
}
.f-input:focus {
  outline: none;
  border-color: #7c3aed;
}
.chk {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 700;
  font-size: 0.84rem;
  cursor: pointer;
}
.chk input {
  accent-color: #7c3aed;
}
.count {
  margin-left: auto;
  font-weight: 800;
  color: #7c3aed;
  font-size: 0.88rem;
}
.legend {
  margin: 12px 0 0;
  color: #9a97b3;
  font-size: 0.78rem;
  font-weight: 600;
}
.btn-s {
  font: inherit;
  font-weight: 700;
  font-size: 0.85rem;
  background: #fff;
  border: 1.5px solid #e4def2;
  color: #34304f;
  border-radius: 10px;
  padding: 8px 14px;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-s:hover:not(:disabled) {
  border-color: #a78bfa;
  background: #faf5ff;
}
.btn-s:disabled {
  opacity: 0.45;
  cursor: not-allowed;
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
  padding: 9px 18px;
  cursor: pointer;
  background: linear-gradient(120deg, #7c3aed, #ec4899);
  transition: transform 0.15s;
}
.btn-p:hover:not(:disabled) {
  transform: translateY(-1px);
}
.btn-p:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* modal hapus */
.overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  background: rgba(31, 27, 58, 0.55);
  backdrop-filter: blur(3px);
  display: grid;
  place-items: center;
  padding: 16px;
}
.modal {
  background: #fff;
  width: 100%;
  max-width: 440px;
  border-radius: 22px;
  padding: 26px 24px;
  display: grid;
  gap: 10px;
  animation: pop 0.35s cubic-bezier(0.2, 1.2, 0.4, 1);
}
@keyframes pop {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.96);
  }
}
.modal h2 {
  font-size: 1.3rem;
}
.quote {
  margin: 0;
  background: #faf8ff;
  border-radius: 12px;
  padding: 10px 14px;
  font-weight: 700;
  font-size: 0.9rem;
}
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 6px;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 860px) {
  .layout {
    grid-template-columns: 1fr;
  }
}
</style>
