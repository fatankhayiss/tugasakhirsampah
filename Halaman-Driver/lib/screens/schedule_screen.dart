import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 1;
  List<dynamic> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    final response = await ApiService.instance.get(ApiConfig.driverSchedules);
    if (response.success && response.data is List) {
      setState(() {
        _schedules = response.data as List;
        _isLoading = false;
      });
    } else {
      setState(() {
        _schedules = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
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
                    child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Jadwal Penjemputan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchSchedules,
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
                    : _schedules.isEmpty
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
                                  Icon(Icons.event_busy_rounded, size: 56, color: DriverColors.textMuted),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada jadwal penjemputan',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: DriverColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Daftar pesanan yang dijadwalkan untuk penjemputan akan muncul di sini.',
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
                                final item = _schedules[index];
                                final statusColor = DriverStyles.getStatusColor(item['status'] as String?);
                                final statusLabel = DriverStyles.getStatusLabel(item['status'] as String?);

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
                                          '/pickup-detail',
                                          arguments: item,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: DriverColors.softBlue,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(Icons.calendar_today_rounded, color: DriverColors.primary, size: 20),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          item['nama_warga'] ?? 'Warga',
                                                          style: const TextStyle(
                                                            fontFamily: 'Plus Jakarta Sans',
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w700,
                                                            color: DriverColors.textDark,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          'ID: #${item['id_order']}',
                                                          style: const TextStyle(
                                                            fontFamily: 'Plus Jakarta Sans',
                                                            fontSize: 12,
                                                            color: DriverColors.textMuted,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    statusLabel,
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      color: statusColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Divider(color: DriverColors.border, height: 1),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, color: DriverColors.primary, size: 20),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    item['alamat_jemput'] ?? '-',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 14,
                                                      color: DriverColors.textDark,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.access_time_rounded, color: DriverColors.primary, size: 20),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '${item['tanggal_order'] ?? ''} (${item['waktu_jemput_dari'] ?? '08:00'} - ${item['waktu_jemput_sampai'] ?? '17:00'})',
                                                      style: const TextStyle(
                                                        fontFamily: 'Plus Jakarta Sans',
                                                        fontSize: 13,
                                                        color: DriverColors.textDark,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '${item['estimasi_berat'] ?? '0'} kg',
                                                  style: const TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: DriverColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _schedules.length,
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
              if (i == 2) {
                Navigator.of(context).pushReplacementNamed('/alerts');
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
}
