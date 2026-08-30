import { useEffect, useState } from 'react';
import DashboardLayout from '../../components/DashboardLayout';
import StatusPill from '../../components/StatusPill';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import api from '../../api/client';
import { useLanguage } from '../../context/LanguageContext';
import { ADMIN_NAV } from './nav';

const STATUSES = ['open', 'in_progress', 'resolved', 'closed'];
const STATUS_LABELS_SO = { open: 'Furan', in_progress: 'Socda', resolved: 'La xaliyay', closed: 'Xiran' };

export default function SupportTickets() {
  const { t: translate, language } = useLanguage();
  const statusLabel = (s) => (language === 'so' ? STATUS_LABELS_SO[s] : s.replace('_', ' '));
  const [filter, setFilter] = useState('open');
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [openId, setOpenId] = useState(null);
  const [reply, setReply] = useState('');
  const [submitting, setSubmitting] = useState(false);

  function load() {
    setLoading(true);
    api
      .get('/admin/support-tickets', { params: { status: filter, limit: 100 } })
      .then(({ data }) => setTickets(data.items))
      .finally(() => setLoading(false));
  }

  useEffect(load, [filter]);

  async function handleReply(id) {
    if (!reply.trim()) return;
    setSubmitting(true);
    try {
      await api.post(`/admin/support-tickets/${id}/replies`, { message: reply });
      setReply('');
      load();
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStatusChange(id, status) {
    await api.patch(`/admin/support-tickets/${id}`, { status });
    load();
  }

  return (
    <DashboardLayout title={translate('adminNav.overview')} nav={ADMIN_NAV}>
      <div className="flex flex-col gap-xl">
        <div className="flex items-center justify-between flex-wrap gap-md">
          <h1 className="text-[24px] font-bold text-text-primary">{translate('adminNav.supportTickets')}</h1>
          <div className="flex gap-xs flex-wrap">
            {STATUSES.map((s) => (
              <button
                key={s}
                onClick={() => setFilter(s)}
                className={`px-md py-xs rounded text-[13px] border capitalize transition-colors ${
                  filter === s ? 'bg-primary/10 text-primary border-primary' : 'border-border text-text-secondary hover:border-primary/40'
                }`}
              >
                {statusLabel(s)}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="flex flex-col gap-sm">{[1, 2, 3].map((i) => <div key={i} className="h-16 bg-surface border border-border rounded-lg animate-pulse" />)}</div>
        ) : tickets.length === 0 ? (
          <EmptyState
            icon="support_agent"
            title={`${translate('adminSupport.noTicketsPrefix')} ${statusLabel(filter)}`}
            description={translate('adminSupport.emptyDesc')}
          />
        ) : (
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
                        {translate('adminSupport.from')} {ticket.userId?.fullName || ticket.guestName || translate('adminSupport.unknown')} ({ticket.userId?.email || ticket.guestEmail || translate('adminSupport.noEmail')})
                      </p>
                    </div>
                    <StatusPill status={ticket.status} />
                  </button>

                  {isOpen && (
                    <div className="border-t border-border p-lg flex flex-col gap-md bg-background">
                      <div className="flex flex-col gap-sm">
                        <p className="text-[13px] text-text-secondary font-medium">
                          {ticket.userId?.fullName || ticket.guestName || translate('adminSupport.unknown')}
                        </p>
                        <p className="text-[14px] text-text-primary">{ticket.message}</p>
                      </div>
                      {ticket.replies.map((r) => (
                        <div key={r._id} className="flex flex-col gap-sm pt-sm border-t border-border">
                          <p className="text-[13px] text-text-secondary font-medium">
                            {r.authorRole === 'admin' ? translate('adminSupport.supportYou') : ticket.userId?.fullName || ticket.guestName || translate('adminSupport.userLabel')}
                          </p>
                          <p className="text-[14px] text-text-primary">{r.message}</p>
                        </div>
                      ))}

                      <div className="flex flex-col gap-sm pt-sm border-t border-border">
                        <textarea
                          rows={3}
                          value={reply}
                          onChange={(e) => setReply(e.target.value)}
                          placeholder={translate('myTickets.replyPlaceholder')}
                          className="w-full px-lg py-md rounded border border-border bg-surface text-text-primary outline-none focus:border-2 focus:border-primary transition-colors"
                        />
                        <div className="flex items-center justify-between">
                          <div className="flex gap-xs">
                            {STATUSES.filter((s) => s !== ticket.status).map((s) => (
                              <Button
                                key={s}
                                variant="secondary"
                                className="h-[32px] px-md text-[12px] capitalize"
                                onClick={() => handleStatusChange(ticket._id, s)}
                              >
                                {translate('adminSupport.markPrefix')} {statusLabel(s)}
                              </Button>
                            ))}
                          </div>
                          <Button disabled={submitting || !reply.trim()} onClick={() => handleReply(ticket._id)}>
                            {submitting ? translate('team.sending') : translate('myTickets.sendReply')}
                          </Button>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
