import { Link, useLocation } from 'react-router-dom';
import Navbar from './Navbar';
import { useLanguage } from '../context/LanguageContext';

// Sidebar nav arrays (donor/organizer/admin nav.js) carry a `labelKey` —
// translating here means every dashboard sidebar is covered by one change.
export default function DashboardLayout({ title, nav, children }) {
  const location = useLocation();
  const { t } = useLanguage();

  return (
    <div className="min-h-screen flex flex-col">
      <Navbar />
      <div className="max-w-container mx-auto w-full px-xl py-2xl flex flex-col md:flex-row gap-2xl flex-grow">
        <aside className="w-full md:w-56 flex-shrink-0">
          <h2 className="text-[13px] font-semibold text-text-secondary uppercase tracking-wide mb-md">{title}</h2>
          <nav className="flex md:flex-col gap-xs overflow-x-auto md:overflow-visible">
            {nav.map((item) => {
              const active = location.pathname === item.to;
              return (
                <Link
                  key={item.to}
                  to={item.to}
                  className={`flex items-center gap-sm px-md py-sm rounded text-[14px] whitespace-nowrap transition-colors ${
                    active ? 'bg-primary/10 text-primary font-medium' : 'text-text-secondary hover:bg-background'
                  }`}
                >
                  <span className="material-symbols-outlined" style={{ fontSize: 18 }}>
                    {item.icon}
                  </span>
                  {item.labelKey ? t(item.labelKey) : item.label}
                </Link>
              );
            })}
          </nav>
        </aside>
        <div className="flex-grow min-w-0">{children}</div>
      </div>
    </div>
  );
}
