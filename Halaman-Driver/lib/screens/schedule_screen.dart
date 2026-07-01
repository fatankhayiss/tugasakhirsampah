import 'package:flutter/material.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 1;
  int _selectedDay = 1;

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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE7E8E9),
                  child: const Text(
                    'LS',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
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
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 16),
                    _buildScheduledInfo(),
                    const SizedBox(height: 12),
                    _buildPickupCardActive(),
                    const SizedBox(height: 12),
                    _buildPickupCard(
                      'Ibu Siti Aminah',
                      '10:00 - 11:00 WIB',
                      'Gg. Kelinci No. 12, Tebet, Jakarta Timur',
                      'Residu',
                      Icons.delete,
                      const Color(0xFFE2DFDE),
                      const Color(0xFF636262),
                    ),
                    const SizedBox(height: 12),
                    _buildPickupCard(
                      'Bapak Ridwan Hakim',
                      '13:00 - 14:30 WIB',
                      'Apartemen Green Park Tower B No. 204',
                      'Organik',
                      Icons.compost,
                      const Color(0xFF5FD9AA),
                      const Color(0xFF005D42),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Jadwal Penjemputan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Row(
          children: const [
            Text(
              'Oktober',
              style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 4),
            Icon(Icons.expand_more, size: 18, color: _primary),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final days = const [
      ('Sen', '14'),
      ('Sel', '15'),
      ('Rab', '16'),
      ('Kam', '17'),
      ('Jum', '18'),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          return InkWell(
            onTap: () => setState(() => _selectedDay = index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? _mint : const Color(0xFFE1E3E4),
                borderRadius: BorderRadius.circular(20),
                border:
                    isSelected ? Border.all(color: _primary, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index].$1,
                    style: TextStyle(
                      color: isSelected ? _primary : _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[index].$2,
                    style: TextStyle(
                      color: isSelected ? _primary : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduledInfo() {
    return Row(
      children: const [
        Icon(Icons.event_note, color: _textMuted, size: 18),
        SizedBox(width: 8),
        Text(
          '8 Penjemputan Dijadwalkan',
          style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPickupCardActive() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      _Dot(),
                      SizedBox(width: 6),
                      Text(
                        'Aktif Sekarang',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Bapak Ahmad Subarjo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              _Chip(
                label: 'Anorganik',
                icon: Icons.recycling,
                bg: Color(0xFFE9F8EF),
                fg: _primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _IconText(icon: Icons.schedule, text: '08:00 - 09:30 WIB'),
          const SizedBox(height: 8),
          _IconText(
            icon: Icons.location_on,
            text:
                'Jl. Melati No. 45, Kompleks Perumahan Griya Indah, Jakarta Selatan',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.call, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(
    String name,
    String time,
    String address,
    String tag,
    IconData tagIcon,
    Color tagBg,
    Color tagFg, {
    bool dimmed = false,
  }) {
    return Opacity(
      opacity: dimmed ? 0.7 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _surfaceVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _Chip(label: tag, icon: tagIcon, bg: tagBg, fg: tagFg),
              ],
            ),
            const SizedBox(height: 12),
            _IconText(icon: Icons.schedule, text: time),
            const SizedBox(height: 8),
            _IconText(icon: Icons.location_on, text: address),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: _textMuted))),
      ],
    );
  }
}
