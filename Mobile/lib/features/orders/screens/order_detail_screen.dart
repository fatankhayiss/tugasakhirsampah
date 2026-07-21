import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/order_repository.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchOrderSilent();
    });
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);
    await _fetchOrderSilent();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrderSilent() async {
    final data = await OrderRepository.instance.getOrderById(widget.orderId);
    if (mounted && data != null) {
      if (data['status'] != null && _order?['status'] != data['status']) {
        NotificationRepository.instance.notifyOrderStatusChange(
          orderId: widget.orderId,
          status: data['status'].toString(),
        );
      }
      setState(() {
        _order = data;
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi terkait.')),
        );
      }
    }
  }

  void _openWhatsApp(String? phone) {
    if (phone == null || phone.isEmpty || phone == '-') return;
    String cleaned = phone.trim();
    if (cleaned.startsWith('+62')) {
      cleaned = cleaned.substring(1);
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('08')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    }
    _launchUrl('https://wa.me/$cleaned');
  }

  void _makeCall(String? phone) {
    if (phone == null || phone.isEmpty || phone == '-') return;
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    _launchUrl('tel:$cleanPhone');
  }

  Future<void> _openMaps(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    final navUri = Uri.parse('google.navigation:q=$lat,$lng');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    try {
      if (await canLaunchUrl(navUri)) {
        await launchUrl(navUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }



  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 0;
      case 'MENUNGGU_KONFIRMASI':
        return 1;
      case 'DRIVER_DITUGASKAN':
      case 'PICKER_DITUGASKAN':
      case 'DITUGASKAN':
        return 2;
      case 'DRIVER_MENUJU_LOKASI':
      case 'PICKER_MENUJU_LOKASI':
      case 'DRIVER_TIBA':
      case 'PICKER_HAMPIR_TIBA':
        return 3;
      case 'PENIMBANGAN':
      case 'SAMPAH_DIJEMPUT':
        return 4;
      case 'MENUJU_BANK_SAMPAH':
      case 'VALIDASI_BANK_SAMPAH':
      case 'POIN_DIPROSES':
        return 5;
      case 'SELESAI':
        return 6;
      default:
        return 1;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'MENUNGGU_KONFIRMASI':
        return const Color(0xFFFEF3C7);
      case 'DRIVER_DITUGASKAN':
      case 'DRIVER_MENUJU_LOKASI':
      case 'DRIVER_TIBA':
      case 'PICKER_DITUGASKAN':
      case 'PICKER_MENUJU_LOKASI':
        return const Color(0xFFEFF6FF);
      case 'PENIMBANGAN':
        return const Color(0xFFFEF3C7);
      case 'SAMPAH_DIJEMPUT':
      case 'MENUJU_BANK_SAMPAH':
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFFF3E8FF);
      case 'POIN_DIPROSES':
        return const Color(0xFFFFE4E6);
      case 'SELESAI':
        return const Color(0xFFDCFCE7);
      case 'DIBATALKAN':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'MENUNGGU_KONFIRMASI':
        return const Color(0xFFD97706);
      case 'DRIVER_DITUGASKAN':
      case 'DRIVER_MENUJU_LOKASI':
      case 'DRIVER_TIBA':
      case 'PICKER_DITUGASKAN':
      case 'PICKER_MENUJU_LOKASI':
        return const Color(0xFF2563EB);
      case 'PENIMBANGAN':
        return const Color(0xFFD97706);
      case 'SAMPAH_DIJEMPUT':
      case 'MENUJU_BANK_SAMPAH':
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFF7E22CE);
      case 'POIN_DIPROSES':
        return const Color(0xFFE11D48);
      case 'SELESAI':
        return const Color(0xFF16A34A);
      case 'DIBATALKAN':
        return const Color(0xFFDC2626);
      default:
        return AppColors.textSoft;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        return 'MENUNGGU KONFIRMASI';
      case 'DRIVER_DITUGASKAN':
        return 'PICKER DITUGASKAN';
      case 'DRIVER_MENUJU_LOKASI':
        return 'PICKER MENUJU LOKASI';
      case 'DRIVER_TIBA':
        return 'PICKER HAMPIR TIBA';
      case 'PENIMBANGAN':
        return 'PENIMBANGAN BERAT';
      case 'SAMPAH_DIJEMPUT':
        return 'SAMPAH DIJEMPUT';
      case 'MENUJU_BANK_SAMPAH':
        return 'MENUJU BANK SAMPAH';
      case 'VALIDASI_BANK_SAMPAH':
        return 'VALIDASI BANK SAMPAH';
      case 'POIN_DIPROSES':
        return 'POIN DIPROSES';
      case 'SELESAI':
        return 'SELESAI';
      case 'DIBATALKAN':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.triangle_alert, color: Color(0xFFEF4444), size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Order Tidak Ditemukan / Gagal Memuat',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Order ID: ${widget.orderId}\nEndpoint: ${ApiConfig.orders}?id=${widget.orderId}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: AppColors.textSoft,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchOrder,
                          icon: const Icon(LucideIcons.refresh_cw, size: 16),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
      bottomNavigationBar: (_isLoading || _order == null) ? null : _buildBottomActions(),
    );
  }

  Widget _buildContent() {
    final status = _order!['status'] as String? ?? 'MENUNGGU_KONFIRMASI';
    final driverName = _order!['nama_driver'] as String?;
    final driverPhoto = _order!['foto_driver'] as String?;
    final driverPhone = _order!['telp_driver'] as String?;
    final jenisKendaraan = _order!['jenis_kendaraan'] as String? ?? 'Motor Box';
    final platNomor = _order!['plat_nomor'] as String? ?? '-';
    
    final isAssigned = (status == 'DRIVER_DITUGASKAN' ||
            status == 'DRIVER_MENUJU_LOKASI' ||
            status == 'DRIVER_TIBA' ||
            status == 'PENIMBANGAN' ||
            status == 'SAMPAH_DIJEMPUT' ||
            status == 'MENUJU_BANK_SAMPAH' ||
            status == 'VALIDASI_BANK_SAMPAH' ||
            status == 'SELESAI') &&
        driverName != null;

    final alamat = _order!['alamat_jemput'] ?? _order!['alamat'] ?? '-';
    final waktu = OrderRepository.formatPickupSchedule(
      _order!['tanggal_order']?.toString() ?? _order!['created_at']?.toString(),
      _order!['waktu_jemput_dari']?.toString(),
    );
    final catatan = _order!['catatan'] as String? ?? '';
    final estimasiBerat = _order!['estimasi_berat'] ?? 0;
    final beratAktual = _order!['berat_aktual'] ?? estimasiBerat;
    final estimasiPoin = _order!['estimasi_poin'] ?? 0;
    final items = (_order!['items'] as List?) ?? (_order!['detail_sampah'] as List?) ?? [];
    final double? lat = _order!['latitude'] != null ? double.tryParse(_order!['latitude'].toString()) : null;
    final double? lng = _order!['longitude'] != null ? double.tryParse(_order!['longitude'].toString()) : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge, Order ID & Pickup Schedule
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ID: #${widget.orderId.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(status),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _getStatusTextColor(status),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.calendar_clock, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Jadwal Penjemputan: $waktu',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card 1: Timeline Status 11 Tahap (Main Focus at Top)
          if (status != 'DIBATALKAN') ...[
            _buildSectionCard(
              icon: LucideIcons.git_commit_vertical,
              iconBgColor: const Color(0xFFEAF8EF),
              iconColor: AppColors.primary,
              title: 'Status Pesanan',
              child: _build7StageTimeline(status),
            ),
            const SizedBox(height: 20),
          ],

          // Card 2: Dynamic Information Card based on Status
          _buildDynamicStatusInfoCard(status, beratAktual, estimasiBerat, estimasiPoin, driverName, lat, lng),
          const SizedBox(height: 20),

          // Card 3: Top Picker Card (If assigned)
          if (isAssigned) ...[
            _buildTopPickerCard(driverName, driverPhoto, driverPhone, jenisKendaraan, platNomor),
            const SizedBox(height: 20),
          ],

          // Card 4: Informasi Penjemputan
          _buildSectionCard(
            icon: LucideIcons.map_pin,
            iconBgColor: const Color(0xFFEAF8EF),
            iconColor: const Color(0xFF2DAA63),
            title: 'Informasi Penjemputan',
            child: Column(
              children: [
                _DetailRow(
                  title: 'Alamat Jemput',
                  content: alamat,
                ),
                const Divider(height: 24, color: AppColors.border),
                _DetailRow(
                  title: 'Jadwal / Waktu',
                  content: waktu,
                ),
                if (lat != null && lng != null) ...[
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Navigasi Lokasi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openMaps(lat, lng),
                        icon: const Icon(LucideIcons.map_pin, size: 16, color: AppColors.primary),
                        label: const Text(
                          'Buka di Google Maps',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (catatan.isNotEmpty) ...[
                  const Divider(height: 24, color: AppColors.border),
                  _DetailRow(
                    title: 'Catatan',
                    content: catatan,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card 5: Informasi Sampah
          _buildSectionCard(
            icon: LucideIcons.recycle,
            iconBgColor: const Color(0xFFEAF8EF),
            iconColor: AppColors.primary,
            title: 'Informasi Sampah',
            child: items.isEmpty
                ? _DetailRow(
                    title: 'Estimasi Berat Total',
                    content: '$estimasiBerat kg',
                  )
                : Column(
                    children: [
                      ...items.map((item) {
                        final nama = item['nama_jenis_sampah'] ?? item['nama_sampah'] ?? item['nama'] ?? 'Sampah';
                        final berat = item['estimasi_berat_kg'] ?? item['berat'] ?? 0;
                        final harga = item['harga_per_kg'] ?? item['harga'] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    if (harga > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Rp $harga / kg',
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          color: AppColors.textSoft,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '$berat kg',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 20, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimasi Berat Total',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSoft,
                            ),
                          ),
                          Text(
                            '$estimasiBerat kg',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      if (_order!['berat_aktual'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Berat Aktual Timbangan',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2DAA63),
                              ),
                            ),
                            Text(
                              '${_order!['berat_aktual']} kg',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2DAA63),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          // Card 6: Estimasi Poin
          _buildSectionCard(
            icon: LucideIcons.sparkles,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: 'Estimasi Poin Didapat',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Poin Setoran',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8EF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '+$estimasiPoin Poin',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2DAA63),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_order != null && _canCancelOrder(_order!['status']?.toString())) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showCancelConfirmationDialog,
                icon: const Icon(LucideIcons.trash_2, size: 18, color: Color(0xFFEF4444)),
                label: const Text(
                  'Batalkan Setoran',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFFEF4444),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _canCancelOrder(String? status) {
    if (status == null) return false;
    final st = status.toUpperCase();
    return st == 'MENUNGGU_KONFIRMASI' || st == 'SUBMITTED' || st == 'DRIVER_DITUGASKAN' || st == 'DITUGASKAN' || st == 'PICKER_DITUGASKAN';
  }

  Future<void> _showCancelConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Batalkan Setoran?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan permintaan penjemputan ini?\n\nSetelah dibatalkan, permintaan tidak dapat dikembalikan.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            height: 1.4,
            color: AppColors.textSoft,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      final response = await OrderRepository.instance.cancelOrder(widget.orderId);
      if (mounted) Navigator.pop(context); // pop loading dialog

      if (response.success) {
        if (mounted) {
          NotificationRepository.instance.notifyOrderStatusChange(
            orderId: widget.orderId,
            status: 'cancelled',
            customMessage: 'Pesanan setoran sampah #${widget.orderId} telah dibatalkan.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isEmpty ? 'Gagal membatalkan permintaan.' : response.message),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  Widget _buildTopPickerCard(String name, String? photoUrl, String? phone, String vehicle, String plate) {
    final bool hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEAF8EF),
            backgroundImage: hasPhoto ? NetworkImage(photoUrl) as ImageProvider : const AssetImage(AppImages.avatar),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$vehicle • $plate',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _openWhatsApp(phone),
                icon: const Icon(LucideIcons.message_square, color: Colors.white, size: 18),
                tooltip: 'WhatsApp',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _makeCall(phone),
                icon: const Icon(LucideIcons.phone, color: Colors.white, size: 18),
                tooltip: 'Telepon',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicStatusInfoCard(
    String status,
    dynamic beratAktual,
    dynamic estimasiBerat,
    dynamic estimasiPoin,
    String? driverName,
    double? lat,
    double? lng,
  ) {
    final st = status.toUpperCase();

    if (st == 'DRIVER_MENUJU_LOKASI' || st == 'ON_THE_WAY') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC7D2FE)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.truck, color: Color(0xFF4F46E5), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Picker sedang menuju lokasi Anda.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF3730A3),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Silakan bersiap di lokasi penjemputan.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF4338CA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (st == 'PICKER_HAMPIR_TIBA' || st == 'DRIVER_TIBA') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.map_pin_check, color: Color(0xFF0284C7), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Picker sudah dekat.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Silakan siapkan sampah Anda untuk diserahkan ke Picker.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF075985),
              ),
            ),
          ],
        ),
      );
    }

    if (st == 'PENIMBANGAN') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.scale, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Picker sedang melakukan penimbangan berat.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimasi Berat:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF78350F))),
                Text('$estimasiBerat Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF78350F))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Berat Aktual Timbangan:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                Text('$beratAktual Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFB45309))),
              ],
            ),
          ],
        ),
      );
    }

    if (st == 'SAMPAH_DIJEMPUT' || st == 'PICKED_UP') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF99F6E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.circle_check, color: Color(0xFF0D9488), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sampah berhasil dijemput.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF115E59),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Berat Aktual:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF134E4A))),
                Text('$beratAktual Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF115E59))),
              ],
            ),
          ],
        ),
      );
    }

    if (st == 'MENUJU_BANK_SAMPAH') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.truck, color: Color(0xFF2563EB), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sampah sedang dibawa menuju Bank Sampah.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Berat Timbangan:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF1E3A8A))),
                Text('$beratAktual Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E40AF))),
              ],
            ),
          ],
        ),
      );
    }

    if (st == 'VALIDASI_BANK_SAMPAH' || st == 'POIN_DIPROSES') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8B4FE)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.file_check, color: Color(0xFF7E22CE), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Validasi Bank Sampah',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF6B21A8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Petugas Admin sedang memverifikasi berat dan menghitung poin.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF581C87)),
            ),
          ],
        ),
      );
    }

    if (st == 'SELESAI' || st == 'COMPLETED') {
      final completionDate = _order!['updated_at']?.toString() ?? _order!['created_at']?.toString() ?? '-';
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.circle_check, color: Color(0xFF16A34A), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Poin telah berhasil ditambahkan ke akun Anda.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('✔ Berat Aktual:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF166534))),
                Text('$beratAktual Kg', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF14532D))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('✔ Total Poin Ditambahkan:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF166534))),
                Text('+$estimasiPoin Poin', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF15803D))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('✔ Tanggal Selesai:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF166534))),
                Text(completionDate, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534))),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _build7StageTimeline(String currentStatus) {
    final stages = [
      {'title': 'Permintaan Dikirim', 'desc': 'Permintaan penjemputan telah berhasil dibuat'},
      {'title': 'Menunggu Konfirmasi', 'desc': 'Menunggu konfirmasi dari Admin Bank Sampah'},
      {'title': 'Picker Ditugaskan', 'desc': 'Petugas Picker telah ditugaskan'},
      {'title': 'Picker Menuju Lokasi', 'desc': 'Picker sedang dalam perjalanan ke lokasi Penyetor'},
      {'title': 'Sampah Dijemput', 'desc': 'Sampah berhasil diangkut oleh Picker'},
      {'title': 'Validasi Bank Sampah', 'desc': 'Proses verifikasi & validasi di Bank Sampah'},
      {'title': 'Selesai', 'desc': 'Penjemputan selesai, poin berhasil diterima'},
    ];

    final currentStepIndex = _getStepIndex(currentStatus);

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentStepIndex;
        final isActive = index == currentStepIndex;
        final isLast = index == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF2DAA63)
                        : (isActive ? AppColors.primary : const Color(0xFFE2E8F0)),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                        : (isActive
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              )),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 38,
                    color: isCompleted ? const Color(0xFF2DAA63) : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stages[index]['title']!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive
                            ? AppColors.textDark
                            : (isCompleted ? AppColors.textDark : AppColors.textSoft),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stages[index]['desc']!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget? _buildBottomActions() {
    final status = (_order!['status'] as String? ?? 'MENUNGGU_KONFIRMASI').toUpperCase();

    if (status == 'SELESAI' || status == 'DIBATALKAN') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: (MediaQuery.of(context).size.height * 0.065).clamp(48.0, 60.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.arrow_left, color: Colors.white, size: 18),
              label: const Text(
                'Lihat Riwayat',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String content;

  const _DetailRow({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSoft,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
