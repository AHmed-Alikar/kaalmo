import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import CampaignCard from '../../components/CampaignCard';
import Button from '../../components/Button';
import StartFundraiserLink from '../../components/StartFundraiserLink';
import api from '../../api/client';
import { CATEGORY_ICONS } from './categoryIcons';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

const TRUST_PILLARS = [
  {
    icon: 'verified_user',
    title: { so: 'Abaabulayaal la xaqiijiyay', en: 'Verified organizers' },
    text: {
      so: 'Abaabule kasta wuxuu dhammaystiraa xaqiijinta aqoonsigiisa ka hor inta ololihiisu bilaabmin.',
      en: 'Every campaign organizer completes identity verification before their campaign can go live.',
    },
  },
  {
    icon: 'account_balance',
    title: { so: 'Wareejin daahfuran', en: 'Transparent transfers' },
    text: {
      so: 'Lacag-bixinta mobile money iyo kaadhka waxaa lagu duubaa diiwaan aan la beddeli karin — waxba si qarsoodi ah looma bedelo.',
      en: 'Mobile money and card payments are recorded on an immutable ledger — nothing is quietly edited.',
    },
  },
  {
    icon: 'update',
    title: { so: 'Cusboonaysiin waajib ah', en: 'Required updates' },
    text: {
      so: 'Abaabulayaashu waxay dhigaan cusboonaysiin horumar ah si wax-bixiyayaashu u arkaan sida lacagta loo isticmaalayo.',
      en: 'Organizers post progress updates so donors can see how funds are actually being used.',
    },
  },
];

