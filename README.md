# EGPT — Studio EG

App Flutter per la gestione dello studio di personal training **Emanuele Guerra PT**: anagrafica clienti, pacchetti, sessioni, presenze e appuntamenti, con calendario integrato e funzionamento offline-first.

- **Admin** — gestisce clienti, pacchetti, agenda e presenze.
- **Utente** — area personale del cliente.

Il ruolo arriva dal JWT di Supabase (claim `auth_role`) e decide quale interfaccia viene aperta.

---

## Indice

- [Stack](#stack)
- [Modello dati](#modello-dati)
- [Architettura](#architettura)
    - [Services](#services)
    - [Sources](#sources)
    - [UI](#ui)
- [Autenticazione](#autenticazione)
- [Sincronizzazione con PowerSync](#sincronizzazione-con-powersync)
- [Calendari](#calendari)
- [Setup](#setup)
- [Struttura del progetto](#struttura-del-progetto)
- [Troubleshooting](#troubleshooting)

---

## Stack

| Ambito            | Pacchetti                                                        |
|-------------------|------------------------------------------------------------------|
| Backend           | `supabase_flutter` (Postgres, Auth, RLS)                         |
| Database locale   | `powersync`, `sqlite_async`, `sqlite3`                           |
| State management  | `provider` (`ChangeNotifier`)                                    |
| Calendario UI     | `flutter_calendar_agenda` (package interno)                      |
| Calendario device | `device_calendar_plus`                                           |
| Login             | `flutter_login`, provider OAuth (Google)                         |
| Configurazione    | `flutter_dotenv`                                                 |
| Utility           | `uuid`, `path`, `path_provider`, `intl`, `font_awesome_flutter`  |
| Localizzazione    | `flutter_localizations` — `it_IT` predefinito, `en_US` supportato |

---

## Modello dati

```
members ──< products ──< sessions
                     ├──< presences   (id = id della session)
                     └──< meetings    (ricorrenti via RRULE)
```

| Tabella     | Colonne principali                                                         |
|-------------|----------------------------------------------------------------------------|
| `members`   | `name`, `first_name`, `last_name`, `birth`, `color`, `email`, `phone`      |
| `products`  | `member_id`, `summary`, `length`, `start`, `stop`                          |
| `sessions`  | `product_id`                                                               |
| `presences` | `product_id`, `start`, `stop`, `presence` (0/1)                            |
| `meetings`  | `product_id`, `start`, `stop`, `recurrence_rule` (ICS), `recurrence_id`    |

Tutte le tabelle hanno `id` (UUID generato lato client), `created_at` e `updated_at`.

- Un **product** è un pacchetto di sessioni con durata (`length`) e validità (`start`–`stop`). Il suo stato (in corso, in scadenza, completato, scaduto) determina icona e colore in UI.
- Una **presence** registra se il cliente si è presentato a una sessione e condivide l'`id` con la `session` corrispondente.
- I **meeting** sono gli appuntamenti in agenda. Le ricorrenze sono salvate come RRULE; le eccezioni puntano al meeting padre con `recurrence_id`.
- Date e orari sono salvati come stringhe e convertiti nel fuso `Europe/Rome`, inizializzato all'avvio.

Le eliminazioni a cascata (member → products → meetings/presences) sono eseguite dal client dentro una transazione locale.

---

## Architettura

```
┌──────────────────────────────────────────────────────────┐
│ UI          AuthGate → LoginPage / AdminPage / UserPage   │
├──────────────────────────────────────────────────────────┤
│ Sources     ServiceSource (AdminSource, …)                │
│             ├─ RegisterSource  (members, products)        │
│             ├─ ScheduleSource  (meetings, presences, dev) │
│             └─ PersonalSource  (sessions del cliente)     │
├──────────────────────────────────────────────────────────┤
│ Services    EGPTServices                                  │
│             ├─ AuthService      → SupabaseService         │
│             ├─ DatabaseService  → PowerSyncService        │
│             ├─ ProviderService  → GoogleService           │
│             └─ CalendarService  → DeviceCalendar          │
├──────────────────────────────────────────────────────────┤
│ Dati        SQLite locale (PowerSync)  ⇄  Supabase        │
└──────────────────────────────────────────────────────────┘
```

### Services

`EGPTServices` è la composition root: viene creata in `main()` e passata all'albero con `Provider`.

- **`SupabaseService`** (singleton) implementa `AuthService`: login email/password e OAuth, lettura del ruolo dal JWT, elenco delle identità collegate.
- **`PowerSyncService`** (singleton) implementa `DatabaseService`: schema locale, CRUD in transazione, builder iniziali e stream reattivi.
- **`LocalService`** definisce nomi di tabelle e colonne e la conversione modello ⇄ riga.
- **`ProviderService`** astrae un provider di identità (Google, Apple): autenticazione nativa, token da passare a Supabase, eventuale calendario associato.
- **`DeviceCalendar`** implementa `CalendarService` sui calendari del dispositivo.

### Sources

Le source tengono in memoria lo stato dell'app e notificano la UI. Ogni collezione implementa `EGPTData<T>`:

```dart
abstract interface class EGPTData<T extends EGPTItem> {
  Map<String, T> get();
  void set(Iterable<T> data);
  void add(Iterable<T> items);
  void put(Iterable<T> items);
  void del(Iterable<T> items);
}
```

| Source           | Contenuto                                                                                       |
|------------------|-------------------------------------------------------------------------------------------------|
| `RegisterSource` | Singleton. `MemberSource` e `ProductSource` (indicizzati per member). Statistiche: membri attivi, in avviso, fermi; miglior e peggior rapporto sessioni fatte/da recuperare. |
| `ScheduleSource` | Singleton, è un `CalendarSources<Event>`. Contiene `MeetingSource` e `PresenceSource` e vi si agganciano i calendari del dispositivo. |
| `PersonalSource` | Sessioni di un singolo membro, raggruppate per product. Si ricostruisce quando cambia la source padre. |
| `ServiceSource`  | Classe astratta con il contratto CRUD; `AdminSource` la implementa per l'interfaccia admin.     |

**`DatabaseSource<T>`** riconcilia il risultato di una query osservata con la collezione in memoria: calcola le differenze (`create`, `update`, `delete`), le applica e restituisce `null` se non è cambiato nulla. È usata da `watchMembers`, `watchProducts`, `watchMeetings` e `watchPresences`.

**Gestione errori.** Le operazioni lanciano eccezioni tipizzate (`MissingMemberException`, `MissingProductException`, `MissingSessionException`, `MissingMeetingException`, `MissingPresenceException`). Su un `RegisterException` la source rifà il `build()` completo per riallinearsi.

**Ordine delle scritture in `AdminSource`.**
- I **meeting** sono ottimistici: prima aggiornano il calendario, poi il database.
- Member, product, session e presence scrivono prima nel database, poi aggiornano le source.

### UI

- **`AuthGate`** — spinner finché l'auth non è inizializzata, poi `LoginPage` senza sessione, `AdminPage` se `privileged`, altrimenti `UserPage`.
- **`AdminPage`** — crea l'`AdminSource` in `initState` e la espone con `ChangeNotifierProvider.value` insieme alla `RegisterSource`. Tre tab in basso: **Agenda**, **Presenze** (home) e **Registro**. Il drawer permette di mostrare o nascondere i calendari (Appuntamenti, Sessioni e quelli privati del dispositivo), cambiare tema e fare logout.
- **Tema** — Material 3 con seed `#72B13F`, chiaro/scuro gestito da `ThemeController`. L'estensione `WarningColors` su `ColorScheme` aggiunge una palette ambra per gli stati di avviso.

---

## Autenticazione

1. Login con email/password oppure con un provider OAuth (`signInWithIdToken`).
2. Supabase rifiuta la registrazione di indirizzi non in allowlist tramite l'hook **before-user-created**.
3. L'hook **custom access token** aggiunge il claim `auth_role` al JWT.
4. Il client decodifica il token: `AuthRole.admin` → interfaccia admin.
5. Se il ruolo manca il login fallisce con "User role undefined."
6. Al logout `EGPTServices.signOut()` disconnette i provider, svuota il database locale e chiude la sessione.

> Il recupero password (`recoverPassword`) non è ancora implementato.

---

## Sincronizzazione con PowerSync

- Il database locale è `egpt-powersync.db` nella cartella di supporto dell'app.
- La connessione parte all'avvio se c'è già una sessione e segue gli eventi di auth: connessione al login, `disconnectAndClear()` al logout, refresh delle credenziali al rinnovo del token.
- I builder (`buildRegister`, `buildSchedule`, `buildPersonal`) attendono la prima sincronizzazione prima di leggere.
- Gli stream usano `db.watch` con throttle di 30 ms.

**Upload (`SupabaseConnector.uploadData`)** — ogni operazione CRUD in coda viene inviata a PostgREST:

| Operazione PowerSync | Chiamata Supabase           |
|----------------------|-----------------------------|
| `put`                | `upsert` con `id`           |
| `patch`              | `update … eq('id', id)`     |
| `delete`             | `delete … eq('id', id)`     |

Un errore PostgREST con codice (violazione di vincolo, RLS) viene loggato e la transazione viene scartata, così la coda non si blocca. Gli errori di rete vengono rilanciati e PowerSync riprova.

Le scritture vanno direttamente sulle tabelle, quindi **le policy RLS su Supabase sono l'unico controllo di accesso**.

---

## Calendari

**Dispositivo** (`DeviceCalendar`)
- Chiede i permessi e legge tutti i calendari visibili.
- Esclude i calendari nascosti e quello identificato da `EGPT_ROOT:EGPT_CALENDAR`, per non mostrare due volte gli appuntamenti già gestiti dall'app.
- Gli eventi hanno id `device:<instanceId>`; quelli annullati vengono scartati.
- L'intervallo caricato si allarga con la navigazione nel calendario e viene ricaricato al ritorno in primo piano dell'app.

**Provider OAuth** — `EGPTServices.calendar` è predisposto per usare il calendario del provider collegato all'utente (es. Google). Al momento restituisce sempre il calendario del dispositivo.

---

## Setup

### 1. Dipendenze

```bash
flutter pub get
```

### 2. File `.env`

Nella root del progetto, dichiarato tra gli asset in `pubspec.yaml`:

```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<publishable-key>
EGPT_ROOT=<email account principale>
EGPT_CALENDAR=<nome del calendario condiviso dello studio>
```

### 3. Supabase

- Tabelle `members`, `products`, `sessions`, `presences`, `meetings` con le colonne del [modello dati](#modello-dati).
- Policy RLS basate su `auth_role` per tutte le tabelle.
- Auth hook **before-user-created** (allowlist) e **custom access token** (`auth_role`).
- Provider Google abilitato in *Authentication → Providers*.

Per esportare la struttura del progetto Supabase:

```bash
supabase link --project-ref <ref>
supabase db dump -f supabase/schema.sql
supabase functions download <nome>
```

### 4. PowerSync

- Istanza collegata al database Supabase, con autenticazione tramite JWT Supabase.
- Sync stream per le cinque tabelle del modello.
- L'endpoint è impostato in `SupabaseConnector.fetchCredentials()`.

### 5. Google Sign-In

- **Android**: registrare SHA-1 (debug e release) e package name in un client OAuth Android; usare il Web client ID come `serverClientId`.
- **iOS**: aggiungere il reversed client ID agli URL scheme in `Info.plist`.

### 6. Avvio

```bash
flutter run
```

---

## Struttura del progetto

```
lib/
├── main.dart                 # bootstrap: timezone, .env, Supabase, PowerSync, Provider
├── auth.dart                 # AuthGate
├── login.dart                # LoginPage (flutter_login)
├── style.dart                # tema, ThemeController, colori di stato
├── types.dart                # EGPTItem, EGPTData, eccezioni
├── models/                   # Member, Product, Session, Presence, Meeting
├── services/
│   ├── api/                  # interfacce: Auth, Database, Calendar, Provider
│   ├── providers/            # GoogleService
│   ├── egpt_services.dart    # composition root
│   ├── supabase_service.dart
│   ├── powersync_service.dart
│   ├── local_service.dart    # schema e mapping SQLite
│   └── device_service.dart   # calendari del dispositivo
├── sources/
│   ├── source_services.dart  # ServiceSource
│   ├── source_register.dart  # RegisterSource
│   ├── source_schedule.dart  # ScheduleSource
│   ├── source_personal.dart  # PersonalSource
│   └── source_database.dart  # DatabaseSource (riconciliazione)
├── admin/                    # AdminPage, AdminSource e tab
├── user/                     # UserPage
├── widgets/
└── utils/
```

---

