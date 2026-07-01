import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);
    final data = await OrderRepository.instance.getOrderById(widget.orderId);
    if (mounted) {
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Setoran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan setor sampah ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await OrderRepository.instance.cancelOrder(widget.orderId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
          );
          Navigator.pop(context, true); // Pop back to history screen and signal refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membatalkan pesanan')),
          );
          _fetchOrder(); // refresh data
        }
      }
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
          'Detail Order',
          style: TextStyle(
            color: AppColors.textDark,
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
              ? const Center(child: Text('Gagal memuat pesanan'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final status = _order!['status'] as String? ?? 'pending';
    final driverName = _order!['nama_driver'] as String?;
    final isAssigned =
        (status == 'accepted' || status == 'on_the_way') && driverName != null;
    final isCompleted = status == 'picked_up' || status == 'completed';
    final items = _order!['items'] as List? ?? [];

    String headerTitle = 'Menunggu Konfirmasi';
    String headerDesc =
        'Admin sedang memverifikasi jadwal penjemputan Anda. Mohon tunggu sebentar ya.';
    if (isAssigned) {
      headerTitle = 'Picker Menuju Lokasi';
      headerDesc =
          'Picker lagi ke lokasimu nih, pastikan kamu sekarang berada di lokasi yah, biar picker gak ribet nyari-nyari kamu.';
    } else if (isCompleted) {
      headerTitle = 'Selesai Dijemput';
      headerDesc =
          'Sampahmu sudah berhasil dijemput. Terima kasih telah menjaga lingkungan kita!';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              headerTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              headerDesc,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Color(0xFF6F7785),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Stepper
            _buildProgressStepper(status),
            const SizedBox(height: 28),

            // Picker Info Card (Premium Layout)
            if (isAssigned || isCompleted)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                            driverName ?? 'Picker',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Chat dengan picker',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.softBlue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            LucideIcons.message_square,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Order Detail Content
            const Text(
              'Detail Penjemputan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _DetailSection(
                    title: 'Alamat',
                    content: _order!['alamat_jemput'] ?? '-',
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _DetailSection(
                    title: 'Waktu Penjemputan',
                    content:
                        '${_order!['waktu_jemput_dari'] ?? ''} - ${_order!['waktu_jemput_sampai'] ?? ''}',
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _DetailSection(
                    title: 'Estimasi Berat',
                    content: '${_order!['estimasi_berat'] ?? 0}',
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _DetailSection(
                    title: 'Estimasi Poin',
                    content: '+${_order!['estimasi_poin'] ?? 0} Poin',
                    isPoint: true,
                  ),
                ],
              ),
            ),

            // Cancel Button (only if pending)
            if (status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelOrder,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Batalkan Setor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper(String status) {
    int currentStep = 1; // Pending
    if (status == 'accepted' || status == 'on_the_way') {
      currentStep = 2; // Proses / Picker Menuju Lokasi
    } else if (status == 'picked_up' || status == 'completed') {
      currentStep = 3; // Selesai
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _StepItem(
            number: '1',
            label: 'Menunggu',
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
          ),
          _StepConnector(isCompleted: currentStep > 1),
          _StepItem(
            number: '2',
            label: 'Menuju\nLokasi',
            isActive: currentStep == 2,
            isCompleted: currentStep > 2,
          ),
          _StepConnector(isCompleted: currentStep > 2),
          _StepItem(
            number: '3',
            label: 'Selesai',
            isActive: currentStep == 3,
            isCompleted: currentStep > 3,
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String label;
  final bool isCompleted;
  final bool isActive;

  const _StepItem({
    required this.number,
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = isCompleted || isActive;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: hasGradient
                ? const LinearGradient(
                    colors: [Color(0xFF4FD17B), Color(0xFF34B96B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hasGradient ? null : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
            boxShadow: hasGradient
                ? [
                    BoxShadow(
                      color: const Color(0xFF34B96B).withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    number,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : const Color(0xFF7C8592),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.textDark : AppColors.textSoft,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;

  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 2.5,
        margin: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color:
              isCompleted ? const Color(0xFF34B96B) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isPoint;

  const _DetailSection({
    required this.title,
    required this.content,
    this.isPoint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSoft,
            ),
          ),
        ),
        Expanded(
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isPoint ? FontWeight.w700 : FontWeight.w600,
              color: isPoint ? const Color(0xFFF59E0B) : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
