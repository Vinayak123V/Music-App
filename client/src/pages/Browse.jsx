import React, { useState, useEffect } from 'react';
import { Compass, Music2 } from 'lucide-react';
import { SongTile } from '../components/common/SongTile';
import { apiFetch } from '../config/api';

export const Browse = () => {
  const [categories, setCategories] = useState([]);
  const [songs, setSongs] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [selectedLanguage, setSelectedLanguage] = useState('All');
  const [visibleCount, setVisibleCount] = useState(40);
  const [loading, setLoading] = useState(true);

  const languages = ['All', 'Kannada', 'Hindi', 'Sanskrit', 'Tamil', 'Telugu', 'Marathi', 'Bengali', 'Gujarati', 'Malayalam', 'Odia'];

  useEffect(() => {
    setVisibleCount(40);
  }, [selectedCategory, selectedLanguage]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [catRes, songRes] = await Promise.all([
          apiFetch('/api/categories').then(r => r.json()),
          apiFetch('/api/songs').then(r => r.json()),
        ]);
        if (catRes.success) setCategories(catRes.data);
        if (songRes.success) setSongs(songRes.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const filteredSongs = songs.filter(song => {
    const matchesCat = selectedCategory ? song.categoryId === selectedCategory : true;
    const matchesLang = selectedLanguage !== 'All' ? song.language?.toLowerCase() === selectedLanguage.toLowerCase() : true;
    return matchesCat && matchesLang;
  });

  return (
    <div className="space-y-6 pb-32">
      <div>
        <h1 className="text-2xl font-black text-stone-900 tracking-tight flex items-center gap-2">
          <Compass className="text-saffron-600" /> Browse Sacred Categories
        </h1>
        <p className="text-xs text-stone-500 mt-0.5">Explore by devotional type and Indian languages</p>
      </div>

      {/* Language Filter Tabs */}
      <div className="flex gap-2 overflow-x-auto no-scrollbar py-1">
        {languages.map(lang => (
          <button
            key={lang}
            onClick={() => setSelectedLanguage(lang)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              selectedLanguage === lang
                ? 'bg-saffron-600 text-white shadow-sm'
                : 'bg-white text-stone-600 border border-saffron-100 hover:bg-saffron-50'
            }`}
          >
            {lang}
          </button>
        ))}
      </div>

      {/* Categories Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3">
        {categories.map(cat => {
          const isSelected = selectedCategory === cat.id;
          return (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(isSelected ? null : cat.id)}
              className={`p-4 rounded-2xl text-left transition-all border flex flex-col justify-between h-24 ${
                isSelected
                  ? 'bg-gradient-to-br from-saffron-600 to-saffron-800 text-white border-transparent shadow-md scale-102'
                  : 'bg-white hover:bg-saffron-50 text-stone-800 border-saffron-100 hover:border-saffron-300 shadow-sm'
              }`}
            >
              <Music2 size={18} className={isSelected ? 'text-gold' : 'text-saffron-600'} />
              <div>
                <p className="font-bold text-xs">{cat.name}</p>
                <p className={`text-[10px] mt-0.5 truncate ${isSelected ? 'text-saffron-100' : 'text-stone-400'}`}>
                  {cat.description}
                </p>
              </div>
            </button>
          );
        })}
      </div>

      {/* Filtered Songs List */}
      <div className="mt-8">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-bold text-stone-900">
            {selectedCategory
              ? categories.find(c => c.id === selectedCategory)?.name
              : 'All Devotional Tracks'}{' '}
            ({filteredSongs.length})
          </h2>
          {selectedCategory && (
            <button
              onClick={() => setSelectedCategory(null)}
              className="text-xs text-saffron-700 font-bold hover:underline"
            >
              Show all categories
            </button>
          )}
        </div>

        {filteredSongs.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-2xl border border-stone-100 text-stone-400 text-sm">
            No tracks found matching the selected filters.
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {filteredSongs.slice(0, visibleCount).map((song, i) => (
                <SongTile key={song.id} song={song} queue={filteredSongs} index={i} />
              ))}
            </div>

            {filteredSongs.length > visibleCount && (
              <div className="text-center mt-6">
                <button
                  onClick={() => setVisibleCount(prev => prev + 40)}
                  className="px-6 py-2.5 rounded-2xl bg-saffron-50 text-saffron-700 font-bold border border-saffron-200 hover:bg-saffron-100 transition-all text-xs"
                >
                  Load More ({filteredSongs.length - visibleCount} more songs)
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};
