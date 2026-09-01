import { useEffect, useState } from 'react';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import StatusPill from '../../components/StatusPill';
import ImageUpload from '../../components/ImageUpload';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

// State machine — the page never shows a blank/null form:
//   loading -> (no profile | rejected | needs_more_information) => editable form
//           -> pending    => locked "submitted, awaiting review"
//           -> verified   => success card
//           -> load error => error + retry
// Beneficiary invitations (organizer named this user) show above the form.
export default function Verification() {
  const { t } = useLanguage();
  const [status, setStatus] = useState('loading'); // loading | ready | error
  const [profile, setProfile] = useState(null);
  const [invites, setInvites] = useState([]);
  const [form, setForm] = useState({ fullName: '', idDocumentUrl: null });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [acceptingId, setAcceptingId] = useState(null);

  function load() {
    setStatus('loading');
    Promise.all([
      api.get('/beneficiaries/me').then((r) => r.data).catch((err) => {
        if (err.response?.status === 404) return null;
        throw err;
      }),
      api.get('/beneficiaries/invites/mine').then((r) => r.data).catch(() => []),
    ])
      .then(([me, inv]) => {
        setProfile(me);
        setInvites(inv || []);
        if (me) setForm({ fullName: me.fullName || '', idDocumentUrl: me.idDocumentUrl || null });
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }

  useEffect(load, []);

  async function accept(id) {
    setAcceptingId(id);
    try {
      await api.post(`/beneficiaries/invites/${id}/accept`);
      load();
    } finally {
      setAcceptingId(null);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const { data } = await api.post('/beneficiaries/me', {
        fullName: form.fullName,
        idDocumentUrl: form.idDocumentUrl || undefined,
      });
      setProfile(data);
      setForm({ fullName: data.fullName || '', idDocumentUrl: data.idDocumentUrl || null });
    } catch (err) {
      setError(err.response?.data?.error?.message || t('verification.error'));
    } finally {
      setSubmitting(false);
    }
  }

  const vStatus = profile?.verificationStatus;
  const isPending = vStatus === 'pending';
  const isVerified = vStatus === 'verified';
  const isRejected = vStatus === 'rejected';
  const isNmi = vStatus === 'needs_more_information';
  const isInvited = vStatus === 'invited';
  const isAccepted = vStatus === 'accepted';
  // The form only opens AFTER the invitation is explicitly accepted — an
  // `invited` record shows the accept CTA above, not the verification form.
  const showForm = !profile || isRejected || isNmi || isAccepted;

  return (
    <PageLayout>
      <div className="max-w-[560px] mx-auto px-xl py-3xl">
        <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('verification.title')}</h1>
        <p className="text-[14px] text-text-secondary mb-2xl">{t('verification.subtitle')}</p>

        {status === 'loading' && (
          <div className="flex flex-col gap-md">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-14 bg-surface border border-border rounded-lg animate-pulse" />
            ))}
          </div>
        )}

        {status === 'error' && (
          <EmptyState
            icon="wifi_off"
            title={t('verification.loadError')}
            description={t('common.checkConnection')}
            action={<Button variant="secondary" onClick={load}>{t('common.retry')}</Button>}
          />
        )}

        {status === 'ready' && (
          <>
            {invites.length > 0 && (
              <div className="mb-xl flex flex-col gap-md">
                <h2 className="text-[15px] font-semibold text-text-primary">{t('verification.invitesTitle')}</h2>
                {invites.map((inv) => (
                  <div key={inv._id} className="bg-surface border border-primary/40 rounded-lg p-lg flex items-center justify-between gap-md flex-wrap">
                    <p className="text-[13px] text-text-primary">
                      {t('verification.inviteFrom').replace('{name}', inv.invitedBy?.fullName || 'An organizer')}
                      {inv.campaignId?.title ? ` — “${inv.campaignId.title.en || inv.campaignId.title.so}”` : ''}
                    </p>
                    <Button
                      className="h-[34px] px-md text-[13px]"
                      disabled={acceptingId === inv._id}
                      onClick={() => accept(inv._id)}
                    >
                      {t('verification.inviteAccept')}
                    </Button>
                  </div>
                ))}
              </div>
            )}

            {profile && (
              <div className="bg-background border border-border rounded-lg p-lg mb-xl flex items-center justify-between">
                <span className="text-[14px] text-text-primary">{t('verification.currentStatus')}</span>
                <StatusPill status={vStatus} />
              </div>
            )}

            {isVerified && (
              <div className="bg-success/10 border border-success/30 rounded-lg p-xl flex items-start gap-md">
                <span className="material-symbols-outlined text-success">verified</span>
                <div>
                  <p className="text-[15px] font-medium text-text-primary">{t('verification.verifiedTitle')}</p>
                  <p className="text-[13px] text-text-secondary">{t('verification.verifiedDesc')}</p>
                </div>
              </div>
            )}

            {isPending && (
              <div className="bg-info/10 border border-info/30 rounded-lg p-xl flex items-start gap-md">
                <span className="material-symbols-outlined text-info">hourglass_top</span>
                <div>
                  <p className="text-[15px] font-medium text-text-primary">{t('verification.pendingTitle')}</p>
                  <p className="text-[13px] text-text-secondary">{t('verification.pendingDesc')}</p>
                  <p className="text-[13px] text-info font-medium mt-xs">{t('verification.awaitingAdmin')}</p>
                </div>
              </div>
            )}

            {isInvited && (
              <div className="bg-primary/5 border border-primary/30 rounded-lg p-lg mb-xl">
                <p className="text-[14px] font-medium text-text-primary">{t('verification.invitedTitle')}</p>
                <p className="text-[13px] text-text-secondary mt-xs">{t('verification.invitedHint')}</p>
              </div>
            )}

            {isAccepted && (
              <div className="bg-background border border-border rounded-lg p-lg mb-xl">
                <p className="text-[14px] font-medium text-text-primary">{t('verification.acceptedTitle')}</p>
                <p className="text-[13px] text-text-secondary mt-xs">{t('verification.acceptedDesc')}</p>
              </div>
            )}

            {(isRejected || isNmi) && (
              <div className={`${isNmi ? 'bg-warning/10 border-warning/30' : 'bg-error/10 border-error/30'} border rounded-lg p-lg mb-xl flex items-start gap-md`}>
                <span className={`material-symbols-outlined ${isNmi ? 'text-warning' : 'text-error'}`}>
                  {isNmi ? 'info' : 'error'}
                </span>
                <div>
                  <p className="text-[14px] font-medium text-text-primary">
                    {isNmi ? t('verification.nmiTitle') : t('verification.rejectedTitle')}
                  </p>
                  <p className="text-[13px] text-text-secondary">
                    {profile.reviewNote || (isNmi ? t('verification.nmiDesc') : t('verification.rejectedDesc'))}
                  </p>
                </div>
              </div>
            )}

            {showForm && (
              <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
                <Input
                  label={t('verification.fullLegalName')}
                  id="fullName"
                  required
                  value={form.fullName}
                  onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                />
                <ImageUpload
                  label={t('verification.idDocument')}
                  value={form.idDocumentUrl}
                  onChange={(url) => setForm({ ...form, idDocumentUrl: url })}
                />
                {error && (
                  <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>
                )}
                <Button type="submit" disabled={submitting} className="self-start">
                  {submitting
                    ? t('verification.submitting')
                    : isRejected || isNmi
                      ? t('verification.resubmit')
                      : t('verification.submitButton')}
                </Button>
              </form>
            )}
          </>
        )}
      </div>
    </PageLayout>
  );
}
