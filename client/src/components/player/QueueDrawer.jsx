import React from 'react';
import { ListMusic, Music, X } from 'lucide-react';
import { usePlayer } from '../../context/PlayerContext';
import { SongTile } from '../common/SongTile';

export const QueueDrawer = () => {
  const { queue, currentIndex, isQueueOpen, setIsQueueOpen } = usePlayer();

  if (!isQueueOpen) return null;

  return (
    <div
      onClick={() => setIsQueueOpen(false)}
      className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex justify-end animate-in fade-in"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full max-w-md h-full bg-cream-light text-stone-900 shadow-2xl flex flex-col border-l border-saffron-200"
      >
        {/* Header */}
        <div className="p-4 border-b border-saffron-100 flex items-center justify-between bg-saffron-50/50">
          <div className="flex items-center gap-2 font-bold text-base text-stone-900">
            <ListMusic size={20} className="text-saffron-700" />
            <span>Devotional Playback Queue ({queue.length})</span>
          </div>
          <button
            onClick={() => setIsQueueOpen(false)}
            className="p-1.5 rounded-full text-stone-400 hover:text-stone-700 hover:bg-stone-200"
          >
            <X size={20} />
          </button>
        </div>

        {/* List of songs */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          {queue.length === 0 ? (
            <div className="text-center py-12 text-stone-400">
              <Music size={40} className="mx-auto mb-2 opacity-40 text-saffron-700" />
              <p className="text-sm font-medium">Queue is currently empty</p>
              <p className="text-xs text-stone-500 mt-1">Play any bhajan or aarti to begin</p>
            </div>
          ) : (
            queue.map((song, idx) => (
              <div key={`${song.id}-${idx}`} className="relative">
                {idx === currentIndex && (
                  <span className="absolute -left-2 top-1/2 -translate-y-1/2 w-1.5 h-6 bg-saffron-600 rounded-r" />
                )}
                <SongTile song={song} queue={queue} index={idx} />
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
