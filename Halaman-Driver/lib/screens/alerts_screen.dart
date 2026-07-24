import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import '../widgets/floating_nav_bar.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final int _currentIndex = 2;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final res = await ApiService.instance.get(ApiConfig.driverNotifications);
    if (res.success && res.data != null) {
      setState(() {
        if (res.data is Map<String, dynamic>) {
          _notifications = res.data['items'] as List? ?? [];
        } else if (res.data is List) {
          _notifications = res.data as List;
        } else {
          _notifications = [];
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              toolbarHeight: 84,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchNotifications,
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      )
                    : _notifications.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: DriverStyles.cardRadius,
                                border: Border.all(color: AppColors.border),
                                boxShadow: DriverStyles.cardShadow,
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.notifications_off_rounded, size: 56, color: AppColors.textMuted),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada notifikasi',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pemberitahuan tugas penjemputan dan informasi penting akan muncul di sini.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final notif = _notifications[index];
                                return _buildNotifCard(notif);
                              },
                              childCount: _notifications.length,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          if (i == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (i == 1) {
            Navigator.of(context).pushReplacementNamed('/schedule');
          } else if (i == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildNotifCard(dynamic notif) {
    final dateStr = notif['created_at'] ?? '';
    final judul = notif['judul']?.toString() ?? 'Info Sistem';
    final pesan = notif['pesan'] ?? '';
    final customerName = notif['customer_name']?.toString() ?? '';
    final alamat = notif['alamat_jemput']?.toString() ?? '';
    final isRead = notif['is_read'] == true || notif['is_read'] == 1 || notif['is_read'] == '1';

    final titleColor = isRead ? AppColors.textDark : AppColors.primary;
    final titleWeight = isRead ? FontWeight.w700 : FontWeight.w800;
    final textColor = isRead ? AppColors.textMuted : AppColors.textDark;
    final iconColor = isRead ? AppColors.textMuted : AppColors.primary;
    final iconBgColor = isRead ? Colors.grey[100] : AppColors.softBlue;
    final badgeColor = isRead ? Colors.grey[200] : const Color(0xFFEF4444);
    final badgeTextColor = isRead ? AppColors.textMuted : Colors.white;
    final badgeText = isRead ? 'Dibaca' : 'Baru';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: DriverStyles.cardRadius,
        child: InkWell(
          borderRadius: DriverStyles.cardRadius,
          onTap: () async {
            final notifId = notif['id_notifikasi'];
            if (!isRead) {
              setState(() {
                notif['is_read'] = true;
                notif['is_read'] = 1; // update raw map directly
              });
              ApiService.instance.put(
                ApiConfig.notifikasiUpdate,
                body: {'id_notifikasi': notifId.toString()},
              ).then((_) {
                _fetchNotifications();
              });
            }

            if (mounted) {
              Navigator.of(context).pushNamed(
                '/alert-detail',
                arguments: notif,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.notifications_active_rounded, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              judul,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: titleColor,
                                fontWeight: titleWeight,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: badgeTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pesan,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                      if (customerName.isNotEmpty || alamat.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customerName.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      customerName,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              if (customerName.isNotEmpty && alamat.isNotEmpty) const SizedBox(height: 6),
                              if (alamat.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        alamat,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
