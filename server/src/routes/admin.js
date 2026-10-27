const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const db = require('../config/db');

const router = express.Router();

// Setup Multer Storage for audio & artwork uploads
const uploadsDir = path.join(__dirname, '..', '..', 'uploads');
const audioDir = path.join(uploadsDir, 'audio');
const artworkDir = path.join(uploadsDir, 'artwork');

[uploadsDir, audioDir, artworkDir].forEach(dir => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.mimetype.startsWith('audio/')) {
      cb(null, audioDir);
    } else {
      cb(null, artworkDir);
    }
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const base = path.basename(file.originalname, ext).replace(/[^a-zA-Z0-9_-]/g, '_');
    cb(null, `${base}-${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
});

// POST /api/admin/login
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (
    (email === 'admin@bhaktimusic.com' || email === 'admin') &&
    (password === 'bhakti2026!' || password === 'admin123')
  ) {
    return res.json({
      success: true,
      token: 'bhakti-admin-jwt-token-2026',
      user: {
        email: 'admin@bhaktimusic.com',
        role: 'super_admin',
        name: 'Bhakti Administrator',
      },
    });
  }
  return res.status(401).json({ success: false, error: 'Invalid admin credentials' });
});

// GET /api/admin/stats
router.get('/stats', (req, res) => {
  const songs = db.getSongs();
  const deities = db.getDeities();
  const categories = db.getCategories();

  const rightsVerifiedCount = songs.filter(s => s.rights && s.rights.licenseReference).length;

  res.json({
    success: true,
    data: {
      totalSongs: songs.length,
      totalDeities: deities.length,
      totalCategories: categories.length,
      rightsVerifiedCount,
      rightsComplianceRatio: songs.length ? Math.round((rightsVerifiedCount / songs.length) * 100) : 100,
    },
  });
});

// POST /api/admin/upload
router.post('/upload', upload.fields([
  { name: 'audio', maxCount: 1 },
  { name: 'artwork', maxCount: 1 },
]), (req, res) => {
  const host = `${req.protocol}://${req.get('host')}`;
  const responseData = {};

  if (req.files.audio && req.files.audio[0]) {
    responseData.audioUrl = `${host}/uploads/audio/${req.files.audio[0].filename}`;
  }
  if (req.files.artwork && req.files.artwork[0]) {
    responseData.artworkUrl = `${host}/uploads/artwork/${req.files.artwork[0].filename}`;
  }

  res.json({
    success: true,
    data: responseData,
  });
});

module.exports = router;
