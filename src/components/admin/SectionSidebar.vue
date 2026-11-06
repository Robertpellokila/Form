<script setup>
defineProps({
  sections: { type: Array, default: () => [] },
  counts: { type: Object, default: () => ({}) },
  total: { type: Number, default: 0 },
  activeCode: { type: String, default: "" },
});
defineEmits(["select", "add", "edit"]);
</script>

<template>
  <aside class="side">
    <div class="side-head">
      <h2>Bagian</h2>
      <button class="btn-s" @click="$emit('add')">+ Bagian</button>
    </div>

    <button
      class="item"
      :class="{ on: activeCode === '' }"
      style="--c: #7c3aed"
      @click="$emit('select', '')"
    >
      <span class="lbl">📚 Semua soal</span>
      <span class="num">{{ total }}</span>
    </button>

    <div
      v-for="s in sections"
      :key="s.code"
      class="item-wrap"
    >
      <button
        class="item"
        :class="{ on: activeCode === s.code }"
        :style="{ '--c': s.color }"
        @click="$emit('select', s.code)"
      >
        <span class="lbl">{{ s.emoji }} {{ s.title }}</span>
        <span class="num">{{ counts[s.code] || 0 }}</span>
      </button>
      <button
        class="edit"
        title="Ubah bagian"
        aria-label="Ubah bagian"
        @click="$emit('edit', s)"
      >
        ✎
      </button>
    </div>

    <p v-if="!sections.length" class="empty">Belum ada bagian.</p>
  </aside>
</template>

<style scoped>
.side {
  background: #fff;
  border: 1px solid #ece7f7;
  border-radius: 18px;
  padding: 14px;
  display: grid;
  gap: 6px;
  align-content: start;
}
.side-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}
.side-head h2 {
  font-size: 1.05rem;
}
.btn-s {
  font: inherit;
  font-weight: 700;
  font-size: 0.8rem;
  background: #fff;
  border: 1.5px solid #e4def2;
  color: #34304f;
  border-radius: 10px;
  padding: 6px 12px;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-s:hover {
  border-color: #a78bfa;
  background: #faf5ff;
}
.item-wrap {
  position: relative;
}
.item {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  font: inherit;
  font-weight: 700;
  font-size: 0.86rem;
  text-align: left;
  color: #34304f;
  background: #fff;
  border: 1.5px solid transparent;
  border-left: 5px solid var(--c);
  border-radius: 12px;
  padding: 10px 40px 10px 12px;
  cursor: pointer;
  transition: all 0.15s;
}
.item:first-of-type {
  padding-right: 12px;
}
.item:hover {
  background: #faf8ff;
}
.item.on {
  background: color-mix(in srgb, var(--c) 10%, #fff);
  border-color: color-mix(in srgb, var(--c) 40%, #fff);
  border-left-color: var(--c);
}
.lbl {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.num {
  font-size: 0.75rem;
  font-weight: 800;
  color: #6b6a86;
  background: #f3f0fa;
  border-radius: 99px;
  padding: 2px 9px;
}
.edit {
  position: absolute;
  top: 50%;
  right: 8px;
  transform: translateY(-50%);
  width: 26px;
  height: 26px;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #9a97b3;
  cursor: pointer;
  font-size: 0.9rem;
  opacity: 0;
  transition: all 0.15s;
}
.item-wrap:hover .edit,
.edit:focus-visible {
  opacity: 1;
}
.edit:hover {
  background: #f3f0fa;
  color: #7c3aed;
}
.item-wrap:has(.num) .num {
  margin-right: 0;
}
.empty {
  text-align: center;
  color: #9a97b3;
  font-weight: 700;
  font-size: 0.85rem;
  padding: 12px 0;
}

@media (max-width: 760px) {
  .edit {
    opacity: 1;
  }
}
</style>