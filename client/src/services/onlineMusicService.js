import { CapacitorHttp, Capacitor } from '@capacitor/core';
import { apiFetch } from '../config/api';
import { seedCatalog } from '../data/seedCatalog';

// In-memory cache for fast responsive search experience
const searchCache = new Map();

export function parseDurationText(str) {
  if (!str) return 300;
  const parts = str.split(':').map(Number);
  if (parts.length === 3) return parts[0] * 3600 + parts[1] * 60 + parts[2];
  if (parts.length === 2) return parts[0] * 60 + parts[1];
  return 300;
}

export function cleanTitle(raw) {
  if (!raw) return 'Devotional Song';
  return raw
    .replace(/\[.*?\]/g, '')
    .replace(/\(.*?\)/g, '')
    .replace(/full video song/i, '')
    .replace(/video song/i, '')
    .replace(/official video/i, '')
    .replace(/lyrical video/i, '')
    .replace(/4k video/i, '')
    .replace(/hd video/i, '')
    .trim();
}

export function detectLanguage(text) {
  if (!text) return 'Hindi';
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

export function detectCategory(text) {
  if (!text) return 'bhajans';
  const t = text.toLowerCase();
  if (t.includes('aarti') || t.includes('आरती')) return 'aartis';
  if (t.includes('chalisa') || t.includes('चालीसा')) return 'chalisa';
  if (t.includes('mantra') || t.includes('मंत्र') || t.includes('chant')) return 'mantras';
  if (t.includes('stotram') || t.includes('stotra') || t.includes('स्तोत्र')) return 'stotrams';
  return 'bhajans';
}

export function detectDeity(text) {
  if (!text) return 'shiva';
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

function parseYouTubeHtml(html) {
  if (!html) return [];
  const startStr = 'var ytInitialData = ';
  let jsonStart = html.indexOf(startStr);
  let jsonStr = '';

  if (jsonStart !== -1) {
    jsonStart += startStr.length;
    const endIdx = html.indexOf(';</script>', jsonStart);
    if (endIdx !== -1) {
      jsonStr = html.substring(jsonStart, endIdx);
    }
  } else {
    const match = html.match(/ytInitialData\s*=\s*({.+?});<\/script>/);
    if (match) jsonStr = match[1];
  }

  if (!jsonStr) return [];

  try {
    const data = JSON.parse(jsonStr);
    const contents = data?.contents?.twoColumnSearchResultsRenderer?.primaryContents?.sectionListRenderer?.contents?.[0]?.itemSectionRenderer?.contents || [];
    const tracks = [];

    for (const item of contents) {
      if (item.videoRenderer) {
        const v = item.videoRenderer;
        const videoId = v.videoId;
        if (!videoId) continue;

        const rawTitle = v.title?.runs?.[0]?.text || '';
        const title = cleanTitle(rawTitle);
        const artist = v.ownerText?.runs?.[0]?.text || 'Devotional Artist';
        const durationText = v.lengthText?.simpleText || '5:00';
        const durationSeconds = parseDurationText(durationText);
        const thumbnail = v.thumbnail?.thumbnails?.slice(-1)[0]?.url || `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`;

        const deity = detectDeity(rawTitle);
        tracks.push({
          id: `yt-${videoId}`,
          title: title || rawTitle,
          originalTitle: rawTitle,
          artist,
          artworkUrl: thumbnail || `/artwork/${deity}.jpg`,
          durationSeconds,
          videoId,
          source: 'youtube',
          language: detectLanguage(rawTitle + ' ' + artist),
          categoryId: detectCategory(rawTitle),
          deityId: deity,
        });
      }
    }
    return tracks;
  } catch (e) {
    console.warn('[OnlineMusic] Failed to parse YouTube JSON:', e);
    return [];
  }
}

async function searchDirectYouTube(query) {
  const url = `https://www.youtube.com/results?search_query=${encodeURIComponent(query + ' devotional bhajan')}`;
  let html = '';

  if (Capacitor.isNativePlatform()) {
    // Native Android HTTP request (bypasses browser CORS completely)
    try {
      const response = await CapacitorHttp.get({
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept-Language': 'en-US,en;q=0.9,hi;q=0.8',
        },
      });
      html = typeof response.data === 'string' ? response.data : JSON.stringify(response.data);
    } catch (e) {
      console.warn('[YouTube Native] Error:', e);
    }
  } else {
    // In web browser: attempt CORS-friendly fetch via public proxy
    try {
      const proxyUrl = `https://api.allorigins.win/raw?url=${encodeURIComponent(url)}`;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 3500);
      const res = await fetch(proxyUrl, { signal: controller.signal });
      clearTimeout(timeoutId);
      if (res.ok) {
        html = await res.text();
      }
    } catch (_) {
      // Gracefully fall back to iTunes Devotional API and seed catalog
    }
  }

  if (!html) return [];
  return parseYouTubeHtml(html);
}

