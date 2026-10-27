import React, { useState } from 'react';
import {
  ChevronDown,
  Heart,
  ListMusic,
  Pause,
  Play,
  Repeat,
  Repeat1,
  Shuffle,
  SkipBack,
  SkipForward,
  Sparkles,
} from 'lucide-react';
import { usePlayer } from '../../context/PlayerContext';
import { useFavorites } from '../../context/FavoritesContext';
import { formatDuration } from '../common/SongTile';
import { RightsBadge } from '../common/RightsBadge';
import { resolveUrl } from '../../config/api';
import { DevotionalImage } from '../common/DevotionalImage';

export const FullPlayerModal = () => {
  const {
    currentSong,
    isPlaying,
    isBuffering,
    currentTime,
    duration,
    loopMode,
    isShuffle,
    playbackRate,
    isFullPlayerOpen,
    setIsFullPlayerOpen,
    setIsQueueOpen,
    togglePlay,
    seek,
    next,
    prev,
    toggleShuffle,
    toggleLoop,
    changePlaybackRate,
  } = usePlayer();

  const { isFavorite, toggleFavorite } = useFavorites();
  const [sliderHoverTime, setSliderHoverTime] = useState(null);

  if (!isFullPlayerOpen || !currentSong) return null;

  const isFav = isFavorite(currentSong.id);
  const activeTime = sliderHoverTime ?? currentTime;

  const rates = [0.75, 1, 1.25];
  const nextRate = () => {
    const nextIdx = (rates.indexOf(playbackRate) + 1) % rates.length;
    changePlaybackRate(rates[nextIdx]);
  };

  return (
    <div className="fixed inset-0 z-50 bg-gradient-to-b from-[#2E1202] via-[#1A0B01] to-[#0A0400] text-white flex flex-col justify-between animate-in fade-in slide-in-from-bottom duration-300">
      {/* Top Bar */}
      <div className="px-6 py-4 flex items-center justify-between border-b border-white/5">
        <button
          onClick={() => setIsFullPlayerOpen(false)}
          className="p-2 -ml-2 text-stone-300 hover:text-white rounded-full hover:bg-white/10 transition-colors"
        >
          <ChevronDown size={28} />
        </button>

        <div className="text-center">
          <p className="text-[11px] uppercase tracking-widest text-saffron-300 font-bold flex items-center justify-center gap-1">
            <Sparkles size={12} className="text-gold" />
            <span>PLAYING DEVOTIONAL AUDIO</span>
          </p>
          <p className="text-xs text-stone-400 font-medium mt-0.5">
            {currentSong.language?.toUpperCase() || 'HINDI'} • BHAKTI MUSIC
          </p>
        </div>

        <button
          onClick={() => setIsQueueOpen(true)}
          className="p-2 -mr-2 text-stone-300 hover:text-white rounded-full hover:bg-white/10 transition-colors"
          title="Open Queue"
        >
          <ListMusic size={22} />
        </button>
      </div>

      {/* Main Body: Artwork & Aura */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-4 max-w-md mx-auto w-full">
        {/* Sacred Artwork with glowing halo */}
        <div className="relative w-64 h-64 sm:w-80 sm:h-80 my-auto flex-shrink-0">
          <div className="absolute inset-0 rounded-3xl bg-gradient-to-tr from-saffron-600/30 to-gold/30 blur-2xl transform scale-105" />

          <div className="relative w-full h-full rounded-3xl overflow-hidden shadow-2xl border-2 border-gold/40 bg-stone-900 flex items-center justify-center">
            <DevotionalImage
              src={currentSong.artworkUrl}
              deityId={currentSong.deityId}
              alt={currentSong.title}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Title, Artist, Rights & Favorite */}
        <div className="w-full mt-6 flex items-start justify-between gap-4">
          <div className="min-w-0">
            <h2 className="text-xl sm:text-2xl font-extrabold text-white tracking-tight truncate">
              {currentSong.title}
            </h2>
            <p className="text-sm sm:text-base text-stone-300 font-medium truncate mt-0.5">
              {currentSong.artist}
            </p>
            <div className="mt-2 flex items-center gap-2">
              <RightsBadge rights={currentSong.rights} />
              <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-saffron-950/80 text-saffron-300 border border-saffron-700/50">
                {currentSong.categoryId}
              </span>
            </div>
          </div>

          <button
            onClick={() => toggleFavorite(currentSong.id)}
            className={`p-3 rounded-full hover:bg-white/10 transition-colors ${
              isFav ? 'text-red-500' : 'text-stone-400 hover:text-white'
            }`}
          >
            <Heart size={26} className={isFav ? 'fill-red-500' : ''} />
          </button>
        </div>

        {/* Scrubber / Progress Slider */}
        <div className="w-full mt-6">
          <div className="relative flex items-center group">
            <input
              type="range"
              min="0"
              max={duration || 1}
              step="0.1"
              value={activeTime}
              onChange={(e) => seek(parseFloat(e.target.value))}
              className="w-full h-1.5 bg-stone-800 rounded-lg appearance-none cursor-pointer accent-saffron-500 hover:h-2 transition-all"
            />
          </div>
          <div className="flex justify-between text-xs text-stone-400 mt-1.5 font-medium">
            <span>{formatDuration(activeTime)}</span>
            <span>{formatDuration(duration || currentSong.durationSeconds)}</span>
          </div>
        </div>

        {/* Playback Controls */}
        <div className="w-full mt-4 flex items-center justify-between">
          {/* Shuffle */}
          <button
            onClick={toggleShuffle}
            className={`p-2.5 rounded-full transition-colors ${
              isShuffle ? 'text-gold bg-gold/10' : 'text-stone-400 hover:text-white'
            }`}
            title="Shuffle"
          >
            <Shuffle size={20} />
          </button>

          {/* Previous */}
          <button
            onClick={prev}
            className="p-3 text-stone-200 hover:text-white rounded-full hover:bg-white/10 transition-colors active:scale-95"
            title="Previous"
          >
            <SkipBack size={28} />
          </button>

          {/* Big Play / Pause */}
          <button
            onClick={togglePlay}
            disabled={isBuffering}
            className="w-18 h-18 sm:w-20 sm:h-20 rounded-full bg-gradient-to-tr from-saffron-500 via-saffron-600 to-gold text-stone-950 flex items-center justify-center font-bold shadow-xl shadow-saffron-600/40 hover:scale-105 active:scale-95 transition-all p-5"
          >
            {isBuffering ? (
              <div className="w-8 h-8 border-3 border-stone-950 border-t-transparent rounded-full animate-spin" />
            ) : isPlaying ? (
              <Pause size={34} className="fill-stone-950" />
            ) : (
              <Play size={34} className="fill-stone-950 translate-x-0.5" />
            )}
          </button>

          {/* Next */}
          <button
            onClick={next}
            className="p-3 text-stone-200 hover:text-white rounded-full hover:bg-white/10 transition-colors active:scale-95"
            title="Next"
          >
            <SkipForward size={28} />
          </button>

          {/* Loop Mode */}
          <button
            onClick={toggleLoop}
            className={`p-2.5 rounded-full transition-colors ${
              loopMode !== 'off' ? 'text-gold bg-gold/10' : 'text-stone-400 hover:text-white'
            }`}
            title={`Loop: ${loopMode}`}
          >
            {loopMode === 'one' ? <Repeat1 size={20} /> : <Repeat size={20} />}
          </button>
        </div>

        {/* Bottom Options: Speed / Devotional Peace */}
        <div className="w-full mt-4 flex items-center justify-between text-xs text-stone-400">
          <button
            onClick={nextRate}
            className="px-2.5 py-1 rounded-lg bg-stone-900 border border-stone-800 text-stone-300 hover:border-gold/50 transition-colors"
          >
            Chant Speed: <span className="text-gold font-bold">{playbackRate}x</span>
          </button>

          <span className="text-[11px] text-stone-500">Pure Devotion • Ad-Free</span>
        </div>
      </div>
    </div>
  );
};
