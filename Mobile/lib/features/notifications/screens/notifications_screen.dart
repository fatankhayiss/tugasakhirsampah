import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/repositories/notification_repository.dart';
import 'notification_detail_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationRepository();
  int _activeFilterIndex = 0; // 0 = Semua, 1 = Belum Dibaca

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepositoryChange);
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChange);
    super.dispose();
  }

  void _onRepositoryChange() {
    if (mounted) {
      setState(() {});
    }
  }

  List<NotificationModel> get _filteredNotifications {
    final list = _repository.getNotifications();
    if (_activeFilterIndex == 1) {
      return list.where((n) => !n.isRead).toList();
    }
    return list;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'pickup':
        return AppColors.secondary; // Eco green
      case 'reward':
        return const Color(0xFFEAB308); // Gold/amber reward
      case 'transfer':
        return AppColors.primaryBlue; // Fintech blue
      default:
        return AppColors.textSoft;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type) {
      case 'pickup':
        return AppColors.softGreen;
      case 'reward':
        return const Color(0xFFFEF9C3);
      case 'transfer':
        return AppColors.softBlue;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pickup':
        return LucideIcons.truck;
      case 'reward':
        return LucideIcons.sparkles;
      case 'transfer':
        return LucideIcons.wallet;
      default:
        return LucideIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _repository.unreadCount;
    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => _repository.markAllAsRead(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Tandai Semua',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Symmetrical Premium Segmented Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Soft gray surface
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilterIndex = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeFilterIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeFilterIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Semua',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _activeFilterIndex == 0 ? AppColors.secondary : AppColors.textSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilterIndex = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeFilterIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeFilterIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum Dibaca',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _activeFilterIndex == 1 ? AppColors.secondary : AppColors.textSoft,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120), // extra padding for bottom navigation
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.softGreen, // Subtle green background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bell_off,
                color: AppColors.secondary, // Eco green
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aktivitas terbaru Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSoft,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final typeColor = _getTypeColor(notification.type);
    final typeBg = _getTypeBgColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: notification.isRead ? 0.75 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : typeColor.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: notification.isRead ? 0.01 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Mark as read immediately on click
            _repository.markAsRead(notification.id);

            Navigator.push(
              context,
              CustomPageRoute(
                page: NotificationDetailScreen(notification: notification),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon block in circular container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Content text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            // Small red unread indicator dot
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: AppColors.textSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.time,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSoft,
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
        ),
      ),
    );
  }
}
