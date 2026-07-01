import 'package:flutter/material.dart';

const _primary = Color(0xFF006D36);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE1E3E4);
const _textMuted = Color(0xFF6D7B6D);

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

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
            toolbarHeight: 72,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: _primary),
                ),
                const Text(
                  'Detail Penjemputan',
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
                    _buildCustomerCard(),
                    const SizedBox(height: 16),
                    _buildDetailCard(),
                    const SizedBox(height: 16),
                    _buildCategoryCard(),
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildCustomerCard() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE7E8E9),
            child: const Text(
              'BB',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bapak Budi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F8EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Pengguna',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEEF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.call, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _IconBadge(icon: Icons.location_on, bg: const Color(0xFFE9F8EF)),
              const SizedBox(width: 12),
              const Expanded(
                child: _InfoBlock(
                  title: 'Alamat Penjemputan',
                  value: 'Jl. Merdeka No. 123, Jakarta Pusat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _IconBadge(
                      icon: Icons.calendar_month,
                      bg: const Color(0xFFE9F8EF),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _InfoBlock(
                        title: 'Hari & Tanggal',
                        value: 'Senin, 24 Mei 2024',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _IconBadge(
                      icon: Icons.schedule,
                      bg: const Color(0xFFE9F8EF),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _InfoBlock(
                        title: 'Slot Waktu',
                        value: '08:00 - 10:00 WIB',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jenis Sampah', style: TextStyle(color: _textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: const [
                    _Tag(text: 'Plastik', bg: Color(0xFFE9F8EF), fg: _primary),
                    _Tag(text: 'Kertas', bg: Color(0xFFE9F8EF), fg: _primary),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('Estimasi Berat', style: TextStyle(color: _textMuted)),
              SizedBox(height: 6),
              Text(
                '3.25 kg',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _surfaceVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan Driver', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            '"Mohon jemput di pintu samping gedung, dekat tempat sampah besar warna hijau. Koordinasikan dengan satpam di gerbang depan."',
            style: TextStyle(color: _textMuted),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.bg});

  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _primary),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: _textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.bg, required this.fg});

  final String text;
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
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
