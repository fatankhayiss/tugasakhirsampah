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
    if (res.success && res.data is List) {
      setState(() {
        _notifications = res.data as List;
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
    final judul = notif['judul']?.toString().toUpperCase() ?? 'INFO';
    final pesan = notif['pesan'] ?? '';

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
            if (notif['is_read'] == 0 || notif['is_read'] == '0') {
              await ApiService.instance.put(
                ApiConfig.notifikasiUpdate,
                body: {'id_notifikasi': notifId},
              );
              _fetchNotifications();
            }

            final relatedId = notif['related_id'];
            if (relatedId != null && int.tryParse(relatedId.toString()) != null && int.parse(relatedId.toString()) > 0) {
              final orderId = int.parse(relatedId.toString());
              
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );

              final res = await ApiService.instance.get(
                '${ApiConfig.baseUrl}modules/api/driver_api.php?action=get_order_detail&id_order=$orderId',
              );

              if (mounted) Navigator.of(context).pop();

              if (res.success && res.data != null) {
                final orderData = res.data as Map<String, dynamic>;
                if (mounted) {
                  Navigator.of(context).pushNamed(
                    '/pickup-detail',
                    arguments: orderData,
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              if (mounted) {
                Navigator.of(context).pushNamed(
                  '/alert-detail',
                  arguments: notif,
                );
              }
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
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                judul,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (notif['is_read'] == 0 || notif['is_read'] == '0') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'BARU',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pesan,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.textMuted,
                          fontSize: 12,
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
