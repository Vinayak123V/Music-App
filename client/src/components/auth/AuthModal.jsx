import React, { useState } from 'react';
import { User, Mail, Lock, Sparkles, ArrowRight, X, Heart, Shield } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export const AuthModal = () => {
  const { isAuthModalOpen, closeAuthModal, login, register, enterAsGuest } = useAuth();
  const [tab, setTab] = useState('login'); // 'login' | 'register'
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  if (!isAuthModalOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (tab === 'register') {
        if (!name.trim()) {
          setError('Please enter your name');
          setLoading(false);
          return;
        }
        const res = await register(name, email, password);
        if (!res.success) {
          setError(res.error || 'Registration failed');
        }
      } else {
        const res = await login(email, password);
        if (!res.success) {
          setError(res.error || 'Invalid credentials');
        }
      }
    } catch (err) {
      setError(err.message || 'An error occurred. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGuestEntry = async () => {
    setLoading(true);
    await enterAsGuest();
    setLoading(false);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-devotional-dark/80 backdrop-blur-md animate-in fade-in duration-200">
      <div className="relative w-full max-w-md bg-white rounded-3xl shadow-2xl border border-saffron-200 overflow-hidden text-stone-900">
        {/* Decorative Top Aura */}
        <div className="h-32 bg-gradient-to-br from-[#3D1400] via-[#2A0D00] to-[#120500] text-white p-6 relative flex flex-col justify-end">
          <div className="absolute top-0 right-0 w-48 h-48 bg-saffron-500/20 rounded-full blur-2xl pointer-events-none" />

          {/* Close button (allows dismissing to continue as guest) */}
          <button
            onClick={closeAuthModal}
            className="absolute top-4 right-4 p-2 rounded-full bg-white/10 hover:bg-white/20 text-white/80 transition-all"
            title="Continue"
          >
            <X size={18} />
          </button>

          <div className="relative z-10 flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-saffron-500 to-saffron-700 flex items-center justify-center shadow-lg border border-gold/40 overflow-hidden">
              <img src="/logo.png" alt="Bhakti Music" className="w-full h-full object-cover" onError={(e) => { e.target.style.display = 'none'; }} />
            </div>
            <div>
              <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-1.5">
                <span>Bhakti Music</span>
                <span className="text-[10px] uppercase font-bold px-1.5 py-0.5 rounded bg-gold/20 text-gold border border-gold/40">Pure</span>
              </h2>
              <p className="text-xs text-saffron-200/90 font-medium">Your Daily Devotional Sanctuary</p>
            </div>
          </div>
        </div>

        {/* Tab Switcher */}
        <div className="flex border-b border-stone-100 bg-cream-light/60 p-1.5 gap-1.5">
          <button
            type="button"
            onClick={() => { setTab('login'); setError(''); }}
            className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all ${
              tab === 'login'
                ? 'bg-white text-saffron-700 shadow-sm'
                : 'text-stone-500 hover:text-stone-800'
            }`}
          >
            Sign In
          </button>
          <button
            type="button"
            onClick={() => { setTab('register'); setError(''); }}
            className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all ${
              tab === 'register'
                ? 'bg-white text-saffron-700 shadow-sm'
                : 'text-stone-500 hover:text-stone-800'
            }`}
          >
            Create Account
          </button>
        </div>

        {/* Form Body */}
        <div className="p-6 space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-red-50 border border-red-200 text-red-700 text-xs font-medium">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3.5">
            {tab === 'register' && (
              <div>
                <label className="block text-xs font-bold text-stone-700 mb-1">Full Name</label>
                <div className="relative">
                  <User size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400" />
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. Ramesh Sharma"
                    className="w-full pl-10 pr-4 py-2.5 bg-cream/40 border border-stone-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-saffron-500/40 focus:border-saffron-500"
                  />
                </div>
              </div>
            )}

            <div>
              <label className="block text-xs font-bold text-stone-700 mb-1">Email Address</label>
              <div className="relative">
                <Mail size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400" />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="devotee@example.com"
                  className="w-full pl-10 pr-4 py-2.5 bg-cream/40 border border-stone-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-saffron-500/40 focus:border-saffron-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-stone-700 mb-1">Password</label>
              <div className="relative">
                <Lock size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400" />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-10 pr-4 py-2.5 bg-cream/40 border border-stone-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-saffron-500/40 focus:border-saffron-500"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-saffron-600 to-saffron-700 hover:from-saffron-700 hover:to-saffron-800 text-white font-bold text-sm shadow-md shadow-saffron-600/30 transition-all flex items-center justify-center gap-2 disabled:opacity-50 mt-2"
            >
              <span>{loading ? 'Please wait...' : tab === 'register' ? 'Register Account' : 'Sign In'}</span>
              <ArrowRight size={16} />
            </button>
          </form>

          {/* Divider */}
          <div className="relative flex items-center justify-center my-3">
            <div className="border-t border-stone-200 w-full" />
            <span className="bg-white px-3 text-[11px] font-bold text-stone-400 uppercase tracking-wider">or</span>
          </div>

          {/* Direct Continue As Guest Button */}
          <button
            type="button"
            onClick={handleGuestEntry}
            disabled={loading}
            className="w-full py-3 px-4 rounded-xl bg-saffron-50 hover:bg-saffron-100 text-saffron-900 border border-saffron-200/80 font-bold text-sm transition-all flex items-center justify-center gap-2 group"
          >
            <span className="text-base group-hover:scale-110 transition-transform">🕉️</span>
            <span>Enter as Guest Devotee</span>
            <span className="text-[10px] text-saffron-600 font-semibold bg-white px-2 py-0.5 rounded-full border border-saffron-200">
              No login required
            </span>
          </button>
        </div>

        {/* Footer info */}
        <div className="p-3 bg-cream-light/60 border-t border-stone-100 text-center">
          <p className="text-[11px] text-stone-500 flex items-center justify-center gap-1">
            <Sparkles size={12} className="text-gold" />
            <span>5,000+ devotional tracks across 10 Indian languages</span>
          </p>
        </div>
      </div>
    </div>
  );
};
export default AuthModal;
