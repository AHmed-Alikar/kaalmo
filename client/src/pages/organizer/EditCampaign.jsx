import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import ImageUpload from '../../components/ImageUpload';
import EmptyState from '../../components/EmptyState';
import StatusPill from '../../components/StatusPill';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

// Assign / view the campaign's beneficiary. Owner action — the backend
// enforces owner-only on POST /campaigns/:id/beneficiary.
function BeneficiaryPanel({ campaignId }) {
  const { t } = useLanguage();
  const [state, setState] = useState('loading'); // loading | none | ready | error
  const [beneficiary, setBeneficiary] = useState(null);
  const [email, setEmail] = useState('');
  const [sending, setSending] = useState(false);
  const [msg, setMsg] = useState(null);
  const [err, setErr] = useState(null);

  function load() {
    setState('loading');
    api
      .get(`/campaigns/${campaignId}/beneficiary`)
      .then(({ data }) => { setBeneficiary(data); setState('ready'); })
      .catch((e) => setState(e.response?.status === 404 ? 'none' : 'error'));
  }
  useEffect(load, [campaignId]);

  async function invite(e) {
    e.preventDefault();
    setSending(true); setErr(null); setMsg(null);
    try {
      await api.post(`/campaigns/${campaignId}/beneficiary`, { email });
      setEmail('');
      setMsg(t('verification.orgInviteSent'));
      load();
    } catch (e2) {
      setErr(e2.response?.data?.error?.message || t('editCampaign.saveError'));
    } finally {
      setSending(false);
    }
  }

  const canInvite = state === 'none' || (beneficiary && beneficiary.verificationStatus !== 'verified');

  return (
    <div className="mt-2xl border-t border-border pt-xl">
      <h2 className="text-[16px] font-semibold text-text-primary mb-md">{t('verification.orgBeneficiaryTitle')}</h2>

      {state === 'loading' && <div className="h-14 bg-surface border border-border rounded-lg animate-pulse" />}
      {state === 'error' && <p className="text-[13px] text-text-secondary">{t('common.checkConnection')}</p>}

      {state === 'ready' && beneficiary && (
        <div className="bg-background border border-border rounded-lg p-lg mb-md flex items-center justify-between gap-md flex-wrap">
          <div>
            <p className="text-[14px] font-medium text-text-primary">
              {beneficiary.fullName || beneficiary.inviteEmail || beneficiary.userId?.email}
            </p>
            {beneficiary.reviewNote && (
              <p className="text-[12px] text-text-secondary mt-xs">{beneficiary.reviewNote}</p>
            )}
          </div>
          <StatusPill status={beneficiary.verificationStatus} />
        </div>
      )}

      {state === 'none' && (
        <p className="text-[13px] text-text-secondary mb-md">{t('verification.orgNoBeneficiary')}</p>
      )}

      {canInvite && (
        <form onSubmit={invite} className="flex items-end gap-sm flex-wrap">
          <div className="flex-1 min-w-[220px]">
            <Input
              label={t('verification.orgInviteLabel')}
              id="beneficiaryEmail"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <Button type="submit" disabled={sending || !email}>
            {sending ? t('team.sending') : t('verification.orgInviteSend')}
          </Button>
        </form>
      )}
      {msg && <p className="text-[13px] text-success mt-sm">{msg}</p>}
      {err && <p className="text-[13px] text-error mt-sm">{err}</p>}
    </div>
  );
}

const CATEGORIES = ['Medical', 'Education', 'Emergency', 'Family', 'Funeral', 'Community', 'Mosque', 'School', 'Orphan Support', 'Disaster Relief', 'Business/Startup', 'NGO', 'Public Projects', 'Other'];

// Editing an already-reviewed campaign sends it back to under_review on the
// backend (campaignService.js EDIT_RETURNS_TO_REVIEW_STATUSES) — mirrored
// here only to decide whether to show the warning banner before saving.
const RETURNS_TO_REVIEW_STATUSES = ['submitted', 'under_review', 'approved', 'published', 'active', 'goal_reached', 'withdrawal'];

