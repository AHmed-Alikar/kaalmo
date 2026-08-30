import { createContext, useContext, useEffect, useState } from 'react';
import api from '../api/client';
import { useAuth } from './AuthContext';
import { translations } from '../i18n/translations';

const LanguageContext = createContext(null);

// Somali is the default (matches User.language's backend default) — a
// logged-in user's saved preference always wins once it loads; a guest's
// choice is remembered locally so it survives a refresh (Rule 34).
export function LanguageProvider({ children }) {
  const { user, refreshUser } = useAuth();
  const [language, setLanguageState] = useState(
    () => localStorage.getItem('kaalmo_language') || 'so'
  );

  useEffect(() => {
    if (user?.language && user.language !== language) setLanguageState(user.language);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user?.language]);

  useEffect(() => {
    localStorage.setItem('kaalmo_language', language);
    document.documentElement.lang = language;
  }, [language]);

  async function setLanguage(next) {
    setLanguageState(next);
    if (user) {
      try {
        await api.patch('/users/me', { language: next });
        await refreshUser();
      } catch {
        // Non-critical — the UI already switched locally; it'll just sync
        // again on the next successful request.
      }
    }
  }

  function t(key) {
    return translations[key]?.[language] || translations[key]?.so || key;
  }

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  return useContext(LanguageContext);
}
