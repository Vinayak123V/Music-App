# Bhakti Music — Firebase Backend Setup Guide

This guide walks you through setting up and connecting the Firebase backend for the **Bhakti Music** streaming app and administration dashboard.

---

## 1. Create Firebase Project

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and enter a name: `bhakti-music-prod` (or your preferred name).
3. Enable **Google Analytics** (recommended for devotional playback tracking).
4. Click **Create Project**.

---

## 2. Enable Firebase Authentication

1. In the Firebase Console left sidebar, click **Build > Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab, enable **Email/Password**.
   - Note: Do NOT enable public registration or anonymous accounts unless needed; administrator accounts are created directly or authorized in Firestore.
4. Click **Save**.

---

## 3. Create Cloud Firestore Database

1. In the Firebase Console, navigate to **Build > Firestore Database**.
2. Click **Create Database**.
3. Choose your database location:
   - For Indian devotees: `asia-south1` (Mumbai) offers the lowest latency.
4. Choose **Start in production mode** (our security rules in `firebase/firestore.rules` will govern access).
5. Click **Enable**.

---

## 4. Create Cloud Storage Bucket

1. In the Firebase Console, navigate to **Build > Storage**.
2. Click **Get Started**.
3. Select the same region: `asia-south1` (Mumbai).
4. Finish wizard with standard settings.

---

## 5. Configure Security Rules

Deploy the included security rules using the Firebase CLI:

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Associate project
firebase use --add

# Deploy Firestore Security Rules & Indexes
firebase deploy --only firestore:rules,firestore:indexes

# Deploy Cloud Storage Security Rules
firebase deploy --only storage
```

The deployed rules enforce:
- Public listeners can read only `published == true` songs and enabled categories.
- Only authorized administrators can upload audio, alter metadata, or publish songs.
- File types are strictly validated (audio files up to 50MB; image artwork up to 5MB).
- Users can access only their own favorites and playlists.

---

## 6. Create Your First Administrator

To authorize an administrator:

### Step A: Create User in Firebase Authentication
1. In Firebase Console, go to **Authentication > Users**.
2. Click **Add User**.
3. Enter email: e.g. `admin@bhaktimusic.app` and a strong password.
4. Copy the generated **User UID** (e.g. `Abc123XyZ456...`).

### Step B: Add Administrator Document in Firestore
1. Navigate to **Firestore Database > Data**.
2. Click **Start Collection**.
3. Collection ID: `admins`.
4. Document ID: Paste the **User UID** copied from Step A.
5. Add fields:
   - `email`: string `admin@bhaktimusic.app`
   - `role`: string `superadmin`
   - `createdAt`: timestamp (current time)
6. Click **Save**.

Now this user is fully recognized by both the frontend router and backend Firestore/Storage Security Rules as an authorized administrator.

---

## 7. Connect Mobile & Web Clients

Run FlutterFire CLI in the project root to automatically generate `lib/core/config/firebase_options.dart`:

```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Android and Web
flutterfire configure --project=YOUR_PROJECT_ID --platforms=android,web
```

Or copy your Project ID, API Keys, and Storage Bucket into `lib/core/config/firebase_options.dart`.

---

## 8. Seed Initial Devotional Catalog

To seed the initial library of sacred songs, deities, and categories:

```bash
dart run tools/seed_database.dart
```

Once seeded, the published songs will immediately appear on all Android devices running Bhakti Music without requiring any app update!
