import React, { createContext, useContext, useState, useRef, useEffect } from 'react';
import { useFavorites } from './FavoritesContext';
import { resolveUrl } from '../config/api';
import { searchOnlineMusic } from '../services/onlineMusicService';

const PlayerContext = createContext();

export const PlayerProvider = ({ children }) => {
  const audioRef = useRef(new Audio());
  const ytPlayerRef = useRef(null);
  const ytTimerRef = useRef(null);
  const { addRecentlyPlayed } = useFavorites();

  const [currentSong, setCurrentSong] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isBuffering, setIsBuffering] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [queue, setQueue] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(-1);
  const [loopMode, setLoopMode] = useState('off'); // 'off' | 'all' | 'one'
  const [isShuffle, setIsShuffle] = useState(false);
  const [playbackRate, setPlaybackRate] = useState(1);
  const [isFullPlayerOpen, setIsFullPlayerOpen] = useState(false);
  const [isQueueOpen, setIsQueueOpen] = useState(false);

  // 1. Initialize YouTube Iframe API once
  useEffect(() => {
    const initYt = () => {
      if (ytPlayerRef.current || !window.YT || !window.YT.Player) return;
      try {
        ytPlayerRef.current = new window.YT.Player('bhakti-yt-hidden-player', {
          height: '240',
          width: '320',
          playerVars: {
            autoplay: 1,
            controls: 0,
            disablekb: 1,
            fs: 0,
            playsinline: 1,
            enablejsapi: 1,
          },
          events: {
            onReady: () => {
              console.log('[YouTube Player] Ready');
            },
            onStateChange: (event) => {
              // -1: unstarted, 0: ended, 1: playing, 2: paused, 3: buffering
              if (event.data === 1) {
                setIsPlaying(true);
                setIsBuffering(false);
                const d = ytPlayerRef.current?.getDuration() || 0;
                if (d > 0) setDuration(d);
              } else if (event.data === 2) {
                setIsPlaying(false);
              } else if (event.data === 3) {
                setIsBuffering(true);
              } else if (event.data === 0) {
                setIsPlaying(false);
                if (loopMode === 'one') {
                  ytPlayerRef.current?.seekTo(0, true);
                  ytPlayerRef.current?.playVideo();
                } else {
                  next();
                }
              }
            },
            onError: (err) => {
              console.warn('[YouTube Player] Error:', err.data);
              setIsBuffering(false);
            },
          },
        });
      } catch (e) {
        console.warn('[YouTube Player] Init error:', e);
      }
    };

    if (window.YT && window.YT.Player) {
      initYt();
    } else {
      window.onYouTubeIframeAPIReady = initYt;
      if (!document.getElementById('yt-iframe-script')) {
        const tag = document.createElement('script');
        tag.id = 'yt-iframe-script';
        tag.src = 'https://www.youtube.com/iframe_api';
        document.body.appendChild(tag);
      }
    }
  }, []);

  // 2. Poll YouTube player currentTime when active
  useEffect(() => {
    if (currentSong?.videoId && isPlaying) {
      ytTimerRef.current = setInterval(() => {
        if (ytPlayerRef.current && typeof ytPlayerRef.current.getCurrentTime === 'function') {
          const t = ytPlayerRef.current.getCurrentTime() || 0;
          setCurrentTime(t);
          const d = ytPlayerRef.current.getDuration() || 0;
          if (d > 0) setDuration(d);
        }
      }, 250);
    } else {
      if (ytTimerRef.current) clearInterval(ytTimerRef.current);
    }

    return () => {
      if (ytTimerRef.current) clearInterval(ytTimerRef.current);
    };
  }, [currentSong, isPlaying]);

  // 3. Setup HTML5 Audio listeners (for local MP3 tracks)
  useEffect(() => {
    const audio = audioRef.current;

    const handleTimeUpdate = () => {
      if (!currentSong?.videoId) {
        setCurrentTime(audio.currentTime);
      }
    };

    const handleLoadedMetadata = () => {
      if (!currentSong?.videoId) {
        setDuration(audio.duration || 0);
        setIsBuffering(false);
      }
    };

    const handleWaiting = () => {
      if (!currentSong?.videoId) setIsBuffering(true);
    };

    const handlePlaying = () => {
      if (!currentSong?.videoId) {
        setIsBuffering(false);
        setIsPlaying(true);
      }
    };

    const handlePause = () => {
      if (!currentSong?.videoId) setIsPlaying(false);
    };

    const handleEnded = () => {
      if (!currentSong?.videoId) {
        if (loopMode === 'one') {
          audio.currentTime = 0;
          audio.play().catch(console.error);
        } else {
          next();
        }
      }
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('waiting', handleWaiting);
    audio.addEventListener('playing', handlePlaying);
    audio.addEventListener('pause', handlePause);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('waiting', handleWaiting);
      audio.removeEventListener('playing', handlePlaying);
      audio.removeEventListener('pause', handlePause);
      audio.removeEventListener('ended', handleEnded);
    };
  }, [loopMode, currentIndex, queue, currentSong]);

  // 4. Sync Web MediaSession API (Lock screen, Android notification, media keys)
  useEffect(() => {
    if (!currentSong || !('mediaSession' in navigator)) return;

    navigator.mediaSession.metadata = new window.MediaMetadata({
      title: currentSong.title,
      artist: currentSong.artist,
      album: `${currentSong.language || 'Devotional'} • Bhakti Music`,
      artwork: [
        {
          src: resolveUrl(currentSong.artworkUrl || `/artwork/${currentSong.deityId || 'default'}.jpg`),
          sizes: '512x512',
          type: 'image/jpeg'
        },
      ],
    });

    navigator.mediaSession.setActionHandler('play', () => togglePlay());
    navigator.mediaSession.setActionHandler('pause', () => togglePlay());
    navigator.mediaSession.setActionHandler('previoustrack', () => prev());
    navigator.mediaSession.setActionHandler('nexttrack', () => next());
    navigator.mediaSession.setActionHandler('seekto', (details) => {
      if (details.seekTime != null) {
        seek(details.seekTime);
      }
    });
  }, [currentSong, isPlaying]);

  const playSong = async (song, newQueue = null, index = null) => {
    if (!song) return;

    let targetSong = { ...song };
    const activeQueue = newQueue || (queue.length > 0 ? queue : [song]);
    const resolvedIndex = index != null ? index : activeQueue.findIndex(s => s.id === song.id);

    setQueue(activeQueue);
    setCurrentIndex(resolvedIndex >= 0 ? resolvedIndex : 0);
    setCurrentSong(targetSong);
    setIsBuffering(true);
    addRecentlyPlayed(targetSong);

    // If song is from catalog and has no direct videoId or audioUrl, resolve stream on the fly
    if (!targetSong.videoId && !targetSong.audioUrl) {
      try {
        const query = targetSong.searchQuery || `${targetSong.title} ${targetSong.artist} devotional`;
        const onlineMatches = await searchOnlineMusic(query);
        if (onlineMatches && onlineMatches.length > 0) {
          const match = onlineMatches[0];
          if (match.videoId) {
            targetSong.videoId = match.videoId;
            targetSong.source = 'youtube';
          } else if (match.audioUrl) {
            targetSong.audioUrl = match.audioUrl;
          }
          if (match.artworkUrl) {
            targetSong.artworkUrl = match.artworkUrl;
          }
          setCurrentSong({ ...targetSong });
        }
      } catch (err) {
        console.warn('[PlayerContext] Stream resolution error:', err);
      }
    }

    if (targetSong.videoId) {
      // 1. YouTube Live Audio Stream
      if (audioRef.current) {
        audioRef.current.pause();
      }

      if (targetSong.durationSeconds) setDuration(targetSong.durationSeconds);
      setCurrentTime(0);

      const startYt = () => {
        if (ytPlayerRef.current && typeof ytPlayerRef.current.loadVideoById === 'function') {
          ytPlayerRef.current.loadVideoById(targetSong.videoId);
          ytPlayerRef.current.playVideo();
        } else {
          setTimeout(startYt, 300);
        }
      };
      startYt();
    } else {
      // 2. Direct MP3 File
      if (ytPlayerRef.current && typeof ytPlayerRef.current.pauseVideo === 'function') {
        ytPlayerRef.current.pauseVideo();
      }

      try {
        const audio = audioRef.current;
        audio.pause();
        audio.src = resolveUrl(targetSong.audioUrl || '/uploads/audio/gayatri_mantra.mp3');
        audio.playbackRate = playbackRate;
        await audio.play();
        setIsPlaying(true);
      } catch (err) {
        console.warn('[Player] Direct playback error, falling back:', err);
        try {
          const audio = audioRef.current;
          audio.src = resolveUrl('/uploads/audio/gayatri_mantra.mp3');
          await audio.play();
          setIsPlaying(true);
        } catch (_) {}
      } finally {
        setIsBuffering(false);
      }
    }
  };

  const togglePlay = () => {
    if (!currentSong) return;

    if (currentSong.videoId) {
      if (isPlaying) {
        ytPlayerRef.current?.pauseVideo();
      } else {
        ytPlayerRef.current?.playVideo();
      }
    } else {
      const audio = audioRef.current;
      if (isPlaying) {
        audio.pause();
      } else {
        audio.play().catch(console.error);
      }
    }
  };

  const seek = (timeInSeconds) => {
    setCurrentTime(timeInSeconds);
    if (currentSong?.videoId) {
      ytPlayerRef.current?.seekTo(timeInSeconds, true);
    } else if (audioRef.current) {
      audioRef.current.currentTime = timeInSeconds;
    }
  };

  const next = () => {
    if (queue.length === 0) return;
    let nextIdx = currentIndex + 1;
    if (nextIdx >= queue.length) {
      if (loopMode === 'all') {
        nextIdx = 0;
      } else {
        return;
      }
    }
    playSong(queue[nextIdx], queue, nextIdx);
  };

  const prev = () => {
    if (queue.length === 0) return;
    if (currentTime > 4) {
      seek(0);
      return;
    }
    let prevIdx = currentIndex - 1;
    if (prevIdx < 0) {
      if (loopMode === 'all') {
        prevIdx = queue.length - 1;
      } else {
        prevIdx = 0;
      }
    }
    playSong(queue[prevIdx], queue, prevIdx);
  };

  const toggleShuffle = () => {
    setIsShuffle(prev => {
      const nextState = !prev;
      if (nextState && currentSong) {
        const shuffled = [...queue].sort(() => Math.random() - 0.5);
        const withoutCurrent = shuffled.filter(s => s.id !== currentSong.id);
        setQueue([currentSong, ...withoutCurrent]);
        setCurrentIndex(0);
      }
      return nextState;
    });
  };

  const toggleLoop = () => {
    setLoopMode(prev => {
      if (prev === 'off') return 'all';
      if (prev === 'all') return 'one';
      return 'off';
    });
  };

  const changePlaybackRate = (rate) => {
    setPlaybackRate(rate);
    if (!currentSong?.videoId && audioRef.current) {
      audioRef.current.playbackRate = rate;
    } else if (currentSong?.videoId && ytPlayerRef.current?.setPlaybackRate) {
      ytPlayerRef.current.setPlaybackRate(rate);
    }
  };

  return (
    <PlayerContext.Provider
      value={{
        currentSong,
        isPlaying,
        isBuffering,
        currentTime,
        duration,
        queue,
        currentIndex,
        loopMode,
        isShuffle,
        playbackRate,
        isFullPlayerOpen,
        isQueueOpen,
        setIsFullPlayerOpen,
        setIsQueueOpen,
        playSong,
        togglePlay,
        seek,
        next,
        prev,
        toggleShuffle,
        toggleLoop,
        changePlaybackRate,
      }}
    >
      {children}
    </PlayerContext.Provider>
  );
};

export const usePlayer = () => useContext(PlayerContext);
