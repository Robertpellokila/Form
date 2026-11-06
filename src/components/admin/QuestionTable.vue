<script setup>
defineProps({
  questions: { type: Array, default: () => [] },
  sectionByCode: { type: Object, default: () => ({}) },
  showSection: { type: Boolean, default: true },
  busyId: { type: [String, Number], default: null },
});
defineEmits(["edit", "delete", "toggle", "move"]);
</script>

<template>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th class="w-num">#</th>
          <th>Pertanyaan</th>
          <th v-if="showSection">Bagian</th>
          <th class="w-status">Status</th>
          <th class="w-order">Urutan</th>
          <th class="w-act">Aksi</th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="!questions.length">
          <td :colspan="showSection ? 6 : 5" class="empty">
            Belum ada pertanyaan.
          </td>
        </tr>
        <tr
          v-for="(q, i) in questions"
          :key="q.id"
          :class="{ off: q.active === false }"
        >
          <td class="muted">{{ i + 1 }}</td>
          <td class="strong">{{ q.text }}</td>
          <td v-if="showSection">
            <span
              v-if="sectionByCode[q.section_code]"
              class="chip"
              :style="{ background: sectionByCode[q.section_code].color }"
              >{{ sectionByCode[q.section_code].emoji }}
              {{ sectionByCode[q.section_code].short }}</span
            >
            <span v-else class="muted">-</span>
          </td>
          <td>
            <button
              class="pill"
              :class="q.active === false ? 'off' : 'on'"
              :disabled="busyId === q.id"
              @click="$emit('toggle', q)"
            >
              {{ q.active === false ? "Nonaktif" : "Aktif" }}
            </button>
          </td>
          <td class="nowrap">
            <button
              class="mv"
              :disabled="i === 0"
              aria-label="Naik"
              @click="$emit('move', q, -1)"
            >
              ▲
            </button>
            <button
              class="mv"
              :disabled="i === questions.length - 1"
              aria-label="Turun"
              @click="$emit('move', q, 1)"
            >
              ▼
            </button>
          </td>
          <td class="nowrap">
            <button class="link" @click="$emit('edit', q)">Ubah</button>
            <button class="link del" @click="$emit('delete', q)">Hapus</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.table-wrap {
  overflow-x: auto;
  border: 1px solid #ece7f7;
  border-radius: 12px;
}
table {
  width: 100%;
  min-width: 720px;
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
  font-size: 0.78rem;
  white-space: nowrap;
}
tbody tr:hover {
  background: #fcfaff;
}
tbody tr.off .strong {
  color: #9a97b3;
  font-weight: 700;
}
.w-num {
  width: 44px;
}
.w-status {
  width: 96px;
}
.w-order {
  width: 84px;
}
.w-act {
  width: 120px;
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
  white-space: nowrap;
}
.pill {
  font: inherit;
  font-size: 0.74rem;
  font-weight: 800;
  border: 0;
  border-radius: 99px;
  padding: 4px 11px;
  cursor: pointer;
}
.pill.on {
  background: #dcfce7;
  color: #15803d;
}
.pill.off {
  background: #f3f0fa;
  color: #9a97b3;
}
.pill:disabled {
  opacity: 0.5;
  cursor: wait;
}
.mv {
  width: 26px;
  height: 26px;
  margin-right: 4px;
  border: 1.5px solid #e4def2;
  background: #fff;
  border-radius: 8px;
  color: #6b6a86;
  font-size: 0.65rem;
  cursor: pointer;
}
.mv:hover:not(:disabled) {
  border-color: #a78bfa;
  background: #faf5ff;
}
.mv:disabled {
  opacity: 0.35;
  cursor: not-allowed;
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
  margin-right: 12px;
}
.link.del {
  color: #be123c;
  margin-right: 0;
}
</style>