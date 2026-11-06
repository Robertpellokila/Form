<script setup>
import { computed, onMounted, onBeforeUnmount, ref, watch } from "vue";
import { SECTIONS } from "../data/questions.js";
import AdminQuestionsView from "./AdminQuestionsView.vue";
import {
  adminAnswers,
  adminDelete,
  adminReport,
  supabaseEnabled,
  WrongCodeError,
} from "../lib/supabase.js";

const STORE_KEY = "mb-admin-code";
const PAGE_SIZE = 15;

const input = ref("");
const code = ref("");
const authed = ref(false);
const checking = ref(false);
const loading = ref(false);
const activeTab = ref("dashboard");
const error = ref("");
const rows = ref([]);

// filter + sort + paging
const search = ref("");
const filterTop = ref("");
const filterGender = ref("");
const sortKey = ref("created_at");
const sortDir = ref("desc");
const page = ref(1);

// detail
const selected = ref(null);
const detailAnswers = ref([]);
const detailLoading = ref(false);
const detailError = ref("");
const confirmDelete = ref(false);
const deleting = ref(false);

const secByCode = Object.fromEntries(SECTIONS.map((s) => [s.code, s]));

/* ---------- auth ---------- */
async function tryLogin(value, remember = true) {
  error.value = "";
  checking.value = true;
  try {
    const data = await adminReport(value);
    rows.value = data || [];
    code.value = value;
    authed.value = true;
    if (remember) sessionStorage.setItem(STORE_KEY, value);
  } catch (e) {
    sessionStorage.removeItem(STORE_KEY);
    authed.value = false;
    error.value =
      e instanceof WrongCodeError
        ? "Kode akses salah. Coba lagi."
        : "Tidak dapat terhubung ke database. Pastikan migration sudah dijalankan dan .env benar.";
    if (!(e instanceof WrongCodeError)) console.error(e);
  } finally {
    checking.value = false;
  }
}

function submitCode() {
  if (!input.value.trim()) return;
  tryLogin(input.value.trim());
}

function logout() {
  sessionStorage.removeItem(STORE_KEY);
  authed.value = false;
  code.value = "";
  input.value = "";
  rows.value = [];
  selected.value = null;
  activeTab.value = "dashboard";
}

async function reload() {
  loading.value = true;
  error.value = "";
  try {
    rows.value = (await adminReport(code.value)) || [];
  } catch (e) {
    if (e instanceof WrongCodeError) logout();
    else error.value = "Gagal memuat data.";
  } finally {
    loading.value = false;
  }
}

let robots;
onMounted(() => {
  document.title = "Admin — Petualangan Bakat";
  robots = document.createElement("meta");
  robots.name = "robots";
  robots.content = "noindex, nofollow";
  document.head.appendChild(robots);
  const saved = sessionStorage.getItem(STORE_KEY);
  if (saved) tryLogin(saved, false);
});
onBeforeUnmount(() => robots?.remove());

/* ---------- data helpers ---------- */
const scoreOf = (row, secCode) =>
  (row.section_scores || []).find((s) => s.code === secCode) || {
    total: 0,
    max: 35,
    percent: 0,
  };
const fmtDateTime = (iso) =>
  new Date(iso).toLocaleString("id-ID", {
    dateStyle: "medium",
    timeStyle: "short",
  });
const fmtDate = (d) =>
  new Date(d + "T00:00:00").toLocaleDateString("id-ID", {
    dateStyle: "medium",
  });
const genderLabel = (g) =>
  g === "L" ? "Laki-laki" : g === "P" ? "Perempuan" : "-";
const topTitles = (row) =>
  (row.top_codes || []).map((c) => secByCode[c]?.title).filter(Boolean);

