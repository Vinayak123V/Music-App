import React, { useState, useEffect } from 'react';
import { Heart, History, Music } from 'lucide-react';
import { useFavorites } from '../context/FavoritesContext';
import { SongTile } from '../components/common/SongTile';
import { apiFetch } from '../config/api';

export const Library = () => {
  const { favorites, recentlyPlayed } = useFavorites();
  const [activeTab, setActiveTab] = useState('favorites'); // 'favorites' | 'recent'
  const [allSongs, setAllSongs] = useState([]);

  useEffect(() => {
    apiFetch('/api/songs')
      .then(r => r.json())
      .then(res => {
        if (res.success) setAllSongs(res.data);
      })
      .catch(console.error);
  }, []);

  const favoriteSongs = allSongs.filter(s => favorites.includes(s.id));

  return (
    <div className="space-y-6 pb-32">
      <div>
        <h1 className="text-2xl font-black text-stone-900 tracking-tight">Your Devotional Library</h1>
        <p className="text-xs text-stone-500 mt-0.5">Your personal favorites and recent listening history</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-saffron-200/60 pb-2">
        <button
          onClick={() => setActiveTab('favorites')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'favorites'
              ? 'bg-saffron-600 text-white shadow-sm'
              : 'text-stone-600 hover:bg-saffron-50'
          }`}
        >
          <Heart size={16} className={activeTab === 'favorites' ? 'fill-white' : ''} />
          <span>Saved Favorites ({favoriteSongs.length})</span>
        </button>

        <button
          onClick={() => setActiveTab('recent')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'recent'
              ? 'bg-saffron-600 text-white shadow-sm'
              : 'text-stone-600 hover:bg-saffron-50'
          }`}
        >
          <History size={16} />
          <span>Recently Played ({recentlyPlayed.length})</span>
        </button>
      </div>

      {/* Content */}
      <div>
        {activeTab === 'favorites' ? (
          favoriteSongs.length === 0 ? (
            <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 text-stone-400">
              <Heart size={36} className="mx-auto mb-2 opacity-30 text-red-500" />
              <p className="font-semibold text-sm">No favorite songs yet</p>
              <p className="text-xs text-stone-400 mt-1">Tap the heart icon on any song to save it here</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {favoriteSongs.map((song, i) => (
                <SongTile key={song.id} song={song} queue={favoriteSongs} index={i} />
              ))}
            </div>
          )
        ) : (
          recentlyPlayed.length === 0 ? (
            <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 text-stone-400">
              <History size={36} className="mx-auto mb-2 opacity-30 text-saffron-600" />
              <p className="font-semibold text-sm">No recently played tracks</p>
              <p className="text-xs text-stone-400 mt-1">Songs you listen to will appear here</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {recentlyPlayed.map((song, i) => (
                <SongTile key={song.id} song={song} queue={recentlyPlayed} index={i} />
              ))}
            </div>
          )
        )}
      </div>
    </div>
  );
};
