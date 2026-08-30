import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import ProgressBar from '../../components/ProgressBar';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

import { ORGANIZER_NAV } from './nav';

// Only real, derivable numbers are shown here. Views, conversion rate, and
// referral-source breakdown need analytics tracking that doesn't exist yet
// (see PROGRESS.md) — we say so rather than fabricate numbers (Rule 43).
export default function Analytics() {
  const { t, language } = useLanguage();
  const [campaigns, setCampaigns] = useState([]);
  const [status, setStatus] = useState('loading');

  useEffect(() => {
    api
      .get('/campaigns/mine')
      .then(({ data }) => {
        setCampaigns(data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }, []);

  const totalRaised = campaigns.reduce((sum, c) => sum + c.raisedAmount, 0);

  return (
    <DashboardLayout title={t('organizerDash.title')} nav={ORGANIZER_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('organizerNav.analytics')}</h1>

        {status === 'ready' && campaigns.length === 0 && (
          <EmptyState icon="monitoring" title={t('analytics.emptyTitle')} description={t('analytics.emptyDesc')} />
        )}

        {campaigns.length > 0 && (
          <>
            <div className="bg-surface border border-border rounded-lg p-xl">
              <p className="text-[13px] text-text-secondary">{t('analytics.totalRaised')}</p>
              <p className="text-[28px] font-bold text-text-primary">${totalRaised.toLocaleString()}</p>
            </div>

            <div className="flex flex-col gap-lg">
              {campaigns.map((c) => (
                <div key={c._id} className="bg-surface border border-border rounded-lg p-lg flex flex-col gap-sm">
                  <h3 className="text-[15px] font-semibold text-text-primary">{c.title?.[language] || c.title?.so || c.title?.en}</h3>
                  <ProgressBar raised={c.raisedAmount} goal={c.goalAmount} />
                </div>
              ))}
            </div>

            <p className="text-[13px] text-text-secondary bg-background border border-border rounded-lg p-lg">
              {t('analytics.trackingNote')}
            </p>
          </>
        )}
      </div>
    </DashboardLayout>
  );
}