/* ---------- ringkasan ---------- */
const totalCount = computed(() => rows.value.length);
const todayCount = computed(() => {
  const t = new Date().toDateString();
  return rows.value.filter((r) => new Date(r.created_at).toDateString() === t)
    .length;
});
const avgAge = computed(() =>
  rows.value.length
    ? (rows.value.reduce((a, r) => a + r.age, 0) / rows.value.length).toFixed(1)
    : "-",
);
const distribution = computed(() => {
  const list = SECTIONS.map((s) => ({
    ...s,
    count: rows.value.filter((r) => (r.top_codes || []).includes(s.code))
      .length,
  }));
  const max = Math.max(1, ...list.map((l) => l.count));
  return list.map((l) => ({ ...l, width: Math.round((l.count / max) * 100) }));
});
const topTalent = computed(() => {
  const best = [...distribution.value].sort((a, b) => b.count - a.count)[0];
  return best && best.count > 0 ? best : null;
});

/* ---------- filter / sort / paging ---------- */
const filtered = computed(() => {
  const q = search.value.trim().toLowerCase();
  let list = rows.value.filter((r) => {
    if (
      q &&
      !`${r.child_name} ${r.parent_name || ""} ${r.grade}`
        .toLowerCase()
        .includes(q)
    )
      return false;
    if (filterTop.value && !(r.top_codes || []).includes(filterTop.value))
      return false;
    if (filterGender.value && r.gender !== filterGender.value) return false;
    return true;
  });
  const dir = sortDir.value === "asc" ? 1 : -1;
  const key = sortKey.value;
  list = [...list].sort((a, b) => {
    const va = key === "child_name" ? a.child_name.toLowerCase() : a[key];
    const vb = key === "child_name" ? b.child_name.toLowerCase() : b[key];
    return va < vb ? -dir : va > vb ? dir : 0;
  });
  return list;
});
const pageCount = computed(() =>
  Math.max(1, Math.ceil(filtered.value.length / PAGE_SIZE)),
);
const paged = computed(() =>
  filtered.value.slice((page.value - 1) * PAGE_SIZE, page.value * PAGE_SIZE),
);
watch(
  [search, filterTop, filterGender, sortKey, sortDir],
  () => (page.value = 1),
);
watch(pageCount, (n) => {
  if (page.value > n) page.value = n;
});

function sortBy(key) {
  if (sortKey.value === key)
    sortDir.value = sortDir.value === "asc" ? "desc" : "asc";
  else {
    sortKey.value = key;
    sortDir.value = key === "child_name" ? "asc" : "desc";
  }
}
const arrow = (key) =>
  sortKey.value === key ? (sortDir.value === "asc" ? "▲" : "▼") : "";

/* ---------- detail ---------- */
async function openDetail(row) {
  selected.value = row;
  detailAnswers.value = [];
  detailError.value = "";
  confirmDelete.value = false;
  detailLoading.value = true;
  try {
    detailAnswers.value = (await adminAnswers(code.value, row.id)) || [];
  } catch (e) {
    detailError.value = "Gagal memuat jawaban.";
  } finally {
    detailLoading.value = false;
  }
}
const closeDetail = () => (selected.value = null);

const answersBySection = computed(() =>
  SECTIONS.map((s) => ({
    ...s,
    items: detailAnswers.value.filter((a) => a.section_code === s.code),
  })).filter((s) => s.items.length),
);

async function doDelete() {
  if (!selected.value) return;
  deleting.value = true;
  try {
    await adminDelete(code.value, selected.value.id);
    rows.value = rows.value.filter((r) => r.id !== selected.value.id);
    selected.value = null;
  } catch (e) {
    detailError.value = "Gagal menghapus data.";
  } finally {
    deleting.value = false;
    confirmDelete.value = false;
  }
}

