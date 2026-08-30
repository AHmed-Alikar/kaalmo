import { useState } from 'react';
import PageLayout from '../../components/PageLayout';
import Input from '../../components/Input';
import Button from '../../components/Button';
import api from '../../api/client';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';

export default function Contact() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const [form, setForm] = useState({ name: '', email: '', subject: '', message: '' });
  const [sent, setSent] = useState(false);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await api.post('/support-tickets', {
        subject: form.subject || 'Message from Contact page',
        message: form.message,
        guestName: user ? undefined : form.name,
        guestEmail: user ? undefined : form.email,
      });
      setSent(true);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('contact.errorFallback'));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl max-w-xl">
        <h1 className="text-[32px] font-bold text-text-primary mb-sm">{t('contact.title')}</h1>
        <p className="text-[15px] text-text-secondary mb-2xl">
          {t('contact.subtitle')}
        </p>

        {sent ? (
          <div className="bg-success/10 border border-success/30 rounded-lg p-xl flex items-center gap-md">
            <span className="material-symbols-outlined text-success">check_circle</span>
            <div>
              <p className="text-[15px] font-medium text-text-primary">{t('contact.sentTitle')}</p>
              <p className="text-[13px] text-text-secondary">
                {user ? t('contact.sentTextUser') : t('contact.sentTextGuest')}
              </p>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="flex flex-col gap-lg">
            {!user && (
              <>
                <Input
                  label={t('contact.name')}
                  id="name"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                />
                <Input
                  label={t('contact.email')}
                  id="email"
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                />
              </>
            )}
            <Input
              label={t('contact.subject')}
              id="subject"
              required
              value={form.subject}
              onChange={(e) => setForm({ ...form, subject: e.target.value })}
            />
            <div className="flex flex-col gap-sm">
              <label htmlFor="message" className="text-[14px] font-medium text-text-primary">
                {t('contact.howCanWeHelp')}
              </label>
              <textarea
                id="message"
                rows={5}
                required
                value={form.message}
                onChange={(e) => setForm({ ...form, message: e.target.value })}
                className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
              />
            </div>
            {error && <p className="text-[13px] text-error bg-error/10 border border-error/30 rounded p-md">{error}</p>}
            <Button type="submit" disabled={submitting} className="self-start">
              {submitting ? t('contact.sending') : t('contact.sendMessage')}
            </Button>
          </form>
        )}
      </div>
    </PageLayout>
  );
}
