import React, { useState, useEffect } from 'react';
import { Search as SearchIcon, X, Music, Sparkles, Radio, Compass, Music2 } from 'lucide-react';
import { SongTile } from '../components/common/SongTile';
import { apiFetch } from '../config/api';
import { searchOnlineMusic } from '../services/onlineMusicService';

export const Search = () => {
  const [query, setQuery] = useState('');
  const [liveResults, setLiveResults] = useState([]);
  const [catalogSongs, setCatalogSongs] = useState([]);
  const [categories, setCategories] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [selectedLanguage, setSelectedLanguage] = useState('All');
  const [visibleCount, setVisibleCount] = useState(40);
  const [loading, setLoading] = useState(false);
  const [catalogLoading, setCatalogLoading] = useState(true);

  const languages = ['All', 'Kannada', 'Hindi', 'Sanskrit', 'Tamil', 'Telugu', 'Marathi', 'Bengali', 'Gujarati', 'Malayalam', 'Odia'];

  const quickPills = [
    'Shree Hanuman Chalisa',
    'Shiva Tandav Stotram',
    'Purandara Dasa',
    'Achyutam Keshavam',
    'Gayatri Mantra',
    'Jai Ganesh Deva',
    'Shree Ram Chandra Kripalu',
    'Aigiri Nandini',
    'Krishna Bhajan',
    'Maha Mrityunjaya Mantra',
  ];

  // 1. Load 5,000+ catalog and categories on mount
  useEffect(() => {
    const loadCatalog = async () => {
      try {
        const [catRes, songRes] = await Promise.all([
          apiFetch('/api/categories').then(r => r.json()),
          apiFetch('/api/songs').then(r => r.json()),
        ]);
        if (catRes.success) setCategories(catRes.data);
        if (songRes.success) setCatalogSongs(songRes.data);
      } catch (err) {
        console.error('[Search & Explore] Catalog fetch error:', err);
      } finally {
        setCatalogLoading(false);
      }
    };
    loadCatalog();
  }, []);

  // Reset pagination when language or category changes
  useEffect(() => {
    setVisibleCount(40);
  }, [selectedCategory, selectedLanguage]);

  // 2. Debounced Live Online Search (when user is typing)
  useEffect(() => {
    if (!query.trim()) {
      setLiveResults([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    let isCancelled = false;

    const fetchLive = async () => {
      try {
        const tracks = await searchOnlineMusic(query.trim());
        if (!isCancelled) {
          setLiveResults(tracks || []);
        }
      } catch (err) {
        if (!isCancelled) {
          console.error('[Search] Live search error:', err);
        }
      } finally {
        if (!isCancelled) {
          setLoading(false);
        }
      }
    };

    const timer = setTimeout(fetchLive, 350);
    return () => {
      isCancelled = true;
      clearTimeout(timer);
    };
  }, [query]);

  // 3. Filtered Browse Catalog (when query is empty)
  const filteredCatalog = catalogSongs.filter(song => {
    const matchesCat = selectedCategory ? song.categoryId === selectedCategory : true;
    const matchesLang = selectedLanguage !== 'All' ? song.language?.toLowerCase() === selectedLanguage.toLowerCase() : true;
    return matchesCat && matchesLang;
  });

  return (
    <div className="space-y-6 pb-32">
      {/* Header */}
      <div>
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-black text-stone-900 tracking-tight flex items-center gap-2">
              <Compass className="text-saffron-600" /> Search & Explore
            </h1>
            <p className="text-xs text-stone-500 mt-0.5">
              Live multi-tier search across millions of devotional songs & browse 5,000+ sacred tracks by language
            </p>
          </div>

          <div className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold">
            <Radio size={14} className="text-emerald-600 animate-pulse" />
            <span>Live Music Engine Online</span>
          </div>
        </div>
      </div>

      {/* Universal Search Input */}
      <div className="relative">
        <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 text-saffron-600" size={20} />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search any bhajan, aarti, deity, singer, or mantra (e.g. 'Purandara Dasa', 'Hanuman Chalisa')..."
          className="w-full pl-12 pr-10 py-3.5 rounded-2xl bg-white border border-saffron-200 text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-saffron-500/50 shadow-sm text-sm"
        />
        {query && (
          <button
            onClick={() => setQuery('')}
            className="absolute right-3.5 top-1/2 -translate-y-1/2 p-1 text-stone-400 hover:text-stone-700"
          >
            <X size={18} />
          </button>
        )}
      </div>

      {/* Quick Search Chips */}
      <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
        <span className="text-xs font-semibold text-stone-400 flex items-center gap-1 flex-shrink-0">
          <Sparkles size={13} className="text-gold" /> Trending:
        </span>
        {quickPills.map(pill => (
          <button
            key={pill}
            onClick={() => setQuery(pill)}
            className="px-3 py-1 rounded-full text-xs font-medium bg-white text-stone-700 border border-saffron-200/80 hover:bg-saffron-50 hover:border-saffron-400 transition-colors whitespace-nowrap shadow-xs flex-shrink-0"
          >
            {pill}
          </button>
        ))}
      </div>

      {/* Language Filter Tabs */}
      <div className="space-y-1.5">
        <p className="text-[11px] font-bold text-stone-400 uppercase tracking-wider px-1">
          Explore By Indian Language
        </p>
        <div className="flex gap-2 overflow-x-auto no-scrollbar py-1">
          {languages.map(lang => (
            <button
              key={lang}
              onClick={() => {
                setSelectedLanguage(lang);
                if (query) setQuery(''); // switch to browse filtered view
              }}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex-shrink-0 ${
                selectedLanguage === lang && !query
                  ? 'bg-saffron-600 text-white shadow-sm'
                  : 'bg-white text-stone-600 border border-saffron-100 hover:bg-saffron-50'
              }`}
            >
              {lang}
            </button>
          ))}
        </div>
      </div>

      {/* Sacred Categories Grid */}
      <div className="space-y-1.5">
        <div className="flex items-center justify-between px-1">
          <p className="text-[11px] font-bold text-stone-400 uppercase tracking-wider">
            Explore Sacred Categories
          </p>
          {selectedCategory && (
            <button
              onClick={() => setSelectedCategory(null)}
              className="text-xs text-saffron-700 font-bold hover:underline"
            >
              Clear Category Filter
            </button>
          )}
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-7 gap-2.5">
          {categories.map(cat => {
            const isSelected = selectedCategory === cat.id && !query;
            return (
              <button
                key={cat.id}
                onClick={() => {
                  setSelectedCategory(isSelected ? null : cat.id);
                  if (query) setQuery('');
                }}
                className={`p-3 rounded-2xl text-left transition-all border flex flex-col justify-between h-20 ${
                  isSelected
                    ? 'bg-gradient-to-br from-saffron-600 to-saffron-800 text-white border-transparent shadow-md scale-102'
                    : 'bg-white hover:bg-saffron-50 text-stone-800 border-saffron-100 hover:border-saffron-300 shadow-xs'
                }`}
              >
                <Music2 size={16} className={isSelected ? 'text-gold' : 'text-saffron-600'} />
                <div>
                  <p className="font-bold text-xs truncate">{cat.name}</p>
                  <p className={`text-[9px] truncate ${isSelected ? 'text-saffron-100' : 'text-stone-400'}`}>
                    {cat.description}
                  </p>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Results Section */}
      <div>
        {loading ? (
          /* Live Searching Spinner */
          <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 shadow-xs">
            <div className="w-8 h-8 border-3 border-saffron-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
            <p className="text-sm font-bold text-stone-700">Searching millions of devotional tracks...</p>
            <p className="text-xs text-stone-400 mt-1">Connecting to live streams, artists, and HD sacred artwork</p>
          </div>
        ) : query.trim() ? (
          /* Live Search Results */
          <div>
            <div className="flex items-center justify-between mb-3 px-1">
              <h2 className="text-base font-bold text-stone-900">
                Live Search Results for "{query}" ({liveResults.length})
              </h2>
              <button
                onClick={() => setQuery('')}
                className="text-xs text-saffron-700 font-bold hover:underline"
              >
                Clear & Return to Catalog
              </button>
            </div>

            {liveResults.length === 0 ? (
              <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 text-stone-400">
                <Music size={36} className="mx-auto mb-2 opacity-30 text-saffron-700" />
                <p className="font-semibold text-sm">No live tracks found for "{query}"</p>
                <p className="text-xs text-stone-400 mt-1">Try another spelling, deity, or singer name</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
                {liveResults.map((song, i) => (
                  <SongTile key={song.id} song={song} queue={liveResults} index={i} />
                ))}
              </div>
            )}
          </div>
        ) : (
          /* Browse Catalog Mode */
          <div>
            <div className="flex items-center justify-between mb-3 px-1">
              <h2 className="text-base font-bold text-stone-900">
                {selectedCategory
                  ? categories.find(c => c.id === selectedCategory)?.name
                  : 'All Devotional Tracks'}{' '}
                {selectedLanguage !== 'All' ? `• ${selectedLanguage}` : ''} ({filteredCatalog.length})
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

            {catalogLoading ? (
              <div className="text-center py-16 bg-white rounded-3xl border border-stone-100">
                <div className="w-8 h-8 border-3 border-saffron-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
                <p className="text-sm font-bold text-stone-700">Loading sacred catalog...</p>
              </div>
            ) : filteredCatalog.length === 0 ? (
              <div className="text-center py-12 bg-white rounded-2xl border border-stone-100 text-stone-400 text-sm">
                No tracks found matching the selected filters.
              </div>
            ) : (
              <>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
                  {filteredCatalog.slice(0, visibleCount).map((song, i) => (
                    <SongTile key={song.id} song={song} queue={filteredCatalog} index={i} />
                  ))}
                </div>

                {filteredCatalog.length > visibleCount && (
                  <div className="text-center mt-6">
                    <button
                      onClick={() => setVisibleCount(prev => prev + 40)}
                      className="px-6 py-2.5 rounded-2xl bg-saffron-50 text-saffron-700 font-bold border border-saffron-200 hover:bg-saffron-100 transition-all text-xs shadow-xs"
                    >
                      Load More ({filteredCatalog.length - visibleCount} more songs)
                    </button>
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
