import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../widgets/rento_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getNotifications();
      setState(() => _notifications = (res['data']?['notifications'] as List<dynamic>?) ?? []);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id) async {
    try {
      await _api.markNotificationRead(id);
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read'] = true;
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      if (mounted) {
        setState(() {
          for (var n in _notifications) {
            n['read'] = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark notifications as read')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => n['read'] == false))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: AppColors.accent)),
            ),
        ],
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) =>
                        _buildNotificationItem(_notifications[index]),
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    final bool isRead = notification['read'] ?? false;
    final String type = notification['type'] ?? 'info';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RentoCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: () {
            if (!isRead) _markRead(notification['id']);
            // Optional: Navigate based on type
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconBgColor(type),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(type), color: _getIconColor(type), size: 22),
          ),
          title: Text(
            notification['title'] ?? 'Notification',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
              color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['body'] ?? '',
                style: TextStyle(
                    fontSize: 13,
                    color: isRead
                        ? AppColors.textSecondary
                        : AppColors.textPrimary.withOpacity(0.8)),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(notification['createdAt']),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle))
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('No new notifications at the moment.',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'kyc':
        return Icons.verified_user_outlined;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return AppColors.success;
      case 'kyc':
        return AppColors.warning;
      case 'support':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getIconBgColor(String type) {
    return _getIconColor(type).withOpacity(0.1);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
