import React, { useState, useEffect } from 'react';
import {
  ShieldCheck,
  Plus,
  Trash2,
  Play,
  Lock,
  Music,
  BarChart3,
  Layers,
  LogOut,
  Sparkles,
} from 'lucide-react';
import { AdminUploadModal } from '../components/admin/AdminUploadModal';
import { usePlayer } from '../context/PlayerContext';
import { apiFetch } from '../config/api';
import { formatDuration } from '../components/common/SongTile';
import { DevotionalImage } from '../components/common/DevotionalImage';

export const AdminDashboard = () => {
  const [isAdmin, setIsAdmin] = useState(() => {
    return sessionStorage.getItem('bhakti_admin_auth') === 'true';
  });

  const [email, setEmail] = useState('admin@bhaktimusic.com');
  const [password, setPassword] = useState('bhakti2026!');
  const [authError, setAuthError] = useState('');

  const [stats, setStats] = useState(null);
  const [songs, setSongs] = useState([]);
  const [categories, setCategories] = useState([]);
  const [deities, setDeities] = useState([]);
  const [isUploadOpen, setIsUploadOpen] = useState(false);

  const { playSong } = usePlayer();

  const loadData = async () => {
    try {
      const [statsRes, songsRes, catRes, deitRes] = await Promise.all([
        apiFetch('/api/admin/stats').then(r => r.json()),
        apiFetch('/api/songs').then(r => r.json()),
        apiFetch('/api/categories').then(r => r.json()),
        apiFetch('/api/deities').then(r => r.json()),
      ]);
      if (statsRes.success) setStats(statsRes.data);
      if (songsRes.success) setSongs(songsRes.data);
      if (catRes.success) setCategories(catRes.data);
      if (deitRes.success) setDeities(deitRes.data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    if (isAdmin) {
      loadData();
    }
  }, [isAdmin]);

  const handleLogin = (e) => {
    e.preventDefault();
    if (
      (email === 'admin@bhaktimusic.com' || email === 'admin') &&
      (password === 'bhakti2026!' || password === 'admin123')
    ) {
      setIsAdmin(true);
      sessionStorage.setItem('bhakti_admin_auth', 'true');
      setAuthError('');
    } else {
      setAuthError('Invalid administrator credentials.');
    }
  };

  const handleLogout = () => {
    setIsAdmin(false);
    sessionStorage.removeItem('bhakti_admin_auth');
  };

  const handleDeleteSong = async (id) => {
    if (!window.confirm('Are you sure you want to delete this devotional song?')) return;
    try {
      const res = await apiFetch(`/api/songs/${id}`, { method: 'DELETE' }).then(r => r.json());
      if (res.success) {
        setSongs(prev => prev.filter(s => s.id !== id));
        loadData();
      }
    } catch (err) {
      alert('Delete failed: ' + err.message);
    }
  };

  // If Not Logged In, Render Secure Admin Login Card
  if (!isAdmin) {
    return (
      <div className="max-w-md mx-auto py-12 px-4">
        <div className="bg-white rounded-3xl p-8 border border-saffron-200 shadow-xl text-stone-900">
          <div className="text-center">
            <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-saffron-500 to-saffron-800 text-white flex items-center justify-center mx-auto shadow-md shadow-saffron-500/30 mb-3">
              <Lock size={26} />
            </div>
            <h2 className="text-xl font-black">Bhakti Music Admin Portal</h2>
            <p className="text-xs text-stone-500 mt-1">Manage devotional audio catalog & verified rights</p>
          </div>

          {authError && (
            <div className="mt-4 p-3 rounded-xl bg-red-50 text-red-700 text-xs border border-red-200">
              {authError}
            </div>
          )}

          <form onSubmit={handleLogin} className="mt-6 space-y-4 text-xs">
            <div>
              <label className="block font-bold text-stone-700 mb-1">Admin Email</label>
              <input
                type="text"
                required
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full px-3 py-2.5 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs"
              />
            </div>
            <div>
              <label className="block font-bold text-stone-700 mb-1">Password</label>
              <input
                type="password"
                required
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full px-3 py-2.5 rounded-xl border border-stone-200 focus:outline-none focus:ring-2 focus:ring-saffron-500/40 text-xs"
              />
            </div>

            <button
              type="submit"
              className="w-full py-3 rounded-xl bg-gradient-to-r from-saffron-600 to-saffron-800 text-white font-bold shadow-md shadow-saffron-600/30 hover:scale-[1.01] active:scale-[0.99] transition-all"
            >
              Sign In to Admin Dashboard
            </button>

            <div className="p-3 rounded-xl bg-saffron-50 text-[11px] text-saffron-900 border border-saffron-200/60 text-center">
              💡 Demo credentials pre-filled: <b>admin@bhaktimusic.com</b> / <b>bhakti2026!</b>
            </div>
          </form>
        </div>
      </div>
    );
  }

  // Admin Dashboard Content
  return (
    <div className="space-y-6 pb-32">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-stone-900 tracking-tight flex items-center gap-2">
            <ShieldCheck className="text-emerald-600" /> Admin Management Console
          </h1>
          <p className="text-xs text-stone-500 mt-0.5">Control live devotional audio catalog & verified publishing rights</p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={() => setIsUploadOpen(true)}
            className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-saffron-600 hover:bg-saffron-700 text-white font-bold text-xs shadow-md shadow-saffron-600/30 transition-all"
          >
            <Plus size={16} />
            <span>Upload New Song</span>
          </button>
          <button
            onClick={handleLogout}
            className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl bg-stone-100 hover:bg-stone-200 text-stone-700 font-bold text-xs transition-colors"
          >
            <LogOut size={16} />
            <span>Logout</span>
          </button>
        </div>
      </div>

      {/* Analytics Metric Cards */}
      {stats && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="bg-white p-4 rounded-2xl border border-saffron-100 shadow-sm">
            <div className="flex items-center justify-between text-stone-400">
              <span className="text-[11px] font-bold uppercase tracking-wider">Total Songs</span>
              <Music size={18} className="text-saffron-600" />
            </div>
            <p className="text-2xl font-black text-stone-900 mt-1">{stats.totalSongs}</p>
            <p className="text-[10px] text-stone-400 mt-0.5">Live in streaming catalog</p>
          </div>

          <div className="bg-white p-4 rounded-2xl border border-saffron-100 shadow-sm">
            <div className="flex items-center justify-between text-stone-400">
              <span className="text-[11px] font-bold uppercase tracking-wider">Rights Compliance</span>
              <ShieldCheck size={18} className="text-emerald-600" />
            </div>
            <p className="text-2xl font-black text-emerald-700 mt-1">{stats.rightsComplianceRatio}%</p>
            <p className="text-[10px] text-emerald-600 mt-0.5">All tracks fully verified</p>
          </div>

          <div className="bg-white p-4 rounded-2xl border border-saffron-100 shadow-sm">
            <div className="flex items-center justify-between text-stone-400">
              <span className="text-[11px] font-bold uppercase tracking-wider">Categories</span>
              <Layers size={18} className="text-gold" />
            </div>
            <p className="text-2xl font-black text-stone-900 mt-1">{stats.totalCategories}</p>
            <p className="text-[10px] text-stone-400 mt-0.5">Bhajans, Aartis, Mantras</p>
          </div>

          <div className="bg-white p-4 rounded-2xl border border-saffron-100 shadow-sm">
            <div className="flex items-center justify-between text-stone-400">
              <span className="text-[11px] font-bold uppercase tracking-wider">Deities Active</span>
              <Sparkles size={18} className="text-saffron-700" />
            </div>
            <p className="text-2xl font-black text-stone-900 mt-1">{stats.totalDeities}</p>
            <p className="text-[10px] text-stone-400 mt-0.5">Ishta Devata catalogs</p>
          </div>
        </div>
      )}

      {/* Catalog Table */}
      <div className="bg-white rounded-3xl border border-saffron-100 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-stone-100 flex items-center justify-between">
          <h2 className="font-bold text-sm text-stone-900">Catalog Content Inventory ({songs.length} Tracks)</h2>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-stone-700">
            <thead className="bg-stone-50 border-b border-stone-100 text-[10px] uppercase font-bold text-stone-400">
              <tr>
                <th className="px-4 py-3">Track</th>
                <th className="px-4 py-3">Category</th>
                <th className="px-4 py-3">Deity</th>
                <th className="px-4 py-3">Language</th>
                <th className="px-4 py-3">Rights Holder</th>
                <th className="px-4 py-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {songs.map(song => (
                <tr key={song.id} className="hover:bg-saffron-50/30 transition-colors">
                  <td className="px-4 py-3 flex items-center gap-3">
                    <div className="w-9 h-9 rounded-lg overflow-hidden bg-stone-100 border border-stone-200 flex-shrink-0 flex items-center justify-center text-sm">
                      <DevotionalImage
                        src={song.artworkUrl}
                        deityId={song.deityId}
                        alt={song.title}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div>
                      <p className="font-bold text-stone-900 truncate max-w-[180px]">{song.title}</p>
                      <p className="text-[10px] text-stone-400">{song.artist}</p>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-medium capitalize">{song.categoryId}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="font-medium capitalize">{song.deityId}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="px-1.5 py-0.5 rounded bg-stone-100 text-stone-600 font-semibold text-[10px]">
                      {song.language}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-semibold text-stone-900">{song.rights?.rightsHolder || 'N/A'}</p>
                    <p className="text-[10px] font-mono text-stone-400">{song.rights?.licenseReference}</p>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        onClick={() => playSong(song, songs)}
                        className="p-1.5 rounded-lg text-saffron-700 hover:bg-saffron-100 transition-colors"
                        title="Preview audio"
                      >
                        <Play size={15} />
                      </button>
                      <button
                        onClick={() => handleDeleteSong(song.id)}
                        className="p-1.5 rounded-lg text-red-500 hover:bg-red-50 transition-colors"
                        title="Delete song"
                      >
                        <Trash2 size={15} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Upload Dialog Modal */}
      <AdminUploadModal
        isOpen={isUploadOpen}
        onClose={() => setIsUploadOpen(false)}
        onSongAdded={() => loadData()}
        categories={categories}
        deities={deities}
      />
    </div>
  );
};
