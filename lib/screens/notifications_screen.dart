import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../data/models/app_notification.dart';
import '../logic/app_state.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _markRead(BuildContext context, AppNotification item) {
    HapticFeedback.selectionClick();
    context.read<AppState>().markNotificationRead(item.id);
    Fluttertoast.showToast(msg: 'تمت قراءة الإشعار');
  }

  void _markAllRead(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<AppState>().markAllNotificationsRead();
    Fluttertoast.showToast(msg: 'تم تعليم الكل كمقروء');
  }

  void _clearAll(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<AppState>().clearNotifications();
    Fluttertoast.showToast(msg: 'تم مسح جميع الإشعارات');
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().notifications;
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'الإشعارات',
        actions: [
          TextButton(
            onPressed: items.isEmpty ? null : () => _markAllRead(context),
            child: const Text('قراءة الكل'),
          ),
          TextButton(
            onPressed: items.isEmpty ? null : () => _clearAll(context),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: items.isEmpty
            ? const Center(child: Text('لا توجد إشعارات'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _NotificationCard(
                    item: item,
                    onTap: () => _markRead(context, item),
                    onRead: () => _markRead(context, item),
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;
  final VoidCallback onRead;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.isRead
      ? Colors.white10
      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(
                  item.isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                                ),
                          ),
                        ),
                        Text(item.time, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.message),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: item.isRead ? null : onRead,
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('تمت القراءة'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
