import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import PageLayout from '../../components/PageLayout';
import Button from '../../components/Button';
import StatusPill from '../../components/StatusPill';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';

export default function MyTickets() {
  const { t } = useLanguage();
  const [tickets, setTickets] = useState([]);
  const [status, setStatus] = useState('loading');
  const [openId, setOpenId] = useState(null);
  const [reply, setReply] = useState('');
  const [submitting, setSubmitting] = useState(false);

  function load() {
    api
      .get('/support-tickets/mine')
      .then(({ data }) => {
        setTickets(data);
        setStatus('ready');
      })
      .catch(() => setStatus('error'));
  }

  useEffect(load, []);

  async function handleReply(id) {
    if (!reply.trim()) return;
    setSubmitting(true);
    try {
      await api.post(`/support-tickets/mine/${id}/replies`, { message: reply });
      setReply('');
      load();
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageLayout>
      <div className="max-w-[640px] mx-auto px-xl py-3xl flex flex-col gap-xl">
        <div className="flex items-center justify-between">
          <h1 className="text-[24px] font-bold text-text-primary">{t('myTickets.title')}</h1>
          <Link to="/contact"><Button variant="secondary">{t('myTickets.newMessage')}</Button></Link>
        </div>

        {status === 'loading' && (
          <div className="flex flex-col gap-sm">{[1, 2].map((i) => <div key={i} className="h-20 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        )}

        {status === 'error' && (
          <EmptyState icon="wifi_off" title={t('myTickets.loadErrorTitle')} description={t('common.checkConnection')} />
        )}

        {status === 'ready' && tickets.length === 0 && (
          <EmptyState
            icon="support_agent"
            title={t('myTickets.emptyTitle')}
            description={t('myTickets.emptyDesc')}
            action={<Link to="/contact"><Button>{t('myTickets.contactSupport')}</Button></Link>}
          />
        )}

        {tickets.length > 0 && (
          <div className="flex flex-col gap-md">
            {tickets.map((ticket) => {
              const isOpen = openId === ticket._id;
              return (
                <div key={ticket._id} className="bg-surface border border-border rounded-lg overflow-hidden">
                  <button
                    onClick={() => setOpenId(isOpen ? null : ticket._id)}
                    className="w-full flex items-center justify-between gap-md p-lg text-left"
                  >
                    <div>
                      <p className="text-[14px] font-medium text-text-primary">{ticket.subject}</p>
                      <p className="text-[13px] text-text-secondary">
                        {ticket.replies.length} {ticket.replies.length === 1 ? t('myTickets.reply') : t('myTickets.replies')} · {t('myTickets.updated')}{' '}
                        {new Date(ticket.updatedAt).toLocaleDateString()}
                      </p>
                    </div>
                    <StatusPill status={ticket.status} />
                  </button>

                  {isOpen && (
                    <div className="border-t border-border p-lg flex flex-col gap-md bg-background">
                      <div className="flex flex-col gap-sm">
                        <p className="text-[13px] text-text-secondary font-medium">{t('myTickets.you')}</p>
                        <p className="text-[14px] text-text-primary">{ticket.message}</p>
                      </div>
                      {ticket.replies.map((r) => (
                        <div key={r._id} className="flex flex-col gap-sm pt-sm border-t border-border">
                          <p className="text-[13px] text-text-secondary font-medium">
                            {r.authorRole === 'admin' ? t('myTickets.kaalmoSupport') : t('myTickets.you')}
                          </p>
                          <p className="text-[14px] text-text-primary">{r.message}</p>
                        </div>
                      ))}

                      {ticket.status !== 'closed' && (
                        <div className="flex flex-col gap-sm pt-sm border-t border-border">
                          <textarea
                            rows={3}
                            value={reply}
                            onChange={(e) => setReply(e.target.value)}
                            placeholder={t('myTickets.replyPlaceholder')}
                            className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
                          />
                          <Button
                            className="self-end"
                            disabled={submitting || !reply.trim()}
                            onClick={() => handleReply(ticket._id)}
                          >
                            {submitting ? t('team.sending') : t('myTickets.sendReply')}
                          </Button>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </PageLayout>
  );
}
