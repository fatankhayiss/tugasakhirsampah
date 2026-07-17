import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _activeTask;
  Map<String, dynamic>? _stats;
  List<dynamic> _schedules = [];
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
    });
    await _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    
    // Fetch Active Task
    final resTask = await ApiService.instance.get(ApiConfig.driverActiveTask);
    if (resTask.success && resTask.data != null) {
      _activeTask = resTask.data;
    } else {
      _activeTask = null;
    }

    // Fetch Dashboard Stats
    final resStats = await ApiService.instance.get(ApiConfig.driverStats);
    if (resStats.success && resStats.data != null) {
      _stats = resStats.data;
    } else {
      _stats = {
        'total_completed': 0,
        'total_berat': 0.0,
        'today_orders': 0,
        'pending_orders': 0,
        'rating': 5.0,
      };
    }

    // Fetch Upcoming Schedules
    final resSched = await ApiService.instance.get(ApiConfig.driverSchedules);
    if (resSched.success && resSched.data is List) {
      _schedules = (resSched.data as List).take(3).toList();
    } else {
      _schedules = [];
    }

    // Fetch History
    final resHist = await ApiService.instance.get(ApiConfig.driverHistory);
    if (resHist.success && resHist.data is List) {
      _history = (resHist.data as List).take(3).toList();
    } else {
      _history = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: DriverColors.primary,
                    child: Text(
                      _userData?['nama_lengkap'] != null && (_userData!['nama_lengkap'] as String).isNotEmpty
                          ? (_userData!['nama_lengkap'] as String).substring(0, 2).toUpperCase()
                          : 'DR',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Halo, Mitra Driver',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: DriverColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userData?['nama_lengkap'] ?? 'Driver iTrashy',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: DriverColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: DriverColors.border),
                      boxShadow: DriverStyles.cardShadow,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pushNamed('/alerts'),
                      icon: const Icon(Icons.notifications_outlined, color: DriverColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildActivePickup(),
                      const SizedBox(height: 24),
                      _buildScheduleSection(),
                      const SizedBox(height: 24),
                      _buildHistorySection(),
                      const SizedBox(height: 24),
                      _buildBanner(),
                      const SizedBox(height: 32),
                    ],
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
              if (i == 1) {
                Navigator.of(context).pushReplacementNamed('/schedule');
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

  Widget _buildStatsCard() {
    final todayCount = _stats?['today_orders'] ?? 0;
    final completedCount = _stats?['total_completed'] ?? 0;
    final totalBerat = _stats?['total_berat'] ?? 0;
    final rating = _stats?['rating'] ?? 5.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DriverColors.primary,
            DriverColors.secondary,
          ],
        ),
        borderRadius: DriverStyles.cardRadius,
        boxShadow: [
          BoxShadow(
            color: DriverColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tugas Hari Ini',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$todayCount',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Total Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Rating: $rating',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.scale_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Total Berat: ${totalBerat}kg',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePickup() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: DriverColors.primary),
        ),
      );
    }

    if (_activeTask == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DriverStyles.cardRadius,
          border: Border.all(color: DriverColors.border),
          boxShadow: DriverStyles.cardShadow,
        ),
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 52, color: DriverColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Tidak ada penjemputan aktif',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DriverColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Saat ini Anda tidak memiliki pesanan yang sedang diproses atau dijadwalkan hari ini.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: DriverColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Penjemputan Aktif',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: DriverColors.textDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DriverColors.badgeOnTheWay.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DriverStyles.getStatusLabel(_activeTask!['status'] as String?),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: DriverColors.badgeOnTheWay,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: DriverStyles.cardRadius,
            border: Border.all(color: DriverColors.border),
            boxShadow: DriverStyles.cardShadow,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DriverColors.softBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.recycling_rounded, color: DriverColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTask!['nama_warga'] ?? 'Warga',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 16, color: DriverColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID Pesanan: #${_activeTask!['id_order']}',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: DriverColors.border, height: 1),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: DriverColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _activeTask!['alamat_jemput'] ?? '-',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: DriverColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${_activeTask!['tanggal_order'] ?? ''} (${_activeTask!['waktu_jemput_dari'] ?? '08:00'} - ${_activeTask!['waktu_jemput_sampai'] ?? '17:00'})',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.category_outlined, color: DriverColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Tipe Sampah: ${_activeTask!['jenis_sampah'] ?? 'Campuran'} (${_activeTask!['estimasi_berat'] ?? '0'} kg)',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/pickup-detail',
                      arguments: _activeTask,
                    );
                  },
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('Lihat Detail Penjemputan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DriverColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Selanjutnya',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: DriverColors.textDark),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/schedule');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_schedules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DriverStyles.cardRadius,
              border: Border.all(color: DriverColors.border),
            ),
            child: const Text(
              'Belum ada jadwal penjemputan lainnya saat ini.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          )
        else
          Column(
            children: _schedules.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DriverStyles.cardRadius,
                  border: Border.all(color: DriverColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DriverColors.softBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_today_rounded, color: DriverColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_warga'] ?? 'Warga',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 15, color: DriverColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['alamat_jemput'] ?? '-',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['tanggal_order'] ?? ''} (${item['waktu_jemput_dari'] ?? ''} - ${item['waktu_jemput_sampai'] ?? ''})',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: DriverColors.textMuted),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Selesai',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: DriverColors.textDark),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/history');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DriverStyles.cardRadius,
              border: Border.all(color: DriverColors.border),
            ),
            child: const Text(
              'Belum ada riwayat penjemputan selesai.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          )
        else
          Column(
            children: _history.map((item) {
              final isCompleted = (item['status'] as String?)?.toLowerCase() == 'completed' || (item['status'] as String?)?.toLowerCase() == 'selesai';
              final statusColor = DriverStyles.getStatusColor(item['status'] as String?);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DriverStyles.cardRadius,
                  border: Border.all(color: DriverColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: statusColor,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_warga'] ?? 'Warga',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 15, color: DriverColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['alamat_jemput'] ?? '-',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['tanggal_order'] ?? '',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DriverStyles.getStatusLabel(item['status'] as String?),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['berat_aktual'] ?? item['estimasi_berat'] ?? '0'} kg',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: DriverColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: DriverStyles.cardRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Dark blue
            DriverColors.primary,
          ],
        ),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Kelola Tugas Mudah',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Periksa rute & verifikasi berat sampah warga dengan akurat.',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
