import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
    });

    final res = await ApiService.instance.get(ApiConfig.driverProfile);
    if (res.success && res.data != null && res.data is Map<String, dynamic>) {
      if (user != null) {
        final updated = Map<String, dynamic>.from(user)..addAll(res.data);
        await _authService.saveUser(updated);
        if (mounted) {
          setState(() {
            _userData = updated;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userData = res.data;
          });
        }
      }
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
        onRefresh: _loadUser,
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
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isLoading ? null : _loadUser,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: DriverColors.primary))
                        : const Icon(Icons.refresh_rounded, color: DriverColors.primary),
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
                      const SizedBox(height: 48),
                      _buildIdentitySection(),
                      const SizedBox(height: 24),
                      _buildVehicleSection(),
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
              if (i == 2) {
                Navigator.of(context).pushReplacementNamed('/alerts');
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

  Widget _buildHero() {
    return SizedBox(
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: DriverStyles.cardRadius,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), DriverColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: DriverStyles.cardShadow,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -40,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: DriverColors.softBlue,
                      child: Text(
                        _userData?['nama_lengkap'] != null && (_userData!['nama_lengkap'] as String).isNotEmpty
                            ? (_userData!['nama_lengkap'] as String).substring(0, 2).toUpperCase()
                            : 'DR',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: DriverColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Pribadi',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: DriverColors.textDark),
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
              _InfoRow(label: 'NAMA LENGKAP', value: _userData?['nama_lengkap'] ?? '-'),
              const Divider(height: 28, color: DriverColors.border),
              _InfoRow(label: 'EMAIL / USERNAME', value: _userData?['email'] ?? _userData?['username'] ?? '-'),
              const Divider(height: 28, color: DriverColors.border),
              _InfoRow(label: 'NO. TELEPON', value: _userData?['no_telepon'] ?? '-'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kendaraan Operasional',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: DriverColors.textDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DriverColors.badgeCompleted.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Aktif Operasional',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.badgeCompleted, fontSize: 12, fontWeight: FontWeight.w700),
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
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  _getVehicleIcon(_userData?['tipe_kendaraan']),
                  size: 76,
                  color: DriverColors.primary.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'TIPE / JENIS KENDARAAN',
                    value: (_userData?['tipe_kendaraan'] ?? _userData?['jenis_kendaraan'] ?? 'Belum terdaftar').toString().toUpperCase(),
                  ),
                  const Divider(height: 28, color: DriverColors.border),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          label: 'PLAT NOMOR',
                          value: (_userData?['plat_nomor'] ?? '-').toString().toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoRow(
                          label: 'KAPASITAS ANGKUT',
                          value: '${_userData?['kapasitas_berat'] ?? '0'} Kg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                  border: Border.all(color: DriverColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DriverColors.softBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.history_rounded, color: DriverColors.primary),
                    ),
                    const SizedBox(height: 10),
                    const Text('Riwayat Selesai', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: DriverColors.textDark)),
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
                  border: Border.all(color: DriverColors.border),
                  boxShadow: DriverStyles.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.logout_rounded, color: DriverColors.badgeCancelled),
                    ),
                    const SizedBox(height: 10),
                    const Text('Keluar / Logout', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: DriverColors.badgeCancelled)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String? type) {
    if (type == null) return Icons.local_shipping_rounded;
    final t = type.toLowerCase();
    if (t.contains('motor')) return Icons.two_wheeler_rounded;
    if (t.contains('truk') || t.contains('truck') || t.contains('pick')) return Icons.local_shipping_rounded;
    return Icons.local_shipping_rounded;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: DriverColors.textMuted,
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DriverColors.textDark,
          ),
        ),
      ],
    );
  }
}
