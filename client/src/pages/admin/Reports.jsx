import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

export default function AdminReports() {
  const { t } = useLanguage();
  const [reports, setReports] = useState([]);
  const [status, setStatus] = useState('loading');

  function load() {
    setStatus('loading');
    api
      .get('/admin/reports', { params: { status: 'open' } })
      .then(({ data }) => {
        setReports(data.items);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }

  useEffect(load, []);

  async function review(id, reviewStatus) {
    await api.patch(`/admin/reports/${id}/review`, { status: reviewStatus });
    load();
  }

  const targetLink = (r) => (r.targetType === 'campaign' ? `/campaigns/${r.targetId}` : `/admin/users`);

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.reports')}</h1>

        {status === 'loading' && (
          <div className="flex flex-col gap-sm">{[1, 2].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('adminReports.loadErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && reports.length === 0 && (
          <EmptyState icon="flag" title={t('adminReports.emptyTitle')} description={t('adminReports.emptyDesc')} />
        )}

        {reports.length > 0 && (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {reports.map((r) => (
              <div key={r._id} className="flex items-center justify-between py-lg gap-md flex-wrap">
                <div className="min-w-0">
                  <p className="text-[14px] font-medium text-text-primary truncate">{r.reason}</p>
                  <p className="text-[13px] text-text-secondary">
                    {r.targetType} · {t('adminReports.reportedBy')} {r.reporterId?.fullName || t('adminSupport.unknown')} ·{' '}
                    <Link to={targetLink(r)} className="text-primary hover:underline">{t('adminReports.viewTarget')}</Link>
                  </p>
                </div>
                <div className="flex items-center gap-md">
                  <StatusPill status={r.status} />
                  <Button className="h-[34px] px-md text-[13px]" onClick={() => review(r._id, 'reviewed')}>
                    {t('adminReports.markReviewed')}
                  </Button>
                  <Button variant="secondary" className="h-[34px] px-md text-[13px]" onClick={() => review(r._id, 'dismissed')}>
                    {t('adminReports.dismiss')}
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
