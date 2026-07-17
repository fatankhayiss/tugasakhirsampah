import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_config.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final response = await ApiService.instance.get(ApiConfig.driverHistory);
    if (response.success && response.data is List) {
      setState(() {
        _history = response.data as List;
        _isLoading = false;
      });
    } else {
      setState(() {
        _history = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        color: DriverColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              backgroundColor: DriverColors.background,
              elevation: 0,
              toolbarHeight: 84,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: DriverColors.textDark),
                  ),
                  const Text(
                    'Riwayat Penjemputan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchHistory,
                    icon: const Icon(Icons.refresh_rounded, color: DriverColors.primary),
                  ),
                ],
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: DriverColors.primary),
                          ),
                        ),
                      )
                    : _history.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: DriverStyles.cardRadius,
                                border: Border.all(color: DriverColors.border),
                                boxShadow: DriverStyles.cardShadow,
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.history_toggle_off_rounded, size: 56, color: DriverColors.textMuted),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada riwayat penjemputan',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: DriverColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Semua tugas penjemputan yang telah selesai atau dibatalkan akan tercatat di sini.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      color: DriverColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _history[index];
                                final isCompleted = (item['status'] as String?)?.toLowerCase() == 'completed' || (item['status'] as String?)?.toLowerCase() == 'selesai';
                                final statusColor = DriverStyles.getStatusColor(item['status'] as String?);
                                final statusLabel = DriverStyles.getStatusLabel(item['status'] as String?);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
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
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                                  color: statusColor,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['nama_warga'] ?? 'Warga',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: DriverColors.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'ID: #${item['id_order']}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 12,
                                                      color: DriverColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
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
                                      const SizedBox(height: 16),
                                      const Divider(color: DriverColors.border, height: 1),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, color: DriverColors.primary, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item['alamat_jemput'] ?? '-',
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 14,
                                                color: DriverColors.textDark,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_rounded, color: DriverColors.primary, size: 18),
                                              const SizedBox(width: 10),
                                              Text(
                                                item['tanggal_order'] ?? '',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 13,
                                                  color: DriverColors.textDark,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${item['berat_aktual'] ?? item['estimasi_berat'] ?? '0'} kg',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: DriverColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: _history.length,
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
