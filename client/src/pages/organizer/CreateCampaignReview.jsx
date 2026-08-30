import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import WizardSteps from '../../components/WizardSteps';
import Button from '../../components/Button';
import StatusPill from '../../components/StatusPill';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel } from '../../i18n/translations';

export default function CreateCampaignReview() {
  const { t, language } = useLanguage();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const campaignId = searchParams.get('id');
  const [campaign, setCampaign] = useState(null);
  const [beneficiaryStatus, setBeneficiaryStatus] = useState(null); // null = not submitted yet
  const [error, setError] = useState(null);
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const STEPS = [t('wizard.basics'), t('wizard.story'), t('wizard.reviewSubmit')];

  useEffect(() => {
    if (!campaignId) return;
    api.get(`/campaigns/${campaignId}`).then(({ data }) => setCampaign(data));
    api
      .get('/beneficiaries/me')
      .then(({ data }) => setBeneficiaryStatus(data.verificationStatus))
      .catch(() => setBeneficiaryStatus(null));
  }, [campaignId]);

  async function handleSubmit() {
    setSubmitting(true);
    setError(null);
    try {
      await api.post(`/campaigns/${campaignId}/submit`);
      setSubmitted(true);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('createReview.error'));
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <PageLayout noFooter>
        <div className="max-w-[520px] mx-auto px-xl py-4xl text-center flex flex-col items-center gap-lg">
          <span className="material-symbols-outlined text-success" style={{ fontSize: 48 }}>task_alt</span>
          <h1 className="text-[22px] font-bold text-text-primary">{t('createReview.submittedTitle')}</h1>
          <p className="text-[14px] text-text-secondary">
            {t('createReview.submittedDesc')}
          </p>
          <Link to="/organizer"><Button>{t('createReview.goToCampaigns')}</Button></Link>
        </div>
      </PageLayout>
    );
  }

  if (!campaign) {
    return (
      <PageLayout noFooter>
        <div className="max-w-[560px] mx-auto px-xl py-3xl animate-pulse">
          <div className="h-40 bg-surface border border-border rounded-lg" />
        </div>
      </PageLayout>
    );
  }

  return (
    <PageLayout noFooter>
      <div className="max-w-[560px] mx-auto px-xl py-3xl">
        <WizardSteps steps={STEPS} current={3} />
        <h1 className="text-[24px] font-bold text-text-primary mb-2xl">{t('createReview.title')}</h1>

        <div className="bg-surface border border-border rounded-lg p-xl flex flex-col gap-lg mb-xl">
          <div className="flex items-start justify-between">
            <div>
              <h2 className="text-[18px] font-semibold text-text-primary">{campaign.title?.so}</h2>
              <p className="text-[13px] text-text-secondary">{categoryLabel(campaign.category, language)} · {t('createReview.goal')} ${campaign.goalAmount.toLocaleString()}</p>
            </div>
            <StatusPill status={campaign.status} />
          </div>
          <p className="text-[14px] text-text-secondary whitespace-pre-line">{campaign.story?.so}</p>
        </div>

        <div className="bg-background border border-border rounded-lg p-lg mb-xl flex items-center justify-between gap-md flex-wrap">
          <p className="text-[13px] text-text-secondary max-w-sm">
            {t('createReview.withdrawalNote')}
          </p>
          {beneficiaryStatus ? (
            <StatusPill status={beneficiaryStatus} />
          ) : (
            <Link to="/verification" className="text-[13px] font-medium text-primary hover:underline whitespace-nowrap">
              {t('withdrawals.submitVerificationLink')}
            </Link>
          )}
        </div>

        {error && <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md mb-lg">{error}</p>}

        <div className="flex justify-end">
          <Button onClick={handleSubmit} disabled={submitting}>
            {submitting ? t('withdrawals.submitting') : t('createReview.submitButton')}
          </Button>
        </div>
      </div>
    </PageLayout>
  );
}
