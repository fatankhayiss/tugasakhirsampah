import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import '../widgets/floating_nav_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final int _currentIndex = 1;
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
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
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
                    child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Jadwal Penjemputan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchSchedules,
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
                    : _schedules.isEmpty
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
                                  Icon(Icons.event_busy_rounded, size: 56, color: AppColors.textMuted),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada jadwal penjemputan',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Daftar pesanan yang dijadwalkan untuk penjemputan akan muncul di sini.',
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
                                final item = _schedules[index];
                                final statusColor = DriverStyles.getStatusColor(item['status'] as String?);
                                final statusLabel = DriverStyles.getStatusLabel(item['status'] as String?);

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
                                                        color: AppColors.softBlue,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
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
                                                            color: AppColors.textDark,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          'ID: #${item['id_order']}',
                                                          style: const TextStyle(
                                                            fontFamily: 'Plus Jakarta Sans',
                                                            fontSize: 12,
                                                            color: AppColors.textMuted,
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
                                            const Divider(color: AppColors.border, height: 1),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    item['alamat_jemput'] ?? '-',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 14,
                                                      color: AppColors.textDark,
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
                                                    const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      DriverStyles.formatPickupSchedule(item['tanggal_order'], item['waktu_jemput_dari']),
                                                      style: const TextStyle(
                                                        fontFamily: 'Plus Jakarta Sans',
                                                        fontSize: 13,
                                                        color: AppColors.textDark,
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
                                                    color: AppColors.primary,
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
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          if (i == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (i == 2) {
            Navigator.of(context).pushReplacementNamed('/alerts');
          } else if (i == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    );
  }
}
