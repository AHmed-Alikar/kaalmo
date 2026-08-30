import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import CampaignCard from '../../components/CampaignCard';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { DONOR_NAV } from './nav';

export default function FollowedCampaigns() {
  const { t } = useLanguage();
  const [campaigns, setCampaigns] = useState([]);
  const [status, setStatus] = useState('loading');

  useEffect(() => {
    api
      .get('/users/me/followed-campaigns')
      .then(({ data }) => {
        setCampaigns(data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }, []);

  return (
    <DashboardLayout title={t('donor.myAccount')} nav={DONOR_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('donor.followedCampaigns')}</h1>

        {status === 'loading' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-lg">
            {[1, 2].map((i) => <div key={i} className="h-72 bg-surface border border-border rounded-lg animate-pulse" />)}
          </div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('donor.loadFollowedErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && campaigns.length === 0 && (
          <EmptyState
            icon="notifications_active"
            title={t('donor.noFollowedTitle')}
            description={t('donor.noFollowedDesc')}
            action={<Link to="/explore"><Button variant="secondary">{t('donor.exploreCampaigns')}</Button></Link>}
          />
        )}

        {campaigns.length > 0 && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-lg">
            {campaigns.map((c) => <CampaignCard key={c._id} campaign={c} />)}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
