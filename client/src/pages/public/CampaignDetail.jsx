import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import ProgressBar from '../../components/ProgressBar';
import VerificationBadge from '../../components/VerificationBadge';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { categoryLabel, regionLabel } from '../../i18n/translations';

// Campaign detail is a Trust + Understanding + Donation experience
// (Design_Rules.md Rule 22) — story and trust signals come before secondary
// features like comments; the donate panel stays clear and uncluttered.
export default function CampaignDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { t, language } = useLanguage();
  const [campaign, setCampaign] = useState(null);
  const [updates, setUpdates] = useState([]);
  const [donations, setDonations] = useState([]);
  const [supporterCount, setSupporterCount] = useState(0);
  const [status, setStatus] = useState('loading');
  const [following, setFollowing] = useState(false);
  const [saved, setSaved] = useState(false);
  const [reportOpen, setReportOpen] = useState(false);
  const [reportReason, setReportReason] = useState('');
  const [reportError, setReportError] = useState(null);
  const [reportSent, setReportSent] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    setStatus('loading');
    Promise.all([
      api.get(`/campaigns/${id}`),
      api.get(`/campaigns/${id}/updates`),
      api.get(`/campaigns/${id}/donations`, { params: { limit: 10 } }),
    ])
      .then(([campaignRes, updatesRes, donationsRes]) => {
        setCampaign(campaignRes.data);
        setUpdates(updatesRes.data);
        setDonations(donationsRes.data.items);
        setSupporterCount(donationsRes.data.supporterCount);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));

    // Fetched separately: whether the viewer follows/has saved this
    // campaign is a nice-to-have for button state, not core page content —
    // an expired/invalid session here should never block the campaign
    // itself from displaying.
    if (user) {
      api
        .get(`/campaigns/${id}/interactions`)
        .then(({ data }) => {
          setFollowing(data.following);
          setSaved(data.saved);
        })
        .catch(() => {});
    }
  }, [id, user]);

  async function toggleFollow() {
    if (!user) return navigate('/login', { state: { from: `/campaigns/${id}` } });
    if (following) {
      await api.delete(`/campaigns/${id}/follow`);
      setFollowing(false);
    } else {
      await api.post(`/campaigns/${id}/follow`);
      setFollowing(true);
    }
  }

  async function toggleSave() {
    if (!user) return navigate('/login', { state: { from: `/campaigns/${id}` } });
    if (saved) {
      await api.delete(`/campaigns/${id}/save`);
      setSaved(false);
    } else {
      await api.post(`/campaigns/${id}/save`);
      setSaved(true);
    }
  }

  function handleShare() {
    navigator.clipboard.writeText(window.location.href);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  async function handleReport(e) {
    e.preventDefault();
    if (!user) return navigate('/login', { state: { from: `/campaigns/${id}` } });
    setReportError(null);
    try {
      await api.post('/reports', { targetType: 'campaign', targetId: id, reason: reportReason });
      setReportSent(true);
    } catch (err) {
      setReportError(err.response?.data?.error?.message || t('campaign.reportError'));
    }
  }

  if (status === 'loading') {
    return (
      <PageLayout>
        <div className="max-w-container mx-auto px-xl py-2xl animate-pulse">
          <div className="h-80 bg-surface border border-border rounded-lg mb-xl" />
          <div className="h-6 w-2/3 bg-surface border border-border rounded mb-md" />
          <div className="h-4 w-1/3 bg-surface border border-border rounded" />
        </div>
      </PageLayout>
    );
  }

  if (status === 'error' || !campaign) {
    return (
      <PageLayout>
        <div className="max-w-container mx-auto px-xl py-4xl">
          <EmptyState
            icon="error"
            title={t('campaign.notFoundTitle')}
            description={t('campaign.notFoundDesc')}
            action={
              <Link to="/explore">
                <Button variant="secondary">{t('campaign.backToExplore')}</Button>
              </Link>
            }
          />
        </div>
      </PageLayout>
    );
  }

  const title = campaign.title?.[language] || campaign.title?.so || campaign.title?.en;
  const story = campaign.story?.[language] || campaign.story?.so || campaign.story?.en;

  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-2xl grid grid-cols-1 lg:grid-cols-3 gap-2xl">
        {/* Primary column: trust + story */}
        <div className="lg:col-span-2 flex flex-col gap-xl">
          <div className="h-80 w-full rounded-lg bg-background border border-border overflow-hidden flex items-center justify-center">
            {campaign.coverImageUrl ? (
              <img src={campaign.coverImageUrl} alt={title} className="w-full h-full object-cover" />
            ) : (
              <span className="material-symbols-outlined text-text-secondary" style={{ fontSize: 48 }}>image</span>
            )}
          </div>

          <div className="flex flex-col gap-sm">
            <div className="flex items-center justify-between gap-md">
              <span className="text-[13px] font-medium text-primary uppercase tracking-wide">{categoryLabel(campaign.category, language)}</span>
              <button
                onClick={toggleSave}
                className="flex items-center gap-xs text-[13px] text-text-secondary hover:text-primary transition-colors"
              >
                <span className="material-symbols-outlined" style={{ fontSize: 20, fontVariationSettings: saved ? "'FILL' 1" : "'FILL' 0" }}>
                  bookmark
                </span>
                {saved ? t('campaign.saved') : t('campaign.save')}
              </button>
            </div>
            <h1 className="text-[28px] md:text-[32px] font-bold text-text-primary leading-tight">{title}</h1>
            <div className="flex flex-wrap gap-xs">
              {(campaign.verificationBadges || []).map((b) => (
                <VerificationBadge key={b} type={b} />
              ))}
            </div>
          </div>

          <div className="prose-none">
            <h2 className="text-[18px] font-semibold text-text-primary mb-sm">{t('campaign.theStory')}</h2>
            <p className="text-[15px] text-text-secondary leading-relaxed whitespace-pre-line">{story}</p>
          </div>

          <div>
            <h2 className="text-[18px] font-semibold text-text-primary mb-md">
              {t('campaign.recentDonations')} {supporterCount > 0 && <span className="text-text-secondary font-normal">({supporterCount})</span>}
            </h2>
            {donations.length === 0 ? (
              <EmptyState
                icon="volunteer_activism"
                title={t('campaign.noDonationsTitle')}
                description={t('campaign.noDonationsDesc')}
              />
            ) : (
              <div className="flex flex-col divide-y divide-border border-t border-b border-border">
                {donations.map((d) => (
                  <div key={d._id} className="py-md flex items-start justify-between gap-md">
                    <div className="min-w-0">
                      <p className="text-[14px] font-medium text-text-primary">{d.donorName || t('campaign.anonymous')}</p>
                      {d.message && <p className="text-[13px] text-text-secondary mt-xs truncate">{d.message}</p>}
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="text-[14px] font-semibold text-text-primary">${d.amount.toLocaleString()}</p>
                      <p className="text-[12px] text-text-secondary">{new Date(d.createdAt).toLocaleDateString()}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div>
            <div className="flex items-center justify-between mb-md">
              <h2 className="text-[18px] font-semibold text-text-primary">{t('campaign.updates')}</h2>
              <button
                onClick={toggleFollow}
                className={`text-[13px] font-medium transition-colors ${following ? 'text-primary' : 'text-text-secondary hover:text-primary'}`}
              >
                {following ? t('campaign.following') : t('campaign.followForUpdates')}
              </button>
            </div>
            {updates.length === 0 ? (
              <EmptyState
                icon="update"
                title={t('campaign.noUpdatesTitle')}
                description={t('campaign.noUpdatesDesc')}
              />
            ) : (
              <div className="flex flex-col gap-lg">
                {updates.map((u) => (
                  <div key={u._id} className="border-l-2 border-border pl-lg">
                    <p className="text-[13px] text-text-secondary mb-xs">
                      {new Date(u.createdAt).toLocaleDateString()}
                    </p>
                    <p className="text-[14px] text-text-primary">{u.text}</p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Donation panel — must remain clear, not competing with share/report (Rule 22) */}
        <div className="lg:col-span-1">
          <div className="sticky top-24 bg-surface border border-border rounded-lg p-xl flex flex-col gap-lg">
            <ProgressBar raised={campaign.raisedAmount} goal={campaign.goalAmount} />
            <p className="text-[13px] text-text-secondary">
              {supporterCount} {supporterCount === 1 ? t('card.supporter') : t('card.supporters')} · {campaign.region ? regionLabel(campaign.region, language) : t('campaign.regionNotSpecified')}
            </p>

            <Link to={`/donate/${campaign._id}`}>
              <Button className="w-full">{t('campaign.donateButton')}</Button>
            </Link>

            <div className="flex items-center justify-between pt-md border-t border-border">
              <button onClick={handleShare} className="flex items-center gap-xs text-[13px] text-text-secondary hover:text-primary transition-colors">
                <span className="material-symbols-outlined" style={{ fontSize: 18 }}>share</span>
                {copied ? t('campaign.linkCopied') : t('campaign.share')}
              </button>
              <button
                onClick={() => setReportOpen(true)}
                className="flex items-center gap-xs text-[13px] text-text-secondary hover:text-error transition-colors"
              >
                <span className="material-symbols-outlined" style={{ fontSize: 18 }}>flag</span>
                {t('campaign.report')}
              </button>
            </div>
          </div>
        </div>
      </div>

      {reportOpen && (
        <div className="fixed inset-0 bg-text-primary/40 flex items-center justify-center p-xl z-50">
          <div className="bg-surface rounded-lg border border-border p-xl max-w-md w-full flex flex-col gap-lg">
            {reportSent ? (
              <>
                <h3 className="text-[16px] font-semibold text-text-primary">{t('campaign.reportSubmittedTitle')}</h3>
                <p className="text-[13px] text-text-secondary">{t('campaign.reportSubmittedDesc')}</p>
                <Button variant="secondary" onClick={() => { setReportOpen(false); setReportSent(false); setReportReason(''); }}>
                  {t('campaign.close')}
                </Button>
              </>
            ) : (
              <>
                <h3 className="text-[16px] font-semibold text-text-primary">{t('campaign.reportTitle')}</h3>
                <p className="text-[13px] text-text-secondary">{t('campaign.reportDesc')}</p>
                <form onSubmit={handleReport} className="flex flex-col gap-lg">
                  <textarea
                    rows={3}
                    required
                    minLength={5}
                    value={reportReason}
                    onChange={(e) => setReportReason(e.target.value)}
                    placeholder={t('campaign.reportPlaceholder')}
                    className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary"
                  />
                  {reportError && <p className="text-[13px] text-error">{reportError}</p>}
                  <div className="flex justify-end gap-md">
                    <Button type="button" variant="tertiary" onClick={() => setReportOpen(false)}>{t('campaign.cancel')}</Button>
                    <Button type="submit" variant="destructive">{t('campaign.submitReport')}</Button>
                  </div>
                </form>
              </>
            )}
          </div>
        </div>
      )}
    </PageLayout>
  );
}
