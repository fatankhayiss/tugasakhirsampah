import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/repositories/notification_repository.dart';
import 'notification_detail_screen.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../shared/widgets/staggered_animation.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationRepository();
  int _activeFilterIndex = 0; // 0 = Semua, 1 = Belum Dibaca
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepositoryChange);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _repository.fetchNotifications();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        _showErrorDialog(_errorMessage!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Terjadi Kesalahan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontFamily: 'Plus Jakarta Sans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppColors.textSoft)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChange);
    super.dispose();
  }

  void _onRepositoryChange() {
    if (mounted && !_isLoading) {
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

  List<dynamic> get _groupedNotificationItems {
    final list = _filteredNotifications;
    final List<dynamic> items = [];
    bool hasToday = false;
    bool hasYesterday = false;
    bool hasOlder = false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final n in list) {
      String group = 'Sebelumnya';
      if (n.createdAt != null) {
        final date = DateTime(n.createdAt!.year, n.createdAt!.month, n.createdAt!.day);
        if (date == today) {
          group = 'Hari Ini';
        } else if (date == yesterday) {
          group = 'Kemarin';
        }
      }

      if (group == 'Hari Ini' && !hasToday) {
        items.add('Hari Ini');
        hasToday = true;
      } else if (group == 'Kemarin' && !hasYesterday) {
        items.add('Kemarin');
        hasYesterday = true;
      } else if (group == 'Sebelumnya' && !hasOlder) {
        items.add('Sebelumnya');
        hasOlder = true;
      }
      items.add(n);
    }
    return items;
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD97706); // Kuning/amber
      case 'accepted':
        return AppColors.primaryBlue; // Biru primary
      case 'on_the_way':
        return const Color(0xFF4F46E5); // Ungu/indigo
      case 'picked_up':
      case 'pickup':
        return const Color(0xFF0D9488); // Teal eco green
      case 'validating':
        return const Color(0xFFEA580C); // Oranye
      case 'completed':
      case 'reward':
        return const Color(0xFF16A34A); // Hijau selesai
      case 'transfer':
      case 'tukar_poin':
        return AppColors.primaryBlue; // Fintech blue
      default:
        return AppColors.primaryBlue;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF9C3);
      case 'accepted':
        return const Color(0xFFDBEAFE);
      case 'on_the_way':
        return const Color(0xFFE0E7FF);
      case 'picked_up':
      case 'pickup':
        return const Color(0xFFCCFBF1);
      case 'validating':
        return const Color(0xFFFFEDD5);
      case 'completed':
      case 'reward':
        return const Color(0xFFDCFCE7);
      case 'transfer':
      case 'tukar_poin':
        return AppColors.softBlue;
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pending':
        return LucideIcons.clock;
      case 'accepted':
        return LucideIcons.user_check;
      case 'on_the_way':
        return LucideIcons.navigation;
      case 'picked_up':
      case 'pickup':
        return LucideIcons.package_check;
      case 'validating':
        return LucideIcons.scale;
      case 'completed':
      case 'reward':
        return LucideIcons.sparkles;
      case 'transfer':
      case 'tukar_poin':
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
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Notifikasi',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: TextButton(
                        onPressed: () => _repository.markAllAsRead(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          'Tandai Semua',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Symmetrical Premium Segmented Filter matching Edukasi and Order
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ScaleTap(
                      onTap: () => setState(() => _activeFilterIndex = 0),
                      scaleDown: 0.96,
                      duration: const Duration(milliseconds: 160),
                      executeOnTap: true,
                      child: GestureDetector(
                        onTap: () => setState(() => _activeFilterIndex = 0),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _activeFilterIndex == 0 ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: _activeFilterIndex == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Text(
                              'Semua',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: _activeFilterIndex == 0 ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13.5,
                                color: _activeFilterIndex == 0 ? Colors.white : AppColors.textSoft,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ScaleTap(
                    onTap: () => setState(() => _activeFilterIndex = 1),
                    scaleDown: 0.96,
                    duration: const Duration(milliseconds: 160),
                    executeOnTap: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilterIndex = 1),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _activeFilterIndex == 1 ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: _activeFilterIndex == 1
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.22),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum Dibaca',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: _activeFilterIndex == 1 ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13.5,
                                color: _activeFilterIndex == 1 ? Colors.white : AppColors.textSoft,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _activeFilterIndex == 1 ? Colors.white : const Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    color: _activeFilterIndex == 1 ? AppColors.primary : Colors.white,
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
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120, top: 16),
                    itemCount: 6,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerSkeleton(width: 48, height: 48, borderRadius: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ShimmerSkeleton(width: double.infinity, height: 16, borderRadius: 4),
                                const SizedBox(height: 6),
                                const ShimmerSkeleton(width: 150, height: 14, borderRadius: 4),
                                const SizedBox(height: 10),
                                const ShimmerSkeleton(width: 80, height: 12, borderRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.primary,
                    child: notifications.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 100),
                            children: [_buildEmptyState()],
                          )
                        : Builder(
                            builder: (context) {
                              final grouped = _groupedNotificationItems;
                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 120), // extra padding for bottom navigation
                                itemCount: grouped.length,
                                itemBuilder: (context, index) {
                                  final item = grouped[index];
                                  if (item is String) {
                                    return _buildGroupHeader(item);
                                  }
                                  return _buildNotificationItem(item as NotificationModel, index);
                                },
                              );
                            },
                          ),
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

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    final typeColor = _getTypeColor(notification.type);
    final typeBg = _getTypeBgColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return StaggeredCardAnimation(
      index: index,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: notification.isRead ? 0.75 : 1.0,
        child: ScaleTap(
          enableHaptic: true,
          onTap: () {
            // Mark as read immediately on click
            _repository.markAsRead(notification.id);

            if (notification.relatedId != null) {
              Navigator.push(
                context,
                CustomPageRoute(
                  page: OrderDetailScreen(orderId: notification.relatedId.toString()),
                ),
              );
            } else {
              Navigator.push(
                context,
                CustomPageRoute(
                  page: NotificationDetailScreen(notification: notification),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
                            LucideIcons.calendar,
                            size: 12,
                            color: AppColors.textSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.createdAt != null
                                ? '${notification.createdAt!.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][notification.createdAt!.month - 1]} ${notification.createdAt!.year}'
                                : notification.time,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (notification.createdAt != null) ...[
                            Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: AppColors.textSoft,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${notification.createdAt!.hour.toString().padLeft(2, '0')}:${notification.createdAt!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                          if (notification.priority != null && notification.priority!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (notification.priority!.toLowerCase() == 'high' || notification.priority!.toLowerCase() == 'tinggi')
                                    ? const Color(0xFFFFE4E6)
                                    : const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notification.priority!.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: (notification.priority!.toLowerCase() == 'high' || notification.priority!.toLowerCase() == 'tinggi')
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
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
    ),
  );
}
}
