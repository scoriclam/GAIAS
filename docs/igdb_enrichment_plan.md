# IGDB Enrichment Plan

## Purpose

The IGDB enrichment process will automate selected external game metadata while preserving user-maintained fields, data lineage, and existing GAIAS data-quality controls.

## Design Principle

IGDB data will not directly overwrite user-maintained or curated GAIAS data.

The enrichment flow will follow:

IGDB API → External Staging → Validation and Conflict Resolution → Curated GAIAS Model → Analytical and Recommendation Layers

## Initial Field Ownership

### IGDB-Sourced Fields

- IGDB ID
- Release Date
- Genre
- Theme
- Game Mode
- Player Perspective

### User-Maintained Fields

- Owned Status
- Acquisition Source
- Storage Location
- Organization Folder
- Play Status
- Personal Rating
- Comments
- Wishlist Status

### GAIAS-Derived Fields

- Recommendation Score
- Taste Affinity
- Playability Adjustment
- Quality Composite
- Recommendation Status
- Recommendation Context
- Data Quality Flags

## Source Precedence and Conflict Rules

### General Rule

IGDB is an enrichment source, not the authoritative owner of all GAIAS fields.

Existing user-maintained values will not be overwritten automatically.

### IGDB ID

- If a trusted IGDB ID already exists, preserve it.
- If no IGDB ID exists, the enrichment process may assign one after a successful title/platform match.
- If multiple plausible IGDB matches are returned, do not assign an ID automatically.
- Ambiguous matches must be routed to review.

### Release Date

- Preserve a trusted existing release date when it has already passed validation.
- If the existing release date is missing, IGDB may supply a candidate release date.
- If IGDB conflicts with an existing trusted release date, preserve the existing value and flag the conflict for review.
- Future release dates are allowed when the game is legitimately unreleased.

### Genre, Theme, Game Mode, and Player Perspective

- IGDB may enrich missing classifications.
- Existing curated classifications should not be removed solely because IGDB does not return the same value.
- New IGDB classifications may be added when they map cleanly to the GAIAS classification model.
- Unmapped or unexpected IGDB values should be staged for review before entering the curated model.

### User-Maintained Fields

IGDB must never overwrite:

- Owned Status
- Acquisition Source
- Storage Location
- Organization Folder
- Play Status
- Personal Rating
- Comments
- Wishlist Status

### Conflict Handling

Conflicts should be preserved as data-quality events rather than silently resolved.

Each conflict should retain:

- Game identifier
- Field name
- Existing GAIAS value
- IGDB value
- Conflict type
- Review status
- Resolution value, when applicable
- Resolution date, when applicable

## Raw IGDB Staging Design

### Purpose

The raw IGDB staging layer will preserve data returned by the IGDB API before validation, matching, conflict resolution, or promotion into curated GAIAS structures.

This layer provides source lineage and allows IGDB responses to be reviewed without modifying existing GAIAS records.

### Proposed Staging Table

The initial staging table will be named:

`stg_igdb_game_raw`

### Proposed Fields

- `GAIASGameID` — GAIAS game identifier associated with the enrichment request
- `SearchTitle` — title submitted to IGDB
- `SearchPlatform` — platform used to help identify the correct game
- `IGDBID` — IGDB game identifier returned by the API
- `IGDBName` — game title returned by IGDB
- `ReleaseDate` — release date returned by IGDB
- `GenresRaw` — raw genre values returned by IGDB
- `ThemesRaw` — raw theme values returned by IGDB
- `GameModesRaw` — raw game mode values returned by IGDB
- `PlayerPerspectivesRaw` — raw player perspective values returned by IGDB
- `RawPayload` — preserved API response for lineage and troubleshooting
- `FetchStatus` — result of the API request
- `FetchedAt` — date and time the response was retrieved

### Staging Rules

- API responses will be written to staging before any curated GAIAS tables are updated.
- Raw source values will be preserved without silently modifying them.
- Missing or failed API responses will retain a fetch status for troubleshooting.
- Ambiguous matches will remain in staging until reviewed.
- Staging records may be refreshed without changing user-maintained GAIAS fields.
- Promotion from staging into curated structures will occur through separate validation and resolution logic.