/* ---------- CSV ---------- */
function exportCsv() {
  const esc = (v) => `"${String(v ?? "").replace(/"/g, '""')}"`;
  const head = [
    "Tanggal Isi",
    "Tanggal Tes",
    "Nama Anak",
    "Orang Tua/Wali",
    "Jenis Kelamin",
    "Usia",
    "Kelas",
    "Bakat Teratas",
    ...SECTIONS.map((s) => `${s.title} (skor)`),
    ...SECTIONS.map((s) => `${s.title} (%)`),
  ];
  const lines = filtered.value.map((r) =>
    [
      fmtDateTime(r.created_at),
      r.test_date,
      r.child_name,
      r.parent_name,
      genderLabel(r.gender),
      r.age,
      r.grade,
      topTitles(r).join(" & "),
      ...SECTIONS.map((s) => scoreOf(r, s.code).total),
      ...SECTIONS.map((s) => scoreOf(r, s.code).percent),
    ]
      .map(esc)
      .join(","),
  );
  const blob = new Blob(
    ["﻿" + [head.map(esc).join(","), ...lines].join("\r\n")],
    { type: "text/csv;charset=utf-8" },
  );
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `laporan-minat-bakat-${new Date().toISOString().slice(0, 10)}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

const cellStyle = (row, s) => {
  const sc = scoreOf(row, s.code);
  return {
    background: `color-mix(in srgb, ${s.color} ${Math.round(sc.percent * 0.45)}%, #fff)`,
  };
};
</script>

