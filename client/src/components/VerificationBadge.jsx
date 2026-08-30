import { useLanguage } from '../context/LanguageContext';

const LABELS = {
  identity_verified: { icon: 'verified', so: 'Aqoonsi la xaqiijiyay', en: 'Identity Verified' },
  beneficiary_verified: { icon: 'gpp_good', so: 'Faa\'iidaystaha la xaqiijiyay', en: 'Beneficiary Verified' },
  payment_verified: { icon: 'payments', so: 'Lacag-bixin la xaqiijiyay', en: 'Payment Verified' },
  organization_verified: { icon: 'domain_verification', so: 'Hay\'ad la xaqiijiyay', en: 'Organization Verified' },
};

// Trust signals must stay visible, not decorative — never imply a guarantee
// that everything about a campaign is true (Design_Rules.md Rule 18).
export default function VerificationBadge({ type, compact = false }) {
  const { language } = useLanguage();
  const meta = LABELS[type];
  if (!meta) return null;

  return (
    <span
      className={`inline-flex items-center gap-xs bg-background border border-border rounded-sm text-text-secondary ${
        compact ? 'px-sm py-[2px] text-[12px]' : 'px-md py-xs text-[13px]'
      }`}
    >
      <span className="material-symbols-outlined text-success" style={{ fontSize: compact ? 14 : 16 }}>
        {meta.icon}
      </span>
      {meta[language] || meta.so}
    </span>
  );
}
