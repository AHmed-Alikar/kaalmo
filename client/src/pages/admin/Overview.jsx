import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

// Admin dashboard is an operational tool — prioritize queues and status, not
// a wall of colorful KPI cards (Design_Rules.md Rule 24).
export default function AdminOverview() {
  const { t } = useLanguage();
  const [counts, setCounts] = useState(null);

  useEffect(() => {
    Promise.all([
      api.get('/admin/campaigns', { params: { status: 'submitted', limit: 1 } }),
      api.get('/admin/campaigns', { params: { status: 'under_review', limit: 1 } }),
      api.get('/admin/campaigns', { params: { status: 'active', limit: 1 } }),
      api.get('/admin/beneficiaries', { params: { status: 'pending' } }),
      api.get('/admin/donations', { params: { status: 'confirmed', limit: 1 } }),
      api.get('/admin/support-tickets', { params: { status: 'open', limit: 1 } }),
    ]).then(([submitted, review, active, beneficiaries, donations, tickets]) => {
      setCounts({
        awaitingReview: submitted.data.total + review.data.total,
        active: active.data.total,
        pendingVerification: beneficiaries.data.length,
        confirmedDonations: donations.data.total,
        openTickets: tickets.data.total,
      });
    });
  }, []);

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-2xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.overview')}</h1>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-lg">
          <Link to="/admin/donations?status=confirmed" className="bg-surface border border-border rounded-lg p-lg hover:border-primary/40 transition-colors">
            <p className="text-[13px] text-text-secondary">{t('adminOverview.confirmedDonations')}</p>
            <p className="text-[28px] font-bold text-text-primary">{counts ? counts.confirmedDonations : '—'}</p>
          </Link>
          <Link to="/admin/campaigns?status=submitted" className="bg-surface border border-border rounded-lg p-lg hover:border-primary/40 transition-colors">
            <p className="text-[13px] text-text-secondary">{t('adminOverview.campaignsAwaitingReview')}</p>
            <p className="text-[28px] font-bold text-text-primary">{counts ? counts.awaitingReview : '—'}</p>
          </Link>
          <Link to="/admin/verification" className="bg-surface border border-border rounded-lg p-lg hover:border-primary/40 transition-colors">
            <p className="text-[13px] text-text-secondary">{t('adminOverview.pendingVerification')}</p>
            <p className="text-[28px] font-bold text-text-primary">{counts ? counts.pendingVerification : '—'}</p>
          </Link>
          <Link to="/admin/campaigns?status=active" className="bg-surface border border-border rounded-lg p-lg hover:border-primary/40 transition-colors">
            <p className="text-[13px] text-text-secondary">{t('adminOverview.activeCampaigns')}</p>
            <p className="text-[28px] font-bold text-text-primary">{counts ? counts.active : '—'}</p>
          </Link>
          <Link to="/admin/support" className="bg-surface border border-border rounded-lg p-lg hover:border-primary/40 transition-colors">
            <p className="text-[13px] text-text-secondary">{t('adminOverview.openTickets')}</p>
            <p className="text-[28px] font-bold text-text-primary">{counts ? counts.openTickets : '—'}</p>
          </Link>
        </div>

        <p className="text-[13px] text-text-secondary bg-background border border-border rounded-lg p-lg">
          {t('adminOverview.fraudNote')}
        </p>
      </div>
    </DashboardLayout>
  );
}
