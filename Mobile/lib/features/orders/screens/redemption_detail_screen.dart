import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/repositories/order_repository.dart';
import '../../orders/models/ongoing_order_model.dart';
import '../../orders/models/history_item_model.dart';
import '../../../core/constants/api_config.dart';

class RedemptionDetailScreen extends StatefulWidget {
  final String redemptionId;
  final OngoingOrderModel? ongoingItem;
  final HistoryItemModel? historyItem;

  const RedemptionDetailScreen({
    super.key,
    required this.redemptionId,
    this.ongoingItem,
    this.historyItem,
  });

  @override
  State<RedemptionDetailScreen> createState() => _RedemptionDetailScreenState();
}

class _RedemptionDetailScreenState extends State<RedemptionDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final apiData = await OrderRepository.instance.getRedemptionDetail(widget.redemptionId);
    if (mounted) {
      setState(() {
        if (apiData != null) {
          _data = apiData;
        } else if (widget.ongoingItem != null) {
          _data = {
            'id': widget.ongoingItem!.id,
            'transaction_code': widget.ongoingItem!.transactionCode,
            'destination_type': widget.ongoingItem!.destination ?? 'E-Wallet',
            'provider': widget.ongoingItem!.provider ?? '-',
            'account_name': widget.ongoingItem!.accountName ?? '-',
            'account_number': widget.ongoingItem!.accountNumber ?? '-',
            'redeem_point': int.tryParse(widget.ongoingItem!.estimatedPoints?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
            'estimated_amount': widget.ongoingItem!.estimatedAmount ?? 0.0,
            'status': widget.ongoingItem!.rawStatus ?? (widget.ongoingItem!.status == OngoingStatus.pending ? 'pending' : 'processing'),
            'created_at': widget.ongoingItem!.date,
            'admin_note': widget.ongoingItem!.adminNote,
            'transfer_proof': null,
            'rejection_reason': null,
          };
        } else if (widget.historyItem != null) {
          _data = {
            'id': widget.historyItem!.id,
            'transaction_code': widget.historyItem!.transactionCode,
            'destination_type': widget.historyItem!.destination ?? 'E-Wallet',
            'provider': widget.historyItem!.provider ?? '-',
            'account_name': widget.historyItem!.accountName ?? '-',
            'account_number': widget.historyItem!.accountNumber ?? '-',
            'redeem_point': int.tryParse(widget.historyItem!.points.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
            'estimated_amount': widget.historyItem!.estimatedAmount ?? 0.0,
            'status': widget.historyItem!.rawStatus ?? 'completed',
            'created_at': widget.historyItem!.date,
            'admin_note': widget.historyItem!.adminNote,
            'transfer_proof': widget.historyItem!.transferProof,
            'rejection_reason': widget.historyItem!.rejectionReason,
          };
        }
        _isLoading = false;
      });
    }
  }

  String _maskAccount(String? number) {
    if (number == null || number.isEmpty || number == '-') return '-';
    if (number.length <= 4) return '****$number';
    return '${'****' * ((number.length - 4) ~/ 4 + 1)}${number.substring(number.length - 4)}';
  }

  int _getStepIndex(String status) {
    final s = status.toLowerCase();
    if (s == 'rejected' || s == 'cancelled') return 3;
    if (s == 'completed') return 3;
    if (s == 'processing') return 2;
    if (s == 'pending') return 1;
    return 0;
  }

  String _getStatusTitle(String status) {
    final s = status.toLowerCase();
    if (s == 'rejected') return 'Ditolak';
    if (s == 'completed') return 'Selesai';
    if (s == 'processing') return 'Sedang Diproses';
    return 'Menunggu Verifikasi';
  }

  Color _getStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s == 'rejected') return const Color(0xFFFEE2E2);
    if (s == 'completed') return const Color(0xFFDDF8E7);
    if (s == 'processing') return const Color(0xFFEAF8EF);
    return const Color(0xFFFEF3C7);
  }

  Color _getStatusTextColor(String status) {
    final s = status.toLowerCase();
    if (s == 'rejected') return const Color(0xFFDC2626);
    if (s == 'completed') return const Color(0xFF2DAA63);
    if (s == 'processing') return AppColors.primary;
    return const Color(0xFFD97706);
  }

  String _getOrFormatTrxNumber(Map<String, dynamic>? data, String id, String dateStr) {
    if (data != null && data['transaction_code'] != null && data['transaction_code'].toString().trim().isNotEmpty) {
      return data['transaction_code'].toString().trim();
    }
    if (data != null && data['transaction_number'] != null && data['transaction_number'].toString().trim().isNotEmpty) {
      return data['transaction_number'].toString().trim();
    }
    if (id.toUpperCase().startsWith('TRX-')) return id;
    String cleanDate = '20260716';
    if (dateStr.length >= 10) {
      final parts = dateStr.substring(0, 10).split(RegExp(r'[^0-9]'));
      if (parts.isNotEmpty) cleanDate = parts.join('');
    }
    final cleanId = id.replaceAll(RegExp(r'[^0-9]'), '');
    final paddedId = cleanId.isEmpty ? id.padLeft(6, '0') : cleanId.padLeft(6, '0');
    return 'TRX-$cleanDate-$paddedId';
  }

  @override
  Widget build(BuildContext context) {
    final status = _data?['status']?.toString().toLowerCase() ?? 'pending';
    final dest = _data?['destination_type']?.toString() ?? '-';
    final provider = _data?['provider']?.toString() ?? '-';
    final accNum = _data?['account_number']?.toString() ?? '-';
    final accName = _data?['account_name']?.toString() ?? '-';
    final pts = (_data?['redeem_point'] as num?)?.toInt() ?? 0;
    final amt = (_data?['estimated_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = _data?['created_at']?.toString() ?? '-';
    final processedAt = _data?['processed_at']?.toString() ?? _data?['processing_at']?.toString();
    final completedAt = _data?['completed_at']?.toString();
    final adminNote = _data?['admin_note']?.toString();
    final rejectionReason = _data?['rejection_reason']?.toString() ?? adminNote;
    final submittedAt = _data?['submitted_at']?.toString() ?? createdAt;
    final verifiedAt = _data?['verified_at']?.toString() ?? processedAt;
    final proofUrl = _data?['transfer_proof']?.toString() ?? _data?['transfer_proof_url']?.toString();
    final trxNumber = _getOrFormatTrxNumber(_data, widget.redemptionId, createdAt);
    final estTime = _data?['estimated_processing_time']?.toString() ?? '1x24 Jam Kerja';
    final convRate = _data?['conversion_rate']?.toString() ?? (pts > 0 && amt > 0 ? '100 Poin = Rp ${((amt / pts) * 100).toStringAsFixed(0)}' : '100 Poin = Rp 1.000');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Tukar Poin',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _data == null
              ? const Center(
                  child: Text(
                    'Data penukaran tidak ditemukan',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDetail,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Part 13: Information Banner
                        _buildInfoBanner(),

                        // Header Status (Part 16)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(status),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  status == 'rejected'
                                      ? Icons.cancel_outlined
                                      : (status == 'completed'
                                          ? Icons.check_circle_outline
                                          : LucideIcons.clock),
                                  color: _getStatusTextColor(status),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Penukaran #$trxNumber',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getStatusTitle(status),
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: _getStatusTextColor(status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Part 15: Admin Note (Color-coded)
                        if (rejectionReason != null && rejectionReason.trim().isNotEmpty && status == 'rejected')
                          _buildAdminNoteCard(rejectionReason.trim(), status),

                        // Section 1: Timeline Progress (Part 14)
                        _buildSectionCard(
                          icon: LucideIcons.git_commit_vertical,
                          title: 'Status Penukaran',
                          child: _build4StageTimeline(status, submittedAt, verifiedAt, processedAt, completedAt),
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Informasi Penukaran (Part 11 & Part 12)
                        _buildSectionCard(
                          icon: LucideIcons.wallet,
                          title: 'Informasi Penukaran',
                          child: Column(
                            children: [
                              _DetailRow(title: 'Nomor Transaksi', content: trxNumber),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Status Saat Ini', content: _getStatusTitle(status), contentStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: _getStatusTextColor(status))),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Waktu Pengajuan', content: createdAt),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Estimasi Proses', content: estTime),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Tujuan', content: dest),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Penyedia Layanan', content: provider),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Nomor Rekening / HP', content: _maskAccount(accNum)),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Nama Pemilik', content: accName),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Kurs Penukaran', content: convRate),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(title: 'Poin Ditukar', content: '$pts Poin'),
                              const Divider(height: 24, color: AppColors.border),
                              _DetailRow(
                                title: 'Estimasi Pencairan',
                                content: 'Rp ${amt.toStringAsFixed(0)}',
                                contentStyle: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2DAA63),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Waktu & Catatan
                        _buildSectionCard(
                          icon: LucideIcons.calendar,
                          title: 'Riwayat Waktu',
                          child: Column(
                            children: [
                              _DetailRow(title: 'Waktu Pengajuan', content: createdAt),
                              if (processedAt != null && processedAt.isNotEmpty) ...[
                                const Divider(height: 24, color: AppColors.border),
                                _DetailRow(title: 'Waktu Diproses', content: processedAt),
                              ],
                              if (completedAt != null && completedAt.isNotEmpty) ...[
                                const Divider(height: 24, color: AppColors.border),
                                _DetailRow(title: status == 'rejected' ? 'Waktu Ditolak' : 'Waktu Selesai', content: completedAt),
                              ],
                            ],
                          ),
                        ),

                        // Part 17: Proof of Transfer (Conditional)
                        if (proofUrl != null && proofUrl.trim().isNotEmpty && proofUrl != '-')
                          _buildProofSection(proofUrl.trim()),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBE5CA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Penukaran akan diproses secara manual oleh Admin setelah verifikasi.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B6A41),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNoteCard(String note, String status) {
    final isRejected = status.toLowerCase() == 'rejected';
    final bgColor = isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFEAF8EF);
    final borderColor = isRejected ? const Color(0xFFFECACA) : const Color(0xFFBBE5CA);
    final iconColor = isRejected ? const Color(0xFFDC2626) : const Color(0xFF1B6A41);
    final textColor = isRejected ? const Color(0xFFDC2626) : const Color(0xFF1B6A41);
    final iconData = isRejected ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Admin',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSection(String proofUrl) {
    return _buildSectionCard(
      icon: LucideIcons.image,
      title: 'Bukti Transfer',
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                children: [
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: Image.network(
                        '${ApiConfig.baseUrl}/bank_sampah/$proofUrl',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  '${ApiConfig.baseUrl}/bank_sampah/$proofUrl',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(40),
                    color: const Color(0xFFF9FAFB),
                    child: const Column(
                      children: [
                        Icon(LucideIcons.image_off, color: AppColors.textSoft, size: 40),
                        SizedBox(height: 12),
                        Text(
                          'Gagal memuat gambar bukti',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textSoft),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.maximize, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build4StageTimeline(
    String currentStatus,
    String? submittedAt,
    String? verifiedAt,
    String? processingAt,
    String? completedAt,
  ) {
    final stages = [
      {
        'title': 'Permintaan Dikirim',
        'desc': 'Permintaan tukar poin telah diterima dan dicatat dalam sistem',
        'time': submittedAt,
      },
      {
        'title': 'Menunggu Verifikasi Admin',
        'desc': 'Tim Admin sedang memeriksa kesesuaian data rekening/E-Wallet Anda',
        'time': verifiedAt,
      },
      {
        'title': 'Admin Memproses Transfer',
        'desc': 'Proses pengiriman dana ke rekening tujuan sedang berlangsung',
        'time': processingAt,
      },
      {
        'title': currentStatus == 'rejected' ? 'Penukaran Ditolak' : 'Transfer Selesai',
        'desc': currentStatus == 'rejected'
            ? 'Penukaran poin ditolak oleh Admin. Poin telah dikembalikan ke saldo Anda'
            : 'Dana berhasil ditransfer ke rekening atau E-Wallet Anda',
        'time': completedAt,
      },
    ];

    final currentStepIndex = _getStepIndex(currentStatus);

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentStepIndex && currentStatus != 'rejected';
        final isActive = index == currentStepIndex;
        final isLast = index == stages.length - 1;
        final isRejectState = isActive && currentStatus == 'rejected' && index == 3;
        final timeStr = stages[index]['time']?.toString().trim();
        final hasTime = timeStr != null && timeStr.isNotEmpty && timeStr != '-';

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
                        : (isRejectState
                            ? const Color(0xFFDC2626)
                            : (isActive ? AppColors.primary : const Color(0xFFE2E8F0))),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: (isRejectState ? const Color(0xFFDC2626) : AppColors.primary).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : (isRejectState
                            ? const Icon(Icons.close, color: Colors.white, size: 14)
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
                                  ))),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: hasTime ? 50 : 38,
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
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isRejectState
                            ? const Color(0xFFDC2626)
                            : (isActive ? AppColors.textDark : (isCompleted ? AppColors.textDark : AppColors.textSoft)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stages[index]['desc']!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isRejectState
                            ? const Color(0xFFDC2626)
                            : (isActive ? AppColors.primary : AppColors.textSoft),
                      ),
                    ),
                    if (hasTime) ...[
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isRejectState
                              ? const Color(0xFFDC2626)
                              : (isActive ? AppColors.primary : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle? contentStyle;

  const _DetailRow({
    required this.title,
    required this.content,
    this.contentStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSoft,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: contentStyle ??
                const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
          ),
        ),
      ],
    );
  }
}
