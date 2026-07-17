import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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
        backgroundColor: DriverColors.background,
        appBar: AppBar(
          backgroundColor: DriverColors.background,
          elevation: 0,
          title: const Text('Error', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textDark)),
        ),
        body: const Center(
          child: Text('Data pesanan tidak ditemukan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted)),
        ),
      );
    }

    final statusStr = task['status']?.toString().toLowerCase() ?? 'on_the_way';
    final isAlreadyPickedUp = statusStr == 'picked_up' || statusStr == 'diangkut';

    return Scaffold(
      backgroundColor: DriverColors.background,
      appBar: AppBar(
        backgroundColor: DriverColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: DriverColors.textDark),
        ),
        title: Text(
          isAlreadyPickedUp ? 'Penyelesaian di Bank Sampah' : 'Verifikasi & Timbang Sampah',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DriverColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerCard(task),
            const SizedBox(height: 16),
            _DynamicMapCard(task: task),
            const SizedBox(height: 16),
            _buildWeightInput(task, isAlreadyPickedUp),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: DriverColors.textMuted,
                    side: const BorderSide(color: DriverColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final weightStr = _weightController.text.trim();
                    final finalWeight = weightStr.isNotEmpty ? '$weightStr Kg' : (task['berat_aktual'] ?? task['estimasi_berat'] ?? '0 Kg');
                    task['berat_aktual'] = finalWeight;
                    final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                    final nextStatus = isAlreadyPickedUp ? 'completed' : 'picked_up';

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator(color: DriverColors.primary)),
                    );

                    final res = await ApiService().updateOrderStatus(orderId, nextStatus, beratAktual: finalWeight);
                    if (context.mounted) Navigator.of(context).pop(); // pop loading dialog

                    if (res['success'] == true) {
                      task['status'] = nextStatus;
                      if (context.mounted) {
                        if (nextStatus == 'completed') {
                          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Tugas berhasil diselesaikan! Poin & saldo telah diperbarui.'),
                            backgroundColor: DriverColors.badgeCompleted,
                          ));
                        } else {
                          Navigator.of(context).pop(); // Go back or refresh
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Verifikasi sukses: Sampah telah diangkut ke kendaraan!'),
                            backgroundColor: DriverColors.primary,
                          ));
                        }
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res['message']?.toString() ?? 'Gagal memperbarui verifikasi'),
                          backgroundColor: DriverColors.badgeCancelled,
                        ));
                      }
                    }
                  },
                  icon: Icon(isAlreadyPickedUp ? Icons.task_alt_rounded : Icons.check_circle_outline_rounded, size: 22),
                  label: Text(
                    isAlreadyPickedUp ? 'Selesaikan Tugas & Setor' : 'Konfirmasi Diangkut',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DriverColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: DriverColors.primary.withValues(alpha: 0.3),
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
    final inisial = nama.toString().isNotEmpty ? nama.toString().substring(0, nama.toString().length > 1 ? 2 : 1).toUpperCase() : 'W';
    final alamat = task['alamat_jemput'] ?? '-';
    
    final jenisStr = task['jenis_sampah']?.toString() ?? 'Campuran';
    final categories = jenisStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final berat = task['estimasi_berat'] ?? '0 Kg';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: DriverColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: DriverColors.softBlue,
                child: Text(
                  inisial,
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: DriverColors.primary, fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: DriverColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alamat,
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: DriverColors.border, height: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...categories.map((cat) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DriverColors.softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cat,
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Estimasi: $berat',
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textDark, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(Map<String, dynamic> task, bool isAlreadyPickedUp) {
    final estStr = task['estimasi_berat'] ?? '0 kg';
    final estNumStr = estStr.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    final estVal = double.tryParse(estNumStr) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: DriverColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAlreadyPickedUp ? 'Konfirmasi Timbangan Akhir' : 'Timbangan Aktual Sampah',
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: DriverColors.textDark),
              ),
              Text('Est: $estStr', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: DriverColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: estVal > 0 ? estVal.toStringAsFixed(2) : '0.00',
                  hintStyle: const TextStyle(color: DriverColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: DriverColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: DriverColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: DriverColors.primary, width: 2),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 22, fontWeight: FontWeight.w800, color: DriverColors.textDark),
              ),
              const Positioned(
                right: 20,
                top: 20,
                child: Text(
                  'Kg',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: DriverColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (estVal > 0) {
                      _weightController.text = (estVal * 1.2).toStringAsFixed(2);
                    } else {
                      _weightController.text = '5.00';
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: DriverColors.softBlue,
                    foregroundColor: DriverColors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Muatan +20%', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (estVal > 0) {
                      _weightController.text = estVal.toStringAsFixed(2);
                    } else {
                      _weightController.text = '2.50';
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: DriverColors.textDark,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Sesuai Estimasi', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
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
    const double lat = -6.974028;
    const double lng = 107.630348;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: DriverColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: DriverStyles.cardRadius,
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
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: DriverColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                child: InkWell(
                  onTap: _openGoogleMaps,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: const [
                        Icon(Icons.directions_rounded, color: DriverColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Buka Navigasi Maps',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: DriverColors.primary, fontSize: 13),
                        ),
                      ],
                    ),
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
