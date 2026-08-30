import { useLanguage } from '../context/LanguageContext';

export default function ProgressBar({ raised, goal, currency = 'USD' }) {
  const { t } = useLanguage();
  const pct = goal > 0 ? Math.min(100, Math.round((raised / goal) * 100)) : 0;

  return (
    <div className="flex flex-col gap-xs">
      <div className="flex justify-between items-baseline">
        <span className="text-[16px] font-bold text-text-primary">
          ${raised.toLocaleString()}
          <span className="text-[13px] font-normal text-text-secondary"> {t('progressBar.raisedOf')} ${goal.toLocaleString()}</span>
        </span>
        <span className="text-[13px] text-text-secondary">{pct}%</span>
      </div>
      <div className="w-full h-2 bg-border rounded-full overflow-hidden">
        <div className="h-full bg-accent rounded-full" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}
