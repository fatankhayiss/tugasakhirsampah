import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: _bg,
            elevation: 0,
            toolbarHeight: 84,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E8E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBCCABB)),
                  ),
                  child: const Icon(Icons.person, color: _textMuted),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Driver Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: _textMuted),
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
                    const SizedBox(height: 40),
                    _buildIdentitySection(),
                    const SizedBox(height: 28),
                    _buildVehicleSection(),
                    const SizedBox(height: 28),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
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
          selectedItemColor: _primary,
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [_mint.withValues(alpha: 0.25), _bg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: _surface, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFB9D7D0),
                      child: Icon(Icons.person, size: 56, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
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
        Row(
          children: [
            const Text(
              'Identitas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18, color: _primary),
              label: const Text(
                'Edit',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: 'NAMA LENGKAP', value: _userData?['nama_lengkap'] ?? '-'),
              const Divider(height: 28, color: _surfaceVariant),
              _InfoRow(label: 'USERNAME / EMAIL', value: _userData?['username'] ?? '-'),
              const Divider(height: 28, color: _surfaceVariant),
              _InfoRow(label: 'NO TELEPON', value: _userData?['no_telepon'] ?? '-'),
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
          children: [
            const Text(
              'Kendaraan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _mint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  _getVehicleIcon(_userData?['tipe_kendaraan']),
                  size: 72,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'VEHICLE TYPE', value: _userData?['jenis_kendaraan'] ?? 'Belum terdaftar'),
                  const Divider(height: 28, color: _surfaceVariant),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          label: 'LICENSE PLATE',
                          value: _userData?['plat_nomor'] ?? '-',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoRow(label: 'CAPACITY', value: '${_userData?['kapasitas_berat'] ?? 0} Kg'),
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
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed('/history'),
            borderRadius: BorderRadius.circular(20),
            child: _QuickActionCard(
              title: 'History',
              icon: Icons.history,
              color: _mint.withValues(alpha: 0.35),
              iconColor: _primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const _QuickActionCard(
              title: 'Logout',
              icon: Icons.logout,
              color: Color(0xFFFFDAD6),
              iconColor: Color(0xFFBA1A1A),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String? type) {
    if (type == null) return Icons.directions_car;
    final t = type.toLowerCase();
    if (t == 'motor') return Icons.two_wheeler;
    if (t == 'truk' || t == 'truck') return Icons.local_shipping;
    return Icons.directions_car;
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
            color: _textMuted,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
