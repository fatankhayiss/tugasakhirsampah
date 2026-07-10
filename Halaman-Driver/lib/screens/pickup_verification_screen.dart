import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);
const _surface = Colors.white;
const _surfaceVariant = Color(0xFFE7E7E7);
const _textMuted = Color(0xFF6D7B6D);

class PickupVerificationScreen extends StatefulWidget {
  const PickupVerificationScreen({super.key});

  @override
  State<PickupVerificationScreen> createState() => _PickupVerificationScreenState();
}

class _PickupVerificationScreenState extends State<PickupVerificationScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

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
            toolbarHeight: 72,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: _primary),
                ),
                const Text(
                  'Verifikasi Penjemputan',
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
                    _buildCustomerCard(task),
                    const SizedBox(height: 16),
                    _DynamicMapCard(task: task),
                    const SizedBox(height: 16),
                    _buildWeightInput(task),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(color: _surfaceVariant.withValues(alpha: 0.4)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7E8E9),
                    foregroundColor: _textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final weightStr = _weightController.text.trim();
                    final finalWeight = weightStr.isNotEmpty ? '$weightStr Kg' : (task['estimasi_berat'] ?? '0 Kg');
                    task['berat_aktual'] = finalWeight;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    final res = await ApiService().updateOrderStatus(task['id_order'], 'picked_up', beratAktual: finalWeight);
                    if (context.mounted) Navigator.of(context).pop();
                    if (res['success']) {
                      task['status'] = 'picked_up';
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/complete-pickup', arguments: task);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal')));
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    'Konfirmasi Sampah Diangkut',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: const Color(0xFF0B4F2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> task) {
    final nama = task['nama_warga'] ?? 'Warga';
    final inisial = nama.toString().substring(0, nama.toString().length > 1 ? 2 : 1).toUpperCase();
    final alamat = task['alamat_jemput'] ?? '-';
    
    final jenisStr = task['jenis_sampah']?.toString() ?? 'Campuran';
    final categories = jenisStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final berat = task['estimasi_berat'] ?? '0 Kg';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alamat,
                      style: const TextStyle(color: _textMuted, fontSize: 12),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...categories.map((cat) => _Tag(
                text: cat,
                bg: const Color(0xFFE8F5E9),
                fg: const Color(0xFF2E7D32),
              )),
              _Tag(text: '$berat Est.', bg: const Color(0xFFE7E8E9), fg: _textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(Map<String, dynamic> task) {
    final estStr = task['estimasi_berat'] ?? '0 kg';
    final estNumStr = estStr.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    final estVal = double.tryParse(estNumStr) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Input Berat Aktual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text('Estimasi: $estStr', style: const TextStyle(color: _textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: estVal > 0 ? estVal.toStringAsFixed(2) : '0.00',
                filled: true,
                fillColor: const Color(0xFFF3F4F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Positioned(
              right: 20,
              top: 18,
              child: Text(
                'kg',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (estVal > 0) {
                    _weightController.text = (estVal * 1.5).toStringAsFixed(2);
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7E8E9),
                  foregroundColor: _textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Muatan Penuh'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (estVal > 0) {
                    _weightController.text = estVal.toStringAsFixed(2);
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7E8E9),
                  foregroundColor: _textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Sesuai Estimasi'),
              ),
            ),
          ],
        ),
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


class _DynamicMapCard extends StatelessWidget {
  final Map<String, dynamic> task;
  const _DynamicMapCard({required this.task});

  Future<void> _openGoogleMaps() async {
    final alamat = task['alamat_jemput'] ?? '';
    if (alamat.isNotEmpty) {
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(alamat)}');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch Google Maps');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Telkom University Bandung Coordinates
    const double lat = -6.974028;
    const double lng = 107.630348;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(lat, lng),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://b.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tugasakhir.banksampah.driver',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.school, // Changed to a school/building icon to represent Telkom Univ
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: InkWell(
                onTap: _openGoogleMaps,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
                    ]
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.directions, color: _primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Buka di Google Maps',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
