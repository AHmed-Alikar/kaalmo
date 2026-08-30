import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

const SCORE_COLOR = { LOW: 'text-text-secondary', MEDIUM: 'text-warning', HIGH: 'text-error' };

// Signals are computed live from real donation/account/campaign data (see
// server/src/services/fraudService.js) using simple, explainable rules —
// not a black-box ML score. Recomputed on every load, so there's no
// separate "dismiss" workflow: once the underlying pattern stops (e.g. the
// donation velocity settles down), the signal disappears on its own.
export default function FraudRisk() {
  const { t } = useLanguage();
  const [signals, setSignals] = useState([]);
  const [status, setStatus] = useState('loading');

  useEffect(() => {
    api
      .get('/admin/fraud-signals')
      .then(({ data }) => {
        setSignals(data.items);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }, []);

  function linkFor(s) {
    return s.subjectType === 'campaign' ? `/campaigns/${s.subjectId}` : `/admin/users`;
  }

  return (
    <DashboardLayout title={t('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('adminNav.fraudRisk')}</h1>
        <p className="text-[13px] text-text-secondary bg-background border border-border rounded-lg p-lg">
          {t('fraudRisk.explanation')}
        </p>

        {status === 'loading' && (
          <div className="flex flex-col gap-sm">{[1, 2, 3].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('fraudRisk.loadErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && signals.length === 0 && (
          <EmptyState icon="verified_user" title={t('fraudRisk.emptyTitle')} description={t('fraudRisk.emptyDesc')} />
        )}

        {signals.length > 0 && (
          <div className="flex flex-col divide-y divide-border border-t border-b border-border">
            {signals.map((s) => (
              <div key={s.id} className="flex items-center justify-between py-lg gap-md flex-wrap">
                <div>
                  <p className="text-[14px] font-medium text-text-primary">{s.subject}</p>
                  <p className="text-[13px] text-text-secondary">{s.signal}</p>
                </div>
                <div className="flex items-center gap-lg">
                  <span className={`text-[13px] font-semibold ${SCORE_COLOR[s.score]}`}>{s.score}</span>
                  <Link
                    to={linkFor(s)}
                    className="h-[34px] px-md text-[13px] inline-flex items-center rounded border border-primary text-primary hover:bg-primary/5 transition-colors"
                  >
                    {t('fraudRisk.review')}
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
