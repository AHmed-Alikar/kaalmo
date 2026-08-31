import Notification from '../models/Notification.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';

export const listMyNotifications = asyncHandler(async (req, res) => {
  const notifications = await Notification.find({ userId: req.user.id }).sort({ createdAt: -1 }).limit(50);
  const unreadCount = await Notification.countDocuments({ userId: req.user.id, read: false });
  res.json({ items: notifications, unreadCount });
});

export const markNotificationRead = asyncHandler(async (req, res) => {
  const notification = await Notification.findOne({ _id: req.params.id, userId: req.user.id });
  if (!notification) throw new ApiError(404, 'NOT_FOUND', 'Notification not found');
  notification.read = true;
  await notification.save();
  res.json(notification);
});

export const markAllNotificationsRead = asyncHandler(async (req, res) => {
  await Notification.updateMany({ userId: req.user.id, read: false }, { read: true });
  res.json({ updated: true });
});
