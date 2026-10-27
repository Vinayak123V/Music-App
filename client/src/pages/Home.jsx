import React, { useState, useEffect } from 'react';
import { Sparkles, Play, ShieldCheck, Flame, Compass } from 'lucide-react';
import { DeityPill } from '../components/common/DeityPill';
import { SongTile } from '../components/common/SongTile';
import { DevotionalImage } from '../components/common/DevotionalImage';
import { usePlayer } from '../context/PlayerContext';
import { apiFetch, resolveUrl } from '../config/api';

export const Home = ({ onSelectCategory, onSelectDeity, onGoToSearch }) => {
  const [songs, setSongs] = useState([]);
  const [deities, setDeities] = useState([]);
  const [selectedDeity, setSelectedDeity] = useState(null);
  const [loading, setLoading] = useState(true);

  const { playSong } = usePlayer();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [songsRes, deitiesRes] = await Promise.all([
          apiFetch('/api/songs').then(r => r.json()),
          apiFetch('/api/deities').then(r => r.json()),
        ]);
        if (songsRes.success) setSongs(songsRes.data);
        if (deitiesRes.success) setDeities(deitiesRes.data);
      } catch (err) {
        console.error('Fetch home error:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const heroSong = songs.find(s => s.featured) || songs[0];
  const morningPrayers = songs.filter(s => s.categoryId === 'morning-prayers' || s.categoryId === 'mantras');
  const bhajansAndAartis = songs.filter(s => s.categoryId === 'bhajans' || s.categoryId === 'aartis');

  const filteredByDeity = selectedDeity
    ? songs.filter(s => s.deityId === selectedDeity)
    : null;

  return (
    <div className="space-y-8 pb-32">
      {/* Hero Featured Card */}
      {heroSong && (
        <section className="relative rounded-3xl overflow-hidden bg-gradient-to-br from-[#3D1400] via-[#2A0D00] to-[#120500] text-white p-6 sm:p-8 shadow-2xl border border-saffron-500/20 aura-glow">
          <div className="absolute top-0 right-0 w-80 h-80 bg-saffron-500/10 rounded-full blur-3xl pointer-events-none" />

          <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="max-w-xl text-center md:text-left">
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-saffron-500/20 text-saffron-300 border border-saffron-500/30 text-xs font-bold mb-3">
                <Sparkles size={13} className="text-gold" />
                <span>SACRED TRACK OF THE DAY</span>
              </div>
              <h1 className="text-2xl sm:text-4xl font-extrabold tracking-tight text-white leading-tight">
                {heroSong.title}
              </h1>
              <p className="text-saffron-200/90 font-medium text-sm sm:text-base mt-1.5">
                {heroSong.artist} • <span className="text-gold">{heroSong.language}</span>
              </p>
              <p className="text-stone-300 text-xs sm:text-sm mt-3 line-clamp-2 leading-relaxed">
                {heroSong.description}
              </p>

              <div className="mt-6 flex flex-wrap items-center justify-center md:justify-start gap-3">
                <button
                  onClick={() => playSong(heroSong, songs)}
                  className="flex items-center gap-2.5 px-6 py-3 rounded-2xl bg-gradient-to-r from-saffron-500 to-saffron-600 hover:from-saffron-600 hover:to-saffron-700 text-stone-950 font-bold shadow-lg shadow-saffron-500/30 hover:scale-105 active:scale-95 transition-all text-sm"
                >
                  <Play size={18} className="fill-stone-950" />
                  <span>Play Divine Audio</span>
                </button>

                <div className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-white/5 border border-white/10 text-xs text-stone-300">
                  <ShieldCheck size={15} className="text-emerald-400" />
                  <span>Verified Sacred Rights</span>
                </div>
              </div>
            </div>

            {/* Sacred Cover */}
            <div className="w-44 h-44 sm:w-56 sm:h-56 rounded-2xl overflow-hidden shadow-2xl border-2 border-gold/40 flex-shrink-0 bg-stone-900 group">
              <DevotionalImage
                src={heroSong.artworkUrl}
                deityId={heroSong.deityId}
                alt={heroSong.title}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
              />
            </div>
          </div>
        </section>
      )}

      {/* Live Online Music Search Callout */}
      <div
        onClick={onGoToSearch}
        className="p-4 sm:p-5 rounded-2xl bg-gradient-to-r from-saffron-500/10 via-gold/10 to-saffron-500/10 border border-saffron-300/60 shadow-xs flex items-center justify-between cursor-pointer hover:border-saffron-500 transition-all group"
      >
        <div className="flex items-center gap-3.5">
          <div className="w-11 h-11 rounded-xl bg-saffron-600 text-white flex items-center justify-center font-bold text-lg shadow-sm group-hover:scale-105 transition-transform">
            🔍
          </div>
          <div>
            <h3 className="font-bold text-sm text-stone-900 group-hover:text-saffron-800 transition-colors">
              Looking for a specific bhajan, singer, or mantra?
            </h3>
            <p className="text-xs text-stone-500 mt-0.5">
              Live Music Engine searches & streams millions of devotional songs instantly — zero upload needed!
            </p>
          </div>
        </div>
        <span className="text-xs font-bold text-saffron-700 bg-white px-3.5 py-1.5 rounded-xl border border-saffron-200 group-hover:bg-saffron-600 group-hover:text-white transition-all hidden sm:inline-block">
          Open Search →
        </span>
      </div>

      {/* Deities Filter Carousel */}
      <section>
        <div className="flex items-center justify-between mb-3 px-1">
          <div>
            <h2 className="text-lg font-bold text-stone-900 flex items-center gap-2">
              <span className="text-saffron-600">🕉️</span> Sacred Deities & Avatars
            </h2>
            <p className="text-xs text-stone-500">Filter audio dedicated to your Ishta Devata</p>
          </div>
          {selectedDeity && (
            <button
              onClick={() => setSelectedDeity(null)}
              className="text-xs text-saffron-700 hover:underline font-bold"
            >
              Clear filter
            </button>
          )}
        </div>

        <div className="flex gap-3 overflow-x-auto no-scrollbar py-2 px-1">
          {deities.map(deity => (
            <DeityPill
              key={deity.id}
              deity={deity}
              isSelected={selectedDeity === deity.id}
              onClick={() => setSelectedDeity(selectedDeity === deity.id ? null : deity.id)}
            />
          ))}
        </div>
      </section>

      {/* Deity Specific Selection */}
      {filteredByDeity && (
        <section className="bg-white p-5 rounded-3xl border border-saffron-200/70 shadow-sm">
          <h3 className="text-base font-bold text-stone-900 mb-3 flex items-center gap-2">
            <span>✨</span> Devotional Tracks for {deities.find(d => d.id === selectedDeity)?.name}
          </h3>
          {filteredByDeity.length === 0 ? (
            <p className="text-xs text-stone-400 py-4 text-center">No tracks currently for this deity.</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {filteredByDeity.slice(0, 12).map((song, i) => (
                <SongTile key={song.id} song={song} queue={filteredByDeity} index={i} />
              ))}
            </div>
          )}
        </section>
      )}

      {/* Morning Invocations & Mantras */}
      <section>
        <div className="flex items-center justify-between mb-3 px-1">
          <div>
            <h2 className="text-lg font-bold text-stone-900 flex items-center gap-2">
              <Flame size={18} className="text-saffron-600" /> Morning Prayers & Chants
            </h2>
            <p className="text-xs text-stone-500">Peaceful Gayatri Mantra and Rigvedic chants for daily sadhana</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
          {morningPrayers.slice(0, 8).map((song, i) => (
            <SongTile key={song.id} song={song} queue={morningPrayers} index={i} />
          ))}
        </div>
      </section>

      {/* Popular Bhajans & Aartis */}
      <section>
        <div className="flex items-center justify-between mb-3 px-1">
          <div>
            <h2 className="text-lg font-bold text-stone-900 flex items-center gap-2">
              <Compass size={18} className="text-saffron-600" /> Beloved Bhajans & Aartis
            </h2>
            <p className="text-xs text-stone-500">Hanuman Chalisa, Ganesh Aarti, and Krishna Bhajans</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
          {bhajansAndAartis.slice(0, 10).map((song, i) => (
            <SongTile key={song.id} song={song} queue={bhajansAndAartis} index={i} />
          ))}
        </div>
      </section>
    </div>
  );
};