export default function EditCampaign() {
  const { t, language } = useLanguage();
  const { user } = useAuth();
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState(null);
  const [isOwner, setIsOwner] = useState(true);
  const [loadError, setLoadError] = useState(null);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    api
      .get(`/campaigns/${id}`)
      .then(({ data }) => {
        setIsOwner(String(data.organizerId) === String(user?.id));
        setForm({
          title: data.title?.so || '',
          story: data.story?.so || '',
          category: data.category,
          goalAmount: data.goalAmount,
          region: data.region || '',
          coverImageUrl: data.coverImageUrl || null,
          status: data.status,
        });
      })
      .catch((err) => setLoadError(err.response?.data?.error?.message || t('editCampaign.loadError')));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await api.patch(`/campaigns/${id}`, {
        title: { so: form.title },
        story: { so: form.story },
        category: form.category,
        goalAmount: Number(form.goalAmount),
        region: form.region || undefined,
        coverImageUrl: form.coverImageUrl || undefined,
      });
      navigate('/organizer');
    } catch (err) {
      setError(err.response?.data?.error?.message || t('editCampaign.saveError'));
    } finally {
      setSubmitting(false);
    }
  }

  if (loadError) {
    return (
      <PageLayout noFooter>
        <div className="max-w-[560px] mx-auto px-xl py-3xl">
          <EmptyState icon="error" title={t('editCampaign.loadErrorTitle')} description={loadError} />
        </div>
      </PageLayout>
    );
  }

  if (!form) {
    return (
      <PageLayout noFooter>
        <div className="max-w-[560px] mx-auto px-xl py-3xl flex flex-col gap-lg">
          <div className="h-64 bg-surface border border-border rounded-lg animate-pulse" />
        </div>
      </PageLayout>
    );
  }

  const returnsToReview = RETURNS_TO_REVIEW_STATUSES.includes(form.status);

  return (
    <PageLayout noFooter>
      <div className="max-w-[560px] mx-auto px-xl py-3xl">
        <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('editCampaign.title')}</h1>
        <p className="text-[14px] text-text-secondary mb-lg">
          {t('editCampaign.subtitle')}
        </p>

        {!isOwner && (
          <div className="bg-primary/5 border border-primary/30 rounded-lg p-md mb-lg">
            <p className="text-[13px] font-medium text-primary">{t('coOrg.bannerTitle')}</p>
            <p className="text-[12px] text-text-secondary mt-xs">{t('coOrg.bannerBody')}</p>
          </div>
        )}

        {returnsToReview && (
          <p className="text-[13px] text-text-primary bg-warning/10 border border-warning/30 rounded p-md mb-lg">
            {t('editCampaign.reviewWarningPrefix')} {form.status === 'under_review' ? t('editCampaign.inReview') : form.status.replace(/_/g, ' ')}.
            {' '}{t('editCampaign.reviewWarningSuffix')}
          </p>
        )}

        <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
          <ImageUpload
            label={t('editCampaign.coverPhoto')}
            value={form.coverImageUrl}
            onChange={(url) => setForm({ ...form, coverImageUrl: url })}
          />

          <Input
            label={t('editCampaign.campaignTitle')}
            id="title"
            required
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
          />

          <div className="flex flex-col gap-sm">
            <label htmlFor="category" className="text-[14px] font-medium text-text-primary">{t('explore.category')}</label>
            <select
              id="category"
              value={form.category}
              onChange={(e) => setForm({ ...form, category: e.target.value })}
              className="w-full h-[44px] px-lg rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
            >
              {CATEGORIES.map((c) => <option key={c} value={c}>{categoryLabel(c, language)}</option>)}
            </select>
          </div>

          <Input
            label={t('editCampaign.fundingGoal')}
            id="goalAmount"
            type="number"
            min="1"
            required
            value={form.goalAmount}
            onChange={(e) => setForm({ ...form, goalAmount: e.target.value })}
          />

          <Input
            label={t('editCampaign.regionOptional')}
            id="region"
            placeholder="e.g. Mogadishu"
            value={form.region}
            onChange={(e) => setForm({ ...form, region: e.target.value })}
          />

          <div className="flex flex-col gap-sm">
            <label htmlFor="story" className="text-[14px] font-medium text-text-primary">{t('editCampaign.story')}</label>
            <textarea
              id="story"
              rows={8}
              required
              minLength={20}
              value={form.story}
              onChange={(e) => setForm({ ...form, story: e.target.value })}
              className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
            />
          </div>

          {error && <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>}

          <div className="flex items-center justify-between pt-md">
            <Link to="/organizer" className="text-[13px] text-text-secondary hover:underline">{t('campaign.cancel')}</Link>
            <Button type="submit" disabled={submitting}>
              {submitting ? t('common.saving') : t('settings.saveChanges')}
            </Button>
          </div>
        </form>

        {isOwner && <BeneficiaryPanel campaignId={id} />}
      </div>
    </PageLayout>
  );
}
