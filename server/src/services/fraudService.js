import Donation from '../models/Donation.js';
import Campaign from '../models/Campaign.js';
import User from '../models/User.js';

// Real, rule-based signals computed live from current data — not a machine
// learning model (that's out of scope), but genuinely derived rather than
// fabricated. Each rule below is deliberately simple and explainable, since
// a false positive here can block a real donor/organizer (Design_Rules.md
// Rule 18 — verification/trust language must stay honest, not a black box).

// Signal 1: a campaign receiving an unusually high number of confirmed
// donations in a short window — could be legitimate virality, but worth a
// human look (e.g. wash donations to fake a track record).
async function donationVelocitySignals() {
  const since = new Date(Date.now() - 60 * 60 * 1000); // last hour
  const rows = await Donation.aggregate([
    { $match: { status: 'confirmed', createdAt: { $gte: since } } },
    { $group: { _id: '$campaignId', count: { $sum: 1 }, total: { $sum: '$amount' } } },
    { $match: { count: { $gte: 5 } } },
    { $sort: { count: -1 } },
    { $limit: 20 },
  ]);
  if (rows.length === 0) return [];

  const campaigns = await Campaign.find({ _id: { $in: rows.map((r) => r._id) } }).select('title');
  const titleById = Object.fromEntries(campaigns.map((c) => [String(c._id), c.title?.en || c.title?.so]));

  return rows.map((r) => ({
    id: `velocity-${r._id}`,
    subjectType: 'campaign',
    subjectId: r._id,
    subject: `Campaign — "${titleById[String(r._id)] || 'Unknown'}"`,
    signal: `${r.count} confirmed donations ($${r.total.toLocaleString()}) in the last hour`,
    score: r.count >= 15 ? 'HIGH' : r.count >= 8 ? 'MEDIUM' : 'LOW',
    detectedAt: new Date(),
  }));
}

// Signal 2: a very new account launching a high-goal campaign — a common
// pattern in fake-campaign scams (create account, immediately ask for a
// large sum, disappear).
async function newAccountHighGoalSignals() {
  const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000);
  const campaigns = await Campaign.find({
    goalAmount: { $gte: 2000 },
    status: { $nin: ['draft', 'rejected', 'cancelled'] },
  })
    .select('title goalAmount organizerId createdAt')
    .populate('organizerId', 'fullName email createdAt')
    .limit(200);

  return campaigns
    .filter((c) => c.organizerId && c.organizerId.createdAt >= cutoff && c.organizerId.createdAt <= c.createdAt)
    .map((c) => ({
      id: `new-account-${c._id}`,
      subjectType: 'campaign',
      subjectId: c._id,
      subject: `Campaign — "${c.title?.en || c.title?.so}"`,
      signal: `Organizer account created ${Math.round((c.createdAt - c.organizerId.createdAt) / (60 * 60 * 1000))}h before this $${c.goalAmount.toLocaleString()} goal campaign`,
      score: c.goalAmount >= 10000 ? 'HIGH' : 'MEDIUM',
      detectedAt: new Date(),
    }));
}

// Signal 3: the same donor repeatedly donating to the same campaign in a
// short window — could be a legitimate recurring supporter, but also a
// pattern used to artificially inflate a campaign's raised amount.
async function repeatDonorSignals() {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const rows = await Donation.aggregate([
    { $match: { status: 'confirmed', donorId: { $ne: null }, createdAt: { $gte: since } } },
    { $group: { _id: { campaignId: '$campaignId', donorId: '$donorId' }, count: { $sum: 1 }, total: { $sum: '$amount' } } },
    { $match: { count: { $gte: 4 } } },
    { $sort: { count: -1 } },
    { $limit: 20 },
  ]);
  if (rows.length === 0) return [];

  const [campaigns, users] = await Promise.all([
    Campaign.find({ _id: { $in: rows.map((r) => r._id.campaignId) } }).select('title'),
    User.find({ _id: { $in: rows.map((r) => r._id.donorId) } }).select('email fullName'),
  ]);
  const titleById = Object.fromEntries(campaigns.map((c) => [String(c._id), c.title?.en || c.title?.so]));
  const userById = Object.fromEntries(users.map((u) => [String(u._id), u.email]));

  return rows.map((r) => ({
    id: `repeat-donor-${r._id.campaignId}-${r._id.donorId}`,
    subjectType: 'user',
    subjectId: r._id.donorId,
    subject: `User — ${userById[String(r._id.donorId)] || 'Unknown'}`,
    signal: `${r.count} donations ($${r.total.toLocaleString()}) to the same campaign in 24h`,
    score: r.count >= 8 ? 'HIGH' : 'MEDIUM',
    detectedAt: new Date(),
  }));
}

export async function computeFraudSignals() {
  const [velocity, newAccount, repeatDonor] = await Promise.all([
    donationVelocitySignals(),
    newAccountHighGoalSignals(),
    repeatDonorSignals(),
  ]);

  const order = { HIGH: 0, MEDIUM: 1, LOW: 2 };
  return [...velocity, ...newAccount, ...repeatDonor].sort((a, b) => order[a.score] - order[b.score]);
}
