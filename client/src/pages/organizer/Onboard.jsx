import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';

// Becoming an organizer requires a dedicated email confirmation — a
// deliberate, separate step from general account verification — so nobody
// gets organizer access just by loading this page or clicking one button.
// The confirmation is code-based, not link-based: the user stays on this
// page, enters the 6-digit code we emailed them, and the role is granted
// immediately (no separate page for clicking a link).
export default function OrganizerOnboard() {
  const { user, requestOrganizerAccess, applyTokens } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: user?.fullName || '', purpose: '' });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [sent, setSent] = useState(false);

  const [code, setCode] = useState('');
  const [codeError, setCodeError] = useState(null);
  const [verifying, setVerifying] = useState(false);
  const [resent, setResent] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await requestOrganizerAccess(form);
      setSent(true);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('onboard.genericError'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleVerify(e) {
    e.preventDefault();
    setVerifying(true);
    setCodeError(null);
    try {
      const { data } = await api.post('/users/me/confirm-organizer-access', { code });
      await applyTokens(data);
      navigate('/organizer/new/basics');
    } catch (err) {
      setCodeError(err.response?.data?.error?.message || t('checkEmail.verifyError'));
    } finally {
      setVerifying(false);
    }
  }

  async function handleResend() {
    setCodeError(null);
    setResent(false);
    try {
      await requestOrganizerAccess(form);
      setResent(true);
    } catch (err) {
      setCodeError(err.response?.data?.error?.message || t('checkEmail.resendError'));
    }
  }

  if (sent) {
    return (
      <PageLayout noFooter>
        <div className="max-w-[440px] mx-auto px-xl py-4xl flex flex-col items-center gap-lg">
          <span className="material-symbols-outlined text-primary" style={{ fontSize: 48 }}>mark_email_unread</span>
          <div className="text-center">
            <h1 className="text-[22px] font-bold text-text-primary">{t('onboard.confirmByEmail')}</h1>
            <p className="text-[14px] text-text-secondary mt-xs">
              {t('onboard.confirmSubtitle')}
            </p>
          </div>

          <form onSubmit={handleVerify} className="w-full flex flex-col gap-lg">
            <input
              type="text"
              inputMode="numeric"
              autoComplete="one-time-code"
              maxLength={6}
              required
              value={code}
              onChange={(e) => setCode(e.target.value.replace(/\D/g, ''))}
              placeholder="000000"
              className="w-full h-[56px] text-center text-[28px] tracking-[12px] font-semibold rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
            />

            {codeError && <p className="text-[13px] text-error text-center">{codeError}</p>}

            <Button type="submit" disabled={verifying || code.length !== 6} className="w-full">
              {verifying ? t('checkEmail.verifying') : t('onboard.confirmAndContinue')}
            </Button>
          </form>

          {resent && <p className="text-[13px] text-success">{t('checkEmail.resent')}</p>}

          <button onClick={handleResend} className="text-[13px] text-primary hover:underline">
            {t('checkEmail.didntGetCode')}
          </button>
        </div>
      </PageLayout>
    );
  }

  return (
    <PageLayout noFooter>
      <div className="max-w-[480px] mx-auto px-xl py-4xl">
        <div className="text-center mb-2xl flex flex-col items-center gap-sm">
          <span className="material-symbols-outlined text-primary" style={{ fontSize: 40 }}>campaign</span>
          <h1 className="text-[24px] font-bold text-text-primary">{t('nav.startFundraiser')}</h1>
          <p className="text-[14px] text-text-secondary">
            {t('onboard.subtitle')}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-lg bg-surface border border-border rounded-lg p-xl">
          <Input
            label={t('onboard.yourFullName')}
            id="fullName"
            required
            value={form.fullName}
            onChange={(e) => setForm({ ...form, fullName: e.target.value })}
          />

          <div className="flex flex-col gap-sm">
            <label htmlFor="purpose" className="text-[14px] font-medium text-text-primary">
              {t('onboard.purposeLabel')}
            </label>
            <textarea
              id="purpose"
              rows={3}
              placeholder={t('onboard.purposePlaceholder')}
              value={form.purpose}
              onChange={(e) => setForm({ ...form, purpose: e.target.value })}
              className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
            />
          </div>

          {error && <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>}

          <Button type="submit" disabled={submitting} className="w-full">
            {submitting ? t('team.sending') : t('onboard.sendCode')}
          </Button>
        </form>
      </div>
    </PageLayout>
  );
}
