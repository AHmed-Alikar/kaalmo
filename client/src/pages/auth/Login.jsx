import { useState } from 'react';
import { Link, useNavigate, useLocation, useSearchParams } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';

export default function Login() {
  const { login } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const location = useLocation();
  const [searchParams] = useSearchParams();
  const redirectTo = location.state?.from || searchParams.get('redirect') || '/';
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const loggedInUser = await login(form);
      if (!loggedInUser.emailVerified) {
        navigate(`/check-email?redirect=${encodeURIComponent(redirectTo)}`);
        return;
      }
      navigate(redirectTo);
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageLayout noFooter>
      <div className="flex items-center justify-center px-xl py-4xl min-h-[80vh]">
        <div className="w-full max-w-[420px] bg-surface border border-border rounded-lg p-2xl">
          <div className="text-center mb-xl">
            <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('login.welcomeBack')}</h1>
            <p className="text-[14px] text-text-secondary">{t('login.subtitle')}</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
            <Input
              label={t('login.email')}
              id="email"
              type="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
            />
            <Input
              label={t('login.password')}
              id="password"
              type="password"
              required
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
            />

            {error && (
              <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>
            )}

            <Button type="submit" disabled={submitting} className="w-full">
              {submitting ? t('login.loggingIn') : t('login.logIn')}
            </Button>
          </form>

          <p className="text-center text-[13px] text-text-secondary mt-xl">
            {t('login.noAccount')}{' '}
            <Link to="/register" className="text-primary hover:underline">{t('login.createOne')}</Link>
          </p>
        </div>
      </div>
    </PageLayout>
  );
}
