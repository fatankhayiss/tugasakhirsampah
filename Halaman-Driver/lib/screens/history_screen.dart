import 'package:flutter/material.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 2;
  int _selectedFilter = 0;

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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
                const Text(
                  'Riwayat Penjemputan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: _primary),
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
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterPills(),
                    const SizedBox(height: 16),
                    const Text(
                      'Selesai - 12 Oktober 2023',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HistoryCard(
                      name: 'Bapak Budi',
                      time: '10:30 WIB',
                      location: 'Kebun Jeruk',
                      wasteType: 'Plastik & Kertas',
                      weight: '12.5 kg',
                    ),
                    const SizedBox(height: 12),
                    _HistoryCard(
                      name: 'Ibu Sari',
                      time: '08:15 WIB',
                      location: 'Palmerah',
                      wasteType: 'Organik',
                      weight: '8.2 kg',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Selesai - 11 Oktober 2023',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HistoryCard(
                      name: 'Pak Agus',
                      time: '15:45 WIB',
                      location: 'Grogol',
                      wasteType: 'Logam & Kaca',
                      weight: '20.0 kg',
                      dimmed: true,
                    ),
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: _textMuted),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['Semua', 'Hari Ini', '7 Hari Terakhir', 'Pilih Tanggal'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return InkWell(
            onTap: () => setState(() => _selectedFilter = index),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _primary : const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? _primary : const Color(0xFFBCCABB),
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.name,
    required this.time,
    required this.location,
    required this.wasteType,
    required this.weight,
    this.dimmed = false,
  });

  final String name;
  final String time;
  final String location;
  final String wasteType;
  final String weight;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
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
      child: Opacity(
        opacity: dimmed ? 0.9 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE2DFDE),
                  child: Text(
                    name.isNotEmpty ? name[0] : 'U',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$time - $location',
                        style: const TextStyle(color: _textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _mint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: _primary),
                      SizedBox(width: 4),
                      Text(
                        'Selesai',
                        style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Jenis Limbah',
                    value: wasteType,
                    valueColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    label: 'Berat Total',
                    value: weight,
                    valueColor: _primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}
