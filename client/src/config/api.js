import { seedCatalog } from '../data/seedCatalog';

// Default Wi-Fi IP of the host machine running the backend (for local dev / home Wi-Fi)
export const DEFAULT_SERVER_URL = 'http://192.168.1.18:5000';

export function isCapacitorApp() {
  if (typeof window === 'undefined') return false;
  return Boolean(
    window.Capacitor?.isNativePlatform?.() ||
    window.location.protocol === 'capacitor:' ||
    window.location.protocol === 'file:' ||
    (window.location.origin.includes('localhost') && window.location.protocol === 'https:' && !window.location.port)
  );
}

export function getServerUrl() {
  if (typeof window === 'undefined') return '';
  const stored = localStorage.getItem('bhakti_server_url');
  if (stored) return stored.replace(/\/$/, '');
  
  if (isCapacitorApp()) {
    return DEFAULT_SERVER_URL;
  }
  return '';
}

export function setServerUrl(url) {
  if (!url) {
    localStorage.removeItem('bhakti_server_url');
  } else {
    localStorage.setItem('bhakti_server_url', url.replace(/\/$/, ''));
  }
}

export function resolveUrl(path) {
  if (!path) return '';
  if (
    path.startsWith('http://') ||
    path.startsWith('https://') ||
    path.startsWith('blob:') ||
    path.startsWith('data:')
  ) {
    return path;
  }
  const base = getServerUrl();
  return `${base}${path.startsWith('/') ? '' : '/'}${path}`;
}

export function getMockApiResponse(path) {
  try {
    const url = new URL(path, 'http://localhost');
    const pathname = url.pathname;

    if (pathname.startsWith('/api/songs')) {
      let filtered = [...(seedCatalog.songs || [])];
      const category = url.searchParams.get('category') || url.searchParams.get('categoryId');
      const deity = url.searchParams.get('deity') || url.searchParams.get('deityId');
      const language = url.searchParams.get('language');
      const q = url.searchParams.get('q');
      const featured = url.searchParams.get('featured');

      if (category && category !== 'all') {
        filtered = filtered.filter(s => s.categoryId === category);
      }
      if (deity && deity !== 'all') {
        filtered = filtered.filter(s => s.deityId === deity);
      }
      if (language && language !== 'All') {
        filtered = filtered.filter(s => s.language?.toLowerCase() === language.toLowerCase());
      }
      if (featured === 'true') {
        filtered = filtered.filter(s => s.featured);
      }
      if (q) {
        const lower = q.toLowerCase();
        filtered = filtered.filter(s =>
          s.title?.toLowerCase().includes(lower) ||
          s.artist?.toLowerCase().includes(lower) ||
          s.description?.toLowerCase().includes(lower)
        );
      }

      return {
        ok: true,
        status: 200,
        headers: new Headers({ 'content-type': 'application/json' }),
        json: async () => ({ success: true, count: filtered.length, data: filtered }),
        text: async () => JSON.stringify({ success: true, count: filtered.length, data: filtered }),
      };
    }

    if (pathname.startsWith('/api/categories')) {
      const data = seedCatalog.categories || [];
      return {
        ok: true,
        status: 200,
        headers: new Headers({ 'content-type': 'application/json' }),
        json: async () => ({ success: true, count: data.length, data }),
        text: async () => JSON.stringify({ success: true, count: data.length, data }),
      };
    }

    if (pathname.startsWith('/api/deities')) {
      const data = seedCatalog.deities || [];
      return {
        ok: true,
        status: 200,
        headers: new Headers({ 'content-type': 'application/json' }),
        json: async () => ({ success: true, count: data.length, data }),
        text: async () => JSON.stringify({ success: true, count: data.length, data }),
      };
    }

    if (pathname.startsWith('/api/languages')) {
      const langs = ['Kannada', 'Hindi', 'Sanskrit', 'Tamil', 'Telugu', 'Marathi', 'Bengali', 'Gujarati', 'Malayalam', 'Odia'];
      return {
        ok: true,
        status: 200,
        headers: new Headers({ 'content-type': 'application/json' }),
        json: async () => ({ success: true, data: langs }),
        text: async () => JSON.stringify({ success: true, data: langs }),
      };
    }
  } catch (e) {
    console.warn('[MockApi] Path parsing error:', e);
  }
  return null;
}

export async function apiFetch(path, options = {}) {
  const serverUrl = getServerUrl();
  const isStaticHost = !serverUrl && typeof window !== 'undefined' && !window.location.hostname.includes('localhost');

  // If on static web hosting (Netlify/Vercel) without a dedicated backend configured,
  // return instant embedded seed data to avoid HTML redirects and network latency
  if (isStaticHost) {
    const mockRes = getMockApiResponse(path);
    if (mockRes) return mockRes;
  }

  const url = resolveUrl(path);
  try {
    const res = await fetch(url, options);
    const contentType = res.headers.get('content-type') || '';
    
    // If the server returned HTML (e.g. Netlify SPA index.html fallback) or a non-200,
    // intercept it with seedCatalog instead of failing JSON parsing in components
    if (!res.ok || contentType.includes('text/html') || !contentType.includes('application/json')) {
      const mockRes = getMockApiResponse(path);
      if (mockRes) {
        console.warn(`[API] Static fallback served for ${path}`);
        return mockRes;
      }
      throw new Error(`HTTP ${res.status}: Non-JSON response`);
    }
    return res;
  } catch (err) {
    const mockRes = getMockApiResponse(path);
    if (mockRes) {
      console.warn(`[API] Network offline fallback for ${path}`);
      return mockRes;
    }
    throw err;
  }
}
