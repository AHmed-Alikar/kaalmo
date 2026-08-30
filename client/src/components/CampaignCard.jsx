import { Link } from 'react-router-dom';
import ProgressBar from './ProgressBar';
import VerificationBadge from './VerificationBadge';
import { useLanguage } from '../context/LanguageContext';
import { categoryLabel, regionLabel } from '../i18n/translations';

// Campaign card content follows Design_Rules.md Rule 21 — image, category,
// title, organizer, verification, raised/goal, progress, donor count only.
export default function CampaignCard({ campaign }) {
  const { language, t } = useLanguage();
  // Bilingual campaign content shows in the viewer's chosen language first —
  // English was previously always preferred regardless of app language.
  const title = campaign.title?.[language] || campaign.title?.so || campaign.title?.en;

  return (
    <Link
      to={`/campaigns/${campaign._id}`}
      className="bg-surface rounded-lg border border-border overflow-hidden flex flex-col group hover:border-primary/40 transition-colors"
    >
      <div className="relative h-48 w-full overflow-hidden bg-background">
        {campaign.coverImageUrl ? (
          <img
            src={campaign.coverImageUrl}
            alt={title}
            className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-text-secondary">
            <span className="material-symbols-outlined" style={{ fontSize: 32 }}>
              image
            </span>
          </div>
        )}
        <span className="absolute top-sm right-sm bg-surface/95 border border-border px-sm py-xs rounded-sm text-[12px] font-medium text-primary">
          {categoryLabel(campaign.category, language)}
        </span>
      </div>
      <div className="p-lg flex flex-col flex-grow gap-sm">
        {campaign.verificationBadges?.length > 0 && (
          <div className="flex flex-wrap gap-xs">
            {campaign.verificationBadges.map((b) => (
              <VerificationBadge key={b} type={b} compact />
            ))}
          </div>
        )}
        <h3 className="text-[16px] font-semibold text-text-primary leading-snug group-hover:text-primary transition-colors">
          {title}
        </h3>
        <p className="text-[13px] text-text-secondary">{regionLabel(campaign.region, language)}</p>
        <div className="mt-auto pt-sm flex flex-col gap-xs">
          <ProgressBar raised={campaign.raisedAmount} goal={campaign.goalAmount} />
          {typeof campaign.donorCount === 'number' && (
            <p className="text-[12px] text-text-secondary">
              {campaign.donorCount} {campaign.donorCount === 1 ? t('card.supporter') : t('card.supporters')}
            </p>
          )}
        </div>
      </div>
    </Link>
  );
}
