import { useLanguage } from '../context/LanguageContext';

// Minimal reusable pager for the { items, total, page, limit } API shape.
// Renders nothing when there is only one page.
export default function Pagination({ page, limit, total, onPage }) {
  const { t } = useLanguage();
  const totalPages = Math.max(1, Math.ceil((total || 0) / (limit || 20)));
  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-between gap-md pt-md text-[13px] text-text-secondary">
      <button
        type="button"
        disabled={page <= 1}
        onClick={() => onPage(page - 1)}
        className="h-[34px] px-md rounded border border-border disabled:opacity-40 hover:border-primary/60"
      >
        {t('pagination.prev')}
      </button>
      <span>{t('pagination.pageOf').replace('{page}', page).replace('{total}', totalPages)}</span>
      <button
        type="button"
        disabled={page >= totalPages}
        onClick={() => onPage(page + 1)}
        className="h-[34px] px-md rounded border border-border disabled:opacity-40 hover:border-primary/60"
      >
        {t('pagination.next')}
      </button>
    </div>
  );
}
