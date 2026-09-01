import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import Pagination from '../../components/Pagination';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ORGANIZER_NAV } from './nav';

const LIMIT = 20;
const STATUSES = ['', 'confirmed', 'pending', 'failed', 'refunded'];

export default function OrganizerDonations() {
  const { t, language } = useLanguage();
  const [rows, setRows] = useState([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');
  const [q, setQ] = useState('');
  const [state, setState] = useState('loading'); // loading | ready | error

  function load(p = page, s = status, query = q) {
    setState('loading');
    api
      .get('/campaigns/mine/donations', {
        params: { page: p, limit: LIMIT, status: s || undefined, q: query || undefined },
      })
      .then(({ data }) => { setRows(data.items); setTotal(data.total); setState('ready'); })
      .catch(() => setState('error'));
  }

  useEffect(() => { load(page, status, q); /* eslint-disable-next-line */ }, [page, status]);
  function search() { setPage(1); load(1, status, q); }

  return (
    <DashboardLayout title={t('organizerNav.donations')} nav={ORGANIZER_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('organizerDonations.title')}</h1>

        <div className="flex items-center gap-md flex-wrap">
          <div className="relative flex-1 min-w-[240px] max-w-sm">
            <span className="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-text-secondary">search</span>
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && search()}
              placeholder={t('organizerDonations.searchPlaceholder')}
              className="w-full pl-4xl pr-lg h-[40px] rounded border border-border bg-surface text-text-primary outline-none focus:border-primary"
            />
          </div>
          <div className="flex gap-xs flex-wrap">
            {STATUSES.map((s) => (
              <button
                key={s || 'all'}
                onClick={() => { setStatus(s); setPage(1); }}
                className={`px-md py-xs rounded text-[13px] border capitalize transition-colors ${
                  status === s ? 'bg-primary/10 text-primary border-primary' : 'border-border text-text-secondary hover:border-primary/40'
                }`}
              >
                {s || t('adminReports.filterAll')}
              </button>
            ))}
          </div>
        </div>

        {state === 'loading' && (
          <div className="flex flex-col gap-sm">{[1, 2, 3].map((i) => <div key={i} className="h-14 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        )}
        {state === 'error' && (
          <EmptyState icon="wifi_off" title={t('common.checkConnection')} action={<Button variant="secondary" onClick={() => load(page, status, q)}>{t('common.retry')}</Button>} />
        )}
        {state === 'ready' && rows.length === 0 && (
          <EmptyState icon="volunteer_activism" title={t('organizerDonations.emptyTitle')} description={t('organizerDonations.emptyDesc')} />
        )}
        {state === 'ready' && rows.length > 0 && (
          <div className="overflow-x-auto">
            <table className="w-full text-[14px]">
              <thead>
                <tr className="text-left text-[12px] text-text-secondary uppercase border-b border-border">
                  <th className="py-sm pr-md">{t('organizerDonations.date')}</th>
                  <th className="py-sm pr-md">{t('organizerDonations.campaign')}</th>
                  <th className="py-sm pr-md">{t('organizerDonations.donor')}</th>
                  <th className="py-sm pr-md">{t('organizerDonations.amount')}</th>
                  <th className="py-sm pr-md">{t('organizerDonations.status')}</th>
                  <th className="py-sm pr-md">{t('organizerDonations.reference')}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {rows.map((d) => (
                  <tr key={d._id}>
                    <td className="py-md pr-md text-text-secondary whitespace-nowrap">{new Date(d.createdAt).toLocaleDateString()}</td>
                    <td className="py-md pr-md text-text-primary">{d.campaign?.title?.[language] || d.campaign?.title?.so || d.campaign?.title?.en || '—'}</td>
                    <td className="py-md pr-md text-text-secondary">{d.isAnonymous ? t('organizerDonations.anonymous') : d.donorName || '—'}</td>
                    <td className="py-md pr-md text-text-primary font-semibold">${Number(d.amount).toLocaleString()} {d.currency}</td>
                    <td className="py-md pr-md"><StatusPill status={d.status} /></td>
                    <td className="py-md pr-md text-text-secondary font-mono text-[12px]">{d.reference.slice(-8)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <Pagination page={page} limit={LIMIT} total={total} onPage={setPage} />
      </div>
    </DashboardLayout>
  );
}
