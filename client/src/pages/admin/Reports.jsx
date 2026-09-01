import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import Pagination from '../../components/Pagination';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

const LIMIT = 20;
const STATUS_TABS = ['', 'open', 'under_review', 'resolved', 'dismissed'];

export default function AdminReports() {
  const { t } = useLanguage();
  const [reports, setReports] = useState([]);
  const [summary, setSummary] = useState(null);
  const [status, setStatus] = useState('open');
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [state, setState] = useState('loading'); // loading | ready | error

  function load(p = page, s = status) {
    setState('loading');
    Promise.all([
      api.get('/admin/reports', { params: { status: s || undefined, page: p, limit: LIMIT } }),
      api.get('/admin/reports/summary'),
    ])
      .then(([list, sum]) => {
        setReports(list.data.items);
        setTotal(list.data.total);
        setSummary(sum.data);
        setState('ready');
      })
      .catch(() => setState('error'));
  }

  useEffect(() => { load(page, status); /* eslint-disable-next-line */ }, [page, status]);

  async function review(id, reviewStatus) {
    await api.patch(`/admin/reports/${id}/review`, { status: reviewStatus });
    load(page, status);
  }

  const targetLink = (r) =>
    r.targetType === 'campaign' ? `/campaigns/${r.targetId}` : r.targetType === 'user' ? '/admin/users' : null;

  const cards = summary
    ? [
        ['adminReports.total', summary.total],
        ['adminReports.open', summary.open],
        ['adminReports.underReview', summary.underReview],
        ['adminReports.resolved', summary.resolved],
        ['adminReports.dismissed', summary.dismissed],
        ['adminReports.recent7d', summary.recent7d],
      ]
    : [];

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.reports')}</h1>

        {summary && (
          <div className="grid grid-cols-2 md:grid-cols-6 gap-md">
            {cards.map(([k, v]) => (
              <div key={k} className="bg-surface border border-border rounded-lg p-md">
                <p className="text-[12px] text-text-secondary">{t(k)}</p>
                <p className="text-[20px] font-bold text-text-primary">{v ?? 0}</p>
              </div>
            ))}
          </div>
        )}

        <div className="flex gap-xs flex-wrap">
          {STATUS_TABS.map((s) => (
            <button
              key={s || 'all'}
              onClick={() => { setStatus(s); setPage(1); }}
              className={`px-md py-xs rounded text-[13px] border capitalize transition-colors ${
                status === s ? 'bg-primary/10 text-primary border-primary' : 'border-border text-text-secondary hover:border-primary/40'
              }`}
            >
              {s ? s.replace(/_/g, ' ') : t('adminReports.filterAll')}
            </button>
          ))}
        </div>

        {state === 'loading' && (
          <div className="flex flex-col gap-sm">{[1, 2].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        )}
        {state === 'error' && (
          <EmptyState
            icon="wifi_off"
            title={t('adminReports.loadErrorTitle')}
            description={t('common.checkConnection')}
            action={<Button variant="secondary" onClick={() => load(page, status)}>{t('common.retry')}</Button>}
          />
        )}
        {state === 'ready' && reports.length === 0 && (
          <EmptyState icon="flag" title={t('adminReports.emptyTitle')} description={t('adminReports.emptyDesc')} />
        )}

        {state === 'ready' && reports.length > 0 && (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {reports.map((r) => (
              <div key={r._id} className="flex items-start justify-between py-lg gap-md flex-wrap">
                <div className="min-w-0 flex-1">
                  <p className="text-[14px] font-medium text-text-primary">{r.reason}</p>
                  <p className="text-[12px] text-text-secondary mt-xs">
                    <span className="capitalize">{r.targetType}</span> · {t('adminReports.reportedBy')}{' '}
                    {r.reporterId?.fullName || t('adminSupport.unknown')} · {new Date(r.createdAt).toLocaleDateString()}
                    {targetLink(r) && (
                      <>
                        {' · '}
                        <Link to={targetLink(r)} className="text-primary hover:underline">{t('adminReports.viewTarget')}</Link>
                      </>
                    )}
                  </p>
                  {r.reviewNote && <p className="text-[12px] text-text-secondary mt-xs italic">“{r.reviewNote}”</p>}
                  {r.reviewedBy?.fullName && (
                    <p className="text-[11px] text-text-secondary mt-xs">
                      {t('adminReports.reviewedByLabel')}: {r.reviewedBy.fullName}
                      {r.reviewedAt ? ` · ${new Date(r.reviewedAt).toLocaleDateString()}` : ''}
                    </p>
                  )}
                </div>
                <div className="flex items-center gap-sm flex-wrap">
                  <StatusPill status={r.status} />
                  {r.status === 'open' && (
                    <Button className="h-[32px] px-md text-[12px]" variant="secondary" onClick={() => review(r._id, 'under_review')}>
                      {t('adminReports.startReview')}
                    </Button>
                  )}
                  {r.status !== 'resolved' && r.status !== 'dismissed' && (
                    <Button className="h-[32px] px-md text-[12px]" onClick={() => review(r._id, 'resolved')}>
                      {t('adminReports.resolve')}
                    </Button>
                  )}
                  {r.status !== 'dismissed' && (
                    <Button className="h-[32px] px-md text-[12px]" variant="tertiary" onClick={() => review(r._id, 'dismissed')}>
                      {t('adminReports.dismiss')}
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        <Pagination page={page} limit={LIMIT} total={total} onPage={setPage} />
      </div>
    </DashboardLayout>
  );
}
