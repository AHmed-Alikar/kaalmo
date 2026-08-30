import { useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { DONOR_NAV } from './nav';

const LANGUAGE_OPTIONS = [
  { code: 'so', flag: '🇸🇴', label: 'Soomaali' },
  { code: 'en', flag: '🇬🇧', label: 'English' },
];

export default function Settings() {
  const { user, refreshUser } = useAuth();
  const { language, setLanguage, t } = useLanguage();
  const [fullName, setFullName] = useState(user?.fullName || '');
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    setSaved(false);
    try {
      await api.patch('/users/me', { fullName });
      await refreshUser();
      setSaved(true);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('settings.saveError'));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <DashboardLayout title={t('donor.myAccount')} nav={DONOR_NAV}>
      <div className="flex flex-col gap-xl max-w-md">
        <h1 className="text-[24px] font-bold text-text-primary">{t('donor.settings')}</h1>

        <form onSubmit={handleSubmit} className="flex flex-col gap-lg bg-surface border border-border rounded-lg p-xl">
          <Input label={t('register.fullName')} id="fullName" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
          <Input label={t('login.email')} id="email" value={user?.email || ''} disabled />
          <Input label={t('register.phone')} id="phone" value={user?.phone || ''} disabled />

          {saved && <p className="text-[13px] text-success">{t('common.saved')}</p>}
          {error && <p className="text-[13px] text-error">{error}</p>}

          <Button type="submit" disabled={submitting} className="self-start">
            {submitting ? t('common.saving') : t('settings.saveChanges')}
          </Button>
        </form>

        <div className="flex flex-col gap-md bg-surface border border-border rounded-lg p-xl">
          <label className="text-[14px] font-medium text-text-primary">{t('settings.language')}</label>
          <div className="flex gap-sm">
            {LANGUAGE_OPTIONS.map((l) => (
              <button
                key={l.code}
                onClick={() => setLanguage(l.code)}
                className={`flex items-center gap-sm px-lg py-sm rounded border text-[14px] transition-colors ${
                  l.code === language ? 'border-primary text-primary bg-primary/5' : 'border-border text-text-secondary hover:border-primary/40'
                }`}
              >
                <span aria-hidden="true" style={{ fontSize: 16 }}>{l.flag}</span>
                {l.label}
              </button>
            ))}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
