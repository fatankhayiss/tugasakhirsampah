import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

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
  bool _isLoadingTask = true;
  
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
    _fetchActiveTask();
  }

  Future<void> _fetchActiveTask() async {
    setState(() => _isLoadingTask = true);
    final response = await ApiService.instance.post(ApiConfig.driverActiveTask);
    if (response.success && response.data != null) {
      setState(() {
        _activeTask = response.data;
        _isLoadingTask = false;
      });
    } else {
      setState(() {
        _activeTask = null;
        _isLoadingTask = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: _fetchActiveTask,
        color: _primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _mint,
                  child: Text(
                    _userData?['nama_lengkap']?.substring(0, 2).toUpperCase() ?? 'DR',
                    style: const TextStyle(
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
                        'Halo,',
                        style: TextStyle(fontSize: 13, color: _textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userData?['nama_lengkap'] ?? 'Driver!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black87,
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
                    const SizedBox(height: 18),
                    _buildActivePickup(),
                    const SizedBox(height: 18),
                    _buildSchedule(),
                    const SizedBox(height: 18),
                    _buildHistory(),
                    const SizedBox(height: 18),
                    _buildBanner(),
                    const SizedBox(height: 24),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tugas Hari Ini',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Text('Selesai', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text(
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Eco-Performance: 66%',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.66,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePickup() {
    if (_isLoadingTask) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeTask == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _surfaceVariant),
        ),
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Tidak ada penjemputan hari ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.recycling, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTask!['nama_warga'] ?? 'Warga',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${_activeTask!['id_order']}',
                          style: const TextStyle(color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Tipe: ${_activeTask!['jenis_sampah'] ?? 'Campuran'}',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: _textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _activeTask!['alamat_jemput'] ?? '-',
                      style: const TextStyle(color: _textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/pickup-detail',
                      arguments: _activeTask,
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Mulai Navigasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildSchedule() {
    final times = ['14:30', '15:15', '16:00'];
    final names = [
      'Ibu Siti Nurhaliza',
      'Bp. Heru Santoso',
      'Warung Makan Jaya',
    ];
    final sub = [
      'Komp. Griya Indah No. 45',
      'Jl. Merdeka Raya No. 12',
      'Pasar Minggu Terminal A3',
    ];
    final distances = ['1.2km', '3.5km', '5.8km'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Selanjutnya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/schedule');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(color: _primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _surfaceVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          i == 0
                              ? _primary
                              : (i == 1 ? _mint : const Color(0xFF5F5E5E)),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 64,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          times[i],
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          distances[i],
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          names[i],
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub[i],
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F1F1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final items = [
      ('Bapak Ahmad', 'Jl. Melati No. 45', '12kg'),
      ('Warung Bu Endang', 'Pasar Modern', '45kg'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/history');
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(color: _primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children:
              items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _surfaceVariant),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: const [
                          Icon(Icons.check_circle, color: _primary),
                          SizedBox(height: 4),
                          Text(
                            'Selesai',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.$3,
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'COLLECTED',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 10,
                              letterSpacing: 1,
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
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/banners/banner_recycle.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color.fromRGBO(0, 0, 0, 0.35),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Recycle\nYour Waste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Learn more about sorting',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
