import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';

export default function Register() {
  const { register } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('redirect') || '';
  const [form, setForm] = useState({
    fullName: '',
    email: searchParams.get('email') || '',
    phone: '',
    password: '',
  });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await register(form);
      navigate(`/check-email${redirect ? `?redirect=${encodeURIComponent(redirect)}` : ''}`);
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageLayout noFooter>
      <div className="flex items-center justify-center px-xl py-4xl min-h-[80vh]">
        <div className="w-full max-w-[440px] bg-surface border border-border rounded-lg p-2xl">
          <div className="text-center mb-xl">
            <h1 className="text-[24px] font-bold text-text-primary mb-xs">{t('register.title')}</h1>
            <p className="text-[14px] text-text-secondary">{t('register.subtitle')}</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
            <Input
              label={t('register.fullName')}
              id="fullName"
              required
              value={form.fullName}
              onChange={(e) => setForm({ ...form, fullName: e.target.value })}
            />
            <Input
              label={t('login.email')}
              id="email"
              type="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
            />
            <Input
              label={t('register.phone')}
              id="phone"
              type="tel"
              placeholder="+252 6XX XXX XXX"
              required
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
            />
            <Input
              label={t('login.password')}
              id="password"
              type="password"
              required
              minLength={8}
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
            />

            {error && (
              <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>
            )}

            <Button type="submit" disabled={submitting} className="w-full">
              {submitting ? t('register.creating') : t('register.createAccount')}
            </Button>
          </form>

          <p className="text-center text-[13px] text-text-secondary mt-xl">
            {t('register.haveAccount')}{' '}
            <Link to="/login" className="text-primary hover:underline">{t('login.logIn')}</Link>
          </p>
        </div>
      </div>
    </PageLayout>
  );
}
