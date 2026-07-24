import 'package:flutter/material.dart';
import '../constants/api_config.dart';
import '../services/api_service.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final judul = args?['judul']?.toString() ?? 'Pemberitahuan Tugas';
    final pesan = args?['pesan']?.toString() ?? 'Tugas penjemputan baru atau update status dari sistem.';
    final tanggal = args?['created_at']?.toString() ?? args?['tanggal_order']?.toString() ?? '-';
    final tipe = args?['tipe']?.toString() ?? 'info';
    final isRead = (args?['is_read'] == 1 || args?['is_read'] == true);
    
    final customerName = args?['customer_name']?.toString() ?? args?['nama_warga']?.toString() ?? 'Tidak Diketahui';
    final alamat = args?['alamat_jemput']?.toString() ?? 'Alamat tidak tersedia';
    final orderId = args?['related_id']?.toString() ?? '-';
    
    // Attempt to parse out photo if available (from API updates)
    final String? customerPhoto = args?['customer_photo']?.toString();
    final bool hasOrder = args?['related_id'] != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        ),
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: DriverStyles.cardRadius,
                border: Border.all(color: AppColors.border),
                boxShadow: DriverStyles.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              tipe.toLowerCase() == 'order' || tipe.toLowerCase() == 'pickup' ? Icons.local_shipping_rounded : Icons.notifications_active_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                judul,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tanggal,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text('DIBACA', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade600)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Text('BARU', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'PESAN SISTEM',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pesan,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                  if (hasOrder) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ID Order', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                              Text('#$orderId', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: (customerPhoto != null && customerPhoto.isNotEmpty)
                                    ? ClipOval(
                                        child: Image.network(
                                          customerPhoto,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 20),
                                        ),
                                      )
                                    : const Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alamat,
                                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (hasOrder) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          );
                          final res = await ApiService().getOrderDetail(int.tryParse(orderId) ?? 0);
                          if (context.mounted) Navigator.of(context).pop();

                          if (res['success'] == true && res['data'] != null) {
                            if (context.mounted) {
                              Navigator.of(context).pushReplacementNamed('/pickup-detail', arguments: res['data']);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Gagal memuat detail pesanan'),
                                backgroundColor: AppColors.badgeCancelled,
                              ));
                            }
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Buka Detail Penjemputan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Kembali', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
