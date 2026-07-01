import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _currentIndex = 2;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final res = await ApiService.instance.post(ApiConfig.driverNotifications);
    if (res.success && res.data != null) {
      setState(() {
        _notifications = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
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
                    const Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pantau tugas penjemputan harian Anda.',
                      style: TextStyle(color: _textMuted),
                    ),
                    const SizedBox(height: 24),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _notifications.isEmpty 
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('Belum ada notifikasi.', style: TextStyle(color: _textMuted)),
                            ),
                          )
                        : Column(
                            children: _notifications.map((notif) => _buildNotifCard(notif)).toList(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(dynamic notif) {
    // Parse date if possible
    final dateStr = notif['created_at'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_active, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif['judul']?.toString().toUpperCase() ?? 'INFO',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif['pesan'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

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
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
