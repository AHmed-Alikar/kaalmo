import PageLayout from '../../components/PageLayout';
import { useLanguage } from '../../context/LanguageContext';

export function Terms() {
  const { t } = useLanguage();
  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl max-w-2xl flex flex-col gap-md">
        <h1 className="text-[32px] font-bold text-text-primary">{t('legal.termsTitle')}</h1>
        <p className="text-[14px] text-text-secondary">
          {t('legal.termsText')}
        </p>
      </div>
    </PageLayout>
  );
}

export function Privacy() {
  const { t } = useLanguage();
  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl max-w-2xl flex flex-col gap-md">
        <h1 className="text-[32px] font-bold text-text-primary">{t('legal.privacyTitle')}</h1>
        <p className="text-[14px] text-text-secondary">
          {t('legal.privacyText')}
        </p>
      </div>
    </PageLayout>
  );
}
