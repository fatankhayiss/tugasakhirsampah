import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import '../widgets/vehicle_form_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class PickupDetailScreen extends StatefulWidget {
  const PickupDetailScreen({super.key});

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  late Map<String, dynamic> _task;
  bool _initialized = false;
  final TextEditingController _beratAktualController = TextEditingController();



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _task = Map<String, dynamic>.from(args);
        final initialWeight = _task['berat_aktual']?.toString() ?? _task['estimasi_berat']?.toString() ?? '';
        final cleanWeight = initialWeight.replaceAll(RegExp(r'[^0-9.]'), '');
        _beratAktualController.text = cleanWeight.isNotEmpty ? cleanWeight : '1.0';
      } else {
        _task = {};
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _beratAktualController.dispose();
    super.dispose();
  }

  String _normalizeWhatsAppPhone(String rawPhone) {
    if (rawPhone.isEmpty) return '';
    String cleaned = rawPhone.trim();
    if (cleaned.startsWith('+62')) {
      cleaned = cleaned.substring(1);
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('08')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    }
    return cleaned;
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty || phone == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon Penyetor tidak tersedia.')),
      );
      return;
    }

    final normalized = _normalizeWhatsAppPhone(phone);
    final webWaUrl = 'https://wa.me/$normalized';
    final deepWaUrl = 'whatsapp://send?phone=$normalized';

    final uriWeb = Uri.parse(webWaUrl);
    final uriDeep = Uri.parse(deepWaUrl);

    try {
      if (await canLaunchUrl(uriDeep)) {
        await launchUrl(uriDeep, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
          );
        }
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    if (phone.isEmpty || phone == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon Penyetor tidak tersedia.')),
      );
      return;
    }

    final cleanPhone = phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi Telepon.')),
        );
      }
    }
  }

  Future<void> _launchGoogleMaps(dynamic latStr, dynamic lngStr) async {
    // STEP 1 & STEP 2: Verify backend and Flutter receive latitude & longitude
    debugPrint('Latitude Raw: $latStr');
    debugPrint('Longitude Raw: $lngStr');

    if (latStr == null || lngStr == null) {
      debugPrint('Maps Launch Aborted: Latitude or Longitude is NULL');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koordinat lokasi penjemputan tidak tersedia.')),
        );
      }
      return;
    }

    final lat = latStr.toString().trim();
    final lng = lngStr.toString().trim();

    if (lat.isEmpty || lng.isEmpty || lat == '0' || lng == '0') {
      debugPrint('Maps Launch Aborted: Latitude or Longitude is empty/zero');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koordinat lokasi penjemputan tidak valid.')),
        );
      }
      return;
    }

    // STEP 3 & STEP 5: Generate Navigation URI & Browser URI
    final navString = 'google.navigation:q=$lat,$lng';
    final webString = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    final navUri = Uri.parse(navString);
    final webUri = Uri.parse(webString);

    debugPrint('Latitude: $lat');
    debugPrint('Longitude: $lng');
    debugPrint('Generated Navigation URI: $navString');
    debugPrint('Generated Browser URI: $webString');

    bool launched = false;

    // STEP 3: Attempt google.navigation with LaunchMode.externalApplication
    try {
      if (await canLaunchUrl(navUri)) {
        launched = await launchUrl(navUri, mode: LaunchMode.externalApplication);
        debugPrint('Launch Result (Navigation URI via canLaunchUrl): $launched');
      } else {
        launched = await launchUrl(navUri, mode: LaunchMode.externalApplication);
        debugPrint('Launch Result (Navigation URI direct launch): $launched');
      }
    } catch (e) {
      debugPrint('Navigation URI launch failed: $e');
      launched = false;
    }

    // STEP 4: Fallback to Browser URI if first attempt failed
    if (!launched) {
      debugPrint('Falling back to Browser URI: $webString');
      try {
        if (await canLaunchUrl(webUri)) {
          launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
          debugPrint('Launch Result (Browser URI via canLaunchUrl): $launched');
        } else {
          launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
          debugPrint('Launch Result (Browser URI direct launch): $launched');
        }
      } catch (e) {
        debugPrint('Browser URI launch failed: $e');
        launched = false;
      }
    }

    debugPrint('Final Launch Result: $launched');

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka lokasi di Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          ),
          title: const Text(
            'Detail Penjemputan',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
        ),
        body: const Center(
          child: Text('Data pesanan tidak ditemukan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted)),
        ),
      );
    }

    final statusStr = _task['status']?.toString().toUpperCase() ?? 'PENDING';
    final statusLabel = DriverStyles.getStatusLabel(statusStr);
    final statusColor = DriverStyles.getStatusColor(statusStr);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detail Penjemputan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Order ID : #${_task['id_order'] ?? ''}',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              statusLabel,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskSummary(_task),
            const SizedBox(height: 16),
            _buildCustomerDetail(_task),
            const SizedBox(height: 16),
            _buildCategoryChips(_task),
            const SizedBox(height: 24),
            _buildActionButtons(context, _task, statusStr),
            const SizedBox(height: 16),
            _buildActivityLog(_task),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummary(Map<String, dynamic> task) {
    final scheduleStr = DriverStyles.formatPickupSchedule(task['tanggal_order'], task['waktu_jemput_dari']);
    final berat = '${task['estimasi_berat'] ?? '0'} Kg';
    final jenis = task['jenis_sampah'] ?? 'Campuran';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jadwal & Estimasi',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  scheduleStr,
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Estimasi: $berat',
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        jenis,
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
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
    final nama = task['nama_warga'] ?? task['nama_penyetor'] ?? 'Penyetor';
    final inisial = nama.toString().isNotEmpty ? nama.toString().substring(0, nama.toString().length > 1 ? 2 : 1).toUpperCase() : 'P';
    final alamat = task['alamat_jemput'] ?? '-';
    final noTelp = task['telp_warga'] ?? task['no_telepon_warga'] ?? task['no_telepon'] ?? '-';
    final fotoWarga = task['foto_warga'] ?? task['profile_photo'] ?? task['photo_url'] ?? task['avatar'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.softBlue,
                child: (fotoWarga != null && fotoWarga.toString().isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          fotoWarga.toString(),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              inisial,
                              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
                            );
                          },
                        ),
                      )
                    : Text(
                        inisial,
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Telp: $noTelp',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(14)),
                    child: IconButton(
                      onPressed: () => _launchWhatsApp(noTelp),
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                    child: IconButton(
                      onPressed: () => _launchPhone(noTelp),
                      icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.softBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alamat Penjemputan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(alamat, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    if (task['latitude'] != null && task['longitude'] != null)
                      TextButton.icon(
                        onPressed: () => _launchGoogleMaps(task['latitude'], task['longitude']),
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text('Buka di Google Maps', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildCategoryChips(Map<String, dynamic> task) {
    final jenisStr = task['jenis_sampah']?.toString() ?? 'Campuran';
    final categories = jenisStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Sampah Siap Angkut',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> task, String status) {
    final st = status.toUpperCase();

    if (st == 'SELESAI' || st == 'COMPLETED' || st == 'DIBATALKAN' || st == 'CANCELLED') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          st == 'SELESAI' || st == 'COMPLETED' ? 'Penjemputan ini telah selesai.' : 'Pesanan ini telah dibatalkan.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: DriverStyles.getStatusColor(st)),
        ),
      );
    }

    if (st == 'VALIDASI_BANK_SAMPAH') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF99F6E4)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488), size: 22),
                SizedBox(width: 10),
                Text(
                  'Menunggu Validasi Bank Sampah',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF115E59),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Sampah telah diserahkan dan sedang diverifikasi oleh Petugas Admin di Bank Sampah.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF134E4A)),
            ),
          ],
        ),
      );
    }

    if (st == 'SAMPAH_DIJEMPUT') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Menuju Bank Sampah',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Sampah telah berhasil diangkut. Silakan bawa sampah menuju Bank Sampah.',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF1E3A8A)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
                final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                final res = await ApiService().updateOrderStatus(orderId, 'VALIDASI_BANK_SAMPAH');
                if (context.mounted) Navigator.of(context).pop();

                if (res['success'] == true) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/pickup-success');
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res['message']?.toString() ?? 'Gagal memperbarui status'),
                      backgroundColor: AppColors.badgeCancelled,
                    ));
                  }
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text(
                'Sampah Sudah Diserahkan',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      );
    }

    if (st == 'PENIMBANGAN') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DriverStyles.cardRadius,
          border: Border.all(color: AppColors.border),
          boxShadow: DriverStyles.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.scale_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text(
                  'Penimbangan Berat',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimasi Berat:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textMuted)),
                Text('${task['estimasi_berat'] ?? '0'} Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Berat Aktual Timbangan (Kg):', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _beratAktualController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Contoh: 1.5',
                suffixText: 'Kg',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final inputWeight = _beratAktualController.text.trim();
                  if (inputWeight.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan berat aktual timbangan terlebih dahulu.')));
                    return;
                  }
                  final formattedWeight = '$inputWeight Kg';

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                  final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                  final res = await ApiService().updateOrderStatus(orderId, 'SAMPAH_DIJEMPUT', beratAktual: formattedWeight);
                  if (context.mounted) Navigator.of(context).pop();

                  if (res['success'] == true) {
                    setState(() {
                      _task['status'] = 'SAMPAH_DIJEMPUT';
                      _task['berat_aktual'] = formattedWeight;
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Konfirmasi Berat Sukses: Sampah telah diangkut!'),
                        backgroundColor: AppColors.primary,
                      ));
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(res['message']?.toString() ?? 'Gagal memperbarui status'),
                        backgroundColor: AppColors.badgeCancelled,
                      ));
                    }
                  }
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text('Konfirmasi Berat', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isPendingOrAccepted = st == 'PENDING' || st == 'ACCEPTED' || st == 'MENUNGGU_KONFIRMASI' || st == 'DRIVER_DITUGASKAN';
    final isOnTheWay = st == 'ON_THE_WAY' || st == 'DALAM_PERJALANAN' || st == 'DRIVER_MENUJU_LOKASI';
    final isArrived = st == 'DRIVER_TIBA' || st == 'PICKER_HAMPIR_TIBA';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final ctx = context;
              // Vehicle Check
              final vRes = await ApiService().getDailyVehicle();
              bool hasVehicle = vRes['success'] == true && vRes['data'] != null;
              if (!hasVehicle) {
                if (!mounted) return;
                final fill = await VehicleFormSheet.showValidationDialog(ctx);
                if (fill == true && mounted) {
                  final saved = await VehicleFormSheet.showVehicleSheet(ctx);
                  if (saved == true) {
                    hasVehicle = true;
                  }
                }
              }

              if (!hasVehicle) {
                return;
              }

              if (isPendingOrAccepted) {
                if (!mounted) return;
                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
                final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                final res = await ApiService().updateOrderStatus(orderId, 'DRIVER_MENUJU_LOKASI');
                if (!mounted) return;
                Navigator.of(ctx).pop();
                if (res['success'] == true) {
                  setState(() {
                    _task['status'] = 'DRIVER_MENUJU_LOKASI';
                  });
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Status diperbarui: Picker Menuju Lokasi!'),
                    backgroundColor: AppColors.primary,
                  ));
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(res['message']?.toString() ?? 'Gagal memperbarui status'),
                    backgroundColor: AppColors.badgeCancelled,
                  ));
                }
              } else if (isOnTheWay) {
                if (!mounted) return;
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text(
                      'Konfirmasi Lokasi',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Apakah Anda yakin sudah berada di lokasi Penyetor?',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Plus Jakarta Sans')),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Ya', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  if (!mounted) return;
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                  final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                  final res = await ApiService().updateOrderStatus(orderId, 'DRIVER_TIBA');
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  if (res['success'] == true) {
                    setState(() {
                      _task['status'] = 'DRIVER_TIBA';
                    });
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Status diperbarui: Picker telah tiba di lokasi!'),
                      backgroundColor: AppColors.primary,
                    ));
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(res['message']?.toString() ?? 'Gagal memperbarui status'),
                      backgroundColor: AppColors.badgeCancelled,
                    ));
                  }
                }
              } else if (isArrived) {
                if (!mounted) return;
                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
                final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                final res = await ApiService().updateOrderStatus(orderId, 'PENIMBANGAN');
                if (!mounted) return;
                Navigator.of(ctx).pop();
                if (res['success'] == true) {
                  setState(() {
                    _task['status'] = 'PENIMBANGAN';
                  });
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Memulai Penimbangan!'),
                    backgroundColor: AppColors.primary,
                  ));
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(res['message']?.toString() ?? 'Gagal memulai penimbangan'),
                    backgroundColor: AppColors.badgeCancelled,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPendingOrAccepted ? Icons.play_arrow_rounded : (isOnTheWay ? Icons.location_on_rounded : Icons.scale_rounded), size: 22),
                const SizedBox(width: 10),
                Text(
                  isPendingOrAccepted ? 'Mulai Perjalanan' : (isOnTheWay ? 'Saya Sudah Tiba' : 'Mulai Timbang'),
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isPendingOrAccepted
              ? 'Tekan tombol di atas saat Anda mulai berangkat menuju alamat Penyetor.'
              : 'Tekan tombol di atas saat Anda telah tiba di sekitar alamat Penyetor.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
  // ... (Other functions end here)

  Widget _buildActivityLog(Map<String, dynamic> task) {
    if (task['activity_log'] == null) return const SizedBox();
    
    final Map<String, dynamic> log = task['activity_log'];
    
    // Ordered steps
    final steps = [
      {'title': 'Ditugaskan', 'time': log['assigned_at'], 'icon': Icons.assignment_turned_in_rounded},
      {'title': 'Menuju Lokasi', 'time': log['departed_at'], 'icon': Icons.directions_car_rounded},
      {'title': 'Tiba di Lokasi', 'time': log['arrived_at'], 'icon': Icons.location_on_rounded},
      {'title': 'Selesai Jemput', 'time': log['pickup_finished_at'], 'icon': Icons.check_circle_outline_rounded},
      {'title': 'Tiba di Bank', 'time': log['arrived_bank_at'], 'icon': Icons.store_rounded},
      {'title': 'Selesai/Dibongkar', 'time': log['unloaded_at'], 'icon': Icons.inventory_2_rounded},
    ];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DriverStyles.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: DriverStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Operasional',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ...steps.map((step) {
            final timeStr = step['time']?.toString() ?? '';
            final isDone = timeStr.isNotEmpty;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.softBlue : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      step['icon'] as IconData,
                      color: isDone ? AppColors.primary : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                            color: isDone ? AppColors.textDark : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if (isDone) ...[
                          const SizedBox(height: 2),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
