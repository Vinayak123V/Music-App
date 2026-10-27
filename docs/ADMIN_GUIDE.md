# Administrator Operations & Content Guide

This document describes daily administrative workflows for managing the **Bhakti Music** streaming platform.

---

## 1. Accessing the Dashboard

1. Launch Flutter Web build or navigate to `/admin/login`.
2. Enter your authorized administrator email and password.
3. Upon successful verification, you will be redirected to `/admin/dashboard`.

> [!IMPORTANT]
> Non-admin users attempting to log in will receive an "Access denied" notification, enforced both on client routes and by Firestore Security Rules.

---

## 2. Devotional Upload Workflow

When uploading new tracks (Bhajans, Aartis, Mantras, Chants):

1. Click **Add Devotional Song** in the top-right of the **Songs** tab.
2. Fill in the required metadata:
   - **Song Title**: Full sacred title (e.g., *Shree Hanuman Chalisa*).
   - **Artist / Singer**: Vocalist or tradition (e.g., *Pt. Jasraj* or *Traditional*).
   - **Deity**: Choose the dedicated deity (e.g., *Lord Hanuman*).
   - **Category**: Select *Chalisa*, *Bhajan*, *Aarti*, *Mantra*, etc.
   - **Language**: Choose *Hindi*, *Sanskrit*, *Kannada*, *Telugu*, etc.
   - **Duration**: Duration in seconds (e.g., `588` for 9m 48s).
3. Select audio file:
   - Must be MP3, M4A, or AAC format.
   - Maximum file size: **50 MB**.
4. Select cover artwork:
   - JPG or PNG format.
   - Maximum file size: **5 MB**.
   - Square 1:1 ratio recommended.
5. Enter **Rights & Licensing Record**:
   - Rights Holder name (e.g., *Bhakti Records India*).
   - License Reference # (e.g., *BM-2026-HN-01*).
   - Commercial authorized checkbox.
6. Toggle **Publish Immediately** or keep as draft.
7. Click **Upload & Publish**.

The system will:
1. Upload the audio to `audio/{songId}/original.mp3` in Cloud Storage.
2. Upload the artwork to `artwork/{songId}/cover.jpg`.
3. Save metadata and search tokens to `songs/{songId}` in Cloud Firestore.
4. Notify all connected mobile clients in real-time.

---

## 3. Previewing and Editing Audio

- To preview an audio track before publishing, click the **Play** icon next to the song in the admin catalog table.
- To modify metadata or replace the audio file, click the **Edit** icon.
- To take a song down immediately (e.g., in case of a rights inquiry), toggle the **Publish** switch to off. The change takes effect instantaneously.

---

## 4. Managing Categories & Festivals

- Navigate to the **Categories** tab to enable or disable genres (e.g., *Stotrams*, *Evening Prayers*).
- Navigate to the **Playlists** tab to create festival-specific collections (e.g., *Maha Shivaratri*, *Navratri Chants*, *Janmashtami Bhajans*).