<template>
  <div class="admin">
    <!-- ================= LOGIN (kode akses) ================= -->
    <div v-if="!authed" class="gate">
      <form class="gate-card" @submit.prevent="submitCode">
        <div class="lock">🔐</div>
        <h1>Area Admin</h1>
        <p>Masukkan kode akses untuk melihat laporan hasil pengisian.</p>
        <input
          v-model="input"
          type="password"
          class="gate-input"
          placeholder="Kode akses"
          autocomplete="off"
          autofocus
          :disabled="checking"
        />
        <p v-if="!supabaseEnabled" class="err">
          Supabase belum dikonfigurasi (.env).
        </p>
        <p v-if="error" class="err" role="alert">{{ error }}</p>
        <button
          class="gate-btn"
          :disabled="checking || !input.trim() || !supabaseEnabled"
        >
          {{ checking ? "Memeriksa..." : "Masuk" }}
        </button>
      </form>
    </div>

    <!-- ================= LAPORAN ================= -->
    <div v-else class="shell">
      <header class="bar">
        <div>
          <h1>
            {{
              activeTab === "dashboard"
                ? "Laporan Minat & Bakat"
                : "Bank Soal"
            }}
          </h1>
          <p>
            {{
              activeTab === "dashboard"
                ? "Hasil pengisian oleh orang tua"
                : "Kelola bagian dan pertanyaan kuesioner"
            }}
          </p>
        </div>
        <div class="bar-actions">
          <button
            class="btn-s tab"
            :class="{ active: activeTab === 'dashboard' }"
            @click="activeTab = 'dashboard'"
          >
            📊 Dashboard
          </button>
          <button
            class="btn-s tab"
            :class="{ active: activeTab === 'questions' }"
            @click="activeTab = 'questions'"
          >
            📝 Bank Soal
          </button>
          <template v-if="activeTab === 'dashboard'">
            <button class="btn-s" :disabled="loading" @click="reload">
              {{ loading ? "Memuat..." : "↻ Muat ulang" }}
            </button>
            <button
              class="btn-s"
              :disabled="!filtered.length"
              @click="exportCsv"
            >
              ⬇ Unduh CSV
            </button>
          </template>
          <button class="btn-s out" @click="logout">Keluar</button>
        </div>
      </header>

      <!-- ===== TAB: DASHBOARD ===== -->
      <template v-if="activeTab === 'dashboard'">
        <p v-if="error" class="err-box">{{ error }}</p>

        <section class="stats">
          <div class="stat" style="--c: #7c3aed">
            <span>Total pengisian</span><strong>{{ totalCount }}</strong>
          </div>
          <div class="stat" style="--c: #0ea5e9">
            <span>Hari ini</span><strong>{{ todayCount }}</strong>
          </div>
          <div class="stat" style="--c: #f59e0b">
            <span>Rata-rata usia</span><strong>{{ avgAge }}</strong>
          </div>
          <div class="stat" style="--c: #10b981">
            <span>Bakat terbanyak</span>
            <strong class="small">{{
              topTalent ? `${topTalent.emoji} ${topTalent.short}` : "-"
            }}</strong>
          </div>
        </section>

        <section class="panel">
          <h2>Sebaran bakat teratas</h2>
          <div class="dist">
            <div v-for="d in distribution" :key="d.code" class="dist-row">
              <span class="dl">{{ d.emoji }} {{ d.short }}</span>
              <div class="dbar">
                <i :style="{ width: d.width + '%', background: d.color }" />
              </div>
              <span class="dc">{{ d.count }}</span>
            </div>
          </div>
        </section>

        <section class="panel">
          <div class="filters">
            <input
              v-model="search"
              class="f-input"
              placeholder="Cari nama anak / orang tua / kelas..."
            />
            <select v-model="filterTop" class="f-input">
              <option value="">Semua bakat teratas</option>
              <option v-for="s in SECTIONS" :key="s.code" :value="s.code">
                {{ s.emoji }} {{ s.title }}
              </option>
            </select>
            <select v-model="filterGender" class="f-input">
              <option value="">Semua jenis kelamin</option>
              <option value="L">Laki-laki</option>
              <option value="P">Perempuan</option>
            </select>
            <span class="count">{{ filtered.length }} data</span>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th class="sortable" @click="sortBy('created_at')">
                    Tanggal {{ arrow("created_at") }}
                  </th>
                  <th class="sortable sticky" @click="sortBy('child_name')">
                    Nama Anak {{ arrow("child_name") }}
                  </th>
                  <th>Orang Tua</th>
                  <th>L/P</th>
                  <th class="sortable" @click="sortBy('age')">
                    Usia {{ arrow("age") }}
                  </th>
                  <th>Kelas</th>
                  <th>Bakat Teratas</th>
                  <th
                    v-for="s in SECTIONS"
                    :key="s.code"
                    class="sc"
                    :title="s.title"
                  >
                    {{ s.emoji }}<br />{{ s.short }}
                  </th>
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!paged.length">
                  <td :colspan="9 + SECTIONS.length" class="empty">
                    {{
                      rows.length
                        ? "Tidak ada data yang cocok."
                        : "Belum ada data pengisian."
                    }}
                  </td>
                </tr>
                <tr v-for="(r, i) in paged" :key="r.id">
                  <td class="muted">{{ (page - 1) * PAGE_SIZE + i + 1 }}</td>
                  <td class="nowrap">{{ fmtDateTime(r.created_at) }}</td>
                  <td class="sticky strong">{{ r.child_name }}</td>
                  <td>{{ r.parent_name || "-" }}</td>
                  <td>{{ r.gender }}</td>
                  <td>{{ r.age }}</td>
                  <td class="nowrap">{{ r.grade }}</td>
                  <td>
                    <span
                      v-for="c in r.top_codes"
                      :key="c"
                      class="chip"
                      :style="{ background: secByCode[c]?.color }"
                      >{{ secByCode[c]?.emoji }}
                      {{ secByCode[c]?.short }}</span
                    >
                  </td>
                  <td
                    v-for="s in SECTIONS"
                    :key="s.code"
                    class="score"
                    :class="{ best: (r.top_codes || []).includes(s.code) }"
                    :style="cellStyle(r, s)"
                  >
                    {{ scoreOf(r, s.code).total }}
                  </td>
                  <td>
                    <button class="link" @click="openDetail(r)">Detail</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="pager" v-if="pageCount > 1">
            <button class="btn-s" :disabled="page === 1" @click="page--">
              ← Sebelumnya
            </button>
            <span>Halaman {{ page }} / {{ pageCount }}</span>
            <button
              class="btn-s"
              :disabled="page === pageCount"
              @click="page++"
            >
              Berikutnya →
            </button>
          </div>
          <p class="legend">
            Angka pada kolom bakat = total skor (maks. 35). Warna makin pekat =
            skor makin tinggi; cetak tebal = bakat teratas.
          </p>
        </section>
      </template>

      <!-- ===== TAB: BANK SOAL ===== -->
      <AdminQuestionsView v-else :code="code" @unauthorized="logout" />
    </div>

    <!-- ================= DETAIL ================= -->
    <Transition name="fade">
      <div v-if="selected" class="overlay" @click.self="closeDetail">
        <div class="modal" role="dialog" aria-modal="true">
          <button class="x" aria-label="Tutup" @click="closeDetail">✕</button>
          <h2>{{ selected.child_name }}</h2>
          <p class="sub">
            {{ genderLabel(selected.gender) }} · {{ selected.age }} tahun ·
            {{ selected.grade }} · Orang tua/wali:
            {{ selected.parent_name || "-" }}
          </p>
          <p class="sub">
            Diisi {{ fmtDateTime(selected.created_at) }} (tanggal tes
            {{ fmtDate(selected.test_date) }})
          </p>

          <div class="tops">
            <span
              v-for="c in selected.top_codes"
              :key="c"
              class="chip big"
              :style="{ background: secByCode[c]?.color }"
              >⭐ {{ secByCode[c]?.emoji }} {{ secByCode[c]?.title }}</span
            >
          </div>

          <div class="sbars">
            <div v-for="s in SECTIONS" :key="s.code" class="sbar">
              <span class="sl">{{ s.emoji }} {{ s.short }}</span>
              <div class="sb">
                <i
                  :style="{
                    width: scoreOf(selected, s.code).percent + '%',
                    background: s.color,
                  }"
                />
              </div>
              <span class="sv"
                >{{ scoreOf(selected, s.code).total }}/{{
                  scoreOf(selected, s.code).max
                }}</span
              >
            </div>
          </div>

          <h3>Jawaban</h3>
          <p v-if="detailLoading" class="muted">Memuat jawaban...</p>
          <p v-else-if="detailError" class="err">{{ detailError }}</p>
          <div v-else class="answers">
            <div
              v-for="sec in answersBySection"
              :key="sec.code"
              class="ans-sec"
            >
              <h4 :style="{ color: sec.color }">
                {{ sec.emoji }} {{ sec.title }}
              </h4>
              <ol>
                <li v-for="a in sec.items" :key="a.question_code">
                  <span>{{ a.question_text }}</span>
                  <b :class="'s' + a.score">{{ a.score }}</b>
                </li>
              </ol>
            </div>
          </div>

          <div class="danger">
            <template v-if="!confirmDelete">
              <button class="btn-s del" @click="confirmDelete = true">
                Hapus data ini
              </button>
            </template>
            <template v-else>
              <span>Yakin hapus permanen?</span>
              <button
                class="btn-s del solid"
                :disabled="deleting"
                @click="doDelete"
              >
                {{ deleting ? "Menghapus..." : "Ya, hapus" }}
              </button>
              <button class="btn-s" @click="confirmDelete = false">
                Batal
              </button>
            </template>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.admin {
  min-height: 100vh;
  background: #f4f5fb;
  color: #1f1b3a;
}