export default function Home() {
  const navigate = useNavigate();
  const { t, language } = useLanguage();
  const [campaigns, setCampaigns] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    Promise.all([
      api.get('/campaigns', { params: { limit: 6 } }),
      api.get('/campaigns/stats'),
    ])
      .then(([campaignsRes, statsRes]) => {
        setCampaigns(campaignsRes.data.items);
        setStats(statsRes.data);
      })
      .catch(() => setCampaigns([]))
      .finally(() => setLoading(false));
  }, []);

  function handleSearch(e) {
    e.preventDefault();
    navigate(searchTerm ? `/explore?q=${encodeURIComponent(searchTerm)}` : '/explore');
  }

  return (
    <PageLayout>
      {/* Hero — full-bleed photo with a dark overlay for text contrast, like a
          real fundraising platform's hero (not a decorative gradient/blob,
          Design_Rules.md Rule 6). The image itself must show real people with
          dignity — Somali communities, families, community projects — never a
          random stock photo or AI-generated person (Design_Rules.md Rule 20).
          Falls back to a plain primary-dark surface if /hero.jpg is missing,
          so the page never breaks waiting on an asset. */}
      <section
        className="relative bg-primary-dark bg-cover bg-center min-h-[420px] md:min-h-[520px] flex items-center"
        style={{
          backgroundImage:
            "linear-gradient(90deg, rgba(7,17,20,0.85) 0%, rgba(7,17,20,0.65) 40%, rgba(7,17,20,0.25) 75%, rgba(7,17,20,0) 100%), url(/hero.png)",
        }}
      >
        <div className="max-w-container w-full mx-auto px-lg md:px-xl py-4xl flex flex-col items-start text-left gap-lg">
          <h1 className="text-[32px] md:text-[48px] font-bold text-white leading-tight max-w-lg">
            {t('home.heroTitle')}
          </h1>
          <p className="text-[16px] md:text-[18px] text-white/90 max-w-md">
            {t('home.heroSubtitle')}
          </p>

          <form onSubmit={handleSearch} className="w-full max-w-md flex flex-col sm:flex-row gap-sm mt-md">
            <div className="relative flex-grow">
              <span className="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-text-secondary">
                search
              </span>
              <input
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('home.searchPlaceholder')}
                className="w-full h-[48px] pl-4xl pr-lg rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors placeholder:text-text-secondary"
              />
            </div>
            <Button type="submit" className="h-[48px] px-2xl">
              {t('home.search')}
            </Button>
          </form>

          <div className="flex items-center gap-sm mt-xs">
            <StartFundraiserLink>
              <Button variant="accent" className="h-[40px] px-lg">
                {t('home.startFundraiserBtn')}
              </Button>
            </StartFundraiserLink>
            <Link
              to="/explore"
              className="text-[14px] text-white hover:underline underline-offset-2 px-md"
            >
              {t('home.browseCampaigns')}
            </Link>
          </div>
        </div>
      </section>

      {/* Trust stats — real, derivable numbers only (Rule 43); no invented totals */}
      <section className="border-b border-border bg-background">
        <div className="max-w-container mx-auto px-lg md:px-xl py-xl grid grid-cols-1 sm:grid-cols-3 gap-lg text-center">
          <div>
            <p className="text-[28px] font-bold text-primary">
              {stats ? `$${stats.totalRaised.toLocaleString()}` : '—'}
            </p>
            <p className="text-[13px] text-text-secondary">{t('home.raised')}</p>
          </div>
          <div>
            <p className="text-[28px] font-bold text-primary">{stats ? stats.campaignCount : '—'}</p>
            <p className="text-[13px] text-text-secondary">{t('home.campaigns')}</p>
          </div>
          <div>
            <p className="text-[28px] font-bold text-primary">{stats ? stats.donorCount : '—'}</p>
            <p className="text-[13px] text-text-secondary">{t('home.donors')}</p>
          </div>
        </div>
      </section>

      {/* Category strip — quick entry into Explore by cause */}
      <section className="max-w-container mx-auto px-lg md:px-xl py-3xl">
        <h2 className="text-[22px] font-semibold text-text-primary mb-lg">{t('home.browseByCategory')}</h2>
        <div className="flex gap-sm overflow-x-auto pb-xs -mx-lg px-lg md:mx-0 md:px-0 md:flex-wrap">
          {CATEGORY_ICONS.map((c) => (
            <Link
              key={c.label}
              to={`/explore?category=${encodeURIComponent(c.label)}`}
              className="flex items-center gap-sm shrink-0 px-lg py-sm rounded-full border border-border bg-surface hover:border-primary hover:bg-primary/5 transition-colors"
            >
              <span className="material-symbols-outlined text-primary" style={{ fontSize: 20 }}>
                {c.icon}
              </span>
              <span className="text-[13px] font-medium text-text-primary whitespace-nowrap">{categoryLabel(c.label, language)}</span>
            </Link>
          ))}
        </div>
      </section>

      {/* Campaigns to support */}
      <section className="max-w-container mx-auto px-lg md:px-xl py-3xl border-t border-border">
        <div className="flex items-center justify-between mb-lg">
          <h2 className="text-[22px] font-semibold text-text-primary">{t('home.campaignsToSupport')}</h2>
          <Link to="/explore" className="text-[14px] text-primary hover:underline">
            {t('home.viewAll')}
          </Link>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-lg">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-80 bg-surface border border-border rounded-lg animate-pulse" />
            ))}
          </div>
        ) : campaigns.length === 0 ? (
          <p className="text-text-secondary text-[14px]">
            {t('home.noCampaigns')}
          </p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-lg">
            {campaigns.map((c) => (
              <CampaignCard key={c._id} campaign={c} />
            ))}
          </div>
        )}
      </section>

      {/* How Kaalmo builds trust */}
      <section className="bg-background border-t border-border">
        <div className="max-w-container mx-auto px-lg md:px-xl py-3xl">
          <div className="text-center mb-2xl max-w-xl mx-auto">
            <h2 className="text-[22px] font-semibold text-text-primary">{t('home.trustTitle')}</h2>
            <p className="text-[14px] text-text-secondary mt-xs">
              {t('home.trustSubtitle')}
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-lg">
            {TRUST_PILLARS.map((pillar) => (
              <div key={pillar.icon} className="bg-surface border border-border rounded-lg p-lg flex flex-col items-center text-center gap-sm">
                <span className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
                  <span className="material-symbols-outlined text-primary" style={{ fontSize: 24 }}>
                    {pillar.icon}
                  </span>
                </span>
                <h3 className="text-[16px] font-semibold text-text-primary">{pillar.title[language] || pillar.title.so}</h3>
                <p className="text-[13px] text-text-secondary">{pillar.text[language] || pillar.text.so}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Closing CTA */}
      <section className="max-w-container mx-auto px-lg md:px-xl py-4xl text-center flex flex-col items-center gap-lg">
        <h2 className="text-[24px] font-bold text-text-primary max-w-lg">
          {t('home.closingTitle')}
        </h2>
        <StartFundraiserLink>
          <Button className="px-2xl">{t('home.startFundraiserBtn')}</Button>
        </StartFundraiserLink>
      </section>
    </PageLayout>
  );
}