async function searchDirectITunes(query) {
  const url = `https://itunes.apple.com/search?term=${encodeURIComponent(query + ' devotional')}&media=music&entity=song&limit=15`;
  const res = await fetch(url);
  if (!res.ok) return [];
  const data = await res.json();
  const results = data.results || [];
  return results.map(r => ({
    id: `itunes-${r.trackId}`,
    title: r.trackName,
    artist: r.artistName,
    artworkUrl: (r.artworkUrl100 || '').replace('100x100bb.jpg', '600x600bb.jpg'),
    audioUrl: r.previewUrl,
    durationSeconds: Math.round((r.trackTimeMillis || 30000) / 1000),
    source: 'itunes',
    language: detectLanguage(r.trackName + ' ' + r.artistName),
    categoryId: detectCategory(r.trackName),
    deityId: detectDeity(r.trackName),
  }));
}

export async function searchOnlineMusic(query) {
  if (!query || !query.trim()) return [];
  const cleanQ = query.trim();
  const cacheKey = cleanQ.toLowerCase();

  if (searchCache.has(cacheKey)) {
    return searchCache.get(cacheKey);
  }

  let results = [];

  // Tier 1: Try Local Backend Search with quick timeout (if PC server happens to be running on Wi-Fi)
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);
    const backendRes = await apiFetch(`/api/search/live?q=${encodeURIComponent(cleanQ)}`, {
      signal: controller.signal,
    });
    clearTimeout(timeoutId);

    if (backendRes.ok) {
      const data = await backendRes.json();
      if (data.success && Array.isArray(data.data) && data.data.length > 0) {
        console.log('[OnlineMusic] Fetched tracks from backend server');
        results = data.data;
      }
    }
  } catch (err) {
    // Backend server not available (normal when phone is standalone or mobile data)
  }

  // Tier 2: Direct Native YouTube Search (via Capacitor native HTTP on phone)
  if (results.length === 0) {
    try {
      const ytTracks = await searchDirectYouTube(cleanQ);
      if (ytTracks && ytTracks.length > 0) {
        console.log(`[OnlineMusic] Fetched ${ytTracks.length} tracks directly from YouTube`);
        results = ytTracks;
      }
    } catch (err) {
      console.warn('[OnlineMusic] Direct YouTube search fallback:', err);
    }
  }

  // Tier 3: Direct iTunes Devotional API Search (CORS friendly, works everywhere globally)
  if (results.length === 0) {
    try {
      const itunesTracks = await searchDirectITunes(cleanQ);
      if (itunesTracks && itunesTracks.length > 0) {
        console.log(`[OnlineMusic] Fetched ${itunesTracks.length} tracks from iTunes API`);
        results = itunesTracks;
      }
    } catch (err) {
      console.warn('[OnlineMusic] iTunes search fallback:', err);
    }
  }

  // Tier 4: Offline Seed Catalog search filter
  if (results.length === 0) {
    console.log('[OnlineMusic] Matching offline catalog');
    const lower = cleanQ.toLowerCase();
    results = seedCatalog.songs.filter(s =>
      s.title.toLowerCase().includes(lower) ||
      s.artist.toLowerCase().includes(lower) ||
      (s.deityId && s.deityId.toLowerCase().includes(lower)) ||
      (s.language && s.language.toLowerCase().includes(lower))
    );
  }

  if (results.length > 0) {
    searchCache.set(cacheKey, results);
    if (searchCache.size > 100) {
      const firstKey = searchCache.keys().next().value;
      searchCache.delete(firstKey);
    }
  }

  return results;
}
