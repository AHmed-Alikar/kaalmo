import { useLanguage } from '../context/LanguageContext';

// Status must never be communicated by color alone (Design_Rules.md Rule 39) —
// each status always renders with its label text, color is a secondary cue.
const STATUS_STYLES = {
  draft: 'bg-background text-text-secondary border-border',
  submitted: 'bg-info/10 text-info border-info/30',
  under_review: 'bg-info/10 text-info border-info/30',
  approved: 'bg-success/10 text-success border-success/30',
  published: 'bg-success/10 text-success border-success/30',
  active: 'bg-success/10 text-success border-success/30',
  goal_reached: 'bg-accent/10 text-accent border-accent/30',
  withdrawal: 'bg-info/10 text-info border-info/30',
  completed: 'bg-success/10 text-success border-success/30',
  rejected: 'bg-error/10 text-error border-error/30',
  suspended: 'bg-warning/10 text-warning border-warning/30',
  frozen: 'bg-warning/10 text-warning border-warning/30',
  cancelled: 'bg-background text-text-secondary border-border',
  expired: 'bg-background text-text-secondary border-border',
  pending: 'bg-warning/10 text-warning border-warning/30',
  confirmed: 'bg-success/10 text-success border-success/30',
  failed: 'bg-error/10 text-error border-error/30',
  refunded: 'bg-info/10 text-info border-info/30',
  processing: 'bg-info/10 text-info border-info/30',
  open: 'bg-warning/10 text-warning border-warning/30',
  in_progress: 'bg-info/10 text-info border-info/30',
  resolved: 'bg-success/10 text-success border-success/30',
  closed: 'bg-background text-text-secondary border-border',
  reviewed: 'bg-success/10 text-success border-success/30',
  dismissed: 'bg-background text-text-secondary border-border',
  verified: 'bg-success/10 text-success border-success/30',
  accepted: 'bg-success/10 text-success border-success/30',
  banned: 'bg-error/10 text-error border-error/30',
};

// Somali labels for every status a StatusPill can render anywhere in the
// app — centralizing this here means every table/card/badge that already
// uses StatusPill gets translated automatically, without touching each page.
const STATUS_LABELS_SO = {
  draft: 'Qabyo',
  submitted: 'La gudbiyay',
  under_review: 'La eegayaa',
  approved: 'La ansixiyay',
  published: 'La daabacay',
  active: 'Firfircoon',
  goal_reached: 'Hadafka la gaadhay',
  withdrawal: 'Lacag-ka bixin',
  completed: 'Dhammaaday',
  rejected: 'La diiday',
  suspended: 'La joojiyay',
  frozen: 'La qaboojiyay',
  cancelled: 'La baabi\'iyay',
  expired: 'Dhacay',
  pending: 'Sugaya',
  confirmed: 'La xaqiijiyay',
  failed: 'Fashilmay',
  refunded: 'Dib loo celiyay',
  processing: 'Waa la habeynayaa',
  open: 'Furan',
  in_progress: 'Socda',
  resolved: 'La xaliyay',
  closed: 'Xiran',
  reviewed: 'La eegay',
  dismissed: 'La diiday',
  verified: 'La xaqiijiyay',
  accepted: 'La aqbalay',
  banned: 'Waa la mamnuucay',
};

function toEnglishLabel(status) {
  return status.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

export default function StatusPill({ status }) {
  const { language } = useLanguage();
  const style = STATUS_STYLES[status] || 'bg-background text-text-secondary border-border';
  const label = language === 'so' && STATUS_LABELS_SO[status] ? STATUS_LABELS_SO[status] : toEnglishLabel(status);
  return (
    <span className={`inline-flex items-center px-md py-xs rounded-sm border text-[13px] font-medium ${style}`}>
      {label}
    </span>
  );
}
