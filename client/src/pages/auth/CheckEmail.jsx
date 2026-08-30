import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Button from '../../components/Button';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';

// Email verification is code-based, not link-based: the user stays on this
// page, enters the 6-digit code we emailed them, and unlocks the app
// immediately — no separate page for clicking a link.
export default function CheckEmail() {
  const { logout, refreshUser } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('redirect') || '/';
  const [code, setCode] = useState('');
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [resent, setResent] = useState(false);
  const [resendError, setResendError] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await api.post('/auth/verify-email-otp', { code });
      await refreshUser();
      navigate(redirect);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('checkEmail.verifyError'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleResend() {
    setResendError(null);
    setResent(false);
    try {
      await api.post('/auth/resend-verification-email');
      setResent(true);
    } catch (err) {
      setResendError(err.response?.data?.error?.message || t('checkEmail.resendError'));
    }
  }

  function handleLogout() {
    logout();
    navigate('/');
  }

  return (
    <PageLayout noFooter minimalNav>
      <div className="max-w-[440px] mx-auto px-xl py-4xl flex flex-col items-center gap-lg">
        <span className="material-symbols-outlined text-primary" style={{ fontSize: 48 }}>mark_email_unread</span>
        <div className="text-center">
          <h1 className="text-[22px] font-bold text-text-primary">{t('checkEmail.title')}</h1>
          <p className="text-[14px] text-text-secondary mt-xs">
            {t('checkEmail.subtitle')}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="w-full flex flex-col gap-lg">
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

          {error && <p className="text-[13px] text-error text-center">{error}</p>}

          <Button type="submit" disabled={submitting || code.length !== 6} className="w-full">
            {submitting ? t('checkEmail.verifying') : t('checkEmail.verifyEmail')}
          </Button>
        </form>

        {resent && <p className="text-[13px] text-success">{t('checkEmail.resent')}</p>}
        {resendError && <p className="text-[13px] text-error">{resendError}</p>}

        <button onClick={handleResend} className="text-[13px] text-primary hover:underline">
          {t('checkEmail.didntGetCode')}
        </button>

        <div className="pt-md flex flex-col items-center gap-md border-t border-border w-full">
          <Link to="/explore" className="pt-md"><Button variant="secondary">{t('checkEmail.browseWithoutAccount')}</Button></Link>
          <button onClick={handleLogout} className="text-[13px] text-text-secondary hover:text-error transition-colors">
            {t('nav.logout')}
          </button>
        </div>
      </div>
    </PageLayout>
  );
}
