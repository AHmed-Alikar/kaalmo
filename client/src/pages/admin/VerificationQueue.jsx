import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

export default function VerificationQueue() {
  const { t } = useLanguage();
  const [beneficiaries, setBeneficiaries] = useState([]);
  const [loading, setLoading] = useState(true);

  function load() {
    setLoading(true);
    api
      .get('/admin/beneficiaries', { params: { status: 'pending' } })
      .then(({ data }) => setBeneficiaries(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, []);

  async function review(id, status) {
    await api.patch(`/admin/beneficiaries/${id}/review`, { status });
    load();
  }

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.verificationQueue')}</h1>

        {loading ? (
          <div className="flex flex-col gap-sm">
            {[1, 2].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}
          </div>
        ) : beneficiaries.length === 0 ? (
          <EmptyState icon="gpp_good" title={t('verificationQueue.emptyTitle')} description={t('verificationQueue.emptyDesc')} />
        ) : (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {beneficiaries.map((b) => (
              <div key={b._id} className="flex items-center justify-between py-lg gap-md flex-wrap">
                <div>
                  <p className="text-[14px] font-medium text-text-primary">{b.fullName}</p>
                  <p className="text-[13px] text-text-secondary">{t('verificationQueue.account')}: {b.userId?.email || t('adminSupport.unknown')}</p>
                </div>
                <div className="flex items-center gap-md">
                  <StatusPill status={b.verificationStatus} />
                  <Button className="h-[36px] px-md text-[13px]" onClick={() => review(b._id, 'verified')}>
                    {t('verificationQueue.verify')}
                  </Button>
                  <Button variant="destructive" className="h-[36px] px-md text-[13px]" onClick={() => review(b._id, 'rejected')}>
                    {t('verificationQueue.reject')}
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
