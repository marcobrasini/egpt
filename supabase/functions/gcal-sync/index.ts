// supabase/functions/gcal-sync/index.ts
//
// Sincronizzazione unidirezionale Supabase → Google Calendar.
// Lavora sulla tabella `gcal`:
//   pending  → crea/aggiorna l'evento su Google → synced | error
//   deleting → cancella l'evento su Google → elimina la riga di sync
//   sorgente non trovata → cancella l'evento su Google (se c'è) ed elimina
//                          subito la riga di sync
//
// Ricorrenze (modello "EXDATE"):
//   - una serie è un meeting con recurrence_rule; le occorrenze sostituite sono
//     escluse con EXDATE nella regola stessa
//   - un'eccezione è un meeting con recurrence_id = id della serie; su Google
//     diventa un evento indipendente
//
// Segreti richiesti (Edge Functions → Secrets):
//   GOOGLE_SERVICE_ACCOUNT_JSON, GCAL_CALENDAR_ID, CRON_SECRET
// (SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY sono già disponibili)
//
// Il cron deve inviare sia `Authorization: Bearer <chiave>` (verifica JWT di
// Supabase) sia `x-cron-secret: <CRON_SECRET>`.
//
// Punti da adattare al tuo schema: cerca "ADATTA".

import { createClient } from "npm:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5";

// ─────────────────────────── Configurazione ───────────────────────────

function requireEnv(name: string): string {
  const v = Deno.env.get(name);
  if (!v) throw new Error(`Variabile d'ambiente mancante: ${name}`);
  return v;
}

const CRON_SECRET = requireEnv("CRON_SECRET");
const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SERVICE_ROLE_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
const SERVICE_ACCOUNT = JSON.parse(requireEnv("GOOGLE_SERVICE_ACCOUNT_JSON"));
const CALENDAR_ID = encodeURIComponent(requireEnv("GCAL_CALENDAR_ID"));

const TIME_ZONE = "Europe/Rome";
const BATCH_SIZE = 50;
const SYNC_TABLE = "gcal";
const GCAL_BASE = "https://www.googleapis.com/calendar/v3";

// Righe sorgente con il nome del membro:
//   meetings.product_id → products.id → products.member_id → members.id
//   presences.id → sessions.id → sessions.product_id → products → members
// ADATTA se tabelle o colonne hanno nomi diversi. Se l'hint "!id" risulta
// ambiguo, sostituiscilo con il nome del vincolo (es. "!presences_id_fkey").
const SOURCE_SELECT: Record<GcalType, string> = {
  meeting: "*, product:products!product_id(member:members!member_id(name))",
  session:
    "*, session:sessions!id(product:products!product_id(member:members!member_id(name)))",
};

// ADATTA: se le date escluse NON stanno nella recurrence_rule ma in una colonna
// separata di meetings (es. timestamptz[]), metti qui il nome della colonna.
const EXDATES_COLUMN: string | null = null;

// ADATTA (opzionale): colonna timestamptz di `gcal` in cui registrare l'istante
// del lock, per recuperare i job rimasti in 'syncing' dopo un crash o un timeout.
// Per attivarla:
//   alter table public.gcal add column gcal_locked_at timestamptz;
// e poi imposta qui "gcal_locked_at".
const LOCK_COLUMN: string | null = null;
const STALE_LOCK_MINUTES = 10;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

// ─────────────────────────────── Tipi ────────────────────────────────

type GcalType = "meeting" | "session";
type SyncStatus = "pending" | "syncing" | "synced" | "error" | "deleting";
type Row = Record<string, any>;

interface SyncJob {
  id: string;
  gcal_type: GcalType;
  gcal_event_id: string | null;
  gcal_synced_at: string | null;
  gcal_sync_status: SyncStatus;
  gcal_sync_error: string | null;
}

const SOURCE_TABLE: Record<GcalType, string> = {
  meeting: "meetings",
  session: "presences",
};

const GCAL_TYPES: GcalType[] = ["meeting", "session"];

// Errore restituito dalle API di Google, con status HTTP e reason
class GcalError extends Error {
  constructor(message: string, readonly status: number, readonly reason?: string) {
    super(message);
    this.name = "GcalError";
  }
}

// Transitori (si riprova al giro successivo): 429, 5xx e i rate limit
// che Google restituisce come 403
function isTransient(e: unknown): boolean {
  if (!(e instanceof GcalError)) return false;
  if (e.status === 429 || e.status >= 500) return true;
  return e.status === 403 && /rateLimitExceeded/i.test(e.reason ?? "");
}

