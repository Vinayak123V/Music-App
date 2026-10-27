import React from 'react';
import { Compass, Heart, Home, Music2, Search, User as UserIcon, LogOut } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export const Navbar = ({ currentTab, setCurrentTab }) => {
  const { user, isGuest, isAuthenticated, openAuthModal, logout } = useAuth();

  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'browse', label: 'Browse', icon: Compass },
    { id: 'search', label: 'Search', icon: Search },
    { id: 'library', label: 'My Library', icon: Heart },
  ];

  return (
    <header className="sticky top-0 z-40 bg-cream-light/95 backdrop-blur-md border-b border-saffron-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        {/* Brand */}
        <div
          onClick={() => setCurrentTab('home')}
          className="flex items-center gap-3 cursor-pointer select-none group"
        >
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-saffron-500 to-saffron-800 flex items-center justify-center text-white shadow-md shadow-saffron-500/20 group-hover:scale-105 transition-transform overflow-hidden border border-gold/40">
            <img src="/logo.png" alt="Bhakti Music" className="w-full h-full object-cover" onError={(e) => { e.target.style.display = 'none'; }} />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-lg text-stone-900 tracking-tight">Bhakti Music</span>
              <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-saffron-100 text-saffron-800 border border-saffron-200">
                Pure
              </span>
            </div>
            <p className="text-[11px] text-stone-500 hidden sm:block">Your Daily Devotional Music</p>
          </div>
        </div>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-1">
          {navItems.map(item => {
            const Icon = item.icon;
            const isActive = currentTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setCurrentTab(item.id)}
                className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-saffron-500 text-white shadow-sm shadow-saffron-500/30'
                    : 'text-stone-600 hover:text-stone-900 hover:bg-saffron-50'
                }`}
              >
                <Icon size={17} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>

        {/* User Account / Guest Status */}
        <div className="flex items-center gap-2">
          {isAuthenticated ? (
            <div className="flex items-center gap-2 pl-3 pr-2 py-1.5 rounded-full bg-saffron-50 border border-saffron-200 shadow-sm">
              <div className="w-6 h-6 rounded-full bg-gradient-to-br from-saffron-600 to-saffron-800 text-white flex items-center justify-center text-xs font-bold">
                {user.name ? user.name[0].toUpperCase() : 'D'}
              </div>
              <span className="text-xs font-bold text-stone-800 hidden sm:inline max-w-[120px] truncate">
                {user.name}
              </span>
              <button
                onClick={logout}
                title="Log out"
                className="p-1 rounded-full text-stone-400 hover:text-red-600 hover:bg-red-50 transition-all"
              >
                <LogOut size={14} />
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-stone-100 text-stone-600 border border-stone-200 hidden sm:inline-flex items-center gap-1">
                <span>🙏</span> Guest Devotee
              </span>
              <button
                onClick={openAuthModal}
                className="text-xs font-bold px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-saffron-600 to-saffron-700 hover:from-saffron-700 hover:to-saffron-800 text-white shadow-sm shadow-saffron-600/20 transition-all"
              >
                Sign In / Register
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
