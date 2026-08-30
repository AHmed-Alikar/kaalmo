import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { DONOR_NAV } from './nav';

export default function DonorDashboard() {
  const { t, language } = useLanguage();
  const [donations, setDonations] = useState([]);
  const [status, setStatus] = useState('loading');

  useEffect(() => {
    api
      .get('/donations/mine')
      .then(({ data }) => {
        setDonations(data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }, []);

  return (
    <DashboardLayout title={t('donor.myAccount')} nav={DONOR_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('donor.myDonations')}</h1>

        {status === 'loading' && (
          <div className="flex flex-col gap-sm">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />
            ))}
          </div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('donor.loadDonationsErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && donations.length === 0 && (
          <EmptyState
            icon="volunteer_activism"
            title={t('donor.noDonationsTitle')}
            description={t('donor.noDonationsDesc')}
            action={
              <Link to="/explore">
                <Button variant="secondary">{t('donor.exploreCampaigns')}</Button>
              </Link>
            }
          />
        )}

        {status === 'ready' && donations.length > 0 && (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {donations.map((d) => (
              <div key={d._id} className="flex items-center justify-between py-lg">
                <div>
                  <p className="text-[14px] font-medium text-text-primary">
                    {d.campaignId?.title?.[language] || d.campaignId?.title?.so || d.campaignId?.title?.en || t('donor.campaign')}
                  </p>
                  <p className="text-[13px] text-text-secondary">{new Date(d.createdAt).toLocaleDateString()}</p>
                </div>
                <div className="flex items-center gap-lg">
                  <span className="text-[15px] font-semibold text-text-primary">${d.amount.toLocaleString()}</span>
                  <StatusPill status={d.status} />
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
