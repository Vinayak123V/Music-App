const express = require('express');
const fs = require('fs');
const path = require('path');
const db = require('../config/db');

const router = express.Router();

// GET /api/stream/:id
router.get('/:id', (req, res) => {
  const song = db.getSongById(req.params.id);
  if (!song) {
    return res.status(404).json({ success: false, error: 'Song not found' });
  }

  // If the song has a remote audioUrl, redirect to it directly (supports CDN caching & CORS)
  if (song.audioUrl && (song.audioUrl.startsWith('http://') || song.audioUrl.startsWith('https://'))) {
    return res.redirect(song.audioUrl);
  }

  // Otherwise, handle local audio file streaming with HTTP 206 Partial Content
  const filePath = path.join(__dirname, '..', '..', song.storagePath || '');
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ success: false, error: 'Audio file not found on disk' });
  }

  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const chunksize = end - start + 1;
    const file = fs.createReadStream(filePath, { start, end });
    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'audio/mpeg',
    };
    res.writeHead(206, head);
    file.pipe(res);
  } else {
    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'audio/mpeg',
    };
    res.writeHead(200, head);
    fs.createReadStream(filePath).pipe(res);
  }
});

module.exports = router;
