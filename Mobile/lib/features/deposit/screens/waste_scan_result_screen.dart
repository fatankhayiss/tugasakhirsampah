import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/scan_record.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/waste_labels.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/repositories/detect_repository.dart';
import '../../../core/repositories/waste_repository.dart';
import 'manual_deposit_screen.dart';

class WasteScanResultScreen extends StatefulWidget {
  final int? detectionId;
  final String? localImagePath;
  final List<WasteItem>? existingCartItems;

  const WasteScanResultScreen({
    super.key,
    required this.detectionId,
    this.localImagePath,
    this.existingCartItems,
  });

  @override
  State<WasteScanResultScreen> createState() => _WasteScanResultScreenState();
}

class _WasteScanResultScreenState extends State<WasteScanResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  ScanRecord? _record;
  bool _isLoading = true;
  String? _errorMessage;

  List<WasteItem> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.detectionId == null) {
      setState(() {
        _errorMessage = 'ID Deteksi tidak valid.';
        _isLoading = false;
      });
      return;
    }

    final repo = DetectRepository();
    final record = await repo.getScanRecord(widget.detectionId!);
    final wasteRepo = WasteRepository();
    final categories = await wasteRepo.getAvailableWaste();

    if (mounted) {
      setState(() {
        _availableCategories = categories;
        if (record != null) {
          _record = record;
        } else {
          _errorMessage = 'Gagal memuat data deteksi dari server.';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _confirmAndProceed() {
    if (_record == null) return;

    final imageUrl = widget.localImagePath?.isNotEmpty == true
        ? widget.localImagePath
        : _record!.imageUrl;

    double pricePerKg = 0;
    if (_record!.berat > 0) {
      pricePerKg = _record!.estimasiPoin / _record!.berat;
    }

    Navigator.pushReplacement(
      context,
      CustomPageRoute(
        page: ManualDepositScreen(
          initialCartItems: widget.existingCartItems,
          activeScannedItem: WasteItem(
            id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
            name: _record!.kategoriSampah,
            imageAsset: 'water_bottle', // generic icon fallback
            pricePerKg: pricePerKg,
            weight: _record!.berat,
            imageUrl: imageUrl,
            category: _record!.kategoriSampah,
            confidence: '${(_record!.confidence * 100).toStringAsFixed(0)}%',
            isScanned: true,
          ),
        ),
      ),
    );
  }

  void _goManual() {
    Navigator.pushReplacement(
      context,
      CustomPageRoute(
        page: ManualDepositScreen(
          initialCartItems: widget.existingCartItems,
        ),
      ),
    );
  }

  void _openEditSheet() {
    if (_record == null) return;

    WasteItem? selectedCategory;
    try {
      selectedCategory = _availableCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == _record!.kategoriSampah.toLowerCase()
      );
    } catch (_) {
      selectedCategory = _availableCategories.isNotEmpty 
          ? _availableCategories.first 
          : WasteItem(id: '0', name: _record!.kategoriSampah, imageAsset: '', pricePerKg: 0);
    }

    double sheetWeight = _record!.berat;
    final weightController = TextEditingController(text: sheetWeight.toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Edit Hasil Deteksi',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Kategori Sampah',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableCategories.map((cat) {
                          final isSel = selectedCategory?.id == cat.id;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSel ? AppColors.primary : const Color(0xFFE5E7EB),
                                  width: isSel ? 2 : 1,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSel) ...[
                                    const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.white : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Estimasi Berat',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 1.50',
                          suffixText: 'Kg',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Berat tidak boleh kosong';
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null) return 'Masukkan angka yang valid';
                          if (parsed <= 0) return 'Berat harus > 0';
                          return null;
                        },
                        onChanged: (v) {
                          final parsed = double.tryParse(v.trim());
                          if (parsed != null) {
                            setSheetState(() => sheetWeight = parsed);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimasi Poin',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                            Text(
                              '${(sheetWeight * (selectedCategory?.pricePerKg ?? 0)).toStringAsFixed(0)} Poin',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final w = double.tryParse(weightController.text.trim()) ?? sheetWeight;
                                  
                                  // Show loading overlay
                                  showDialog(
                                    context: ctx,
                                    barrierDismissible: false,
                                    builder: (c) => const Center(child: CircularProgressIndicator()),
                                  );

                                  final success = await DetectRepository().updateScanRecord(widget.detectionId!, selectedCategory?.name ?? 'Lainnya', w);
                                  
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(ctx); // Close loading overlay
                                  
                                  if (success) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(ctx); // Close bottom sheet
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                      content: Text('Hasil scan berhasil diperbarui.'),
                                      backgroundColor: Colors.green,
                                    ));
                                    _fetchRecord(); // Refresh data from DB
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                      content: Text('Gagal menyimpan perubahan.'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }
                              },
                              icon: const Icon(Icons.save_rounded, size: 18),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Deteksi Sampah',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _record != null)
            IconButton(
              tooltip: 'Edit Kategori & Berat',
              icon: const Icon(Icons.edit_rounded, color: Color(0xFF6B7280)),
              onPressed: _openEditSheet,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildBody(),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildFallbackView(
        icon: Icons.wifi_off_rounded,
        iconColor: const Color(0xFFEF4444),
        title: 'Gagal memuat data',
        subtitle: _errorMessage!,
        showManualButton: true,
      );
    }

    if (_record == null) {
      return _buildFallbackView(
        icon: Icons.search_off_rounded,
        iconColor: const Color(0xFFD97706),
        title: 'Sampah tidak dapat dikenali',
        subtitle: 'Pastikan sampah terlihat jelas dalam foto.',
        showManualButton: true,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sampah terdeteksi!',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openEditSheet,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(),
          const SizedBox(height: 24),
          _buildWeightSummary(),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirmAndProceed,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Konfirmasi & Lanjutkan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _goManual,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Pilih Kategori Manual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final localPath = widget.localImagePath;
    final networkUrl = _record?.imageUrl;

    Widget imageWidget;
    if (localPath != null && localPath.isNotEmpty) {
      imageWidget = Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => networkUrl != null && networkUrl.isNotEmpty
            ? _buildNetworkImage(networkUrl)
            : _imageFallback(),
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      imageWidget = _buildNetworkImage(networkUrl);
    } else {
      imageWidget = _imageFallback();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: SizedBox(width: double.infinity, child: imageWidget),
          ),
          const Positioned(
            top: 10, right: 10,
            child: _ScanBadge(),
          ),
          if (_record != null && _record!.confidence > 0)
            Positioned(
              bottom: 10, left: 10,
              child: _ConfidenceBadge(
                confidence: '${(_record!.confidence * 100).toStringAsFixed(0)}%',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFF9CA3AF)),
          SizedBox(height: 8),
          Text('Gambar tidak tersedia', style: TextStyle(color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _buildWeightSummary() {
    if (_record == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              icon: Icons.scale_rounded,
              iconColor: AppColors.primary,
              bgColor: AppColors.softGreen,
              label: 'Estimasi Berat',
              value: '${_record!.berat.toStringAsFixed(2)} Kg',
            ),
          ),
          Container(width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.border),
          Expanded(
            child: _summaryTile(
              icon: Icons.stars_rounded,
              iconColor: AppColors.primary,
              bgColor: AppColors.softGreen,
              label: 'Est. Poin',
              value: _record!.estimasiPoin.toStringAsFixed(0),
            ),
          ),
          Container(width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.border),
          Expanded(
            child: _summaryTile(
              icon: Icons.category_rounded,
              iconColor: AppColors.primary,
              bgColor: AppColors.softGreen,
              label: 'Kategori',
              value: WasteLabels.display(_record!.kategoriSampah),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSoft), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDetailCard() {
    if (_record == null) return const SizedBox.shrink();
    
    double harga = 0;
    if (_record!.berat > 0) harga = _record!.estimasiPoin / _record!.berat;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(WasteLabels.display(_record!.kategoriSampah), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const Text('Hasil deteksi dan prediksi sistem', style: TextStyle(fontSize: 12, color: AppColors.textSoft)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(20)),
                child: Text('Rp${harga.toStringAsFixed(0)}/kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackView({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showManualButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSoft, height: 1.5)),
            if (showManualButton) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _goManual,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Pilih Kategori Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Scan Ulang', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600))),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanBadge extends StatelessWidget {
  const _ScanBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text('Hasil Scan AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String confidence;
  const _ConfidenceBadge({required this.confidence});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text('AI $confidence', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
