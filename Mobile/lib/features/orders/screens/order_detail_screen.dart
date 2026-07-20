import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import 'driver_tracking_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);
    final data = await OrderRepository.instance.getOrderById(widget.orderId);
    if (mounted) {
      if (data != null && data['status'] != null) {
        NotificationRepository.instance.notifyOrderStatusChange(
          orderId: widget.orderId,
          status: data['status'].toString(),
        );
      }
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await AppDialogTransitions.showFadeScaleDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Batalkan Setoran?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pesanan setor sampah ini?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            height: 1.5,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Tidak',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success =
          await OrderRepository.instance.cancelOrder(widget.orderId);
      if (mounted) {
        if (success) {
          NotificationRepository.instance.notifyOrderStatusChange(
            orderId: widget.orderId,
            status: 'cancelled',
            customMessage: 'Pesanan setoran sampah #${widget.orderId} telah dibatalkan atas permintaan Anda.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membatalkan pesanan'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          _fetchOrder();
        }
      }
    }
  }

  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 0;
      case 'MENUNGGU_KONFIRMASI':
        return 1;
      case 'DRIVER_DITUGASKAN':
        return 2;
      case 'DRIVER_MENUJU_LOKASI':
        return 3;
      case 'SAMPAH_DIJEMPUT':
        return 4;
      case 'VALIDASI_BANK_SAMPAH':
        return 5;
      case 'SELESAI':
        return 6;
      default:
        return 1;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        return const Color(0xFFFEF9C3);
      case 'DRIVER_DITUGASKAN':
        return const Color(0xFFDBEAFE);
      case 'DRIVER_MENUJU_LOKASI':
        return const Color(0xFFE0E7FF);
      case 'SAMPAH_DIJEMPUT':
        return const Color(0xFFCCFBF1);
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFFFFEDD5);
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
      case 'MENUNGGU_KONFIRMASI':
        return const Color(0xFFD97706);
      case 'DRIVER_DITUGASKAN':
        return const Color(0xFF2563EB);
      case 'DRIVER_MENUJU_LOKASI':
        return const Color(0xFF4F46E5);
      case 'SAMPAH_DIJEMPUT':
        return const Color(0xFF0D9488);
      case 'VALIDASI_BANK_SAMPAH':
        return const Color(0xFFEA580C);
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
        return 'PESANAN DITERIMA';
      case 'DRIVER_MENUJU_LOKASI':
        return 'DRIVER MENUJU LOKASI';
      case 'SAMPAH_DIJEMPUT':
        return 'SAMPAH DIJEMPUT';
      case 'VALIDASI_BANK_SAMPAH':
        return 'PROSES VALIDASI';
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
              ? const Center(
                  child: Text(
                    'Gagal memuat pesanan',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                  ),
                )
              : _buildContent(),
      bottomNavigationBar: (_isLoading || _order == null)
          ? null
          : _buildBottomActions(),
    );
  }

  Widget _buildContent() {
    final status = _order!['status'] as String? ?? 'MENUNGGU_KONFIRMASI';
    final driverName = _order!['nama_driver'] as String?;
    final platNomor = _order!['plat_nomor'] as String? ?? 'Motor Box - B 1234 ABC';
    final isAssigned = (status == 'DRIVER_DITUGASKAN' ||
            status == 'DRIVER_MENUJU_LOKASI' ||
            status == 'SAMPAH_DIJEMPUT' ||
            status == 'VALIDASI_BANK_SAMPAH' ||
            status == 'SELESAI') &&
        driverName != null;

    final alamat = _order!['alamat_jemput'] ?? _order!['alamat'] ?? '-';
    final waktu = (_order!['waktu_jemput_dari'] != null &&
            _order!['waktu_jemput_sampai'] != null)
        ? '${_order!['waktu_jemput_dari']} - ${_order!['waktu_jemput_sampai']} WIB'
        : (_order!['waktu_jemput'] ?? _order!['tanggal'] ?? '-');
    final catatan = _order!['catatan'] as String? ?? '';
    final estimasiBerat = _order!['estimasi_berat'] ?? 0;
    final estimasiPoin = _order!['estimasi_poin'] ?? 0;
    final items = (_order!['items'] as List?) ?? (_order!['detail_sampah'] as List?) ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge & Order ID
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
          const SizedBox(height: 24),

          // Card 1: Timeline Status 6 Tahap
          if (status != 'DIBATALKAN') ...[
            _buildSectionCard(
              icon: LucideIcons.git_commit_vertical,
              iconBgColor: const Color(0xFFEAF8EF),
              iconColor: AppColors.primary,
              title: 'Status Pesanan',
              child: _build6StageTimeline(status),
            ),
            const SizedBox(height: 20),
          ],

          // Card 2: Picker / Driver Info (If assigned)
          if (isAssigned) ...[
            Container(
              padding: const EdgeInsets.all(16),
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFEAF8EF),
                    backgroundImage: AssetImage(AppImages.avatar),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          platNomor,
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
                  if (status == 'DRIVER_DITUGASKAN' || status == 'DRIVER_MENUJU_LOKASI')
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF8EF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Action chat driver
                        },
                        icon: const Icon(
                          LucideIcons.message_square,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Card 3: Informasi Penjemputan
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

          // Card 4: Informasi Sampah
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
                        final nama = item['nama_jenis_sampah'] ?? item['nama'] ?? 'Sampah';
                        final berat = item['estimasi_berat_kg'] ?? item['berat'] ?? 0;
                        final harga = item['poin_per_kg'] ?? item['harga'] ?? 0;
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
                            'Total Estimasi Berat',
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
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          // Card 5: Estimasi Poin
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _build6StageTimeline(String currentStatus) {
    final stages = [
      {'title': 'Permintaan Dikirim', 'desc': 'Permintaan penjemputan telah dibuat'},
      {'title': 'Menunggu Konfirmasi', 'desc': 'Menunggu verifikasi dan persetujuan admin'},
      {'title': 'Driver Ditugaskan', 'desc': 'Petugas driver telah dialokasikan'},
      {'title': 'Driver Menuju Lokasi', 'desc': 'Driver sedang dalam perjalanan ke lokasi Anda'},
      {'title': 'Sampah Dijemput', 'desc': 'Sampah berhasil diangkut oleh driver'},
      {'title': 'Validasi Bank Sampah', 'desc': 'Proses penimbangan fisik di gudang'},
      {'title': 'Selesai', 'desc': 'Poin reward telah ditambahkan ke saldo Anda'},
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
                        : (isActive
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0)),
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
                        ? const Icon(LucideIcons.check,
                            color: Colors.white, size: 14)
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
                    color: isCompleted
                        ? const Color(0xFF2DAA63)
                        : const Color(0xFFE2E8F0),
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
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive
                            ? AppColors.textDark
                            : (isCompleted
                                ? AppColors.textDark
                                : AppColors.textSoft),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stages[index]['desc']!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSoft,
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
    final status = _order!['status'] as String? ?? 'pending';
    final driverName = _order!['nama_driver'] as String? ?? 'Driver Bersinar #104';
    final platNomor = _order!['plat_nomor'] as String? ?? 'Motor Box - B 1234 ABC';

    // Button Batalkan HANYA ketika status == 'pending'
    if (status == 'pending') {
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
            child: OutlinedButton.icon(
              onPressed: _cancelOrder,
              icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 18),
              label: const Text(
                'Batalkan Setor',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Button Lacak Driver HANYA ketika status == 'accepted' atau 'on_the_way'
    if (status == 'accepted' || status == 'on_the_way') {
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
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverTrackingScreen(
                        orderId: widget.orderId,
                        driverName: driverName,
                        driverPlate: platNomor,
                      ),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.navigation,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Lacak Driver',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
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
