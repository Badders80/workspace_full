# State Trap Map
Date: 2026-03-12
Status: ACTIVE

## Purpose

Map dynamic local-state dependencies that will block a clean Google Cloud move
unless they are first wrapped behind repository or service seams.

## Summary

The current blockers are not "Firestore is missing." The blockers are:

- direct SSOT reads from local `seed.json`
- direct HLT draft reads and writes to local folders
- browser `localStorage` as working persistence
- direct generated-file reads from `public/`
- local filesystem writes for investor updates
- hardcoded Google Sheets webhook sinks

## Evolution_Platform

### 1. Canonical SSOT read trap

- File: `src/lib/ssot/seed-loader.ts`
- Signals: lines `2`, `19`, `71`
- Current behavior: reads `../SSOT_Build/intake/v0.1/seed.json` directly from disk
- Why it blocks cloud: the platform is coupled to one local repo-relative file layout
- Future seam: `SsotReadRepository`

### 2. HLT draft persistence trap

- File: `src/app/api/ssot/hlt/route.ts`
- Signals: lines `2`, `85`, `87`, `174`, `176`
- Current behavior: lists, reads, and writes draft JSON files under `SSOT_Build/intake/v0.1/hlt_drafts`
- Why it blocks cloud: dynamic user-created data is stored as local JSON files
- Future seam: `HltDraftRepository`

### 3. Generated update catalog trap

- File: `src/app/api/updates/route.ts`
- Signals: lines `2`, `56`, `57`
- Current behavior: enumerates update HTML files from `public/updates`
- Why it blocks cloud: update discovery assumes local public-file storage
- Future seam: `InvestorUpdateCatalog`

### 4. Generated update content trap

- File: `app/updates/[slug]/page.tsx`
- Signals: lines `2`, `15`, `18`, `39`
- Current behavior: reads the update HTML file directly from `public/updates/<slug>.html`
- Why it blocks cloud: content delivery is coupled to local filesystem reads
- Future seam: `InvestorUpdateContentStore` or shared blob-backed update reader

### 5. Media catalog trap

- File: `src/app/api/media/prudentia/route.ts`
- Signals: lines `2`, `19`, `26`
- Current behavior: enumerates local video files in `public/videos/prudentia`
- Why it blocks cloud: media discovery assumes local public asset storage
- Future seam: `MediaCatalog` backed by local files first, then GCS

### 6. Lead capture sink trap

- Files:
  - `src/app/api/interest/route.ts`
  - `src/app/api/auth/[...nextauth]/route.ts`
- Signals:
  - `interest/route.ts`: lines `3` to `29`
  - `auth/[...nextauth]/route.ts`: lines `6` to `32`
- Current behavior: posts directly to a Google Sheets Apps Script endpoint, with a hardcoded fallback URL
- Why it blocks cloud: business event handling is tied to a single opaque webhook implementation
- Future seam: `LeadCaptureSink`

### 7. Legacy SQLite subtree

- File: `app/database/db.py`
- Signals: lines `27`, `62`
- Current behavior: references a local SQLite-backed embedded app subtree
- Why it blocks cloud: this is a parallel local-state surface inside the repo
- Recommendation: treat as archive candidate or explicitly re-scope it; do not mix it into the platform migration by accident

## SSOT_Build

### 1. Client persistence trap

- File: `App.tsx`
- Signals: lines `2067`, `2075`, `2080`, `2132`
- Current behavior:
  - loads browser `localStorage`
  - falls back to `/intake/v0.1/seed.json`
  - persists working state back to `localStorage`
- Why it blocks cloud: working edits are local-browser state, not shared or service-backed
- Future seam:
  - `SsotReadRepository` for canonical reads
  - `SsotClientStateStore` or `DraftStateStore` for in-progress edits

### 2. Seed sync trap

- File: `scripts/sync-seed.mjs`
- Signals: lines `5` to `13`
- Current behavior: copies `intake/v0.1/seed.json` into `public/intake/v0.1/seed.json`
- Why it blocks cloud: runtime data delivery assumes a duplicated static JSON file
- Future seam: build/export adapter or repository-backed snapshot export

### 3. Generated investor update write trap

- File: `vite.config.ts`
- Signals:
  - line `11` reads the central `.env`
  - line `70` defines `INVESTOR_UPDATES_ROOT`
  - lines `132` to `135` write update HTML to disk
- Current behavior: dev middleware saves generated investor updates into a local filesystem path
- Why it blocks cloud: generated document storage is local and Vite-server-specific
- Future seam: `GeneratedDocumentStore` or `BlobStore`

### 4. Central env file read trap

- File: `vite.config.ts`
- Signals: lines `5` to `16`
- Current behavior: manually reads `/home/evo/.env` from disk inside Vite config
- Why it blocks cloud: runtime config resolution is custom and local-file dependent
- Future seam: shared config loader or env adapter

## Recommended Seams

### Shared Seams

- `SsotReadRepository`
  - local implementation: reads `seed.json`
  - cloud implementation: reads Firestore
- `HltDraftRepository`
  - local implementation: JSON files
  - cloud implementation: Firestore collection
- `GeneratedDocumentStore`
  - local implementation: filesystem
  - cloud implementation: GCS
- `MediaCatalog`
  - local implementation: `public/` directory
  - cloud implementation: GCS listing plus metadata
- `LeadCaptureSink`
  - local implementation: current Apps Script webhook
  - cloud implementation: Cloud Run endpoint, Pub/Sub, or direct Firestore write depending on flow

## Rollout Order

1. Introduce `SsotReadRepository` in `Evolution_Platform` without changing behavior.
2. Add `HltDraftRepository` for the HLT API route.
3. Mirror the SSOT read seam in `SSOT_Build` so browser boot no longer hardcodes the seed path contract.
4. Move generated update and media access behind blob-oriented interfaces.
5. Replace direct Google Sheets webhook calls with a named sink interface.
6. Keep local implementations as the default until parity tests pass.

## Non-Goals For The Next Pass

- Do not delete `seed.json` yet.
- Do not remove `localStorage` fallback until repository-backed drafts exist.
- Do not move every historical Python or SQLite subtree into the cloud plan by default.
- Do not start Firestore writes from multiple surfaces before the seams are in place.
