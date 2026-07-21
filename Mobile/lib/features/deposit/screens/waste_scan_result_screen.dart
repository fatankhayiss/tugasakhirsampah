import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/detect_result.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_page_transitions.dart';
import 'manual_deposit_screen.dart';

/// Screen displayed after YOLO detection completes.
///
/// Flow:
///   1. Show captured image preview at top (Image.file from local path)
///   2. Show detected labels as selectable chips
///   3. User can Edit category / weight via bottom sheet
///   4. User confirms → navigates to ManualDepositScreen with pre-selected item
class WasteScanResultScreen extends StatefulWidget {
  final DetectResult result;
  final List<WasteItem>? existingCartItems;

  const WasteScanResultScreen({
    super.key,
    required this.result,
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

  // ── Detection selection ──────────────────────────────────────
  String? _selectedLabel;

  // ── Editable state (populated from detection, overridden by Edit sheet) ──
  String? _editedCategory;
  double _editedWeight = 1.0;
  double _editedPricePerKg = 250.0;

  // ── Available categories ─────────────────────────────────────
  static const List<String> _allCategories = [
    'Plastik',
    'Kertas',
    'Kardus',
    'Kaca',
    'Logam',
    'Organik',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Pre-select first label if available
    if (widget.result.labels.isNotEmpty) {
      _selectedLabel = widget.result.labels.first;
      _syncFromDetection(_selectedLabel!);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  /// Sync editable state from the detection data for a given label.
  void _syncFromDetection(String label) {
    _editedCategory = _getCategoryFromDetection(label);
    _editedPricePerKg = _getPriceFromDetection(label);
  }

  double _getPriceFromDetection(String label) {
    final det = widget.result.detections
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (d) =>
              d['label']?.toString() == label ||
              d['nama_sampah']?.toString() == label,
          orElse: () => {},
        );
    if (det.containsKey('harga_per_kg')) {
      return double.tryParse(det['harga_per_kg'].toString()) ?? 250.0;
    }
    return 250.0;
  }

  String _getCategoryFromDetection(String label) {
    final det = widget.result.detections
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (d) =>
              d['label']?.toString() == label ||
              d['nama_sampah']?.toString() == label,
          orElse: () => {},
        );
    return det['kategori']?.toString() ?? 'Plastik';
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────

  void _confirmAndProceed() {
    Navigator.pushReplacement(
      context,
      CustomPageRoute(
        page: ManualDepositScreen(
          initialCartItems: widget.existingCartItems,
          activeScannedItem: _selectedLabel != null
              ? WasteItem(
                  id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
                  name: _editedCategory ?? _selectedLabel!,
                  imageAsset: 'water_bottle',
                  pricePerKg: _editedPricePerKg,
                  weight: _editedWeight,
                  imageUrl: widget.result.uploadedFileUrl,
                  category: _editedCategory,
                  confidence: '95%',
                  isScanned: true,
                )
              : null,
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

  // ─────────────────────────────────────────────────────────────
  // Edit Bottom Sheet
  // ─────────────────────────────────────────────────────────────

  void _openEditSheet() {
    // Local state inside the sheet
    String sheetCategory = _editedCategory ?? _allCategories.first;
    double sheetWeight = _editedWeight;
    final weightController =
        TextEditingController(text: _editedWeight.toString());
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
                      // ── Handle bar ──────────────────────────────────────
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

                      // ── Title ───────────────────────────────────────────
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

                      // ── Category ────────────────────────────────────────
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
                        children: _allCategories.map((cat) {
                          final isSel = sheetCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => sheetCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : const Color(0xFFE5E7EB),
                                  width: isSel ? 2 : 1,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.2),
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
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ── Weight ──────────────────────────────────────────
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 1.50',
                          suffixText: 'Kg',
                          suffixStyle: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEF4444), width: 1.5),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Berat tidak boleh kosong';
                          }
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null) {
                            return 'Masukkan angka yang valid (contoh: 1.50)';
                          }
                          if (parsed <= 0) {
                            return 'Berat harus lebih dari 0';
                          }
                          if (parsed > 100) {
                            return 'Berat maksimal 100 Kg';
                          }
                          return null;
                        },
                        onChanged: (v) {
                          final parsed = double.tryParse(v.trim());
                          if (parsed != null) sheetWeight = parsed;
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Maks. 100 Kg • Desimal diperbolehkan (contoh: 0.25)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Actions ─────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6B7280),
                                side: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final w = double.tryParse(
                                          weightController.text.trim()) ??
                                      sheetWeight;
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _editedCategory = sheetCategory;
                                    _editedWeight = w;
                                  });
                                }
                              },
                              icon: const Icon(Icons.save_rounded, size: 18),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
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

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
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
          // Edit button in AppBar — always visible when there is a result
          if (widget.result.hasDetections)
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
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Worker unavailable
    if (widget.result.workerUnavailable) {
      return _buildFallbackView(
        icon: Icons.cloud_off_rounded,
        iconColor: const Color(0xFF6B7280),
        title: 'Fitur deteksi sampah sedang tidak tersedia',
        subtitle: 'Silakan pilih kategori sampah secara manual.',
        showManualButton: true,
      );
    }

