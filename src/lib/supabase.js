import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const key = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabaseEnabled = Boolean(url && key)
export const supabase = supabaseEnabled ? createClient(url, key) : null

/**
 * Simpan hasil tes ke Supabase (tabel mb_submissions + mb_answers).
 * ID dibuat di client karena publik tidak punya izin SELECT pada mb_submissions.
 */
export async function saveSubmission({ identity, answers, result }) {
  if (!supabase) throw new Error('Supabase belum dikonfigurasi (.env)')

  const id = crypto.randomUUID()

  const { error: subErr } = await supabase.from('mb_submissions').insert({
    id,
    child_name: identity.name.trim(),
    parent_name: identity.parent.trim(),
    gender: identity.gender,
    age: Number(identity.age),
    grade: String(identity.grade).trim(),
    test_date: identity.date,
    section_scores: result.scores.map(({ code, title, total, max, percent }) => ({ code, title, total, max, percent })),
    top_codes: result.tops.map((t) => t.code),
  })
  if (subErr) throw subErr

  const rows = Object.entries(answers).map(([question_code, score]) => ({
    submission_id: id,
    question_code,
    score,
  }))
  const { error: ansErr } = await supabase.from('mb_answers').insert(rows)
  if (ansErr) throw ansErr

  return id
}

/* ================= ADMIN (verifikasi kode di database via RPC) ================= */

export class WrongCodeError extends Error {
  constructor() {
    super('Kode akses salah')
    this.name = 'WrongCodeError'
  }
}

async function rpc(fn, args) {
  if (!supabase) throw new Error('Supabase belum dikonfigurasi (.env)')
  const { data, error } = await supabase.rpc(fn, args)
  if (error) {
    if (String(error.message).includes('KODE_SALAH')) throw new WrongCodeError()
    throw error
  }
  return data
}

export const adminReport = (code) => rpc('mb_admin_report', { p_code: code })
export const adminAnswers = (code, id) => rpc('mb_admin_answers', { p_code: code, p_id: id })
export const adminDelete = (code, id) => rpc('mb_admin_delete', { p_code: code, p_id: id })
