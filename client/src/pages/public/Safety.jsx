import PageLayout from '../../components/PageLayout';
import VerificationBadge from '../../components/VerificationBadge';
import { useLanguage } from '../../context/LanguageContext';

const BADGES = ['identity_verified', 'beneficiary_verified', 'payment_verified', 'organization_verified'];

export default function Safety() {
  const { t } = useLanguage();
  return (
    <PageLayout>
      <div className="max-w-container mx-auto px-xl py-3xl flex flex-col gap-3xl max-w-3xl">
        <div>
          <h1 className="text-[32px] font-bold text-text-primary mb-sm">{t('safety.title')}</h1>
          <p className="text-[15px] text-text-secondary">
            {t('safety.subtitle')}
          </p>
        </div>

        <div className="flex flex-col gap-lg">
          <h2 className="text-[20px] font-semibold text-text-primary">{t('safety.badgesTitle')}</h2>
          <div className="flex flex-wrap gap-md">
            {BADGES.map((b) => (
              <VerificationBadge key={b} type={b} />
            ))}
          </div>
          {/* Honest language required by Design_Rules.md Rule 18 — never imply a
              guarantee about the campaign as a whole. */}
          <p className="text-[14px] text-text-secondary bg-background border border-border rounded-lg p-lg">
            {t('safety.badgesNote')}
          </p>
        </div>

        <div className="flex flex-col gap-md">
          <h2 className="text-[20px] font-semibold text-text-primary">{t('safety.reviewTitle')}</h2>
          <p className="text-[14px] text-text-secondary">
            {t('safety.reviewText')}
          </p>
        </div>

        <div className="flex flex-col gap-md">
          <h2 className="text-[20px] font-semibold text-text-primary">{t('safety.reportTitle')}</h2>
          <p className="text-[14px] text-text-secondary">
            {t('safety.reportText')}
          </p>
        </div>
      </div>
    </PageLayout>
  );
}