    // HTTP / network error
    if (!widget.result.success && !widget.result.workerUnavailable) {
      return _buildFallbackView(
        icon: Icons.wifi_off_rounded,
        iconColor: const Color(0xFFEF4444),
        title: 'Gagal menghubungi server',
        subtitle:
            widget.result.errorMessage ?? 'Periksa koneksi internet Anda.',
        showManualButton: true,
      );
    }

    // Low confidence / nothing detected
    if (!widget.result.hasDetections) {
      return _buildFallbackView(
        icon: Icons.search_off_rounded,
        iconColor: const Color(0xFFD97706),
        title: 'Sampah tidak dapat dikenali',
        subtitle:
            'Pastikan sampah terlihat jelas dalam foto.\nSilakan coba lagi atau pilih manual.',
        showManualButton: true,
      );
    }

    // Success — show detected labels
    return _buildSuccessView();
  }

  // ─────────────────────────────────────────────────────────────
  // Success view
  // ─────────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Captured image preview ─────────────────────────────
          _buildImagePreview(),
          const SizedBox(height: 16),

          // ── 2. AI Detection result header ─────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sampah terdeteksi!',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              // Edit button inline
              OutlinedButton.icon(
                onPressed: _openEditSheet,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih kategori yang sesuai dengan sampah Anda:',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // ── 3. Label chips ────────────────────────────────────────
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.result.labels.map((label) {
              final isSelected = _selectedLabel == label;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedLabel = label;
                  _syncFromDetection(label);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── 4. Detection detail card ──────────────────────────────
          if (_selectedLabel != null) _buildDetailCard(_selectedLabel!),
          const SizedBox(height: 28),

          // ── 5. Edited weight summary pill ─────────────────────────
          _buildWeightSummary(),
          const SizedBox(height: 24),

          // ── 6. Confirm button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _selectedLabel != null ? _confirmAndProceed : null,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Konfirmasi & Lanjutkan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 7. Manual fallback ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _goManual,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Pilih Kategori Manual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Image preview card
  // ─────────────────────────────────────────────────────────────

  Widget _buildImagePreview() {
    final localPath = widget.result.localImagePath;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image
          SizedBox(
            height: 200,
            width: double.infinity,
            child: localPath != null && File(localPath).existsSync()
                ? Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    frameBuilder: (ctx, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      return Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, e, s) => _imageFallback(),
                  )
                : _imageFallback(),
          ),

          // "Hasil Scan AI" chip overlay — top right
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome_rounded,
                      size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Hasil Scan AI',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded,
              size: 48, color: Color(0xFF9CA3AF)),
          SizedBox(height: 8),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Weight summary pill
  // ─────────────────────────────────────────────────────────────

  Widget _buildWeightSummary() {
    final estimatedPoints =
        (_editedWeight * _editedPricePerKg).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              icon: Icons.scale_rounded,
              iconColor: const Color(0xFF3B82F6),
              bgColor: const Color(0xFFEFF6FF),
              label: 'Estimasi Berat',
              value: '${_editedWeight.toStringAsFixed(2)} Kg',
            ),
          ),
          Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _summaryTile(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFFFBEB),
              label: 'Est. Poin',
              value: estimatedPoints,
            ),
          ),
          Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _summaryTile(
              icon: Icons.category_rounded,
              iconColor: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
              label: 'Kategori',
              value: _editedCategory ?? '-',
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
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10,
            color: Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Detection detail card
  // ─────────────────────────────────────────────────────────────

  Widget _buildDetailCard(String label) {
    final det = widget.result.detections
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (d) =>
              d['label']?.toString() == label ||
              d['nama_sampah']?.toString() == label,
          orElse: () => {},
        );
    if (det.isEmpty || det['found'] == false) return const SizedBox.shrink();

    final nama = det['nama_sampah'] ?? label;
    final harga = det['harga_per_kg'];
    final desk = det['deskripsi'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.recycling_rounded,
                    color: Color(0xFF16A34A), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama.toString(),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Kategori: ${_editedCategory ?? det['kategori'] ?? '-'}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (harga != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rp$harga/kg',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
          if (desk != null && desk.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              desk.toString(),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Fallback view (error / no detection)
  // ─────────────────────────────────────────────────────────────

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
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Scan Ulang',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
