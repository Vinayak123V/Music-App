import React from 'react';
import { Compass, Heart, Home, Search } from 'lucide-react';

export const BottomNav = ({ currentTab, setCurrentTab }) => {
  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'search', label: 'Search & Explore', icon: Search },
    { id: 'library', label: 'Library', icon: Heart },
  ];

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-cream-light/95 backdrop-blur-lg border-t border-saffron-100 px-2 py-1.5 flex items-center justify-around shadow-lg">
      {navItems.map(item => {
        const Icon = item.icon;
        const isActive = currentTab === item.id;
        return (
          <button
            key={item.id}
            onClick={() => setCurrentTab(item.id)}
            className={`flex flex-col items-center justify-center py-1 px-3 rounded-xl transition-all ${
              isActive ? 'text-saffron-700 font-bold scale-105' : 'text-stone-500 font-medium'
            }`}
          >
            <div className={`p-1 rounded-lg ${isActive ? 'bg-saffron-100 text-saffron-800' : ''}`}>
              <Icon size={20} />
            </div>
            <span className="text-[10px] mt-0.5">{item.label}</span>
          </button>
        );
      })}
    </nav>
  );
};