/* ---- gate ---- */
.gate {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 20px;
  background:
    radial-gradient(circle at 20% 10%, #ede9fe, transparent 50%),
    radial-gradient(circle at 90% 90%, #fce7f3, transparent 50%), #f4f5fb;
}
.gate-card {
  width: 100%;
  max-width: 380px;
  background: #fff;
  border-radius: 24px;
  padding: 32px 28px;
  text-align: center;
  box-shadow: 0 24px 60px -24px rgba(76, 29, 149, 0.4);
  display: grid;
  gap: 12px;
  animation: pop 0.45s cubic-bezier(0.2, 1.2, 0.4, 1);
}
@keyframes pop {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.96);
  }
}
.lock {
  font-size: 2.6rem;
  animation: bob 2.4s ease-in-out infinite;
}
.gate-card h1 {
  font-size: 1.5rem;
}
.gate-card p {
  margin: 0;
  color: #6b6a86;
  font-size: 0.92rem;
  font-weight: 600;
}
.gate-input {
  height: 50px;
  border-radius: 14px;
  border: 2px solid #e8e2f5;
  padding: 0 16px;
  font: inherit;
  font-weight: 700;
  text-align: center;
  letter-spacing: 0.2em;
}
.gate-input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 5px rgba(124, 58, 237, 0.13);
}
.gate-btn {
  height: 50px;
  border: 0;
  border-radius: 14px;
  font: inherit;
  font-weight: 800;
  color: #fff;
  cursor: pointer;
  background: linear-gradient(120deg, #7c3aed, #ec4899);
  transition:
    transform 0.15s,
    opacity 0.2s;
}
.gate-btn:hover:not(:disabled) {
  transform: translateY(-1px);
}
.gate-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
.err {
  color: #e11d48 !important;
  font-weight: 700 !important;
}
.err-box {
  background: #fff1f2;
  color: #be123c;
  border-radius: 12px;
  padding: 10px 14px;
  font-weight: 700;
}

/* ---- shell ---- */
.shell {
  max-width: 1280px;
  margin: 0 auto;
  padding: 24px 16px 60px;
  display: grid;
  gap: 16px;
}
.bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
}
.bar h1 {
  font-size: 1.6rem;
}
.bar p {
  margin: 2px 0 0;
  color: #6b6a86;
  font-weight: 600;
  font-size: 0.9rem;
}
.bar-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
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
.btn-s.tab.active,
.btn-s.tab.active:hover {
  background: #7c3aed;
  border-color: #7c3aed;
  color: #fff;
}
.btn-s.out {
  color: #be123c;
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

.stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}
.stat {
  background: #fff;
  border-radius: 16px;
  padding: 16px 18px;
  border: 1px solid #ece7f7;
  border-left: 5px solid var(--c);
  animation: rise 0.5s both;
}
.stat span {
  display: block;
  font-size: 0.78rem;
  font-weight: 700;
  color: #6b6a86;
}
.stat strong {
  display: block;
  font-family: "Fredoka", sans-serif;
  font-size: 1.9rem;
  line-height: 1.2;
  color: var(--c);
}
.stat strong.small {
  font-size: 1.3rem;
  padding-top: 6px;
}
@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
}

