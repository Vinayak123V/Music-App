# Cloud Firestore Database Schema

The Bhakti Music database schema is designed for scale, predictable low-cost queries, and strict access controls.

---

## 1. Collection: `songs`

Stores metadata, audio storage pointers, and streaming rights for all devotional tracks.

| Field Name | Type | Description | Required |
|------------|------|-------------|----------|
| `id` | string | Unique song ID (matches storage folder) | Yes |
| `title` | string | Display title (e.g. *Shiva Tandava Stotram*) | Yes |
| `normalizedTitle` | string | Lowercase, diacritic-stripped title for fast prefix querying | Yes |
| `artist` | string | Singer, acharya, or traditional source | Yes |
| `categoryId` | string | Foreign key referencing `categories.id` (e.g. `bhajans`) | Yes |
| `deityId` | string | Foreign key referencing `deities.id` (e.g. `shiva`) | Yes |
| `language` | string | Supported language (e.g. `Hindi`, `Sanskrit`, `Kannada`) | Yes |
| `description` | string | Spiritual context and theological meaning | Optional |
| `storagePath` | string | Cloud Storage path: `audio/{songId}/original.mp3` | Yes |
| `audioUrl` | string | Resolved HTTPS audio download/streaming URL | Optional |
| `artworkPath` | string | Cloud Storage path: `artwork/{songId}/cover.jpg` | Optional |
| `artworkUrl` | string | Resolved HTTPS cover artwork URL | Optional |
| `durationSeconds` | number | Audio duration in seconds | Optional |
| `published` | boolean | True if track is visible to public listeners | Yes |
| `featured` | boolean | True if featured on top of mobile Home screen | Yes |
| `searchTokens` | array<string> | Indexed keywords for Firestore keyword search | Yes |
| `createdAt` | timestamp | Timestamp when track was added | Yes |
| `updatedAt` | timestamp | Timestamp when metadata was last updated | Yes |
| `createdBy` | string | UID of administrator who uploaded the song | Yes |
| `rights` | map | Nested licensing and copyright verification record | Optional |

### Nested Map: `rights`

| Field Name | Type | Description |
|------------|------|-------------|
| `rightsHolder` | string | Entity or artist holding copyright |
| `licenseReference` | string | Agreement or contract identifier |
| `permittedTerritories` | array<string> | Authorized regions (e.g. `['IN', 'GLOBAL']`) |
| `permittedUsage` | string | Authorized use (e.g. `Digital Streaming`) |
| `licenseStartDate` | timestamp | License commencement date |
| `licenseEndDate` | timestamp | License expiration date |
| `commercialAuthorized`| boolean | True if commercial streaming is authorized |

---

## 2. Collection: `categories`

Stores genres and types of devotional audio.

| Field Name | Type | Description | Required |
|------------|------|-------------|----------|
| `id` | string | Category identifier (e.g. `bhajans`, `aartis`) | Yes |
| `name` | string | Display name | Yes |
| `slug` | string | URL slug | Yes |
| `type` | string | Genre classifier | Yes |
| `artworkPath` | string | Storage path for category hero image | Optional |
| `sortOrder` | number | Display sort index | Yes |
| `enabled` | boolean | If false, hidden from public app | Yes |
| `description` | string | Description for devotees | Optional |

---

## 3. Collection: `deities`

Stores deity categories and iconography.

| Field Name | Type | Description | Required |
|------------|------|-------------|----------|
| `id` | string | Deity ID (e.g. `shiva`, `krishna`, `rama`) | Yes |
| `name` | string | Full deity name | Yes |
| `slug` | string | Slug identifier | Yes |
| `title` | string | Divine titles (e.g. *Mahadev, Bholenath*) | Yes |
| `description` | string | Spiritual lore and significance | Yes |
| `iconName` | string | Icon identifier | Yes |
| `sortOrder` | number | Sorting position | Yes |

---

## 4. Collection: `playlists`

Admin-curated collections and festival specials.

| Field Name | Type | Description | Required |
|------------|------|-------------|----------|
| `id` | string | Playlist ID | Yes |
| `title` | string | Playlist title (e.g. *Maha Shivaratri Special*) | Yes |
| `description` | string | Curatorial description | Optional |
| `artworkPath` | string | Storage path for playlist cover | Optional |
| `songIds` | array<string> | Ordered list of `songs.id` | Yes |
| `language` | string | Target language | Yes |
| `published` | boolean | Visibility status | Yes |
| `createdAt` | timestamp | Creation date | Yes |

---

## 5. Collection: `admins`

Administrator whitelist for role-based authorization.

| Field Name | Type | Description |
|------------|------|-------------|
| `id` (Doc ID) | string | Firebase Authentication UID |
| `email` | string | Administrator email |
| `role` | string | `superadmin` or `editor` |
| `createdAt` | timestamp | Access granted date |

---

## 6. Subcollections under `users/{userId}`

- `users/{userId}/favorites/{songId}`: Stores user favorite song IDs.
- `users/{userId}/playbackHistory/{historyId}`: Stores recent tracks played by devotee.
- `users/{userId}/personalPlaylists/{playlistId}`: Devotee-created playlists.
