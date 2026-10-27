import { seedCatalog } from '../data/seedCatalog';

// Default Wi-Fi IP of the host machine running the backend
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

export async function apiFetch(path, options = {}) {
  const url = resolveUrl(path);
  try {
    const res = await fetch(url, options);
    if (!res.ok) {
      throw new Error(`HTTP error ${res.status}`);
    }
    return res;
  } catch (err) {
    // Graceful offline fallback for core endpoints on mobile
    if (path.startsWith('/api/songs')) {
      console.warn('[API] Offline fallback triggered for /api/songs');
      return {
        ok: true,
        json: async () => ({ success: true, count: seedCatalog.songs.length, data: seedCatalog.songs }),
      };
    }
    if (path.startsWith('/api/categories')) {
      console.warn('[API] Offline fallback triggered for /api/categories');
      return {
        ok: true,
        json: async () => ({ success: true, count: seedCatalog.categories.length, data: seedCatalog.categories }),
      };
    }
    if (path.startsWith('/api/deities')) {
      console.warn('[API] Offline fallback triggered for /api/deities');
      return {
        ok: true,
        json: async () => ({ success: true, count: seedCatalog.deities.length, data: seedCatalog.deities }),
      };
    }
    throw err;
  }
}
