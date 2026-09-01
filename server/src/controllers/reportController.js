import Report from '../models/Report.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { logAudit } from '../services/auditLogService.js';

export const createReport = asyncHandler(async (req, res) => {
  const { targetType, targetId, reason } = req.body;
  const report = await Report.create({
    reporterId: req.user.id,
    targetType,
    targetId,
    reason,
  });
  res.status(201).json(report);
});

export const listReports = asyncHandler(async (req, res) => {
  const { status, targetType, page = 1, limit = 20 } = req.query;
  const filter = {};
  if (status) filter.status = status;
  if (targetType) filter.targetType = targetType;

  const skip = (Number(page) - 1) * Number(limit);
  const [items, total] = await Promise.all([
    Report.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit))
      .populate('reporterId', 'fullName email')
      .populate('reviewedBy', 'fullName'),
    Report.countDocuments(filter),
  ]);

  res.json({ items, total, page: Number(page), limit: Number(limit) });
});

// Small real counts for the admin Reports summary cards.
export const reportSummary = asyncHandler(async (req, res) => {
  const [byStatus, byType, byReason, recent] = await Promise.all([
    Report.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]),
    Report.aggregate([{ $group: { _id: '$targetType', count: { $sum: 1 } } }]),
    Report.aggregate([{ $group: { _id: '$reason', count: { $sum: 1 } } }, { $sort: { count: -1 } }, { $limit: 6 }]),
    Report.countDocuments({ createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } }),
  ]);

  const toMap = (rows) => Object.fromEntries(rows.map((r) => [r._id || 'unknown', r.count]));
  const statuses = toMap(byStatus);
  res.json({
    total: Object.values(statuses).reduce((a, b) => a + b, 0),
    open: statuses.open || 0,
    underReview: statuses.under_review || 0,
    resolved: (statuses.resolved || 0) + (statuses.reviewed || 0),
    dismissed: statuses.dismissed || 0,
    byTargetType: toMap(byType),
    byReason,
    recent7d: recent,
  });
});

export const reviewReport = asyncHandler(async (req, res) => {
  const { status, reviewNote } = req.body; // under_review | reviewed | resolved | dismissed
  const report = await Report.findById(req.params.id);
  if (!report) throw new ApiError(404, 'NOT_FOUND', 'Report not found');

  report.status = status;
  report.reviewedBy = req.user.id;
  report.reviewedAt = new Date();
  if (reviewNote) report.reviewNote = reviewNote;
  await report.save();

  await logAudit({
    actorId: req.user.id,
    action: `report.${status}`,
    targetType: 'Report',
    targetId: report._id,
    metadata: { targetType: report.targetType, targetId: report.targetId, reviewNote: reviewNote || undefined },
  });

  res.json(report);
});