function errMsg(e: unknown): string {
  const m = e instanceof Error ? e.message : (e as any)?.message ?? String(e);
  return String(m).slice(0, 500);
}

// ─────────────────────── Autenticazione Google ────────────────────────

// Firma un JWT con la chiave del service account e lo scambia con un access token
async function getAccessToken(): Promise<string> {
  const key = await importPKCS8(SERVICE_ACCOUNT.private_key, "RS256");
  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/calendar",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(SERVICE_ACCOUNT.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`Token Google non ottenuto: ${await res.text()}`);
  return (await res.json()).access_token;
}

// ─────────────────────── Google Calendar API ─────────────────────────

async function gcal(
  token: string,
  method: string,
  path: string,
  body?: unknown,
): Promise<any> {
  const res = await fetch(`${GCAL_BASE}/calendars/${CALENDAR_ID}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  if (res.status === 204) return null;
  const json = await res.json().catch(() => null);
  if (!res.ok) {
    throw new GcalError(
      json?.error?.message ?? `${res.status} ${res.statusText}`,
      res.status,
      json?.error?.errors?.[0]?.reason,
    );
  }
  return json;
}

// Aggiorna l'evento se esiste, altrimenti lo crea con l'ID deterministico.
// PUT sostituisce l'intero evento e ripristina un evento cancellato in passato.
async function upsertEvent(token: string, eventId: string, body: Row) {
  try {
    return await gcal(token, "PUT", `/events/${eventId}`, body);
  } catch (e) {
    if (e instanceof GcalError && e.status === 404) {
      return await gcal(token, "POST", "/events", { id: eventId, ...body });
    }
    throw e;
  }
}

// Cancella l'evento; 404/410 (inesistente o già cancellato) va bene lo stesso
async function deleteEvent(token: string, eventId: string) {
  try {
    await gcal(token, "DELETE", `/events/${eventId}`);
  } catch (e) {
    if (e instanceof GcalError && (e.status === 404 || e.status === 410)) return;
    throw e;
  }
}

// ───────────────────────────── Mappatura ──────────────────────────────

// ID evento Google deterministico: caratteri ammessi a-v e 0-9.
// Pensato per id UUID; String() protegge anche da id numerici.
function makeEventId(type: GcalType, id: string | number): string {
  return (type === "meeting" ? "m" : "p") + String(id).replace(/-/g, "").toLowerCase();
}

function eventIdFor(job: SyncJob): string {
  return job.gcal_event_id ?? makeEventId(job.gcal_type, job.id);
}

// Nome del membro: per i meeting passa da product, per le presenze da session
function memberName(row: Row): string {
  const name =
    row.product?.member?.name ?? // meeting
    row.session?.product?.member?.name; // presenza
  return name?.trim() || "Senza nome";
}

function meetingTitle(m: Row): string {
  return memberName(m);
}

function sessionTitle(p: Row): string {
  return memberName(p);
}

// timestamptz → formato iCal UTC, es. 2026-10-05T07:00:00Z → 20261005T070000Z
function toIcalUtc(ts: string): string {
  return new Date(ts).toISOString().replace(/\.\d{3}/, "").replace(/[-:]/g, "");
}

// recurrence_rule → array "recurrence" di Google.
// Accetta "FREQ=WEEKLY;..." oppure "RRULE:FREQ=...", anche su più righe con EXDATE.
function toRecurrence(m: Row): string[] | undefined {
  const lines: string[] = String(m.recurrence_rule ?? "")
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean)
    .map((l) => (/^(RRULE|EXRULE|RDATE|EXDATE)[:;]/i.test(l) ? l : `RRULE:${l}`));

  if (!lines.length) return undefined;

  if (EXDATES_COLUMN) {
    const exdates = m[EXDATES_COLUMN];
    if (Array.isArray(exdates) && exdates.length) {
      lines.push(`EXDATE:${exdates.map(toIcalUtc).join(",")}`);
    }
  }
  return lines;
}

function meetingToEvent(m: Row): Row {
  const priv: Row = { source: "supabase", gcal_type: "meeting", row_id: String(m.id) };
  if (m.recurrence_id) priv.series_id = String(m.recurrence_id); // eccezione di una serie

  const ev: Row = {
    summary: meetingTitle(m),
    start: { dateTime: m.start, timeZone: TIME_ZONE },
    end: { dateTime: m.stop, timeZone: TIME_ZONE },
    status: "tentative",
    extendedProperties: { private: priv },
  };

  // PUT sostituisce l'intero evento: se la regola viene tolta, la ricorrenza sparisce
  const recurrence = toRecurrence(m);
  if (recurrence) ev.recurrence = recurrence;
  return ev;
}

function sessionToEvent(s: Row): Row {
  return {
    summary: sessionTitle(s),
    start: { dateTime: s.start, timeZone: TIME_ZONE },
    end: { dateTime: s.stop, timeZone: TIME_ZONE },
    status: "confirmed",
    extendedProperties: {
      private: { source: "supabase", gcal_type: "session", row_id: String(s.id) },
    },
  };
}

// ──────────────────────────── Helper DB ───────────────────────────────

// Chiude un job solo se è ancora 'syncing': se nel frattempo la sorgente è stata
// modificata (→ pending) o cancellata (→ deleting), l'aggiornamento non ha effetto.
async function finish(id: string, fields: Row) {
  const { data, error } = await supabase
    .from(SYNC_TABLE)
    .update(fields)
    .eq("id", id)
    .eq("gcal_sync_status", "syncing")
    .select("id, gcal_sync_status");

  if (error) {
    console.error(`gcal ${id}: aggiornamento fallito`, JSON.stringify(error));
  } else if (!data?.length) {
    console.warn(`gcal ${id}: nessuna riga aggiornata (non più 'syncing'?)`);
  } else if (data[0].gcal_sync_status !== fields.gcal_sync_status) {
    console.warn(`gcal ${id}: stato atteso ${fields.gcal_sync_status}, trovato ${data[0].gcal_sync_status}`);
  }
}

// Elimina la riga di sync di un job ancora 'syncing' (stessa guardia di finish)
async function removeJob(id: string) {
  const { error } = await supabase
    .from(SYNC_TABLE)
    .delete()
    .eq("id", id)
    .eq("gcal_sync_status", "syncing");
  if (error) throw error;
}

// Riporta a 'pending' i job indicati, se sono ancora 'syncing'
async function releaseJobs(ids: string[]) {
  if (!ids.length) return;
  const { error } = await supabase
    .from(SYNC_TABLE)
    .update({ gcal_sync_status: "pending" })
    .in("id", ids)
    .eq("gcal_sync_status", "syncing");
  if (error) console.error("gcal: rilascio dei job fallito", error.message);
}

// Recupera i job rimasti in 'syncing' troppo a lungo (crash, timeout).
// Attivo solo se LOCK_COLUMN è configurata.
async function releaseStaleLocks(): Promise<number> {
  if (!LOCK_COLUMN) return 0;
  const cutoff = new Date(Date.now() - STALE_LOCK_MINUTES * 60_000).toISOString();
  const { data, error } = await supabase
    .from(SYNC_TABLE)
    .update({ gcal_sync_status: "pending" })
    .eq("gcal_sync_status", "syncing")
    .lt(LOCK_COLUMN, cutoff)
    .select("id");
  if (error) {
    console.error("gcal: recupero dei lock scaduti fallito", error.message);
    return 0;
  }
  return data?.length ?? 0;
}

// ───────────────────────────── Worker ─────────────────────────────────

async function syncPending(token: string) {
  const stats = {
    synced: 0,
    failed: 0,
    retry: 0,
    orphaned: 0,
    orphanFailed: 0,
    released: 0,
    staleReleased: 0,
  };

  // 0) Job bloccati da esecuzioni precedenti
  stats.staleReleased = await releaseStaleLocks();

  // 1) Job in attesa
  const { data: pending, error } = await supabase
    .from(SYNC_TABLE)
    .select("id")
    .eq("gcal_sync_status", "pending")
    .limit(BATCH_SIZE);
  if (error) throw error;
  if (!pending?.length) return stats;

  // 2) Lock atomico: passano a 'syncing' solo quelli ancora 'pending'
  const lockFields: Row = { gcal_sync_status: "syncing" };
  if (LOCK_COLUMN) lockFields[LOCK_COLUMN] = new Date().toISOString();

  const { data: locked, error: lockErr } = await supabase
    .from(SYNC_TABLE)
    .update(lockFields)
    .in("id", pending.map((j) => j.id))
    .eq("gcal_sync_status", "pending")
    .select("*");
  if (lockErr) throw lockErr;
  const jobs = (locked ?? []) as SyncJob[];

  // 3) Righe sorgente, lette DOPO il lock (una query per tipo).
  //    Se la lettura di un tipo fallisce, solo i suoi job tornano 'pending'
  //    e vengono saltati: gli altri tipi proseguono normalmente.
  const sources = new Map<string, Row>();
  const failedTypes = new Set<GcalType>();

  for (const type of GCAL_TYPES) {
    const ids = jobs.filter((j) => j.gcal_type === type).map((j) => j.id);
    if (!ids.length) continue;

    const { data, error } = await supabase
      .from(SOURCE_TABLE[type])
      .select(SOURCE_SELECT[type])
      .in("id", ids);

    if (error) {
      console.error(`gcal: lettura di ${SOURCE_TABLE[type]} fallita`, error);
      await releaseJobs(ids);
      failedTypes.add(type);
      stats.released += ids.length;
      continue;
    }
    for (const r of (data ?? []) as Row[]) sources.set(String(r.id), r);
  }

  // 4) Sincronizzazione: serie, eccezioni e presenze sono tutti eventi normali
  for (const job of jobs) {
    // IMPORTANTE: senza questo controllo, una lettura fallita farebbe sembrare
    // le sorgenti inesistenti e gli eventi verrebbero cancellati da Google.
    if (failedTypes.has(job.gcal_type)) continue;

    const src = sources.get(String(job.id));

    if (!src) {
      // Sorgente non più esistente: si cancella l'eventuale evento su Google
      // e si elimina subito la riga di sync, senza passare da 'deleting'.
      try {
        // Fallback sull'ID deterministico: copre un evento creato ma mai
        // registrato; se non esiste, deleteEvent ignora il 404.
        await deleteEvent(token, eventIdFor(job));
        await removeJob(job.id);
        stats.orphaned++;
      } catch (e) {
        // Non è stato possibile cancellare: la riga passa a 'deleting'
        // e verrà ritentata da processDeleting.
        await finish(job.id, { gcal_sync_status: "deleting", gcal_sync_error: errMsg(e) });
        stats.orphanFailed++;
      }
      continue;
    }

    try {
      const body = job.gcal_type === "meeting" ? meetingToEvent(src) : sessionToEvent(src);
      const ev = await upsertEvent(token, eventIdFor(job), body);

      await finish(job.id, {
        gcal_event_id: ev.id,
        gcal_sync_status: "synced",
        gcal_synced_at: new Date().toISOString(),
        gcal_sync_error: null,
      });
      stats.synced++;
    } catch (e) {
      const transient = isTransient(e);
      await finish(job.id, {
        gcal_sync_status: transient ? "pending" : "error",
        gcal_sync_error: errMsg(e),
      });
      transient ? stats.retry++ : stats.failed++;
    }
  }

  return stats;
}

async function processDeleting(token: string) {
  const stats = { deleted: 0, deleteFailed: 0 };

  const { data, error } = await supabase
    .from(SYNC_TABLE)
    .select("*")
    .eq("gcal_sync_status", "deleting")
    .limit(BATCH_SIZE);
  if (error) throw error;

  for (const job of (data ?? []) as SyncJob[]) {
    try {
      // Fallback sull'ID deterministico: copre un evento creato ma mai registrato
      await deleteEvent(token, eventIdFor(job));

      const { error: delErr } = await supabase
        .from(SYNC_TABLE)
        .delete()
        .eq("id", job.id)
        .eq("gcal_sync_status", "deleting");
      if (delErr) throw delErr;
      stats.deleted++;
    } catch (e) {
      // Resta 'deleting': verrà ritentata al prossimo giro
      await supabase
        .from(SYNC_TABLE)
        .update({ gcal_sync_error: errMsg(e) })
        .eq("id", job.id)
        .eq("gcal_sync_status", "deleting");
      stats.deleteFailed++;
    }
  }

  return stats;
}

// ───────────────────────────── Entry point ─────────────────────────────

Deno.serve(async (req) => {
  // Solo il cron, che conosce CRON_SECRET, può avviare la sincronizzazione
  if (req.headers.get("x-cron-secret") !== CRON_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  try {
    const token = await getAccessToken();

    // Le due fasi sono indipendenti: un errore nella prima non blocca la seconda
    const result: Row = {};
    const errors: string[] = [];

    try {
      Object.assign(result, await syncPending(token));
    } catch (e) {
      console.error("gcal-sync: syncPending fallita", e);
      errors.push(`syncPending: ${errMsg(e)}`);
    }

    try {
      Object.assign(result, await processDeleting(token));
    } catch (e) {
      console.error("gcal-sync: processDeleting fallita", e);
      errors.push(`processDeleting: ${errMsg(e)}`);
    }

    if (errors.length) result.errors = errors;
    console.log("gcal-sync", result);
    return Response.json(result, { status: errors.length ? 500 : 200 });
  } catch (e) {
    console.error("gcal-sync fallita:", e);
    return Response.json({ error: errMsg(e) }, { status: 500 });
  }
});
