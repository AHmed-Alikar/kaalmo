import { useEffect, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import Button from './Button';
import StartFundraiserLink from './StartFundraiserLink';
import Logo from './Logo';
import api from '../api/client';

const LANGUAGES = [
  { code: 'so', flag: '🇸🇴', label: 'Soomaali' },
  { code: 'en', flag: '🇬🇧', label: 'English' },
];

// Navigation reflects the user's role — never show organizer/admin controls
// to a donor, and vice versa (Design_Rules.md Rule 32/33).
// `minimal` hides the profile icon, notifications, and log-out control —
// used on the email-verification gate pages, where the only action
// available should be verifying (or resending) the email, not navigating
// away into the app.
//
// Mobile (<md) collapses nav links and secondary actions behind a hamburger
// menu rather than shrinking them in place — adapting the hierarchy, not
// just scaling it down (Design_Rules.md Rule 31).
export default function Navbar({ minimal = false }) {
  const { user, logout } = useAuth();
  const { language, setLanguage, t } = useLanguage();
  const navigate = useNavigate();
  const [unreadCount, setUnreadCount] = useState(0);
  const [menuOpen, setMenuOpen] = useState(false);
  const [accountOpen, setAccountOpen] = useState(false);
  const [langOpen, setLangOpen] = useState(false);
  const accountRef = useRef(null);
  const langRef = useRef(null);

  const isOrganizer = user?.roles?.includes('organizer');
  const isAdmin = user?.roles?.includes('admin') || user?.roles?.includes('moderator');
  const currentLang = LANGUAGES.find((l) => l.code === language) || LANGUAGES[0];

  const NAV_LINKS = [
    { to: '/explore', label: t('nav.explore') },
    { to: '/how-it-works', label: t('nav.howItWorks') },
    { to: '/safety', label: t('nav.safety') },
  ];

  useEffect(() => {
    if (!user || minimal) return;
    api
      .get('/notifications/mine')
      .then(({ data }) => setUnreadCount(data.unreadCount))
      .catch(() => {});
  }, [user, minimal]);

  // Close either dropdown on an outside click — standard dropdown behavior,
  // not a novel pattern (Design_Rules.md Rule 48).
  useEffect(() => {
    if (!accountOpen && !langOpen) return;
    function handleClick(e) {
      if (accountOpen && accountRef.current && !accountRef.current.contains(e.target)) setAccountOpen(false);
      if (langOpen && langRef.current && !langRef.current.contains(e.target)) setLangOpen(false);
    }
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, [accountOpen, langOpen]);

  function handleLogout() {
    setMenuOpen(false);
    setAccountOpen(false);
    logout();
    navigate('/');
  }

  function handleSelectLanguage(code) {
    setLanguage(code);
    setLangOpen(false);
    setMenuOpen(false);
  }

  return (
    <header className="bg-surface border-b border-border w-full sticky top-0 z-50">
      <div className="max-w-container mx-auto px-lg md:px-xl h-20 flex items-center justify-between gap-xl">
        <div className="flex items-center gap-2xl">
          <Logo />
          <nav className="hidden md:flex items-center gap-xl text-[14px]">
            {NAV_LINKS.map((link) => (
              <Link key={link.to} to={link.to} className="text-text-secondary hover:text-primary transition-colors">
                {link.label}
              </Link>
            ))}
            {isAdmin && (
              <Link to="/admin" className="text-text-secondary hover:text-primary transition-colors">
                {t('nav.admin')}
              </Link>
            )}
          </nav>
        </div>

        {/* Desktop actions — utility controls (language, notifications, account)
            grouped together with matching circular hit targets, separated
            from the primary CTA by a divider so the two groups read
            distinctly instead of floating loosely (Design_Rules.md Rule 32). */}
        <div className="hidden md:flex items-center gap-lg">
          <div className="flex items-center gap-xs">
            <div className="relative" ref={langRef}>
              <button
                onClick={() => setLangOpen((v) => !v)}
                aria-label="Change language"
                aria-expanded={langOpen}
                className="flex items-center gap-xs h-9 px-md rounded text-[13px] text-text-secondary hover:text-primary hover:bg-background transition-colors"
              >
                <span aria-hidden="true" style={{ fontSize: 16 }}>{currentLang.flag}</span>
                {currentLang.label}
                <span className="material-symbols-outlined" style={{ fontSize: 16 }}>expand_more</span>
              </button>

              {langOpen && (
                <div className="absolute right-0 top-[calc(100%+8px)] w-40 bg-surface border border-border rounded-lg shadow-sm py-xs flex flex-col">
                  {LANGUAGES.map((l) => (
                    <button
                      key={l.code}
                      onClick={() => handleSelectLanguage(l.code)}
                      className={`flex items-center gap-sm px-lg py-sm text-[14px] text-left transition-colors ${
                        l.code === language ? 'text-primary bg-primary/5' : 'text-text-primary hover:bg-background'
                      }`}
                    >
                      <span aria-hidden="true" style={{ fontSize: 16 }}>{l.flag}</span>
                      {l.label}
                      {l.code === language && (
                        <span className="material-symbols-outlined ml-auto" style={{ fontSize: 16 }}>check</span>
                      )}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {user && !minimal && (
              <Link
                to="/donor/notifications"
                className="relative w-9 h-9 rounded-full flex items-center justify-center text-text-secondary hover:text-primary hover:bg-background transition-colors"
              >
                <span className="material-symbols-outlined" style={{ fontSize: 22 }}>
                  notifications
                </span>
                {unreadCount > 0 && (
                  <span className="absolute top-1 right-1 w-4 h-4 rounded-full bg-error text-white text-[10px] font-medium flex items-center justify-center">
                    {unreadCount > 9 ? '9+' : unreadCount}
                  </span>
                )}
              </Link>
            )}

            {user && !minimal && (
              <div className="relative" ref={accountRef}>
                <button
                  onClick={() => setAccountOpen((v) => !v)}
                  aria-label="Account menu"
                  aria-expanded={accountOpen}
                  className="w-9 h-9 rounded-full flex items-center justify-center text-text-secondary hover:text-primary hover:bg-background transition-colors"
                >
                  <span className="material-symbols-outlined" style={{ fontSize: 22 }}>
                    account_circle
                  </span>
                </button>

                {accountOpen && (
                  <div className="absolute right-0 top-[calc(100%+8px)] w-56 bg-surface border border-border rounded-lg shadow-sm py-sm flex flex-col">
                    <div className="px-lg py-sm border-b border-border">
                      <p className="text-[14px] font-medium text-text-primary truncate">{user.fullName}</p>
                      <p className="text-[13px] text-text-secondary truncate">{user.email}</p>
                    </div>
                    <Link
                      to="/donor"
                      onClick={() => setAccountOpen(false)}
                      className="px-lg py-sm text-[14px] text-text-primary hover:bg-background transition-colors"
                    >
                      {t('nav.myAccount')}
                    </Link>
                    <button
                      onClick={handleLogout}
                      className="px-lg py-sm text-[14px] text-left text-error hover:bg-error/5 transition-colors"
                    >
                      {t('nav.logout')}
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>

          {user ? (
            <div className="flex items-center gap-lg pl-lg border-l border-border">
              {isOrganizer ? (
                <Link to="/organizer">
                  <Button variant="secondary" className="h-[38px]">{t('nav.organizerDashboard')}</Button>
                </Link>
              ) : (
                <StartFundraiserLink>
                  <Button variant="secondary" className="h-[38px]">{t('nav.startFundraiser')}</Button>
                </StartFundraiserLink>
              )}
            </div>
          ) : (
            <div className="flex items-center gap-lg">
              <Link to="/login" className="text-[14px] text-text-secondary hover:text-primary transition-colors">
                {t('nav.login')}
              </Link>
              <StartFundraiserLink>
                <Button className="h-[38px]">{t('nav.startFundraiser')}</Button>
              </StartFundraiserLink>
            </div>
          )}
        </div>

        {/* Mobile: unread bell (if logged in) + hamburger toggle */}
        <div className="flex md:hidden items-center gap-xs">
          {user && !minimal && (
            <Link to="/donor/notifications" className="relative text-text-secondary flex items-center p-sm">
              <span className="material-symbols-outlined">notifications</span>
              {unreadCount > 0 && (
                <span className="absolute top-1 right-1 w-4 h-4 rounded-full bg-error text-white text-[10px] flex items-center justify-center">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              )}
            </Link>
          )}
          <button
            onClick={() => setMenuOpen((v) => !v)}
            aria-label={menuOpen ? 'Close menu' : 'Open menu'}
            aria-expanded={menuOpen}
            className="text-text-primary flex items-center p-sm"
          >
            <span className="material-symbols-outlined" style={{ fontSize: 28 }}>
              {menuOpen ? 'close' : 'menu'}
            </span>
          </button>
        </div>
      </div>

      {/* Mobile menu panel */}
      {menuOpen && (
        <div className="md:hidden border-t border-border bg-surface">
          <nav className="flex flex-col px-lg py-md">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                onClick={() => setMenuOpen(false)}
                className="py-md text-[15px] text-text-primary border-b border-border"
              >
                {link.label}
              </Link>
            ))}
            {isAdmin && (
              <Link to="/admin" onClick={() => setMenuOpen(false)} className="py-md text-[15px] text-text-primary border-b border-border">
                {t('nav.admin')}
              </Link>
            )}

            <div className="flex items-center gap-sm py-md border-b border-border">
              {LANGUAGES.map((l) => (
                <button
                  key={l.code}
                  onClick={() => handleSelectLanguage(l.code)}
                  className={`flex items-center gap-xs px-md py-sm rounded border text-[14px] transition-colors ${
                    l.code === language ? 'border-primary text-primary bg-primary/5' : 'border-border text-text-secondary'
                  }`}
                >
                  <span aria-hidden="true" style={{ fontSize: 16 }}>{l.flag}</span>
                  {l.label}
                </button>
              ))}
            </div>

            {user ? (
              <>
                {isOrganizer ? (
                  <Link to="/organizer" onClick={() => setMenuOpen(false)} className="py-md text-[15px] text-text-primary border-b border-border">
                    {t('nav.organizerDashboard')}
                  </Link>
                ) : (
                  <StartFundraiserLink className="py-md text-[15px] text-text-primary border-b border-border block" onClick={() => setMenuOpen(false)}>
                    {t('nav.startFundraiser')}
                  </StartFundraiserLink>
                )}
                {!minimal && (
                  <Link to="/donor" onClick={() => setMenuOpen(false)} className="py-md text-[15px] text-text-primary border-b border-border">
                    {t('nav.myAccount')}
                  </Link>
                )}
                <button onClick={handleLogout} className="py-md text-[15px] text-error text-left">
                  {t('nav.logout')}
                </button>
              </>
            ) : (
              <>
                <Link to="/login" onClick={() => setMenuOpen(false)} className="py-md text-[15px] text-text-primary border-b border-border">
                  {t('nav.login')}
                </Link>
                <div className="pt-lg">
                  <StartFundraiserLink onClick={() => setMenuOpen(false)}>
                    <Button className="w-full">{t('nav.startFundraiser')}</Button>
                  </StartFundraiserLink>
                </div>
              </>
            )}
          </nav>
        </div>
      )}
    </header>
  );
}
