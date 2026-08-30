import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import WizardSteps from '../../components/WizardSteps';
import Input from '../../components/Input';
import Button from '../../components/Button';
import ImageUpload from '../../components/ImageUpload';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

const CATEGORIES = ['Medical', 'Education', 'Emergency', 'Family', 'Funeral', 'Community', 'Mosque', 'School', 'Orphan Support', 'Disaster Relief', 'Business/Startup', 'NGO', 'Public Projects', 'Other'];

export default function CreateCampaignBasics() {
  const { t, language } = useLanguage();
  const navigate = useNavigate();
  const [form, setForm] = useState({ title: '', category: 'Medical', goalAmount: '', region: '', coverImageUrl: null });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  const STEPS = [t('wizard.basics'), t('wizard.story'), t('wizard.reviewSubmit')];

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const { data } = await api.post('/campaigns', {
        title: { so: form.title },
        story: { so: 'Waan sii wadi doonaa qorista sheekada.' }, // placeholder, replaced in step 2
        category: form.category,
        goalAmount: Number(form.goalAmount),
        region: form.region || undefined,
        coverImageUrl: form.coverImageUrl || undefined,
      });
      navigate(`/organizer/new/story?id=${data._id}`);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('createBasics.error'));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageLayout noFooter>
      <div className="max-w-[560px] mx-auto px-xl py-3xl">
        <WizardSteps steps={STEPS} current={1} />
        <h1 className="text-[24px] font-bold text-text-primary mb-2xl">{t('createBasics.title')}</h1>

        <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
          <ImageUpload
            label={t('editCampaign.coverPhoto')}
            value={form.coverImageUrl}
            onChange={(url) => setForm({ ...form, coverImageUrl: url })}
          />

          <Input
            label={t('editCampaign.campaignTitle')}
            id="title"
            placeholder={t('createBasics.titlePlaceholder')}
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

          {error && <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>}

          <div className="flex justify-end pt-md">
            <Button type="submit" disabled={submitting}>
              {submitting ? t('common.saving') : t('createBasics.continueToStory')}
            </Button>
          </div>
        </form>
      </div>
    </PageLayout>
  );
}
