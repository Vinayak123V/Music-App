# Bhakti Music — React & Node.js Architecture Guide

This document describes the **React + Node.js** stack for the **Bhakti Music** devotional audio streaming platform.

---

## 1. Architecture Overview

```
APP/
├── server/                         # Node.js + Express REST API & Streaming Engine
│   ├── src/
│   │   ├── config/
│   │   │   └── db.js              # Persistent JSON database with verified catalog
│   │   ├── data/
│   │   │   └── catalog.json       # Seed devotional tracks, deities & categories
│   │   ├── routes/
│   │   │   ├── songs.js           # GET /api/songs, POST, PUT, DELETE with rights validation
│   │   │   ├── categories.js      # GET /api/categories (Bhajans, Aartis, Mantras, etc.)
│   │   │   ├── deities.js         # GET /api/deities (Shiva, Hanuman, Krishna, Rama, etc.)
│   │   │   ├── stream.js          # GET /api/stream/:id (HTTP 206 Partial Content byte ranges)
│   │   │   └── admin.js           # Admin login, analytics stats, Multer file upload
│   │   └── server.js              # Express app, static /uploads & React client production host
│   ├── uploads/                   # Audio and cover artwork storage
│   └── package.json
│
├── client/                         # React 18 + Vite + Tailwind CSS Frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── layout/            # Navbar, Mobile BottomNav
│   │   │   ├── player/            # DockedMiniPlayer, FullPlayerModal, QueueDrawer
│   │   │   ├── common/            # SongTile, DeityPill, RightsBadge, DevotionalCard
│   │   │   └── admin/             # AdminUploadModal, Stats, Inventory Table
│   │   ├── context/
│   │   │   ├── PlayerContext.jsx  # HTML5 Audio + navigator.mediaSession lock-screen API
│   │   │   └── FavoritesContext.jsx # LocalStorage persistence for favorites & history
│   │   ├── pages/
│   │   │   ├── Home.jsx           # Track of the day hero, Deities scroll, Morning prayers
│   │   │   ├── Browse.jsx         # Category filters and Indian language selectors
│   │   │   ├── Search.jsx         # Live title, singer, deity & chant search
│   │   │   ├── Library.jsx        # Saved favorites & recently played history
│   │   │   └── AdminDashboard.jsx # Content upload, rights management & catalog table
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── index.css              # Saffron, Gold, Cream devotional palette
│   ├── vite.config.js             # Proxies /api and /uploads to port 5000 in dev
│   ├── tailwind.config.js
│   └── package.json
│
└── package.json                   # Root orchestrator scripts
```

---

## 2. Running the Application

### Option A: Run Full-Stack with One Command (Recommended)

From the project root:

```powershell
# 1. Start the unified production server (serves both API and React Web app on port 5000)
npm start
```
Then open your browser to **`http://localhost:5000`**.

---

### Option B: Run in Development Mode with Instant Hot Reload

Open two terminal tabs:

**Terminal 1 (Backend API):**
```powershell
cd server
npm run dev
# Starts backend on http://localhost:5000
```

**Terminal 2 (React Frontend with Vite):**
```powershell
cd client
npm run dev
# Starts frontend on http://localhost:3000 with < 50ms Hot Module Replacement
```

---

## 3. Key Features

1. **Native Web Audio & Lock-Screen MediaSession**:
   - Uses native HTML5 Audio (`<audio>`), eliminating CanvasKit and Web audio plugin crashes.
   - Syncs with `navigator.mediaSession` — shows artwork, title, and artist on Android notifications, phone lock-screen, and keyboard media keys.
2. **Devotional Design System**:
   - Warm Saffron (`#E65100`), subtle Gold (`#D4AF37`), and Cream (`#FFFDF8`).
   - Docked MiniPlayer with expand-to-Full-Player modal.
   - Deity quick filters (Lord Shiva, Hanuman, Krishna, Rama, Ganesha, Durga, Saraswati).
3. **Mandatory Rights Verification**:
   - Every track has explicit rights management: Rights Holder, License Reference Agreement, Permitted Territories, and Authorized Usage.
4. **Admin Console**:
   - Demo credentials: `admin@bhaktimusic.com` / `bhakti2026!`.
   - Upload MP3 audio and artwork images directly.
   - Full catalog delete, preview, and compliance statistics.