.panel {
  background: #fff;
  border: 1px solid #ece7f7;
  border-radius: 18px;
  padding: 18px;
}
.panel h2 {
  font-size: 1.05rem;
  margin-bottom: 12px;
}

.dist {
  display: grid;
  gap: 8px;
}
.dist-row {
  display: grid;
  grid-template-columns: 110px 1fr 32px;
  gap: 10px;
  align-items: center;
  font-size: 0.85rem;
  font-weight: 700;
}
.dbar {
  height: 12px;
  background: #f3f0fa;
  border-radius: 99px;
  overflow: hidden;
}
.dbar i {
  display: block;
  height: 100%;
  border-radius: 99px;
  transition: width 0.8s cubic-bezier(0.2, 1, 0.3, 1);
}
.dc {
  text-align: right;
  color: #6b6a86;
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
  min-width: 160px;
}
.filters .f-input:first-child {
  flex: 1;
  min-width: 220px;
}
.f-input:focus {
  outline: none;
  border-color: #7c3aed;
}
.count {
  margin-left: auto;
  font-weight: 800;
  color: #7c3aed;
  font-size: 0.88rem;
}

.table-wrap {
  overflow-x: auto;
  border: 1px solid #ece7f7;
  border-radius: 12px;
}
table {
  width: 100%;
  min-width: 1180px;
  border-collapse: collapse;
  font-size: 0.85rem;
}
th,
td {
  padding: 9px 10px;
  text-align: left;
  border-bottom: 1px solid #f1edf9;
  vertical-align: middle;
}
thead th {
  background: #faf8ff;
  font-weight: 800;
  color: #4b4868;
  position: sticky;
  top: 0;
  font-size: 0.78rem;
  white-space: nowrap;
}
th.sortable {
  cursor: pointer;
  user-select: none;
}
th.sortable:hover {
  color: #7c3aed;
}
th.sc {
  text-align: center;
  line-height: 1.2;
}
tbody tr:hover {
  background: #fcfaff;
}
.sticky {
  position: sticky;
  left: 0;
  background: #fff;
  z-index: 1;
  box-shadow: 1px 0 0 #f1edf9;
}
thead th.sticky {
  background: #faf8ff;
  z-index: 2;
}
tbody tr:hover .sticky {
  background: #fcfaff;
}
.strong {
  font-weight: 800;
}
.nowrap {
  white-space: nowrap;
}
.muted {
  color: #9a97b3;
}
.empty {
  text-align: center;
  padding: 32px;
  color: #9a97b3;
  font-weight: 700;
}
.chip {
  display: inline-block;
  color: #fff;
  font-size: 0.72rem;
  font-weight: 800;
  padding: 3px 9px;
  border-radius: 99px;
  margin: 1px 3px 1px 0;
  white-space: nowrap;
}
.chip.big {
  font-size: 0.82rem;
  padding: 5px 12px;
}
.score {
  text-align: center;
  font-weight: 600;
  min-width: 52px;
}
.score.best {
  font-weight: 900;
}
.link {
  background: none;
  border: 0;
  font: inherit;
  font-weight: 800;
  color: #7c3aed;
  cursor: pointer;
  text-decoration: underline;
  padding: 0;
}

