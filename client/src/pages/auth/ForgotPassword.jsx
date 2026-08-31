import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

// Always shows the same "check your email" confirmation regardless of
// whether the address is registered — the backend never reveals that
// (see authService.forgotPassword), so the UI must not either.
export default function ForgotPassword() {
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [sent, setSent] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    try {
      await api.post('/auth/forgot-password', { email });
    } catch {
      // Intentionally ignored — response never reveals account existence.
    } finally {
      setSubmitting(false);
      setSent(true);
    }
  }

  if (sent) {
    return (
      <PageLayout noFooter>
        <div className="flex items-center justify-center px-xl py-4xl min-h-[80vh]">
          <div className="w-full max-w-[420px] bg-surface border border-border rounded-lg p-2xl flex flex-col items-center text-center gap-lg">
            <span className="material-symbols-outlined text-primary" style={{ fontSize: 48 }}>mark_email_unread</span>
            <div>
              <h1 className="text-[22px] font-bold text-text-primary">{t('forgotPassword.checkEmailTitle')}</h1>
              <p className="text-[14px] text-text-secondary mt-xs">{t('forgotPassword.checkEmailSubtitle')}</p>
            </div>
            <Button onClick={() => navigate(`/reset-password?email=${encodeURIComponent(email)}`)} className="w-full">
              {t('forgotPassword.continueToReset')}
            </Button>
            <Link to="/login" className="text-[13px] text-primary hover:underline">
              {t('forgotPassword.backToLogin')}
            </Link>
          </div>
        </div>
      </PageLayout>
    );
  }

  return (
    <PageLayout noFooter>
      <div className="flex items-center justify-center px-xl py-4xl min-h-[80vh]">
        <div className="w-full max-w-[420px] bg-surface border border-border rounded-lg p-2xl">
          <div className="text-center mb-xl">
            <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('forgotPassword.title')}</h1>
            <p className="text-[14px] text-text-secondary">{t('forgotPassword.subtitle')}</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
            <Input
              label={t('forgotPassword.email')}
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />

            <Button type="submit" disabled={submitting} className="w-full">
              {submitting ? t('forgotPassword.sending') : t('forgotPassword.sendCode')}
            </Button>
          </form>

          <p className="text-center text-[13px] mt-xl">
            <Link to="/login" className="text-primary hover:underline">{t('forgotPassword.backToLogin')}</Link>
          </p>
        </div>
      </div>
    </PageLayout>
  );
}
