const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');

const router = express.Router();

// GET /api/songs
router.get('/', (req, res) => {
  const { category, deity, search, language } = req.query;
  const songs = db.getSongs({ category, deity, search, language });
  res.json({
    success: true,
    count: songs.length,
    data: songs,
  });
});

// GET /api/songs/:id
router.get('/:id', (req, res) => {
  const song = db.getSongById(req.params.id);
  if (!song) {
    return res.status(404).json({ success: false, error: 'Song not found' });
  }
  res.json({ success: true, data: song });
});

// POST /api/songs
router.post('/', (req, res) => {
  const {
    title,
    artist,
    categoryId,
    deityId,
    language,
    description,
    audioUrl,
    artworkUrl,
    durationSeconds,
    rights,
  } = req.body;

  if (!title || !artist || !categoryId || !deityId || !audioUrl) {
    return res.status(400).json({
      success: false,
      error: 'Title, artist, categoryId, deityId, and audioUrl are required.',
    });
  }

  // Validate devotional rights management
  if (!rights || !rights.rightsHolder || !rights.licenseReference) {
    return res.status(400).json({
      success: false,
      error: 'Rights management fields (rightsHolder, licenseReference) are required for every track.',
    });
  }

  const newSong = {
    id: uuidv4(),
    title: title.trim(),
    artist: artist.trim(),
    categoryId: categoryId.trim(),
    deityId: deityId.trim(),
    language: language || 'Hindi',
    description: description || '',
    audioUrl: audioUrl.trim(),
    artworkUrl: artworkUrl || '',
    durationSeconds: parseInt(durationSeconds, 10) || 300,
    featured: Boolean(req.body.featured),
    published: req.body.published !== false,
    rights: {
      rightsHolder: rights.rightsHolder,
      licenseReference: rights.licenseReference,
      permittedTerritories: rights.permittedTerritories || ['IN', 'GLOBAL'],
      permittedUsage: rights.permittedUsage || 'Streaming',
      commercialAuthorized: Boolean(rights.commercialAuthorized),
    },
    createdAt: new Date().toISOString(),
  };

  db.addSong(newSong);
  res.status(201).json({ success: true, data: newSong });
});

// PUT /api/songs/:id
router.put('/:id', (req, res) => {
  const updated = db.updateSong(req.params.id, req.body);
  if (!updated) {
    return res.status(404).json({ success: false, error: 'Song not found' });
  }
  res.json({ success: true, data: updated });
});

// DELETE /api/songs/:id
router.delete('/:id', (req, res) => {
  const deleted = db.deleteSong(req.params.id);
  if (!deleted) {
    return res.status(404).json({ success: false, error: 'Song not found' });
  }
  res.json({ success: true, message: 'Song deleted successfully' });
});

module.exports = router;
