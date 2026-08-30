import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import ProgressBar from '../../components/ProgressBar';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

import { ORGANIZER_NAV } from './nav';

// Statuses where content can no longer be changed at all (paused/closed by a
// moderator or by completion) — mirrors campaignService.js NOT_EDITABLE_STATUSES.
const NOT_EDITABLE_STATUSES = ['suspended', 'frozen', 'cancelled', 'expired', 'completed'];

// Organizer dashboard answers "what do I need to do next?" — not a wall of
// colorful KPI cards (Design_Rules.md Rule 23).
export default function OrganizerDashboard() {
  const { t, language } = useLanguage();
  const [campaigns, setCampaigns] = useState([]);
  const [status, setStatus] = useState('loading');
  // { type: 'delete' | 'cancel', campaign } — destructive actions always
  // confirm first and explain the consequence (Design_Rules.md Rule 15).
  const [confirmAction, setConfirmAction] = useState(null);
  const [actionError, setActionError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  function load() {
    api
      .get('/campaigns/mine')
      .then(({ data }) => {
        setCampaigns(data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }

  useEffect(load, []);

  async function handleConfirm() {
    setSubmitting(true);
    setActionError(null);
    try {
      if (confirmAction.type === 'delete') {
        await api.delete(`/campaigns/${confirmAction.campaign._id}`);
      } else {
        await api.post(`/campaigns/${confirmAction.campaign._id}/cancel`);
      }
      setConfirmAction(null);
      load();
    } catch (err) {
      setActionError(err.response?.data?.error?.message || t('organizerDash.actionError'));
    } finally {
      setSubmitting(false);
    }
  }

  function campaignTitle(c) {
    return c.title?.[language] || c.title?.so || c.title?.en;
  }

  return (
    <DashboardLayout title={t('organizerDash.title')} nav={ORGANIZER_NAV}>
      <div className="flex flex-col gap-xl">
        <div className="flex items-center justify-between">
          <h1 className="text-[24px] font-bold text-text-primary">{t('organizerDash.myCampaigns')}</h1>
          <Link to="/organizer/new/basics">
            <Button>{t('organizerDash.createCampaign')}</Button>
          </Link>
        </div>

        {status === 'loading' && (
          <div className="flex flex-col gap-sm">
            {[1, 2].map((i) => <div key={i} className="h-24 bg-surface border border-border rounded-lg animate-pulse" />)}
          </div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('organizerDash.loadErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && campaigns.length === 0 && (
          <EmptyState
            icon="campaign"
            title={t('organizerDash.noCampaignsTitle')}
            description={t('organizerDash.noCampaignsDesc')}
            action={<Link to="/organizer/new/basics"><Button>{t('organizerDash.createCampaign')}</Button></Link>}
          />
        )}

        {status === 'ready' && campaigns.length > 0 && (
          <div className="flex flex-col gap-lg">
            {campaigns.map((c) => {
              const isOwner = c.access === 'owner';
              const isEditable = !NOT_EDITABLE_STATUSES.includes(c.status);
              return (
                <div key={c._id} className="bg-surface border border-border rounded-lg p-lg flex flex-col gap-md">
                  <div className="flex items-start justify-between gap-md">
                    <div>
                      <div className="flex items-center gap-sm">
                        <h3 className="text-[16px] font-semibold text-text-primary">{campaignTitle(c)}</h3>
                        {!isOwner && (
                          <span className="text-[11px] font-medium text-primary bg-primary/10 rounded-sm px-sm py-[2px]">
                            {t('organizerDash.coOrganizer')}
                          </span>
                        )}
                      </div>
                      <p className="text-[13px] text-text-secondary">{categoryLabel(c.category, language)}</p>
                    </div>
                    <StatusPill status={c.status} />
                  </div>
                  <ProgressBar raised={c.raisedAmount} goal={c.goalAmount} />
                  <div className="flex items-center flex-wrap gap-md pt-sm border-t border-border">
                    <Link to={`/campaigns/${c._id}`} className="text-[13px] text-primary hover:underline">
                      {t('organizerDash.viewPublicPage')}
                    </Link>
                    {isEditable && (
                      <Link to={`/organizer/campaigns/${c._id}/edit`} className="text-[13px] text-primary hover:underline">
                        {t('organizerDash.edit')}
                      </Link>
                    )}
                    {isOwner && c.status === 'draft' && (
                      <button
                        onClick={() => setConfirmAction({ type: 'delete', campaign: c })}
                        className="text-[13px] text-error hover:underline ml-auto"
                      >
                        {t('organizerDash.delete')}
                      </button>
                    )}
                    {isOwner && c.status === 'submitted' && (
                      <button
                        onClick={() => setConfirmAction({ type: 'cancel', campaign: c })}
                        className="text-[13px] text-error hover:underline ml-auto"
                      >
                        {t('organizerDash.cancelCampaign')}
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {confirmAction && (
        <div className="fixed inset-0 bg-text-primary/40 flex items-center justify-center p-xl z-50">
          <div className="bg-surface rounded-lg border border-border p-xl max-w-md w-full flex flex-col gap-lg">
            <h3 className="text-[16px] font-semibold text-text-primary">
              {confirmAction.type === 'delete' ? t('organizerDash.deleteConfirmTitle') : t('organizerDash.cancelConfirmTitle')}
            </h3>
            <p className="text-[13px] text-text-secondary">
              {confirmAction.type === 'delete'
                ? `"${campaignTitle(confirmAction.campaign)}" ${t('organizerDash.deleteConfirmDesc')}`
                : `"${campaignTitle(confirmAction.campaign)}" ${t('organizerDash.cancelConfirmDesc')}`}
            </p>
            {actionError && <p className="text-[13px] text-error">{actionError}</p>}
            <div className="flex justify-end gap-md">
              <Button variant="tertiary" onClick={() => setConfirmAction(null)}>{t('organizerDash.keepCampaign')}</Button>
              <Button variant="destructive" onClick={handleConfirm} disabled={submitting}>
                {submitting ? t('organizerDash.working') : confirmAction.type === 'delete' ? t('organizerDash.delete') : t('organizerDash.cancelCampaign')}
              </Button>
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