.pager {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 14px;
  margin-top: 14px;
  font-weight: 700;
  font-size: 0.88rem;
}
.legend {
  margin: 12px 0 0;
  color: #9a97b3;
  font-size: 0.78rem;
  font-weight: 600;
}

/* ---- modal ---- */
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
  max-width: 720px;
  max-height: calc(100vh - 32px);
  overflow-y: auto;
  border-radius: 22px;
  padding: 26px 24px;
  animation: pop 0.35s cubic-bezier(0.2, 1.2, 0.4, 1);
}
.modal h2 {
  font-size: 1.5rem;
  padding-right: 36px;
}
.modal h3 {
  margin: 22px 0 8px;
  font-size: 1.05rem;
}
.sub {
  margin: 4px 0 0;
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
.tops {
  margin: 14px 0;
}
.sbars {
  display: grid;
  gap: 6px;
}
.sbar {
  display: grid;
  grid-template-columns: 100px 1fr 52px;
  gap: 10px;
  align-items: center;
  font-size: 0.84rem;
  font-weight: 700;
}
.sb {
  height: 10px;
  background: #f3f0fa;
  border-radius: 99px;
  overflow: hidden;
}
.sb i {
  display: block;
  height: 100%;
  border-radius: 99px;
}
.sv {
  text-align: right;
  color: #6b6a86;
}
.ans-sec {
  margin-bottom: 14px;
}
.ans-sec h4 {
  margin: 0 0 6px;
  font-size: 0.95rem;
}
.ans-sec ol {
  margin: 0;
  padding-left: 22px;
  display: grid;
  gap: 4px;
  font-size: 0.86rem;
}
.ans-sec li span {
  margin-right: 8px;
}
.ans-sec b {
  display: inline-block;
  min-width: 22px;
  text-align: center;
  border-radius: 6px;
  color: #fff;
  font-size: 0.78rem;
  padding: 1px 6px;
}
b.s1 {
  background: #f43f5e;
}
b.s2 {
  background: #fb923c;
}
b.s3 {
  background: #eab308;
}
b.s4 {
  background: #22c55e;
}
b.s5 {
  background: #0ea5e9;
}
.danger {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px dashed #e4def2;
  font-weight: 700;
  font-size: 0.88rem;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@keyframes bob {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-6px);
  }
}

@media (max-width: 760px) {
  .stats {
    grid-template-columns: repeat(2, 1fr);
  }
  .dist-row {
    grid-template-columns: 90px 1fr 28px;
  }
  .sbar {
    grid-template-columns: 84px 1fr 48px;
  }
}
</style>