import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AlertCategory { emergency, fall, health, device }

class AlertNotification {
  AlertNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String message;
  final String time;
  final AlertCategory category;
  bool isRead;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<AlertNotification> _notifications = [
    AlertNotification(
      id: 1,
      title: 'Emergency Alert',
      message:
          'An emergency SOS alert was triggered. Please check the user status.',
      time: '2 min ago',
      category: AlertCategory.emergency,
    ),
    AlertNotification(
      id: 2,
      title: 'Fall Detection Alert',
      message: 'A possible fall event was detected by the wearable device.',
      time: '15 min ago',
      category: AlertCategory.fall,
    ),
    AlertNotification(
      id: 3,
      title: 'Health Monitoring Alert',
      message:
          'A sample health reading has crossed the configured demo threshold.',
      time: '1 hour ago',
      category: AlertCategory.health,
      isRead: true,
    ),
    AlertNotification(
      id: 4,
      title: 'Device Disconnected',
      message: 'The wearable device connection was interrupted in demo mode.',
      time: 'Today',
      category: AlertCategory.device,
    ),
    AlertNotification(
      id: 5,
      title: 'Health Monitoring Active',
      message: 'Your health monitoring module is enabled in the demo system.',
      time: 'Yesterday',
      category: AlertCategory.health,
      isRead: true,
    ),
  ];

  List<AlertNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((item) => !item.isRead).toList();

      case 'Emergency':
        return _notifications
            .where(
              (item) =>
                  item.category == AlertCategory.emergency ||
                  item.category == AlertCategory.fall,
            )
            .toList();

      case 'Health':
        return _notifications
            .where((item) => item.category == AlertCategory.health)
            .toList();

      default:
        return _notifications;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearHistory() async {
    if (_notifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear notification history?'),
        content: const Text(
          'This will remove all notifications from this demo screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification history cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openNotification(AlertNotification notification) {
    setState(() {
      notification.isRead = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _categoryIcon(notification.category, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 7),
                Text(
                  notification.time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(AlertCategory category) {
    switch (category) {
      case AlertCategory.emergency:
      case AlertCategory.fall:
        return AppColors.danger;

      case AlertCategory.health:
        return AppColors.warning;

      case AlertCategory.device:
        return AppColors.primary;
    }
  }

  IconData _categoryIconData(AlertCategory category) {
    switch (category) {
      case AlertCategory.emergency:
        return Icons.sos;

      case AlertCategory.fall:
        return Icons.personal_injury_outlined;

      case AlertCategory.health:
        return Icons.favorite_outline;

      case AlertCategory.device:
        return Icons.watch_outlined;
    }
  }

  Widget _categoryIcon(AlertCategory category, {double size = 44}) {
    final color = _categoryColor(category);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(_categoryIconData(category), color: color, size: size * 0.52),
    );
  }

  Widget _buildFilter(String label) {
    final selected = _selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      onSelected: (_) {
        setState(() => _selectedFilter = label);
      },
    );
  }

  Widget _buildNotificationCard(AlertNotification notification) {
    final color = _categoryColor(notification.category);

    return InkWell(
      onTap: () => _openNotification(notification),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoryIcon(notification.category),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: color),
                      const SizedBox(width: 5),
                      Text(
                        notification.time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        notification.isRead ? 'Read' : 'Unread',
                        style: TextStyle(
                          color: notification.isRead
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read') _markAllAsRead();
              if (value == 'clear') _clearHistory();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'read', child: Text('Mark all as read')),
              PopupMenuItem(value: 'clear', child: Text('Clear history')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Notification Centre header card removed.
            SizedBox(
              height: 55,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilter('All'),
                  const SizedBox(width: 8),
                  _buildFilter('Unread'),
                  const SizedBox(width: 8),
                  _buildFilter('Emergency'),
                  const SizedBox(width: 8),
                  _buildFilter('Health'),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 58,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.55,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No notifications found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'You are all caught up!',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filtered.length} items',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        ...filtered.map(_buildNotificationCard),
                      ],
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              color: AppColors.surface,
              child: const Text(
                'Demo notifications · Real device alerts will be connected later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
