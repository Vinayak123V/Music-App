import React, { useState, useEffect } from 'react';
import { resolveUrl } from '../../config/api';

const deityIcons = {
  shiva: '🕉️',
  hanuman: '🚩',
  krishna: '🦚',
  rama: '🏹',
  ganesha: '🐘',
  durga: '🔱',
  vishnu: '☸️',
  murugan: '🦚',
  ayyappa: '🐅',
  guru: '🪔',
  default: '🕉️'
};

const deityGradients = {
  shiva: 'from-purple-950 via-indigo-900 to-stone-900',
  hanuman: 'from-orange-950 via-amber-900 to-stone-900',
  krishna: 'from-blue-950 via-sky-900 to-stone-900',
  rama: 'from-amber-950 via-yellow-900 to-stone-900',
  ganesha: 'from-rose-950 via-red-900 to-stone-900',
  durga: 'from-red-950 via-rose-900 to-stone-900',
  vishnu: 'from-emerald-950 via-teal-900 to-stone-900',
  murugan: 'from-orange-950 via-red-900 to-stone-900',
  ayyappa: 'from-amber-950 via-orange-900 to-stone-900',
  guru: 'from-yellow-950 via-amber-900 to-stone-900',
  default: 'from-saffron-950 via-stone-900 to-black'
};

export const DevotionalImage = ({
  src,
  deityId = 'default',
  alt = 'Devotional Artwork',
  className = 'w-full h-full object-cover',
  fallbackIcon = null
}) => {
  const normalizedDeity = deityId ? deityId.toLowerCase() : 'default';
  const defaultLocalArtwork = `/artwork/${normalizedDeity}.jpg`;

  const [currentSrc, setCurrentSrc] = useState(() => {
    if (src) return resolveUrl(src);
    return defaultLocalArtwork;
  });
  const [hasError, setHasError] = useState(false);
  const [fallbackTried, setFallbackTried] = useState(false);

  useEffect(() => {
    if (src) {
      setCurrentSrc(resolveUrl(src));
      setHasError(false);
      setFallbackTried(false);
    } else {
      setCurrentSrc(defaultLocalArtwork);
    }
  }, [src, normalizedDeity]);

  const handleError = () => {
    if (!fallbackTried) {
      // First fallback: Switch to local bundled deity artwork
      setFallbackTried(true);
      setCurrentSrc(defaultLocalArtwork);
    } else if (currentSrc !== '/artwork/default.jpg') {
      // Second fallback: Switch to universal golden Om lotus
      setCurrentSrc('/artwork/default.jpg');
    } else {
      // Final fallback: Show styled devotional divine badge
      setHasError(true);
    }
  };

  if (hasError) {
    const icon = fallbackIcon || deityIcons[normalizedDeity] || deityIcons.default;
    const gradient = deityGradients[normalizedDeity] || deityGradients.default;

    return (
      <div className={`w-full h-full flex items-center justify-center bg-gradient-to-br ${gradient} select-none relative overflow-hidden border border-gold/30 shadow-inner`}>
        <div className="absolute inset-0 bg-gold/10 rounded-full blur-xl" />
        <span className="text-4xl sm:text-5xl filter drop-shadow-lg relative z-10 animate-in fade-in zoom-in-75 duration-300">
          {icon}
        </span>
      </div>
    );
  }

  return (
    <img
      src={currentSrc}
      alt={alt}
      className={className}
      onError={handleError}
      loading="lazy"
    />
  );
};
export default DevotionalImage;
