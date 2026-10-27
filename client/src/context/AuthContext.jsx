import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiFetch } from '../config/api';

const AuthContext = createContext();

const STORAGE_KEY = 'bhakti_music_user';
const USERS_DB_KEY = 'bhakti_local_registered_users';

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : null;
    } catch {
      return null;
    }
  });

  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);

  // If first time opening app and no user/guest exists, open the auth modal
  useEffect(() => {
    if (!user) {
      setIsAuthModalOpen(true);
    }
  }, []);

  const saveUserSession = (userData) => {
    setUser(userData);
    if (userData) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(userData));
    } else {
      localStorage.removeItem(STORAGE_KEY);
    }
  };

  const getLocalUsers = () => {
    try {
      const data = localStorage.getItem(USERS_DB_KEY);
      return data ? JSON.parse(data) : [];
    } catch {
      return [];
    }
  };

  const saveLocalUsers = (users) => {
    try {
      localStorage.setItem(USERS_DB_KEY, JSON.stringify(users));
    } catch (e) {
      console.warn('Failed to save local users:', e);
    }
  };

  // 1. Enter as Guest
  const enterAsGuest = async () => {
    const guestUser = {
      id: `guest_${Date.now()}`,
      name: 'Guest Devotee',
      email: null,
      isGuest: true,
      createdAt: new Date().toISOString()
    };

    try {
      await apiFetch('/api/auth/guest', { method: 'POST' });
    } catch {}

    saveUserSession(guestUser);
    setIsAuthModalOpen(false);
    return guestUser;
  };

  // 2. Register User
  const register = async (name, email, password) => {
    const cleanEmail = email.trim().toLowerCase();

    // Check if backend available
    try {
      const res = await apiFetch('/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email: cleanEmail, password }),
      });
      const data = await res.json();
      if (data.success && data.user) {
        saveUserSession(data.user);
        setIsAuthModalOpen(false);
        return { success: true };
      } else {
        return { success: false, error: data.error || 'Registration failed' };
      }
    } catch (err) {
      // Offline fallback: save in client localStorage
      const localUsers = getLocalUsers();
      if (localUsers.some(u => u.email === cleanEmail)) {
        return { success: false, error: 'An account with this email already exists' };
      }

      const newUser = {
        id: `user_${Date.now()}`,
        name: name.trim(),
        email: cleanEmail,
        password: password,
        isGuest: false,
        createdAt: new Date().toISOString()
      };

      localUsers.push(newUser);
      saveLocalUsers(localUsers);

      const { password: _, ...userSafe } = newUser;
      saveUserSession(userSafe);
      setIsAuthModalOpen(false);
      return { success: true };
    }
  };

  // 3. Login User
  const login = async (email, password) => {
    const cleanEmail = email.trim().toLowerCase();

    // Try backend
    try {
      const res = await apiFetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: cleanEmail, password }),
      });
      const data = await res.json();
      if (data.success && data.user) {
        saveUserSession(data.user);
        setIsAuthModalOpen(false);
        return { success: true };
      } else {
        return { success: false, error: data.error || 'Invalid credentials' };
      }
    } catch (err) {
      // Offline fallback
      const localUsers = getLocalUsers();
      const match = localUsers.find(u => u.email === cleanEmail && u.password === password);
      if (match) {
        const { password: _, ...userSafe } = match;
        saveUserSession(userSafe);
        setIsAuthModalOpen(false);
        return { success: true };
      }
      return { success: false, error: 'Invalid email or password' };
    }
  };

  // 4. Logout
  const logout = () => {
    saveUserSession(null);
    setIsAuthModalOpen(true);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: Boolean(user && !user.isGuest),
        isGuest: Boolean(user?.isGuest),
        isAuthModalOpen,
        setIsAuthModalOpen,
        openAuthModal: () => setIsAuthModalOpen(true),
        closeAuthModal: () => {
          // If no user exists, default to guest
          if (!user) enterAsGuest();
          setIsAuthModalOpen(false);
        },
        enterAsGuest,
        register,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
export default AuthContext;
