import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import Input from '../../components/Input';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

import { ORGANIZER_NAV } from './nav';

export default function Withdrawals() {
  const { t, language } = useLanguage();
  const [withdrawals, setWithdrawals] = useState([]);
  const [campaigns, setCampaigns] = useState([]);
  const [payoutAccounts, setPayoutAccounts] = useState([]);
  const [status, setStatus] = useState('loading');
  const [form, setForm] = useState({ campaignId: '', amount: '', payoutAccountId: '' });
  const [error, setError] = useState(null);
  const [errorCode, setErrorCode] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  function loadAll() {
    Promise.all([api.get('/withdrawals/mine'), api.get('/campaigns/mine'), api.get('/payout-accounts/mine')])
      .then(([w, c, p]) => {
        setWithdrawals(w.data);
        // Withdrawals are owner-only — /campaigns/mine also includes
        // campaigns this user merely co-organizes, which must not appear here.
        setCampaigns(c.data.filter((campaign) => campaign.access === 'owner'));
        setPayoutAccounts(p.data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }

  useEffect(loadAll, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    setErrorCode(null);
    try {
      await api.post('/withdrawals', {
        campaignId: form.campaignId,
        amount: Number(form.amount),
        payoutAccountId: form.payoutAccountId,
      });
      setForm({ campaignId: '', amount: '', payoutAccountId: '' });
      loadAll();
    } catch (err) {
      setError(err.response?.data?.error?.message || t('withdrawals.submitError'));
      setErrorCode(err.response?.data?.error?.code);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <DashboardLayout title={t('organizerDash.title')} nav={ORGANIZER_NAV}>
      <div className="flex flex-col gap-2xl">
        <h1 className="text-[24px] font-bold text-text-primary">{t('organizerNav.withdrawals')}</h1>

        <div className="bg-surface border border-border rounded-lg p-xl">
          <h2 className="text-[16px] font-semibold text-text-primary mb-lg">{t('withdrawals.requestTitle')}</h2>

          {payoutAccounts.length === 0 && status === 'ready' && (
            <p className="text-[13px] text-text-secondary bg-background border border-border rounded p-md mb-lg">
              {t('withdrawals.noPayoutAccount')}
            </p>
          )}

          <form onSubmit={handleSubmit} className="flex flex-col gap-lg max-w-md">
            <div className="flex flex-col gap-sm">
              <label className="text-[14px] font-medium text-text-primary">{t('team.campaignLabel')}</label>
              <select
                required
                value={form.campaignId}
                onChange={(e) => setForm({ ...form, campaignId: e.target.value })}
                className="w-full h-[44px] px-lg rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary"
              >
                <option value="">{t('withdrawals.selectCampaign')}</option>
                {campaigns.map((c) => (
                  <option key={c._id} value={c._id}>{c.title?.[language] || c.title?.so || c.title?.en} (${c.raisedAmount} {t('withdrawals.raisedSuffix')})</option>
                ))}
              </select>
            </div>

            <Input
              label={t('donate.amountLabel')}
              type="number"
              min="1"
              required
              value={form.amount}
              onChange={(e) => setForm({ ...form, amount: e.target.value })}
            />

            <div className="flex flex-col gap-sm">
              <label className="text-[14px] font-medium text-text-primary">{t('withdrawals.payoutAccount')}</label>
              <select
                required
                value={form.payoutAccountId}
                onChange={(e) => setForm({ ...form, payoutAccountId: e.target.value })}
                className="w-full h-[44px] px-lg rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary"
              >
                <option value="">{t('withdrawals.selectPayoutAccount')}</option>
                {payoutAccounts.map((p) => (
                  <option key={p._id} value={p._id}>{p.providerName} — {p.accountNumberMasked}</option>
                ))}
              </select>
            </div>

            {error && (
              <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">
                {error}
                {errorCode === 'BENEFICIARY_NOT_VERIFIED' && (
                  <>
                    {' '}
                    <Link to="/verification" className="underline font-medium">{t('withdrawals.submitVerificationLink')}</Link>.
                  </>
                )}
              </p>
            )}

            <Button type="submit" disabled={submitting || payoutAccounts.length === 0} className="self-start">
              {submitting ? t('withdrawals.submitting') : t('withdrawals.requestButton')}
            </Button>
          </form>
        </div>

        <div>
          <h2 className="text-[16px] font-semibold text-text-primary mb-md">{t('withdrawals.historyTitle')}</h2>
          {status === 'ready' && withdrawals.length === 0 && (
            <EmptyState
              icon="account_balance_wallet"
              title={t('withdrawals.noHistoryTitle')}
              description={t('withdrawals.noHistoryDesc')}
            />
          )}
          {withdrawals.length > 0 && (
            <div className="flex flex-col divide-y divide-border border-t border-b border-border">
              {withdrawals.map((w) => (
                <div key={w._id} className="flex items-center justify-between py-lg">
                  <div>
                    <p className="text-[14px] font-medium text-text-primary">${w.amount.toLocaleString()}</p>
                    <p className="text-[13px] text-text-secondary">{new Date(w.createdAt).toLocaleDateString()}</p>
                  </div>
                  <StatusPill status={w.status} />
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
}
