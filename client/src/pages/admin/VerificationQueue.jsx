import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

// The queue shows records actually awaiting an admin decision (pending). Each
// row exposes the submitted identity + document and the three review outcomes
// the backend supports: verified | rejected | needs_more_information.
export default function VerificationQueue() {
  const { t, language } = useLanguage();
  const [beneficiaries, setBeneficiaries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState(null);

  function load() {
    setLoading(true);
    api
      .get('/admin/beneficiaries', { params: { status: 'pending' } })
      .then(({ data }) => setBeneficiaries(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, []);

  async function review(id, status) {
    let reviewNote;
    if (status === 'rejected') {
      reviewNote = window.prompt(t('verificationQueue.rejectPrompt')) || undefined;
    } else if (status === 'needs_more_information') {
      reviewNote = window.prompt(t('verificationQueue.infoPrompt')) || undefined;
      if (!reviewNote) return; // a request for info needs to say what's missing
    }
    setBusyId(id);
    try {
      await api.patch(`/admin/beneficiaries/${id}/review`, { status, reviewNote });
      load();
    } finally {
      setBusyId(null);
    }
  }

  function campaignTitle(c) {
    return c?.title?.[language] || c?.title?.so || c?.title?.en;
  }

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.verificationQueue')}</h1>

        {loading ? (
          <div className="flex flex-col gap-sm">
            {[1, 2].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}
          </div>
        ) : beneficiaries.length === 0 ? (
          <EmptyState icon="gpp_good" title={t('verificationQueue.emptyTitle')} description={t('verificationQueue.emptyDesc')} />
        ) : (
          <div className="flex flex-col gap-md">
            {beneficiaries.map((b) => (
              <div key={b._id} className="bg-surface border border-border rounded-lg p-lg flex flex-col gap-md">
                <div className="flex items-start justify-between gap-md flex-wrap">
                  <div className="flex flex-col gap-[2px]">
                    <p className="text-[15px] font-semibold text-text-primary">{b.fullName || '—'}</p>
                    <p className="text-[13px] text-text-secondary">
                      {t('verificationQueue.account')}: {b.userId?.email || b.inviteEmail || t('adminSupport.unknown')}
                    </p>
                    {b.campaignId && (
                      <p className="text-[13px] text-text-secondary">
                        {t('verificationQueue.campaign')}: {campaignTitle(b.campaignId)}
                      </p>
                    )}
                    {b.invitedBy && (
                      <p className="text-[13px] text-text-secondary">
                        {t('verificationQueue.invitedBy')}: {b.invitedBy.fullName || b.invitedBy.email}
                      </p>
                    )}
                  </div>
                  <StatusPill status={b.verificationStatus} />
                </div>

                {b.idDocumentUrl ? (
                  <a
                    href={b.idDocumentUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="text-[13px] text-primary hover:underline"
                  >
                    {t('verificationQueue.idDocument')}
                  </a>
                ) : (
                  <p className="text-[13px] text-text-secondary">{t('verificationQueue.noIdDocument')}</p>
                )}

                <div className="flex items-center gap-md flex-wrap pt-sm border-t border-border">
                  <Button
                    className="h-[36px] px-md text-[13px]"
                    disabled={busyId === b._id}
                    onClick={() => review(b._id, 'verified')}
                  >
                    {t('verificationQueue.verify')}
                  </Button>
                  <Button
                    variant="secondary"
                    className="h-[36px] px-md text-[13px]"
                    disabled={busyId === b._id}
                    onClick={() => review(b._id, 'needs_more_information')}
                  >
                    {t('verificationQueue.requestInfo')}
                  </Button>
                  <Button
                    variant="destructive"
                    className="h-[36px] px-md text-[13px]"
                    disabled={busyId === b._id}
                    onClick={() => review(b._id, 'rejected')}
                  >
                    {t('verificationQueue.reject')}
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
