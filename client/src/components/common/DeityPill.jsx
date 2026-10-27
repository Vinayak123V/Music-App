import React from 'react';

export const DeityPill = ({ deity, isSelected, onClick }) => {
  return (
    <button
      onClick={onClick}
      className={`flex items-center gap-2.5 px-4 py-2 rounded-2xl whitespace-nowrap transition-all duration-200 border ${
        isSelected
          ? 'bg-gradient-to-r from-saffron-600 to-saffron-800 text-white border-transparent shadow-md shadow-saffron-600/30 scale-[1.02]'
          : 'bg-white hover:bg-saffron-50 text-stone-800 border-saffron-200/70 hover:border-saffron-300 shadow-sm'
      }`}
    >
      <span className="text-xl leading-none">{deity.icon || '🕉️'}</span>
      <div className="text-left">
        <p className={`text-xs font-bold leading-tight ${isSelected ? 'text-white' : 'text-stone-900'}`}>
          {deity.name}
        </p>
        <p className={`text-[10px] leading-tight ${isSelected ? 'text-saffron-100' : 'text-stone-500'}`}>
          {deity.title?.split('&')[0]?.trim()}
        </p>
      </div>
    </button>
  );
};
