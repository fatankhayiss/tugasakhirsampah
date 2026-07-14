import 'package:flutter/material.dart';
import '../services/api_service.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);
const _tertiaryContainer = Color(0xFF5FD9AA);

class PickupDetailScreen extends StatelessWidget {
  const PickupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

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
                  icon: const Icon(Icons.arrow_back, color: _primary),
                ),
                const Text(
                  'Penjemputan',
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
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _mint,
                  child: const Text(
                    'LS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
                    _buildTaskSummary(task),
                    const SizedBox(height: 16),
                    _buildCustomerDetail(task),
                    const SizedBox(height: 16),
                    _buildCategoryChips(task),
                    const SizedBox(height: 20),
                    _buildAction(context, task),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummary(Map<String, dynamic> task) {
    final waktuDari = task['waktu_jemput_dari'] ?? '00:00';
    final waktuSampai = task['waktu_jemput_sampai'] ?? '23:59';
    final tanggal = task['tanggal_order'] ?? '';
    final berat = task['estimasi_berat'] ?? '0 Kg';
    final jenis = task['jenis_sampah'] ?? 'Campuran';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.recycling, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Setor Sampah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tanggal, $waktuDari - $waktuSampai',
                  style: const TextStyle(color: _textMuted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      text: 'Estimasi Berat: $berat',
                      bg: const Color(0xFFE9F8EF),
                      fg: _primary,
                    ),
                    _Pill(
                      text: jenis,
                      bg: const Color(0xFFE2DFDE),
                      fg: const Color(0xFF474746),
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

  Widget _buildCustomerDetail(Map<String, dynamic> task) {
    final nama = task['nama_warga'] ?? 'Warga';
    final inisial = nama.toString().substring(0, nama.toString().length > 1 ? 2 : 1).toUpperCase();
    final alamat = task['alamat_jemput'] ?? '-';
    final waktu = '${task['waktu_jemput_dari']} - ${task['waktu_jemput_sampai']}';

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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE7E8E9),
                child: Text(
                  inisial,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pengguna',
                      style: TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.call, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _surfaceVariant, height: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InfoIcon(icon: Icons.location_on, bg: Color(0xFFEDEEEF)),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoText(
                  title: 'Alamat',
                  value: alamat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InfoIcon(icon: Icons.schedule, bg: Color(0xFFEDEEEF)),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoText(
                  title: 'Jam Penjemputan',
                  value: waktu,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(Map<String, dynamic> task) {
    final jenisStr = task['jenis_sampah']?.toString() ?? 'Campuran';
    final categories = jenisStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Sampah',
          style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            Color bg = const Color(0xFFDDEBFF);
            Color fg = const Color(0xFF1F4E79);
            IconData icon = Icons.recycling;

            if (cat.toLowerCase().contains('plastik')) {
              bg = const Color(0xFFDDEBFF);
              fg = const Color(0xFF1F4E79);
              icon = Icons.liquor;
            } else if (cat.toLowerCase().contains('kertas')) {
              bg = const Color(0xFFFFE7D6);
              fg = const Color(0xFF8A4B08);
              icon = Icons.article;
            } else if (cat.toLowerCase().contains('organik') || cat.toLowerCase().contains('bio')) {
              bg = const Color(0xFFDCF8E4);
              fg = const Color(0xFF1F6B3B);
              icon = Icons.compost;
            } else if (cat.toLowerCase().contains('logam') || cat.toLowerCase().contains('besi') || cat.toLowerCase().contains('kaca')) {
              bg = const Color(0xFFE2DFDE);
              fg = const Color(0xFF474746);
              icon = Icons.precision_manufacturing;
            }

            return _Pill(
              icon: icon,
              text: cat,
              bg: bg,
              fg: fg,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context, Map<String, dynamic> task) {
    bool isAccepted = task['status'] == 'accepted';
    bool isPickedUp = task['status'] == 'picked_up';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (isAccepted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                final res = await ApiService().updateOrderStatus(task['id_order'], 'on_the_way');
                if (context.mounted) Navigator.of(context).pop(); // pop loading
                if (res['success']) {
                  task['status'] = 'on_the_way';
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/pickup-detail', arguments: task);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diperbarui ke Dalam Perjalanan')));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal')));
                  }
                }
              } else if (isPickedUp) {
                Navigator.of(context).pushNamed('/complete-pickup', arguments: task);
              } else {
                Navigator.of(context).pushNamed('/pickup-verify', arguments: task);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepted ? _primary : _mint,
              foregroundColor: isAccepted ? Colors.white : const Color(0xFF0B4F2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isAccepted
                  ? 'Konfirmasi Penjemputan'
                  : (isPickedUp ? 'Selesaikan di Bank Sampah' : 'Lakukan Verifikasi'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAccepted
              ? 'Konfirmasi penjemputan sekarang untuk mulai navigasi'
              : (isPickedUp
                  ? 'Konfirmasi penyelesaian sampah di Bank Sampah'
                  : 'Lakukan verifikasi sampah warga di lokasi'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: _textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.icon, required this.bg});

  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: _primary),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText({required this.title, required this.value});

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
