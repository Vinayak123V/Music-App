import React, { useState } from 'react';
import { Navbar } from './components/layout/Navbar';
import { BottomNav } from './components/layout/BottomNav';
import { DockedMiniPlayer } from './components/player/DockedMiniPlayer';
import { FullPlayerModal } from './components/player/FullPlayerModal';
import { QueueDrawer } from './components/player/QueueDrawer';

import { Home } from './pages/Home';
import { Browse } from './pages/Browse';
import { Search } from './pages/Search';
import { Library } from './pages/Library';
import { AuthModal } from './components/auth/AuthModal';

export function App() {
  const [currentTab, setCurrentTab] = useState('home');

  return (
    <div className="min-h-screen flex flex-col bg-cream text-stone-900 selection:bg-saffron-200">
      {/* Navigation Header */}
      <Navbar currentTab={currentTab} setCurrentTab={setCurrentTab} />

      {/* Main Content Viewport */}
      <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-6">
        {currentTab === 'home' && <Home onGoToSearch={() => setCurrentTab('search')} />}
        {currentTab === 'browse' && <Browse />}
        {currentTab === 'search' && <Search />}
        {currentTab === 'library' && <Library />}
      </main>

      {/* User Login / Register / Guest Auth Modal */}
      <AuthModal />

      {/* Persistent Docked MiniPlayer */}
      <DockedMiniPlayer />

      {/* Full-Screen Devotional Audio Player Modal */}
      <FullPlayerModal />

      {/* Queue Drawer */}
      <QueueDrawer />

      {/* Mobile Bottom Navigation Bar */}
      <BottomNav currentTab={currentTab} setCurrentTab={setCurrentTab} />

      {/* Hidden YouTube Audio Player Engine (positioned offscreen with valid surface for mobile WebView) */}
      <div id="bhakti-yt-hidden-player" className="fixed -bottom-[999px] -right-[999px] w-64 h-64 pointer-events-none opacity-0" />
    </div>
  );
}

export default App;
