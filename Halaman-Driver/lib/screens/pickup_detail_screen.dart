import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class PickupDetailScreen extends StatefulWidget {
  const PickupDetailScreen({super.key});

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  late Map<String, dynamic> _task;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _task = Map<String, dynamic>.from(args);
      } else {
        _task = {};
      }
      _initialized = true;
      _initLocationTracking();
    }
  }

  StreamSubscription<Position>? _positionStream;
  double _distanceToPickup = double.infinity;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final latStr = _task['latitude']?.toString();
    final lngStr = _task['longitude']?.toString();
    if (latStr == null || lngStr == null) return;
    
    final targetLat = double.tryParse(latStr);
    final targetLng = double.tryParse(lngStr);
    if (targetLat == null || targetLng == null) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );
      if (mounted) {
        setState(() {
          _distanceToPickup = distance;
        });
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka aplikasi terkait.')));
      }
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
          title: const Text('Detail Pesanan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ),
        body: const Center(
          child: Text('Data pesanan tidak ditemukan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted)),
        ),
      );
    }

    final statusStr = _task['status']?.toString().toLowerCase() ?? 'pending';
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
        title: Text(
          'Pesanan #${_task['id_order'] ?? ''}',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummary(Map<String, dynamic> task) {
    final waktuDari = task['waktu_jemput_dari'] ?? '08:00';
    final waktuSampai = task['waktu_jemput_sampai'] ?? '17:00';
    final tanggal = task['tanggal_order'] ?? '';
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
                  '$tanggal ($waktuDari - $waktuSampai)',
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
    final nama = task['nama_warga'] ?? 'Warga';
    final inisial = nama.toString().isNotEmpty ? nama.toString().substring(0, nama.toString().length > 1 ? 2 : 1).toUpperCase() : 'W';
    final alamat = task['alamat_jemput'] ?? '-';
    final noTelp = task['no_telepon_warga'] ?? task['no_telepon'] ?? '-';

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
                child: Text(
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
                      onPressed: () => _launchUrl('https://wa.me/$noTelp'),
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                    child: IconButton(
                      onPressed: () => _launchUrl('tel:$noTelp'),
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
                        onPressed: () {
                          final lat = task['latitude'];
                          final lng = task['longitude'];
                          _launchUrl('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                        },
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
    if (status == 'completed' || status == 'selesai' || status == 'cancelled' || status == 'dibatalkan') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Pesanan ini telah selesai / dibatalkan.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: DriverStyles.getStatusColor(status)),
        ),
      );
    }

    final isPendingOrAccepted = status == 'pending' || status == 'accepted' || status == 'menunggu_konfirmasi' || status == 'driver_ditugaskan';
    final isOnTheWay = status == 'on_the_way' || status == 'dalam_perjalanan' || status == 'driver_menuju_lokasi';
    
    final bool canArrive = isOnTheWay && _distanceToPickup <= 100; // 100 meters

    return Column(
      children: [
        if (isOnTheWay && _distanceToPickup > 100)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.badgeOnTheWay.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.badgeOnTheWay.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.badgeOnTheWay, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Jarak ke lokasi: ${_distanceToPickup > 1000 ? '${(_distanceToPickup / 1000).toStringAsFixed(1)} km' : '${_distanceToPickup.toStringAsFixed(0)} m'}. Tombol "Saya Sudah Tiba" akan aktif saat jarak < 100m.',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (isPendingOrAccepted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
                final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                final res = await ApiService().updateOrderStatus(orderId, 'DRIVER_MENUJU_LOKASI');
                if (context.mounted) Navigator.of(context).pop();
                if (res['success'] == true) {
                  setState(() {
                    _task['status'] = 'DRIVER_MENUJU_LOKASI';
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Status diperbarui: Dalam Perjalanan ke lokasi warga!'),
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
              } else if (isOnTheWay) {
                if (canArrive) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                  final orderId = int.tryParse(task['id_order'].toString()) ?? 0;
                  final res = await ApiService().updateOrderStatus(orderId, 'DRIVER_TIBA');
                  if (context.mounted) Navigator.of(context).pop();
                  if (res['success'] == true) {
                    setState(() {
                      _task['status'] = 'DRIVER_TIBA';
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Status diperbarui: Anda sudah tiba!'),
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda belum berada di radius 100m dari lokasi penjemputan.')));
                }
              } else {
                // driver_tiba or picked_up or others -> verify
                Navigator.of(context).pushNamed('/pickup-verify', arguments: _task);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Text(
              isPendingOrAccepted
                  ? 'Konfirmasi & Mulai Jalan'
                  : (isOnTheWay ? 'Saya Sudah Tiba' : 'Lakukan Verifikasi Sampah Warga'),
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isPendingOrAccepted
              ? 'Tekan tombol di atas saat Anda mulai berangkat menuju alamat warga.'
              : (isOnTheWay ? 'Pastikan Anda sudah berada di lokasi sebelum menekan tombol ini.' : 'Verifikasi berat dan kondisi sampah langsung di lokasi penjemputan.'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
