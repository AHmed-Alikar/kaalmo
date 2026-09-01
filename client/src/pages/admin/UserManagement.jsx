import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import Pagination from '../../components/Pagination';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

const LIMIT = 20;

export default function UserManagement() {
  const { t } = useLanguage();
  const [users, setUsers] = useState([]);
  const [q, setQ] = useState('');
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  function load(query = q, p = page) {
    setLoading(true);
    api
      .get('/admin/users', { params: { q: query || undefined, page: p, limit: LIMIT } })
      .then(({ data }) => { setUsers(data.items); setTotal(data.total); })
      .finally(() => setLoading(false));
  }

  useEffect(() => { load(q, page); /* eslint-disable-next-line */ }, [page]);
  function search() { setPage(1); load(q, 1); }

  async function setStatus(id, status) {
    await api.patch(`/admin/users/${id}/status`, { status });
    load(q, page);
  }

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.users')}</h1>

        <div className="relative max-w-sm">
          <span className="material-symbols-outlined absolute left-md top-1/2 -translate-y-1/2 text-text-secondary">search</span>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && search()}
            placeholder={t('userManagement.searchPlaceholder')}
            className="w-full pl-4xl pr-lg h-[40px] rounded border border-border bg-surface text-text-primary outline-none focus:border-primary"
          />
        </div>

        {loading ? (
          <div className="flex flex-col gap-sm">{[1, 2, 3].map((i) => <div key={i} className="h-14 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        ) : users.length === 0 ? (
          <EmptyState icon="group" title={t('userManagement.emptyTitle')} description={t('userManagement.emptyDesc')} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-[14px]">
              <thead>
                <tr className="text-left text-[12px] text-text-secondary uppercase border-b border-border">
                  <th className="py-sm pr-md">{t('userManagement.name')}</th>
                  <th className="py-sm pr-md">{t('login.email')}</th>
                  <th className="py-sm pr-md">{t('userManagement.roles')}</th>
                  <th className="py-sm pr-md">{t('donationConfirmed.status')}</th>
                  <th className="py-sm pr-md">{t('userManagement.actions')}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {users.map((u) => (
                  <tr key={u.id}>
                    <td className="py-md pr-md text-text-primary">{u.fullName}</td>
                    <td className="py-md pr-md text-text-secondary">{u.email}</td>
                    <td className="py-md pr-md text-text-secondary">{u.roles.join(', ')}</td>
                    <td className="py-md pr-md text-text-secondary capitalize">{u.status}</td>
                    <td className="py-md pr-md">
                      {u.status === 'active' ? (
                        <Button variant="destructive" className="h-[32px] px-md text-[12px]" onClick={() => setStatus(u.id, 'suspended')}>
                          {t('userManagement.suspend')}
                        </Button>
                      ) : (
                        <Button className="h-[32px] px-md text-[12px]" onClick={() => setStatus(u.id, 'active')}>
                          {t('userManagement.reactivate')}
                        </Button>
                      )}
                    </td>
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
