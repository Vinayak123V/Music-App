import React from 'react';
import { Heart, Maximize2, Pause, Play, SkipForward } from 'lucide-react';
import { usePlayer } from '../../context/PlayerContext';
import { useFavorites } from '../../context/FavoritesContext';
import { resolveUrl } from '../../config/api';
import { DevotionalImage } from '../common/DevotionalImage';

export const DockedMiniPlayer = () => {
  const {
    currentSong,
    isPlaying,
    isBuffering,
    currentTime,
    duration,
    togglePlay,
    next,
    setIsFullPlayerOpen,
  } = usePlayer();

  const { isFavorite, toggleFavorite } = useFavorites();

  if (!currentSong) return null;

  const isFav = isFavorite(currentSong.id);
  const progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <div
      onClick={() => setIsFullPlayerOpen(true)}
      className="fixed bottom-[65px] md:bottom-4 left-3 right-3 md:left-auto md:right-6 md:w-[420px] z-30 bg-devotional-dark/95 text-white backdrop-blur-xl rounded-2xl shadow-2xl border border-gold/30 cursor-pointer hover:border-gold/60 transition-all select-none overflow-hidden aura-glow"
    >
      {/* Mini top progress line */}
      <div className="w-full bg-stone-800 h-1">
        <div
          className="bg-gradient-to-r from-saffron-500 to-gold h-full transition-all duration-150"
          style={{ width: `${progressPercent}%` }}
        />
      </div>

      <div className="px-3.5 py-2.5 flex items-center justify-between gap-3">
        {/* Artwork + Title */}
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-11 h-11 rounded-xl overflow-hidden bg-stone-800 border border-saffron-500/30 flex-shrink-0 relative">
            <DevotionalImage
              src={currentSong.artworkUrl}
              deityId={currentSong.deityId}
              alt={currentSong.title}
              className="w-full h-full object-cover"
            />
            {isPlaying && (
              <div className="absolute inset-0 bg-saffron-950/40 flex items-center justify-center">
                <span className="w-2 h-2 rounded-full bg-gold animate-ping" />
              </div>
            )}
          </div>

          <div className="min-w-0">
            <h4 className="text-xs font-bold text-white truncate max-w-[150px] sm:max-w-[200px]">
              {currentSong.title}
            </h4>
            <p className="text-[11px] text-stone-400 truncate max-w-[140px] sm:max-w-[180px]">
              {currentSong.artist}
            </p>
          </div>
        </div>

        {/* Controls */}
        <div className="flex items-center gap-1.5 flex-shrink-0">
          {/* Favorite */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              toggleFavorite(currentSong.id);
            }}
            className={`p-2 rounded-full transition-colors ${
              isFav ? 'text-red-500' : 'text-stone-400 hover:text-white'
            }`}
          >
            <Heart size={17} className={isFav ? 'fill-red-500' : ''} />
          </button>

          {/* Play / Pause button */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              togglePlay();
            }}
            disabled={isBuffering}
            className="w-10 h-10 rounded-full bg-gradient-to-r from-saffron-500 to-saffron-600 text-stone-950 flex items-center justify-center font-bold shadow-md shadow-saffron-500/40 hover:scale-105 active:scale-95 transition-all"
          >
            {isBuffering ? (
              <div className="w-4 h-4 border-2 border-stone-900 border-t-transparent rounded-full animate-spin" />
            ) : isPlaying ? (
              <Pause size={18} className="fill-stone-950" />
            ) : (
              <Play size={18} className="fill-stone-950 translate-x-0.5" />
            )}
          </button>

          {/* Next */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              next();
            }}
            className="p-2 text-stone-300 hover:text-white rounded-full hover:bg-stone-800 transition-colors"
          >
            <SkipForward size={18} />
          </button>

          {/* Expand */}
          <button
            onClick={() => setIsFullPlayerOpen(true)}
            className="p-2 text-stone-400 hover:text-white rounded-full hover:bg-stone-800 transition-colors hidden sm:block"
          >
            <Maximize2 size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};
