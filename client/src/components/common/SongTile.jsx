import React from 'react';
import { Heart, Pause, Play, Shield } from 'lucide-react';
import { usePlayer } from '../../context/PlayerContext';
import { useFavorites } from '../../context/FavoritesContext';
import { resolveUrl } from '../../config/api';
import { DevotionalImage } from './DevotionalImage';

export const formatDuration = (sec) => {
  if (!sec || isNaN(sec)) return '0:00';
  const m = Math.floor(sec / 60);
  const s = Math.floor(sec % 60);
  return `${m}:${s < 10 ? '0' : ''}${s}`;
};

export const SongTile = ({ song, queue = null, index = null }) => {
  const { currentSong, isPlaying, playSong, togglePlay } = usePlayer();
  const { isFavorite, toggleFavorite } = useFavorites();

  const isCurrent = currentSong?.id === song.id;
  const isFav = isFavorite(song.id);

  const handleTileClick = () => {
    if (isCurrent) {
      togglePlay();
    } else {
      playSong(song, queue, index);
    }
  };

  return (
    <div
      onClick={handleTileClick}
      className={`group flex items-center justify-between p-3 rounded-2xl cursor-pointer transition-all duration-200 border ${
        isCurrent
          ? 'bg-saffron-50/80 border-saffron-300 shadow-sm'
          : 'bg-white hover:bg-saffron-50/40 border-stone-100 hover:border-saffron-200'
      }`}
    >
      <div className="flex items-center gap-3.5 min-w-0">
        {/* Artwork / Play Overlay */}
        <div className="relative w-12 h-12 rounded-xl overflow-hidden bg-saffron-100 flex-shrink-0 border border-saffron-200/60 shadow-sm">
          <DevotionalImage
            src={song.artworkUrl}
            deityId={song.deityId}
            alt={song.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform"
          />

          {/* Playing overlay */}
          <div
            className={`absolute inset-0 bg-black/40 flex items-center justify-center transition-opacity ${
              isCurrent ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'
            }`}
          >
            {isCurrent && isPlaying ? (
              <Pause size={18} className="text-white fill-white" />
            ) : (
              <Play size={18} className="text-white fill-white translate-x-0.5" />
            )}
          </div>
        </div>

        {/* Text Info */}
        <div className="min-w-0">
          <div className="flex items-center gap-1.5">
            <h4
              className={`text-sm font-bold truncate ${
                isCurrent ? 'text-saffron-800' : 'text-stone-900'
              }`}
            >
              {song.title}
            </h4>
          </div>
          <div className="flex items-center gap-2 text-xs text-stone-500 mt-0.5">
            <span className="truncate max-w-[140px] sm:max-w-[200px]">{song.artist}</span>
            <span>•</span>
            <span className="text-[10px] font-semibold px-1.5 py-0.2 rounded bg-stone-100 text-stone-600">
              {song.language || 'Hindi'}
            </span>
            {song.source === 'youtube' && (
              <span className="text-[9px] font-bold px-1.5 py-0.5 rounded bg-saffron-100 text-saffron-900 border border-saffron-200">
                Live
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Right Actions */}
      <div className="flex items-center gap-3 ml-2 flex-shrink-0">
        <span className="text-xs text-stone-400 font-medium hidden sm:inline">
          {formatDuration(song.durationSeconds)}
        </span>

        {/* Favorite Heart */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            toggleFavorite(song.id);
          }}
          className={`p-2 rounded-full transition-colors ${
            isFav
              ? 'text-red-500 hover:bg-red-50'
              : 'text-stone-400 hover:text-stone-700 hover:bg-stone-100'
          }`}
          title={isFav ? 'Remove from favorites' : 'Add to favorites'}
        >
          <Heart size={18} className={isFav ? 'fill-red-500' : ''} />
        </button>
      </div>
    </div>
  );
};
