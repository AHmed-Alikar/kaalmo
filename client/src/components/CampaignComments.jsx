import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Button from './Button';
import Pagination from './Pagination';
import api from '../api/client';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';

const MAX = 1000;
const LIMIT = 10;

// Web campaign comments — reuses GET/POST /campaigns/:id/comments (the same
// API mobile uses). Guests can read; posting requires login.
export default function CampaignComments({ campaignId }) {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [state, setState] = useState('loading'); // loading | ready | error
  const [text, setText] = useState('');
  const [posting, setPosting] = useState(false);
  const [error, setError] = useState(null);

  function load(p = page) {
    setState('loading');
    api
      .get(`/campaigns/${campaignId}/comments`, { params: { page: p, limit: LIMIT } })
      .then(({ data }) => {
        setItems(data.items || []);
        setTotal(data.total || 0);
        setState('ready');
      })
      .catch(() => setState('error'));
  }

  useEffect(() => { load(page); /* eslint-disable-next-line */ }, [page, campaignId]);

  async function submit(e) {
    e.preventDefault();
    if (posting || !text.trim() || text.length > MAX) return;
    setPosting(true);
    setError(null);
    try {
      await api.post(`/campaigns/${campaignId}/comments`, { text: text.trim() });
      setText('');
      if (page === 1) load(1);
      else setPage(1);
    } catch (err) {
      setError(err.response?.data?.error?.message || t('comments.loadError'));
    } finally {
      setPosting(false);
    }
  }

  return (
    <div>
      <h2 className="text-[18px] font-semibold text-text-primary mb-md">{t('comments.title')}</h2>

      {user ? (
        <form onSubmit={submit} className="flex flex-col gap-sm mb-lg">
          <textarea
            rows={3}
            value={text}
            maxLength={MAX + 1}
            onChange={(e) => setText(e.target.value)}
            placeholder={t('comments.placeholder')}
            className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
          />
          {text.length > MAX && (
            <p className="text-[12px] text-error">{t('comments.tooLong').replace('{max}', MAX)}</p>
          )}
          {error && <p className="text-[12px] text-error">{error}</p>}
          <div className="flex justify-end">
            <Button type="submit" disabled={posting || !text.trim() || text.length > MAX}>
              {posting ? t('comments.posting') : t('comments.post')}
            </Button>
          </div>
        </form>
      ) : (
        <p className="text-[13px] text-text-secondary mb-lg">
          <Link to="/login" className="text-primary hover:underline">{t('comments.loginToPost')}</Link>
        </p>
      )}

      {state === 'loading' && (
        <div className="flex flex-col gap-sm">{[1, 2].map((i) => <div key={i} className="h-12 bg-surface border border-border rounded animate-pulse" />)}</div>
      )}
      {state === 'error' && (
        <p className="text-[13px] text-text-secondary">
          {t('comments.loadError')}{' '}
          <button onClick={() => load(page)} className="text-primary hover:underline">{t('common.retry')}</button>
        </p>
      )}
      {state === 'ready' && items.length === 0 && (
        <p className="text-[13px] text-text-secondary">{t('comments.empty')}</p>
      )}
      {state === 'ready' && items.length > 0 && (
        <div className="flex flex-col gap-md">
          {items.map((c) => (
            <div key={c._id} className="border-l-2 border-border pl-lg">
              <p className="text-[13px] text-text-secondary mb-xs">
                {c.userId?.fullName || t('comments.anonymous')}
                {c.createdAt ? ` · ${new Date(c.createdAt).toLocaleDateString()}` : ''}
              </p>
              <p className="text-[14px] text-text-primary whitespace-pre-wrap">{c.text}</p>
            </div>
          ))}
        </div>
      )}

      <Pagination page={page} limit={LIMIT} total={total} onPage={setPage} />
    </div>
  );
}
