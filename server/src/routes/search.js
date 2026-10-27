const express = require('express');
const ytSearch = require('yt-search');

const router = express.Router();

// Cache search queries in memory for 10 minutes to make repeated searches instant
const searchCache = new Map();

// GET /api/search/live?q=...
router.get('/live', async (req, res) => {
  const query = req.query.q;
  if (!query || !query.trim()) {
    return res.json({ success: true, count: 0, data: [] });
  }

  const cleanQuery = query.trim();
  const cacheKey = cleanQuery.toLowerCase();

  if (searchCache.has(cacheKey)) {
    return res.json({
      success: true,
      count: searchCache.get(cacheKey).length,
      data: searchCache.get(cacheKey),
      cached: true,
    });
  }

  try {
    // Search YouTube Music & devotional audio
    const results = await ytSearch(cleanQuery);
    const videos = (results.videos || []).slice(0, 20);

    const formattedTracks = videos.map(v => {
      // Clean up common video title noise (like [Full Song], HD Video, etc.)
      const cleanedTitle = v.title
        .replace(/\[.*?\]/g, '')
        .replace(/\(.*?\)/g, '')
        .replace(/full video song/i, '')
        .replace(/video song/i, '')
        .replace(/official video/i, '')
        .trim();

      return {
        id: `yt-${v.videoId}`,
        title: cleanedTitle || v.title,
        originalTitle: v.title,
        artist: v.author?.name || 'Devotional Artist',
        artworkUrl: v.thumbnail || `https://i.ytimg.com/vi/${v.videoId}/hq720.jpg`,
        durationSeconds: v.seconds || 300,
        videoId: v.videoId,
        source: 'youtube',
        language: detectLanguage(v.title + ' ' + (v.author?.name || '')),
        categoryId: detectCategory(v.title),
        deityId: detectDeity(v.title),
      };
    });

    searchCache.set(cacheKey, formattedTracks);
    // Auto purge cache if too large
    if (searchCache.size > 200) {
      const firstKey = searchCache.keys().next().value;
      searchCache.delete(firstKey);
    }

    res.json({
      success: true,
      count: formattedTracks.length,
      data: formattedTracks,
    });
  } catch (err) {
    console.error('[LiveSearch] Error:', err);
    res.status(500).json({ success: false, error: 'Failed to search live music' });
  }
});

// Helper heuristic functions to tag language, category and deity automatically
function detectLanguage(text) {
  const t = text.toLowerCase();
  if (/[\u0C80-\u0CFF]/.test(text) || t.includes('kannada')) return 'Kannada';
  if (/[\u0900-\u097F]/.test(text)) {
    if (t.includes('stotram') || t.includes('mantra') || t.includes('suktam')) return 'Sanskrit';
    return 'Hindi';
  }
  if (/[\u0B80-\u0BFF]/.test(text) || t.includes('tamil')) return 'Tamil';
  if (/[\u0C00-\u0C7F]/.test(text) || t.includes('telugu')) return 'Telugu';
  if (/[\u0980-\u09FF]/.test(text) || t.includes('bengali')) return 'Bengali';
  if (t.includes('marathi')) return 'Marathi';
  return 'Hindi';
}

function detectCategory(text) {
  const t = text.toLowerCase();
  if (t.includes('aarti') || t.includes('आरती')) return 'aartis';
  if (t.includes('chalisa') || t.includes('चालीसा')) return 'chalisa';
  if (t.includes('mantra') || t.includes('मंत्र') || t.includes('chant')) return 'mantras';
  if (t.includes('stotram') || t.includes('stotra') || t.includes('स्तोत्र')) return 'stotrams';
  return 'bhajans';
}

function detectDeity(text) {
  const t = text.toLowerCase();
  if (t.includes('shiva') || t.includes('shiv') || t.includes('mahadev') || t.includes('bholenath') || t.includes('शिव')) return 'shiva';
  if (t.includes('hanuman') || t.includes('bajrang') || t.includes('मारुति') || t.includes('हनुमान')) return 'hanuman';
  if (t.includes('krishna') || t.includes('kanha') || t.includes('govind') || t.includes('radha') || t.includes('कृष्ण')) return 'krishna';
  if (t.includes('ram') || t.includes('rama') || t.includes('raghu') || t.includes('सिया') || t.includes('राम')) return 'rama';
  if (t.includes('ganesh') || t.includes('ganpati') || t.includes('vinayak') || t.includes('गणेश')) return 'ganesha';
  if (t.includes('durga') || t.includes('ambe') || t.includes('devi') || t.includes('kali') || t.includes('दुर्गा')) return 'durga';
  if (t.includes('saraswati') || t.includes('sharada') || t.includes('सरस्वती')) return 'saraswati';
  return 'shiva';
}

module.exports = router;
