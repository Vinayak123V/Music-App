import React, { useState, useEffect } from 'react';
import { Search as SearchIcon, X, Music, Sparkles, Radio, Globe } from 'lucide-react';
import { SongTile } from '../components/common/SongTile';
import { apiFetch } from '../config/api';
import { searchOnlineMusic } from '../services/onlineMusicService';

export const Search = () => {
  const [query, setQuery] = useState('');
  const [liveResults, setLiveResults] = useState([]);
  const [curatedSongs, setCuratedSongs] = useState([]);
  const [searchMode, setSearchMode] = useState('live'); // 'live' | 'curated'
  const [loading, setLoading] = useState(false);

  // Load curated local tracks on mount
  useEffect(() => {
    apiFetch('/api/songs')
      .then(r => r.json())
      .then(res => {
        if (res.success) setCuratedSongs(res.data);
      })
      .catch(console.error);
  }, []);

  // Live Online Search via Multi-Tier Engine (Direct Phone YouTube + iTunes + Server)
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
          console.error('Live search error:', err);
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

  const quickPills = [
    'Shree Hanuman Chalisa',
    'Shiva Tandav Stotram',
    'Muttu Halyal Bhajan',
    'Achyutam Keshavam',
    'Gayatri Mantra',
    'Jai Ganesh Deva Aarti',
    'Shree Ram Chandra Kripalu',
    'Aigiri Nandini',
    'Krishna Bhajan',
    'Kannada Bhakti Geethegalu',
  ];

  const displayedCurated = query.trim()
    ? curatedSongs.filter(s =>
        s.title.toLowerCase().includes(query.toLowerCase()) ||
        s.artist.toLowerCase().includes(query.toLowerCase()) ||
        s.language?.toLowerCase().includes(query.toLowerCase()) ||
        s.deityId?.toLowerCase().includes(query.toLowerCase())
      ).slice(0, 50)
    : curatedSongs.slice(0, 30);

  return (
    <div className="space-y-6 pb-32">
      <div>
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-black text-stone-900 tracking-tight flex items-center gap-2">
              <span>🔍</span> Universal Devotional Search
            </h1>
            <p className="text-xs text-stone-500 mt-0.5">
              Instant search across millions of Indian devotional songs & chants (No manual upload needed)
            </p>
          </div>

          <div className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold">
            <Radio size={14} className="text-emerald-600 animate-pulse" />
            <span>Live Music Engine Online</span>
          </div>
        </div>
      </div>

      {/* Search Input Box */}
      <div className="relative">
        <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 text-saffron-600" size={20} />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search any bhajan, aarti, singer, or deity (e.g. 'Muttu Halyal', 'Hanuman Chalisa')..."
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
        <span className="text-xs font-semibold text-stone-400 flex items-center gap-1">
          <Sparkles size={13} className="text-gold" /> Trending:
        </span>
        {quickPills.map(pill => (
          <button
            key={pill}
            onClick={() => setQuery(pill)}
            className="px-3 py-1 rounded-full text-xs font-medium bg-white text-stone-700 border border-saffron-200/80 hover:bg-saffron-50 hover:border-saffron-400 transition-colors whitespace-nowrap shadow-xs"
          >
            {pill}
          </button>
        ))}
      </div>

      {/* Mode Switcher Tabs */}
      <div className="flex gap-2 border-b border-saffron-200/60 pb-2">
        <button
          onClick={() => setSearchMode('live')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            searchMode === 'live'
              ? 'bg-gradient-to-r from-saffron-600 to-saffron-700 text-white shadow-sm'
              : 'text-stone-600 hover:bg-saffron-50'
          }`}
        >
          <Globe size={15} />
          <span>Live Online Music Search {query && liveResults.length > 0 ? `(${liveResults.length})` : ''}</span>
        </button>

        <button
          onClick={() => setSearchMode('curated')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            searchMode === 'curated'
              ? 'bg-gradient-to-r from-saffron-600 to-saffron-700 text-white shadow-sm'
              : 'text-stone-600 hover:bg-saffron-50'
          }`}
        >
          <Music size={15} />
          <span>Verified Local Studio Tracks ({displayedCurated.length})</span>
        </button>
      </div>

      {/* Search Results Content */}
      <div>
        {loading ? (
          <div className="text-center py-16 bg-white rounded-3xl border border-stone-100">
            <div className="w-8 h-8 border-3 border-saffron-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
            <p className="text-sm font-bold text-stone-700">Searching millions of devotional tracks...</p>
            <p className="text-xs text-stone-400 mt-1">Fetching live audio streams, artists, and HD artwork</p>
          </div>
        ) : searchMode === 'live' ? (
          /* Live Search Results */
          query.trim() === '' ? (
            <div className="text-center py-16 bg-white rounded-3xl border border-saffron-100 p-6 shadow-sm">
              <Globe size={40} className="mx-auto mb-3 text-saffron-600 opacity-80" />
              <h3 className="font-bold text-base text-stone-900">Type Any Devotional Song Above</h3>
              <p className="text-xs text-stone-500 max-w-md mx-auto mt-1 leading-relaxed">
                You do not need to upload anything manually. The live search engine connects directly to the cloud to play any bhajan, aarti, mantra, or regional singer instantly.
              </p>
              <div className="mt-4 flex flex-wrap justify-center gap-2">
                {quickPills.slice(0, 5).map(p => (
                  <button
                    key={p}
                    onClick={() => setQuery(p)}
                    className="text-xs font-semibold px-3 py-1 rounded-lg bg-saffron-50 text-saffron-800 border border-saffron-200 hover:bg-saffron-100"
                  >
                    🔍 Try "{p}"
                  </button>
                ))}
              </div>
            </div>
          ) : liveResults.length === 0 ? (
            <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 text-stone-400">
              <Music size={36} className="mx-auto mb-2 opacity-30 text-saffron-700" />
              <p className="font-semibold text-sm">No live tracks found for "{query}"</p>
              <p className="text-xs text-stone-400 mt-1">Try a different spelling or singer name</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {liveResults.map((song, i) => (
                <SongTile key={song.id} song={song} queue={liveResults} index={i} />
              ))}
            </div>
          )
        ) : (
          /* Curated Local Tracks */
          displayedCurated.length === 0 ? (
            <div className="text-center py-16 bg-white rounded-3xl border border-stone-100 text-stone-400">
              <p className="font-semibold text-sm">No verified catalog tracks match "{query}"</p>
              <button
                onClick={() => setSearchMode('live')}
                className="mt-3 px-4 py-2 rounded-xl bg-saffron-600 text-white text-xs font-bold"
              >
                Search in Live Online Music instead
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {displayedCurated.map((song, i) => (
                <SongTile key={song.id} song={song} queue={displayedCurated} index={i} />
              ))}
            </div>
          )
        )}
      </div>
    </div>
  );
};
