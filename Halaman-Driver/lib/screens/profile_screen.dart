import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/driver_status_chip.dart';
import '../widgets/daily_vehicle_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int _currentIndex = 3;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _todayVehicle;
  String _driverStatus = 'offline';
  bool _isLoading = false;
  
  Timer? _nameTimer;
  bool _showUsername = false;
  String? _localAvatarPath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _nameTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) setState(() => _showUsername = !_showUsername);
    });
    _loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString('local_avatar_path');
    if (localPath != null && File(localPath).existsSync()) {
      _localAvatarPath = localPath;
    }

    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
      _driverStatus = user?['driver_status']?.toString() ?? 'offline';
    });

    final res = await ApiService.instance.get(ApiConfig.driverProfile);
    if (res.success && res.data != null && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final updated = user != null
          ? (Map<String, dynamic>.from(user)..addAll(data))
          : data;
      await _authService.saveUser(updated);
      if (mounted) {
        setState(() {
          _userData        = updated;
          _todayVehicle    = data['today_vehicle'] as Map<String, dynamic>?;
          _driverStatus    = data['driver_status']?.toString() ?? 'offline';
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadUser,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              toolbarHeight: 84,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Profil Saya',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isLoading ? null : _loadUser,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                        : const Icon(Icons.refresh_rounded, color: AppColors.primary),
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
                      _buildHero(),
                      const SizedBox(height: 56),
                      // Driver Status
                      _buildDriverStatusSection(),
                      const SizedBox(height: 20),
                      _buildIdentitySection(),
                      const SizedBox(height: 24),
                      _buildTodayVehicleSection(),

                      const SizedBox(height: 24),
                      _buildQuickActions(),
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
          if (i == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (i == 1) {
            Navigator.of(context).pushReplacementNamed('/schedule');
          } else if (i == 2) {
            Navigator.of(context).pushReplacementNamed('/alerts');
          }
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Hero Banner (dengan foto profil)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    final nama        = _userData?['nama_lengkap'] as String? ?? '';
    final fotoPath    = _userData?['foto_profil']?.toString() ?? '';
    final fotoUrl     = fotoPath.isNotEmpty ? '${ApiConfig.baseUrl}$fotoPath' : null;
    final initials    = nama.length >= 2 ? nama.substring(0, 2).toUpperCase() : (nama.isNotEmpty ? nama[0].toUpperCase() : 'DR');

    return SizedBox(
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              borderRadius: DriverStyles.cardRadius,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: DriverStyles.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 60),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _showUsername
                                ? '@${_userData?['username'] ?? 'username'}'
                                : (nama.isNotEmpty ? nama : 'Picker iTrashy'),
                            key: ValueKey(_showUsername),
                            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?['level']?.toString().toUpperCase() ?? 'PICKER',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  // Logo beranimasi
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/splash/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Foto profil di bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: -38,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ClipOval(
                  child: _localAvatarPath != null
                      ? Image.file(File(_localAvatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback(initials))
                      : fotoUrl != null
                          ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback(initials))
                          : _avatarFallback(initials),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String initials) => Container(
    color: AppColors.softBlue,
    alignment: Alignment.center,
    child: Text(initials, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
  );

  // ────────────────────────────────────────────────────────────────────────────
  // Driver Status
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildDriverStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.circle_notifications_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATUS OPERASIONAL', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                SizedBox(height: 2),
                Text('Atur ketersediaan Anda untuk menerima order', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          DriverStatusChip(
            initialStatus: _driverStatus,
            onStatusChanged: (s) => setState(() => _driverStatus = s),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Informasi Pribadi
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Informasi Pribadi',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed('/edit-profile');
                if (result == true) _loadUser();
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
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
              _InfoRow(label: 'NAMA LENGKAP',  value: _userData?['nama_lengkap'] ?? '-'),
              const Divider(height: 28, color: AppColors.border),
              _InfoRow(label: 'USERNAME',       value: _userData?['username']    ?? '-'),
              const Divider(height: 28, color: AppColors.border),
              _InfoRow(label: 'EMAIL',          value: _userData?['email']       ?? '-'),
              const Divider(height: 28, color: AppColors.border),
              _InfoRow(label: 'NO. TELEPON',    value: _userData?['no_telepon']  ?? '-'),
              const Divider(height: 28, color: AppColors.border),
              _InfoRow(label: 'TOTAL ORDER SELESAI', value: '${_userData?['total_completed'] ?? 0} penjemputan'),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Kendaraan Hari Ini (dari backend)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildTodayVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kendaraan Hari Ini',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            TextButton.icon(
              onPressed: () async {
                final ok = await DailyVehicleSheet.show(context, existingVehicle: _todayVehicle);
                if (ok == true) _loadUser();
              },
              icon: Icon(_todayVehicle != null ? Icons.edit_outlined : Icons.add_circle_outline_rounded, size: 16),
              label: Text(_todayVehicle != null ? 'Ubah' : 'Daftarkan'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_todayVehicle != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DriverStyles.cardRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: DriverStyles.cardShadow,
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  right: 0, top: 0,
                  child: Icon(Icons.directions_car_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.06)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'JENIS KENDARAAN', value: _todayVehicle!['vehicle_type'] ?? '-'),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(child: _InfoRow(label: 'PLAT NOMOR', value: (_todayVehicle!['license_plate'] ?? '-').toString().toUpperCase())),
                        const SizedBox(width: 16),
                        Expanded(child: _InfoRow(label: 'KAPASITAS', value: _todayVehicle!['capacity']?.isNotEmpty == true ? _todayVehicle!['capacity'] : '-')),
                      ],
                    ),
                    if ((_todayVehicle!['notes'] as String? ?? '').isNotEmpty) ...[
                      const Divider(height: 24, color: AppColors.border),
                      _InfoRow(label: 'CATATAN', value: _todayVehicle!['notes'] ?? ''),
                    ],
                  ],
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              final ok = await DailyVehicleSheet.show(context);
              if (ok == true) _loadUser();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.badgePending.withValues(alpha: 0.06),
                borderRadius: DriverStyles.cardRadius,
                border: Border.all(color: AppColors.badgePending.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.badgePending.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.directions_car_outlined, color: AppColors.badgePending, size: 22),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kendaraan belum didaftarkan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Ketuk di sini untuk mendaftarkan kendaraan hari ini', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }



  // ────────────────────────────────────────────────────────────────────────────
  // Quick Actions
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: DriverStyles.cardRadius,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/history'),
              borderRadius: DriverStyles.cardRadius,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: DriverStyles.cardRadius,
                  border: Border.all(color: AppColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: const Column(
                  children: [
                    SizedBox(
                      width: 44, height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.softBlue, borderRadius: BorderRadius.all(Radius.circular(16))),
                        child: Icon(Icons.history_rounded, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Riwayat Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: DriverStyles.cardRadius,
            child: InkWell(
              onTap: () async {
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              borderRadius: DriverStyles.cardRadius,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: DriverStyles.cardRadius,
                  border: Border.all(color: AppColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.logout_rounded, color: AppColors.badgeCancelled),
                    ),
                    const SizedBox(height: 10),
                    const Text('Keluar / Logout', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.badgeCancelled)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared widget
// ──────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    );
  }
}
