import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/driver_status_chip.dart';
import '../widgets/daily_vehicle_sheet.dart';
import '../widgets/vehicle_form_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _currentIndex = 0;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _activeTask;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _todayVehicle;
  String _driverStatus = 'offline';
  List<dynamic> _schedules = [];
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _localAvatarPath;

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchAllData(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString('local_avatar_path');
    if (localPath != null && File(localPath).existsSync()) {
      _localAvatarPath = localPath;
    }

    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
      // driverStatus dari cache jika ada
      _driverStatus = user?['driver_status']?.toString() ?? 'offline';
    });
    await _fetchAllData();
  }

  Future<void> _fetchAllData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString('local_avatar_path');
    if (localPath != null && File(localPath).existsSync()) {
      _localAvatarPath = localPath;
    }
    final user = await _authService.getSavedUser();
    if (user != null && mounted) {
      setState(() {
        _userData = user;
        _driverStatus = user['driver_status']?.toString() ?? _driverStatus;
      });
    }

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
        'today_completed': 0,
        'today_berat': 0.0,
        'pending_orders': 0,
      };
    }

    // Fetch Today's Vehicle from backend
    final resVehicle = await ApiService.instance.get(ApiConfig.driverGetDailyVehicle);
    if (resVehicle.success && resVehicle.data != null) {
      _todayVehicle = resVehicle.data as Map<String, dynamic>;
    } else {
      _todayVehicle = null;
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

    if (mounted && !silent) {
      setState(() => _isLoading = false);
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) {
                      ImageProvider? avatarImg;
                      final fotoProfil = _userData?['foto_profil']?.toString();
                      if (fotoProfil != null && fotoProfil.isNotEmpty) {
                        final fullUrl = fotoProfil.startsWith('http')
                            ? fotoProfil
                            : 'http://192.168.110.61/tugasakhirsampah/bank_sampah/assets/uploads/$fotoProfil';
                        avatarImg = NetworkImage(fullUrl);
                      } else if (_localAvatarPath != null && File(_localAvatarPath!).existsSync()) {
                        avatarImg = FileImage(File(_localAvatarPath!));
                      }

                      return CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        backgroundImage: avatarImg,
                        child: avatarImg != null
                            ? null
                            : Text(
                                _userData?['nama_lengkap'] != null && (_userData!['nama_lengkap'] as String).isNotEmpty
                                    ? (_userData!['nama_lengkap'] as String).substring(0, 2).toUpperCase()
                                    : 'PK',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Halo, Mitra Picker',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userData?['nama_lengkap'] ?? 'Picker iTrashy',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  DriverStatusChip(
                    initialStatus: _driverStatus,
                    onStatusChanged: (s) => setState(() => _driverStatus = s),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      boxShadow: DriverStyles.cardShadow,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pushNamed('/alerts'),
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
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
                      const SizedBox(height: 16),
                      _buildVehicleCard(),
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
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          if (i == 1) {
            Navigator.of(context).pushReplacementNamed('/schedule');
          } else if (i == 2) {
            Navigator.of(context).pushReplacementNamed('/alerts');
          } else if (i == 3) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    final todayCount     = _stats?['today_orders']    ?? 0;
    final completedCount = _stats?['total_completed'] ?? 0;
    final todayDone      = _stats?['today_completed'] ?? 0;
    final pendingCount   = _stats?['pending_orders']  ?? 0;
    final todayBerat     = _stats?['today_berat']     ?? 0;
    final totalBerat     = _stats?['total_berat']     ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Kendaraan hari ini (dari backend) ──
        if (_todayVehicle != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DriverStyles.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.softBlue, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kendaraan Hari Ini', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        '${_todayVehicle!["vehicle_type"]} — ${(_todayVehicle!["license_plate"] as String? ?? "").toUpperCase()}',
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          GestureDetector(
            onTap: () async {
              final ok = await DailyVehicleSheet.show(context);
              if (ok == true) _fetchAllData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.badgePending.withValues(alpha: 0.08),
                borderRadius: DriverStyles.cardRadius,
                border: Border.all(color: AppColors.badgePending.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_outlined, color: AppColors.badgePending, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Belum daftar kendaraan hari ini — Ketuk untuk daftarkan',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.badgePending),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.badgePending, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // ── Stats gradient card ──
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: DriverStyles.cardRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
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
                        const Icon(Icons.today_rounded, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Selesai Hari Ini: $todayDone',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.scale_rounded, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${todayBerat > 0 ? todayBerat.toStringAsFixed(1) : totalBerat.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '$pendingCount pesanan masih dalam proses',
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard() {
    final hasVehicle = _todayVehicle != null &&
        _todayVehicle!['vehicle_type'] != null &&
        _todayVehicle!['license_plate'] != null;

    final canEdit = _activeTask == null || _activeTask!['status'] == 'DRIVER_DITUGASKAN';

    if (hasVehicle) {
      final type = _todayVehicle!['vehicle_type'];
      final plate = _todayVehicle!['license_plate'];

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kendaraan Hari Ini',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$type • $plate',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              TextButton.icon(
                onPressed: () {
                  VehicleFormSheet.showVehicleSheet(
                    context,
                    initialVehicle: _todayVehicle,
                    onSaved: () => _fetchAllData(silent: true),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF2563EB)),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Kendaraan Belum Diisi',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Wajib diisi sebelum menjalankan tugas penjemputan',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              VehicleFormSheet.showVehicleSheet(
                context,
                onSaved: () => _fetchAllData(silent: true),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Isi Data',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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
          child: CircularProgressIndicator(color: AppColors.primary),
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
          border: Border.all(color: AppColors.border),
          boxShadow: DriverStyles.cardShadow,
        ),
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 52, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Tidak ada penjemputan aktif',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Saat ini Anda tidak memiliki pesanan yang sedang diproses atau dijadwalkan hari ini.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textMuted),
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
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.badgeOnTheWay.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DriverStyles.getStatusLabel(_activeTask!['status'] as String?),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.badgeOnTheWay,
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
            border: Border.all(color: AppColors.border),
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
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTask!['nama_warga'] ?? 'Warga',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID Pesanan: #${_activeTask!['id_order']}',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _activeTask!['alamat_jemput'] ?? '-',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    DriverStyles.formatPickupSchedule(_activeTask!['tanggal_order'], _activeTask!['waktu_jemput_dari']),
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Tipe Sampah: ${_activeTask!['jenis_sampah'] ?? 'Campuran'} (${_activeTask!['estimasi_berat'] ?? '0'} kg)',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
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
                    backgroundColor: AppColors.primary,
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
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/schedule');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.primary, fontWeight: FontWeight.w700),
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
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Belum ada jadwal penjemputan lainnya saat ini.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 14),
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
                  border: Border.all(color: AppColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_warga'] ?? 'Warga',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['alamat_jemput'] ?? '-',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DriverStyles.formatPickupSchedule(item['tanggal_order'], item['waktu_jemput_dari']),
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/history');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.primary, fontWeight: FontWeight.w700),
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
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Belum ada riwayat penjemputan selesai.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 14),
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
                  border: Border.all(color: AppColors.border),
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
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['alamat_jemput'] ?? '-',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['tanggal_order'] ?? '',
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 12),
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
                            color: AppColors.textDark,
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
            AppColors.primary,
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
