// API bank soal untuk halaman admin.
// Memakai klien Supabase & WrongCodeError yang sudah ada di supabase.js,
// jadi supabase.js tidak perlu diubah.
import { SECTIONS } from "../data/questions.js";
import * as sb from "./supabase.js";

const staticByCode = Object.fromEntries(SECTIONS.map((s) => [s.code, s]));

function client() {
  const c = sb.supabase ?? sb.client ?? sb.default;
  if (!c?.rpc) {
    throw new Error(
      "Klien Supabase tidak ditemukan. Pastikan supabase.js meng-export `supabase`.",
    );
  }
  return c;
}

async function rpc(fn, args) {
  const { data, error } = await client().rpc(fn, args);
  if (error) {
    const msg = error.message || "";
    if (msg.includes("KODE_SALAH")) throw new sb.WrongCodeError();
    const e = new Error(msg);
    if (msg.includes("SUDAH_DIJAWAB"))
      e.friendly =
        "Sudah pernah dijawab responden, jadi tidak bisa dihapus. Nonaktifkan saja.";
    else if (msg.includes("TEKS_TERLALU_PENDEK"))
      e.friendly = "Teks pertanyaan terlalu pendek.";
    else if (msg.includes("duplicate key"))
      e.friendly = "Kode bagian sudah dipakai.";
    console.error(error);
    throw e;
  }
  return data;
}

/* ---------- baca ---------- */
export async function adminSections(code) {
  const data = (await rpc("mb_admin_sections", { p_code: code })) || [];
  return data.map((s) => {
    const fallback = staticByCode[s.code] || {};
    return {
      code: s.code,
      title: s.title,
      short: s.short_title,
      emoji: s.emoji || fallback.emoji || "⭐",
      color: s.color || fallback.color || "#7c3aed",
      sort_order: s.sort_order,
    };
  });
}

export async function adminQuestions(code) {
  const data = (await rpc("mb_admin_questions", { p_code: code })) || [];
  return data.map((q) => ({
    id: q.code, // kode soal dipakai sebagai id
    section_code: q.section_code,
    sort_order: q.position,
    text: q.text,
    active: q.active,
    answered: q.answered,
  }));
}

/* ---------- bagian ---------- */
export function adminSaveSection(code, s) {
  return rpc("mb_admin_save_section", {
    p_code: code,
    p_section: {
      code: s.code,
      title: s.title,
      short_title: s.short,
      emoji: s.emoji,
      color: s.color,
    },
  });
}

export function adminDeleteSection(code, sectionCode) {
  return rpc("mb_admin_delete_section", {
    p_code: code,
    p_section_code: sectionCode,
  });
}

/* ---------- soal ---------- */
export function adminSaveQuestion(code, q) {
  return rpc("mb_admin_save_question", {
    p_code: code,
    p_question: {
      code: q.id || null,
      section_code: q.section_code,
      text: q.text,
      active: q.active !== false,
    },
  });
}

export function adminDeleteQuestion(code, id) {
  return rpc("mb_admin_delete_question", {
    p_code: code,
    p_question_code: id,
  });
}

export function adminReorderQuestions(code, items) {
  return rpc("mb_admin_reorder_questions", {
    p_code: code,
    p_items: items.map((x) => ({ code: x.id, position: x.sort_order })),
  });
}

export { WrongCodeError } from "./supabase.js";
