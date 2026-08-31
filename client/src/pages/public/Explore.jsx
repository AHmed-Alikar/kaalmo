import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import CampaignCard from '../../components/CampaignCard';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel, regionLabel } from '../../i18n/translations';

const CATEGORIES = ['Medical', 'Education', 'Emergency', 'Family', 'Funeral', 'Community', 'Mosque', 'School', 'Orphan Support', 'Disaster Relief', 'Business/Startup', 'NGO', 'Public Projects'];
const REGIONS = ['Mogadishu', 'Hargeisa', 'Puntland', 'Nairobi'];

export default function Explore() {
  const { t, language } = useLanguage();
  const [searchParams, setSearchParams] = useSearchParams();
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [openFilter, setOpenFilter] = useState(null); // null | 'category' | 'region' — mobile only

  const category = searchParams.get('category') || '';
  const region = searchParams.get('region') || '';
  const q = searchParams.get('q') || '';

  useEffect(() => {
    setLoading(true);
    setError(null);
    api
      .get('/campaigns', { params: { category: category || undefined, region: region || undefined, q: q || undefined, limit: 30 } })
      .then(({ data }) => setCampaigns(data.items))
      .catch(() => setError(t('explore.loadError')))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category, region, q]);

  function updateFilter(key, value) {
    const next = new URLSearchParams(searchParams);
    if (value) next.set(key, value);
    else next.delete(key);
    setSearchParams(next);
  }

  const categoryOptions = [
    { value: '', label: t('explore.allCategories') },
    ...CATEGORIES.map((c) => ({ value: c, label: categoryLabel(c, language) })),
  ];
  const regionOptions = [
    { value: '', label: t('explore.allRegions') },
    ...REGIONS.map((r) => ({ value: r, label: regionLabel(r, language) })),
  ];

  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-2xl flex flex-col md:flex-row gap-2xl">
        {/* Desktop/tablet filter panel — always visible in the sidebar */}
        <aside className="hidden md:flex w-64 flex-shrink-0 flex-col gap-lg">
          <div className="bg-surface rounded-lg border border-border p-lg">
            <h3 className="text-[15px] font-semibold text-text-primary mb-md">{t('explore.category')}</h3>
            <div className="flex flex-col gap-sm max-h-64 overflow-y-auto">
              {categoryOptions.map((c) => (
                <label key={c.value} className="flex items-center gap-sm text-[14px] text-text-secondary cursor-pointer">
                  <input
                    type="radio"
                    name="category"
                    checked={category === c.value}
                    onChange={() => updateFilter('category', c.value)}
                    className="text-primary focus:ring-primary"
                  />
                  {c.label}
                </label>
              ))}
            </div>
          </div>

          <div className="bg-surface rounded-lg border border-border p-lg">
            <h3 className="text-[15px] font-semibold text-text-primary mb-md">{t('explore.region')}</h3>
            <div className="flex flex-col gap-sm">
              {regionOptions.map((r) => (
                <label key={r.value} className="flex items-center gap-sm text-[14px] text-text-secondary cursor-pointer">
                  <input
                    type="radio"
                    name="region"
                    checked={region === r.value}
                    onChange={() => updateFilter('region', r.value)}
                    className="text-primary focus:ring-primary"
                  />
                  {r.label}
                </label>
              ))}
            </div>
          </div>
        </aside>

        <div className="flex-grow flex flex-col gap-lg">
          <div className="flex flex-col gap-md">
            <h1 className="text-[28px] font-bold text-text-primary">{t('explore.title')}</h1>
            <div className="relative max-w-xl">
              <span className="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-text-secondary">
                search
              </span>
              <input
                defaultValue={q}
                onKeyDown={(e) => e.key === 'Enter' && updateFilter('q', e.target.value)}
                onBlur={(e) => updateFilter('q', e.target.value)}
                placeholder={t('explore.searchPlaceholder')}
                className="w-full pl-4xl pr-lg py-sm h-[44px] rounded border border-border bg-surface text-text-primary outline-none focus:border-primary transition-colors"
              />
            </div>

            {/* Mobile filter bar — two icon buttons that open the filter options
                on demand, instead of the full lists taking over the screen
                (Design_Rules.md Rule 31 — adapt hierarchy, don't just stack it). */}
            <div className="flex md:hidden gap-sm">
              <button
                type="button"
                onClick={() => setOpenFilter('category')}
                className="flex-1 flex items-center justify-between gap-sm px-lg h-[44px] rounded border border-border bg-surface text-[14px] text-text-primary"
              >
                <span className="flex items-center gap-sm truncate">
                  <span className="material-symbols-outlined text-text-secondary" style={{ fontSize: 20 }}>
                    category
                  </span>
                  <span className="truncate">{category ? categoryLabel(category, language) : t('explore.category')}</span>
                </span>
                <span className="material-symbols-outlined text-text-secondary" style={{ fontSize: 20 }}>
                  expand_more
                </span>
              </button>
              <button
                type="button"
                onClick={() => setOpenFilter('region')}
                className="flex-1 flex items-center justify-between gap-sm px-lg h-[44px] rounded border border-border bg-surface text-[14px] text-text-primary"
              >
                <span className="flex items-center gap-sm truncate">
                  <span className="material-symbols-outlined text-text-secondary" style={{ fontSize: 20 }}>
                    location_on
                  </span>
                  <span className="truncate">{region ? regionLabel(region, language) : t('explore.region')}</span>
                </span>
                <span className="material-symbols-outlined text-text-secondary" style={{ fontSize: 20 }}>
                  expand_more
                </span>
              </button>
            </div>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-lg">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="h-72 bg-surface border border-border rounded-lg animate-pulse" />
              ))}
            </div>
          ) : error ? (
            <EmptyState icon="wifi_off" title={t('explore.errorTitle')} description={error} />
          ) : campaigns.length === 0 ? (
            <EmptyState
              icon="search_off"
              title={t('explore.emptyTitle')}
              description={t('explore.emptyDescription')}
            />
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-lg">
              {campaigns.map((c) => (
                <CampaignCard key={c._id} campaign={c} />
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Mobile filter bottom sheet — shared by the Category and Region buttons above */}
      {openFilter && (
        <div className="md:hidden fixed inset-0 z-50 flex flex-col justify-end">
          <button
            type="button"
            aria-label="Close filters"
            onClick={() => setOpenFilter(null)}
            className="absolute inset-0 bg-black/40"
          />
          <div className="relative bg-surface rounded-t-lg border-t border-border max-h-[70vh] flex flex-col">
            <div className="flex items-center justify-between px-lg py-md border-b border-border">
              <h3 className="text-[16px] font-semibold text-text-primary">
                {openFilter === 'category' ? t('explore.category') : t('explore.region')}
              </h3>
              <button type="button" onClick={() => setOpenFilter(null)} className="p-sm -mr-sm text-text-secondary">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            <div className="flex flex-col gap-sm p-lg overflow-y-auto">
              {(openFilter === 'category' ? categoryOptions : regionOptions).map((opt) => (
                <label
                  key={opt.value}
                  className="flex items-center gap-sm text-[15px] text-text-primary py-sm cursor-pointer"
                >
                  <input
                    type="radio"
                    name={`mobile-${openFilter}`}
                    checked={(openFilter === 'category' ? category : region) === opt.value}
                    onChange={() => {
                      updateFilter(openFilter, opt.value);
                      setOpenFilter(null);
                    }}
                    className="text-primary focus:ring-primary"
                  />
                  {opt.label}
                </label>
              ))}
            </div>
          </div>
        </div>
      )}
    </PageLayout>
  );
}
