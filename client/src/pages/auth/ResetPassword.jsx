import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

export default function ResetPassword() {
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [form, setForm] = useState({
    email: searchParams.get('email') || '',
    code: '',
    password: '',
    confirmPassword: '',
  });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [resent, setResent] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    if (form.password !== form.confirmPassword) {
      setError(t('resetPassword.mismatchError'));
      return;
    }

    setSubmitting(true);
    try {
      await api.post('/auth/reset-password', {
        email: form.email,
        code: form.code,
        password: form.password,
      });
      setSuccess(true);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('resetPassword.genericError'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleResend() {
    setResent(false);
    try {
      await api.post('/auth/forgot-password', { email: form.email });
      setResent(true);
    } catch {
      // Silent — same no-enumeration behavior as ForgotPassword.
    }
  }

  if (success) {
    return (
      <PageLayout noFooter>
        <div className="flex items-center justify-center px-xl py-4xl min-h-[80vh]">
          <div className="w-full max-w-[420px] bg-surface border border-border rounded-lg p-2xl flex flex-col items-center text-center gap-lg">
            <span className="material-symbols-outlined text-success" style={{ fontSize: 48 }}>check_circle</span>
            <p className="text-[15px] text-text-primary">{t('resetPassword.success')}</p>
            <Button onClick={() => navigate('/login')} className="w-full">{t('resetPassword.goToLogin')}</Button>
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
            <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('resetPassword.title')}</h1>
            <p className="text-[14px] text-text-secondary">{t('resetPassword.subtitle')}</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
            <Input
              label={t('resetPassword.email')}
              id="email"
              type="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
            />
            <Input
              label={t('resetPassword.code')}
              id="code"
              type="text"
              inputMode="numeric"
              maxLength={6}
              required
              value={form.code}
              onChange={(e) => setForm({ ...form, code: e.target.value.replace(/\D/g, '') })}
            />
            <Input
              label={t('resetPassword.newPassword')}
              id="password"
              type="password"
              required
              minLength={8}
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
            />
            <Input
              label={t('resetPassword.confirmPassword')}
              id="confirmPassword"
              type="password"
              required
              minLength={8}
              value={form.confirmPassword}
              onChange={(e) => setForm({ ...form, confirmPassword: e.target.value })}
            />

            {error && (
              <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>
            )}

            <Button type="submit" disabled={submitting || form.code.length !== 6} className="w-full">
              {submitting ? t('resetPassword.resetting') : t('resetPassword.resetPassword')}
            </Button>
          </form>

          {resent && <p className="text-[13px] text-success text-center mt-md">{t('checkEmail.resent')}</p>}

          <div className="flex items-center justify-between mt-xl text-[13px]">
            <button onClick={handleResend} className="text-primary hover:underline">
              {t('resetPassword.resendCode')}
            </button>
            <Link to="/login" className="text-text-secondary hover:underline">
              {t('forgotPassword.backToLogin')}
            </Link>
          </div>
        </div>
      </div>
    </PageLayout>
  );
}
