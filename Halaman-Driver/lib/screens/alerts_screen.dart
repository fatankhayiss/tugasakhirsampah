import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _currentIndex = 2;
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
      backgroundColor: DriverColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: DriverColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              backgroundColor: DriverColors.background,
              elevation: 0,
              toolbarHeight: 84,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: DriverColors.primary,
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchNotifications,
                    icon: const Icon(Icons.refresh_rounded, color: DriverColors.primary),
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
                            child: CircularProgressIndicator(color: DriverColors.primary),
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
                                border: Border.all(color: DriverColors.border),
                                boxShadow: DriverStyles.cardShadow,
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.notifications_off_rounded, size: 56, color: DriverColors.textMuted),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada notifikasi',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: DriverColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pemberitahuan tugas penjemputan dan informasi penting akan muncul di sini.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      color: DriverColors.textMuted,
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              if (i == _currentIndex) return;
              if (i == 0) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
                return;
              }
              if (i == 1) {
                Navigator.of(context).pushReplacementNamed('/schedule');
                return;
              }
              if (i == 3) {
                Navigator.of(context).pushReplacementNamed('/profile');
                return;
              }
              setState(() => _currentIndex = i);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: DriverColors.primary,
            unselectedItemColor: DriverColors.textMuted,
            selectedLabelStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500, fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: 'Notifikasi'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
            ],
          ),
        ),
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
        border: Border.all(color: DriverColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: DriverStyles.cardRadius,
        child: InkWell(
          borderRadius: DriverStyles.cardRadius,
          onTap: () {
            Navigator.of(context).pushNamed(
              '/alert-detail',
              arguments: notif,
            );
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
                    color: DriverColors.softBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.notifications_active_rounded, color: DriverColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            judul,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: DriverColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: DriverColors.textMuted, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pesan,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DriverColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: DriverColors.textMuted,
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
