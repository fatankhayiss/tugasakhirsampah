import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/repositories/waste_repository.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../core/navigation/app_page_transitions.dart';
import 'checkout_screen.dart';
import 'scan_deposit_screen.dart';

class ManualDepositScreen extends StatefulWidget {
  final List<WasteItem>? initialCartItems;
  final WasteItem? activeScannedItem;

  const ManualDepositScreen({
    super.key,
    this.initialCartItems,
    this.activeScannedItem,
  });

  @override
  State<ManualDepositScreen> createState() => _ManualDepositScreenState();
}

class _ManualDepositScreenState extends State<ManualDepositScreen> {
  final repository = WasteRepository();
  List<WasteItem> availableItems = [];
  List<WasteItem> cartItems = [];
  bool isLoading = true;
  WasteItem? _activeScannedItem;
  final TextEditingController _topWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartItems = widget.initialCartItems != null ? List<WasteItem>.from(widget.initialCartItems!) : [];
    _activeScannedItem = widget.activeScannedItem;
    if (_activeScannedItem != null) {
      if (!cartItems.any((i) => i.id == _activeScannedItem!.id)) {
        cartItems.add(_activeScannedItem!);
      }
      _topWeightController.text = _activeScannedItem!.weight.toStringAsFixed(
        _activeScannedItem!.weight.truncateToDouble() == _activeScannedItem!.weight ? 1 : 2,
      );
    } else if (cartItems.any((i) => i.isScanned || i.imageUrl != null)) {
      _activeScannedItem = cartItems.lastWhere((i) => i.isScanned || i.imageUrl != null);
      _topWeightController.text = _activeScannedItem!.weight.toStringAsFixed(
        _activeScannedItem!.weight.truncateToDouble() == _activeScannedItem!.weight ? 1 : 2,
      );
    }
    _loadWasteData();
  }

  @override
  void dispose() {
    _topWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadWasteData() async {
    try {
      final items = await repository.getAvailableWaste();
      if (mounted) {
        setState(() {
          availableItems = items.isEmpty ? _getFallbackItems() : items;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          availableItems = _getFallbackItems();
          isLoading = false;
        });
      }
    }
  }

  List<WasteItem> _getFallbackItems() {
    return [
      WasteItem(
        id: '1',
        name: 'Plastik PET',
        imageAsset: 'water_bottle',
        pricePerKg: 250,
      ),
      WasteItem(
        id: '2',
        name: 'Kardus',
        imageAsset: 'inventory_2',
        pricePerKg: 150,
      ),
      WasteItem(
        id: '3',
        name: 'Kertas',
        imageAsset: 'description',
        pricePerKg: 180,
      ),
      WasteItem(
        id: '4',
        name: 'Kaleng',
        imageAsset: 'liquor',
        pricePerKg: 300,
      ),
    ];
  }

  Widget _buildItemImage(WasteItem item, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      if (item.imageUrl!.startsWith('http://') || item.imageUrl!.startsWith('https://')) {
        return Image.network(
          item.imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => Container(
            width: width,
            height: height,
            color: const Color(0xFFEAF1FB),
            child: const Icon(Icons.broken_image, color: AppColors.primaryBlue),
          ),
        );
      } else {
        return Image.file(
          File(item.imageUrl!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => Container(
            width: width,
            height: height,
            color: const Color(0xFFEAF1FB),
            child: const Icon(Icons.broken_image, color: AppColors.primaryBlue),
          ),
        );
      }
    }
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEAF1FB),
      child: const Icon(Icons.recycling, color: AppColors.primaryBlue, size: 24),
    );
  }

  void _openWeightBottomSheet(WasteItem item, {bool isEditing = false}) {
    double tempWeight = isEditing && item.weight > 0 ? item.weight : 1.0;
    final TextEditingController weightController = TextEditingController(
      text: tempWeight.toStringAsFixed(tempWeight.truncateToDouble() == tempWeight ? 1 : 2),
    );
    final FocusNode weightFocusNode = FocusNode();
    String? weightError;

    AppDialogTransitions.showSlideBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void validateAndUpdate(String text) {
              if (text.trim().isEmpty) {
                setModalState(() {
                  weightError = 'Berat sampah tidak boleh kosong';
                });
                return;
              }
              final cleanText = text.replaceAll(',', '.');
              if (cleanText.contains('-')) {
                setModalState(() {
                  weightError = 'Berat sampah tidak boleh bernilai negatif';
                });
                return;
              }
              final parsed = double.tryParse(cleanText);
              if (parsed == null) {
                setModalState(() {
                  weightError = 'Format angka tidak valid';
                });
                return;
              }
              if (parsed <= 0) {
                setModalState(() {
                  weightError = 'Berat sampah harus lebih dari 0 Kg';
                });
                return;
              }
              if (parsed > 1000) {
                setModalState(() {
                  weightError = 'Berat maksimal adalah 1000 Kg';
                });
                return;
              }
              setModalState(() {
                tempWeight = parsed;
                weightError = null;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEditing ? 'Ubah Perkiraan Berat' : 'Perkiraan Berat',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'BERAT SAMPAH (KG)',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      focusNode: weightFocusNode,
                      cursorColor: AppColors.primary,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 2.5',
                        errorText: weightError,
                        errorStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        suffixText: 'Kg',
                        suffixStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAF8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      onChanged: validateAndUpdate,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'CEPAT PILIH BERAT',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1.0, 2.0, 3.0, 5.0, 10.0].map((w) {
                          final isSelected = tempWeight == w;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                '${w.toInt()} Kg',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: const Color(0xFFF8FAF8),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    tempWeight = w;
                                    weightController.text = w.toInt().toString();
                                    weightError = null;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8EF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimasi Poin:',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSoft,
                            ),
                          ),
                          Text(
                            '${(tempWeight * item.pricePerKg).toInt()} Poin',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: isEditing ? 'Simpan Perubahan' : 'Simpan',
                      isGreen: false,
                      onPressed: () {
                        validateAndUpdate(weightController.text);
                        if (weightError != null) return;
                        setState(() {
                          if (isEditing) {
                            item.weight = tempWeight;
                            if (_activeScannedItem?.id == item.id) {
                              _topWeightController.text = tempWeight.toStringAsFixed(
                                tempWeight.truncateToDouble() == tempWeight ? 1 : 2,
                              );
                            }
                          } else {
                            final existingIndex = cartItems.indexWhere((i) => i.id == item.id);
                            if (existingIndex >= 0) {
                              cartItems[existingIndex].weight = tempWeight;
                            } else {
                              item.weight = tempWeight;
                              cartItems.add(item);
                            }
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteItemDialog(WasteItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Item',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus hasil scan ini?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: AppColors.textSoft,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSoft),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                cartItems.removeWhere((i) => i.id == item.id);
                if (_activeScannedItem?.id == item.id) {
                  _activeScannedItem = cartItems.isNotEmpty ? cartItems.last : null;
                  if (_activeScannedItem != null) {
                    _topWeightController.text = _activeScannedItem!.weight.toStringAsFixed(
                      _activeScannedItem!.weight.truncateToDouble() == _activeScannedItem!.weight ? 1 : 2,
                    );
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalWeight = cartItems.fold(0.0, (sum, item) => sum + item.weight);
    final int totalEstPoints = cartItems.fold(0, (sum, item) => sum + item.totalPrice.toInt());
    final bool isAiFlow = _activeScannedItem != null || cartItems.any((i) => i.isScanned || i.imageUrl != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isAiFlow ? 'Setorkan Sampah' : 'Pilih Sampah',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        isAiFlow
                            ? 'Lengkapi estimasi berat sampah hasil scan'
                            : 'Pilih jenis sampah yang akan dijemput',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                if (_activeScannedItem != null) ...[
                  _buildScannedReviewSection(_activeScannedItem!),
                ],

                if (isAiFlow) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Sampah Dipindai',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${cartItems.length} Item',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (cartItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: AppColors.primaryBlue, size: 36),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada sampah yang dipindai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...cartItems.map((item) => _buildSelectedCard(item)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: ScanDepositScreen(existingCartItems: cartItems),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue),
                      label: const Text(
                        'Scan Lagi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Manual Category Section
                Text(
                  isAiFlow ? 'Atau Tambah Kategori Manual' : 'Kategori Sampah',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ...availableItems.map((item) => _buildCategoryCard(item)),

                if (!isAiFlow && cartItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sampah Dipilih',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${cartItems.length} Item',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...cartItems.map((item) => _buildSelectedCard(item)),
                ],

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAiFlow ? AppColors.softBlue : const Color(0xFFEAF8EF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAiFlow
                          ? AppColors.primaryBlue.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isAiFlow ? AppColors.primaryBlue : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Estimasi poin hanya sebagai informasi awal. Poin resmi akan dihitung berdasarkan berat aktual setelah divalidasi oleh petugas Bank Sampah.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            height: 1.5,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCol('JUMLAH ITEM', '${cartItems.length} Item'),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.border,
                  ),
                  _buildSummaryCol(
                    'TOTAL BERAT',
                    '${totalWeight.toStringAsFixed(1)} Kg',
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.border,
                  ),
                  _buildSummaryCol(
                    'EST. POIN',
                    '$totalEstPoints Poin',
                    isAccent: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                text: isAiFlow ? 'Setorkan Sampah' : 'Lanjutkan Penjemputan',
                isGreen: false,
                        onPressed: cartItems.isEmpty || (_activeScannedItem != null && _activeScannedItem!.weight <= 0)
                            ? null
                            : () async {
                                if (cartItems.any((i) => i.weight <= 0)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pastikan berat semua sampah lebih dari 0 Kg.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                );

                                try {
                                  final profile = await ProfileRepository().getProfile();
                                  if (!mounted) return;
                                  Navigator.pop(context); // Close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutScreen(cartItems: cartItems, profile: profile),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  Navigator.pop(context); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal mengambil profil: $e'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannedReviewSection(WasteItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hasil Pemindaian AI',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildItemImage(item, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JENIS SAMPAH',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSoft,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.confidence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item.confidence!,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: AppColors.textSoft,
                    ),
                  ),
                  Text(
                    item.category ?? 'Plastik',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimasi Poin',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: AppColors.textSoft,
                    ),
                  ),
                  Text(
                    '${item.pricePerKg.toInt()} Poin / Kg',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.weight <= 0 ? Colors.redAccent : AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BERAT SAMPAH (KG)',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _topWeightController,
                cursorColor: AppColors.primary,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: 1.5',
                  hintStyle: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w400),
                  suffixText: 'Kg',
                  suffixStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAF8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (val) {
                  final cleanText = val.replaceAll(',', '.');
                  final w = double.tryParse(cleanText) ?? 0.0;
                  setState(() {
                    item.weight = w;
                  });
                },
              ),
              if (item.weight <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Berat sampah wajib diisi dan lebih dari 0 Kg',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryCard(WasteItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Poin: ${item.pricePerKg.toInt()}/kg',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () => _openWeightBottomSheet(item),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Tambah',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(WasteItem item) {
    final bool isScanned = item.isScanned || item.imageUrl != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isScanned ? AppColors.softBlue : const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isScanned
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildItemImage(item, width: 48, height: 48),
                  )
                : const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.weight.toStringAsFixed(1)} Kg • ${item.totalPrice.toInt()} Poin',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: isScanned ? AppColors.primaryBlue : AppColors.textSoft,
              size: 20,
            ),
            onPressed: () {
              if (isScanned) {
                setState(() {
                  _activeScannedItem = item;
                  _topWeightController.text = item.weight.toStringAsFixed(
                    item.weight.truncateToDouble() == item.weight ? 1 : 2,
                  );
                });
              } else {
                _openWeightBottomSheet(item, isEditing: true);
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            onPressed: () => _showDeleteItemDialog(item),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCol(
    String label,
    String value, {
    bool isAccent = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSoft,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isAccent ? AppColors.primaryBlue : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
