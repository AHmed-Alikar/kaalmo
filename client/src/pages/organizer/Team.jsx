import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import Input from '../../components/Input';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ORGANIZER_NAV } from './nav';

// Co-organizers can help manage campaign content but not finances or the
// team itself — only the organizer sees this page (Design_Rules.md Rule 33).
export default function Team() {
  const { t, language } = useLanguage();
  const [campaigns, setCampaigns] = useState([]);
  const [selectedId, setSelectedId] = useState('');
  const [members, setMembers] = useState([]);
  const [email, setEmail] = useState('');
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    // Team management is owner-only — /campaigns/mine also includes
    // campaigns this user merely co-organizes, which must not appear here.
    api.get('/campaigns/mine').then(({ data }) => {
      const owned = data.filter((c) => c.access === 'owner');
      setCampaigns(owned);
      if (owned.length > 0) setSelectedId(owned[0]._id);
    });
  }, []);

  function loadMembers(campaignId) {
    if (!campaignId) return;
    api.get(`/campaigns/${campaignId}/members`).then(({ data }) => setMembers(data));
  }

  useEffect(() => loadMembers(selectedId), [selectedId]);

  async function handleInvite(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await api.post(`/campaigns/${selectedId}/members`, { email });
      setEmail('');
      loadMembers(selectedId);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('team.inviteError'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleRemove(memberId) {
    await api.delete(`/campaigns/${selectedId}/members/${memberId}`);
    loadMembers(selectedId);
  }

  if (campaigns.length === 0) {
    return (
      <DashboardLayout title={t('organizerDash.title')} nav={ORGANIZER_NAV}>
        <EmptyState icon="group" title={t('team.createCampaignFirstTitle')} description={t('team.createCampaignFirstDesc')} />
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout title={t('organizerDash.title')} nav={ORGANIZER_NAV}>
      <div className="flex flex-col gap-xl max-w-lg">
        <h1 className="text-[24px] font-bold text-text-primary">{t('organizerNav.team')}</h1>

        <div className="flex flex-col gap-sm">
          <label className="text-[14px] font-medium text-text-primary">{t('team.campaignLabel')}</label>
          <select
            value={selectedId}
            onChange={(e) => setSelectedId(e.target.value)}
            className="w-full h-[44px] px-lg rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary"
          >
            {campaigns.map((c) => (
              <option key={c._id} value={c._id}>{c.title?.[language] || c.title?.so || c.title?.en}</option>
            ))}
          </select>
        </div>

        <form onSubmit={handleInvite} className="flex gap-sm items-end">
          <div className="flex-grow">
            <Input
              label={t('team.inviteLabel')}
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <Button type="submit" disabled={submitting || !selectedId}>
            {submitting ? t('team.sending') : t('team.invite')}
          </Button>
        </form>
        {error && <p className="text-[13px] text-error">{error}</p>}

        {members.length === 0 ? (
          <EmptyState icon="group" title={t('team.noMembersTitle')} description={t('team.noMembersDesc')} />
        ) : (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {members.map((m) => (
              <div key={m._id} className="flex items-center justify-between py-lg">
                <div>
                  <p className="text-[14px] font-medium text-text-primary">{m.inviteEmail}</p>
                  <p className="text-[13px] text-text-secondary">{t('organizerDash.coOrganizer')}</p>
                </div>
                <div className="flex items-center gap-md">
                  <StatusPill status={m.status} />
                  <Button variant="destructive" className="h-[32px] px-md text-[12px]" onClick={() => handleRemove(m._id)}>
                    {t('team.remove')}
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
