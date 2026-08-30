import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import ImageUpload from '../../components/ImageUpload';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

const CATEGORIES = ['Medical', 'Education', 'Emergency', 'Family', 'Funeral', 'Community', 'Mosque', 'School', 'Orphan Support', 'Disaster Relief', 'Business/Startup', 'NGO', 'Public Projects', 'Other'];

// Editing an already-reviewed campaign sends it back to under_review on the
// backend (campaignService.js EDIT_RETURNS_TO_REVIEW_STATUSES) — mirrored
// here only to decide whether to show the warning banner before saving.
const RETURNS_TO_REVIEW_STATUSES = ['submitted', 'under_review', 'approved', 'published', 'active', 'goal_reached', 'withdrawal'];

export default function EditCampaign() {
  const { t, language } = useLanguage();
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState(null);
  const [loadError, setLoadError] = useState(null);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    api
      .get(`/campaigns/${id}`)
      .then(({ data }) => {
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
        <p className="text-[14px] text-text-secondary mb-2xl">
          {t('editCampaign.subtitle')}
        </p>

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
      </div>
    </PageLayout>
  );
}
