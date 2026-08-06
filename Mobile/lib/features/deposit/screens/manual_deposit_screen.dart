import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_network_image.dart';
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

  List<WasteItem> _getFallbackItems() => [];

  Widget _buildItemImage(WasteItem item, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    IconData iconData = Icons.recycling;
    if (item.imageAsset == 'water_bottle') iconData = Icons.water_drop;
    if (item.imageAsset == 'inventory_2') iconData = Icons.inventory_2;
    if (item.imageAsset == 'description') iconData = Icons.description;
    if (item.imageAsset == 'liquor') iconData = Icons.liquor;

    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      if (item.imageUrl!.startsWith('/') || item.imageUrl!.startsWith('file://')) {
        return Image.file(
          File(item.imageUrl!.startsWith('/') ? item.imageUrl!.replaceFirst('/', '') : item.imageUrl!.replaceFirst('file://', '')),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => _buildErrorImage(width, height),
        );
      } else {
        return AppNetworkImage(
          item.imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorWidget: _buildErrorImage(width, height),
        );
      }
    }
    return Container(
      width: width,
      height: height,
      color: AppColors.softGreen,
      child: Icon(iconData, color: AppColors.primary, size: (width ?? 40) * 0.5),
    );
  }

  Widget _buildErrorImage(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.softGreen,
      child: const Icon(Icons.broken_image, color: AppColors.primary),
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
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: isEditing ? 'Simpan Perubahan' : 'Simpan',
                      isGreen: true,
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

  void _showWasteDetailPopup(WasteItem item) {
    final matchedItem = availableItems.firstWhere(
      (available) => available.name.toLowerCase() == item.name.toLowerCase(),
      orElse: () => item,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
               const SizedBox(height: 24),
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   ClipRRect(
                     borderRadius: BorderRadius.circular(16),
                     child: (matchedItem.imageUrl != null && matchedItem.imageUrl!.isNotEmpty)
                         ? (matchedItem.imageUrl!.startsWith('/') || matchedItem.imageUrl!.startsWith('file://')
                             ? _buildItemImage(matchedItem, width: 80, height: 80, fit: BoxFit.cover)
                             : AppNetworkImage(
                                 matchedItem.imageUrl!,
                                 width: 80,
                                 height: 80,
                                 fit: BoxFit.cover,
                                 errorWidget: Container(
                                   width: 80, height: 80,
                                   color: AppColors.softGreen,
                                   child: const Icon(Icons.recycling, color: AppColors.primary, size: 32),
                                 ),
                               ))
                         : Container(
                             width: 80, height: 80,
                             color: AppColors.softGreen,
                             child: const Icon(Icons.recycling, color: AppColors.primary, size: 32),
                           ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           matchedItem.name,
                           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark),
                         ),
                         const SizedBox(height: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                           child: Text(
                             matchedItem.category ?? 'Tanpa Kategori',
                             style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 24),
               if (matchedItem.description != null && matchedItem.description!.isNotEmpty) ...[
                 const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                 const SizedBox(height: 8),
                 Text(matchedItem.description!, style: const TextStyle(color: AppColors.textSoft, height: 1.5)),
                 const SizedBox(height: 16),
               ],
               if (matchedItem.caraPengolahan != null && matchedItem.caraPengolahan!.isNotEmpty) ...[
                 const Text('Cara Pengolahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                 const SizedBox(height: 8),
                 Text(matchedItem.caraPengolahan!, style: const TextStyle(color: AppColors.textSoft, height: 1.5)),
                 const SizedBox(height: 24),
               ],
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () => Navigator.pop(context),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.primary,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   ),
                   child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
               )
            ],
          ),
        );
      }
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
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
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
                          color: AppColors.softGreen,
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
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 36),
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
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                      label: const Text(
                        'Scan Lagi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
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
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
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
                isGreen: true,
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
                                  if (!context.mounted) return;
                                  Navigator.pop(context); // Close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutScreen(cartItems: cartItems, profile: profile),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
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
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item.confidence!,
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
                      color: AppColors.primary,
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
              color: item.weight <= 0 ? Colors.redAccent : AppColors.primary.withValues(alpha: 0.3),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showWasteDetailPopup(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          ? AppNetworkImage(
                              item.imageUrl!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                width: 52, height: 52,
                                color: AppColors.softGreen,
                                child: const Icon(Icons.recycling, color: AppColors.primary, size: 26),
                              ),
                            )
                          : Container(
                              width: 52,
                              height: 52,
                              color: AppColors.softGreen,
                              child: const Icon(Icons.recycling, color: AppColors.primary, size: 26),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.category ?? 'Sampah',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Poin: ${item.pricePerKg.toInt()}/kg  •  Ketuk untuk detail',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppColors.textSoft,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _openWeightBottomSheet(item),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCard(WasteItem item) {
    final bool isScanned = item.isScanned || item.imageUrl != null;

    // Tentukan gambar yang tampil:
    // 1. Jika ada gambar scan (file lokal) → pakai itu
    // 2. Jika ada imageUrl dari database → pakai itu
    // 3. Fallback: ikon recycling
    Widget imageWidget;
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty &&
        (item.imageUrl!.startsWith('/') || item.imageUrl!.startsWith('file://'))) {
      // Gambar lokal hasil scan kamera
      imageWidget = _buildItemImage(item, width: 52, height: 52);
    } else if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      // Gambar dari database
      imageWidget = AppNetworkImage(
        item.imageUrl!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorWidget: Container(
          width: 52, height: 52,
          color: AppColors.softGreen,
          child: const Icon(Icons.recycling, color: AppColors.primary, size: 26),
        ),
      );
    } else {
      // Cari imageUrl dari availableItems berdasarkan nama
      final matched = availableItems.where(
        (a) => a.name.toLowerCase() == item.name.toLowerCase()
      );
      final dbUrl = matched.isNotEmpty ? matched.first.imageUrl : null;
      if (dbUrl != null && dbUrl.isNotEmpty) {
        imageWidget = AppNetworkImage(
          dbUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: Container(
            width: 52, height: 52,
            color: AppColors.softGreen,
            child: const Icon(Icons.recycling, color: AppColors.primary, size: 26),
          ),
        );
      } else {
        imageWidget = Container(
          width: 52, height: 52,
          color: AppColors.softGreen,
          child: const Icon(Icons.recycling, color: AppColors.primary, size: 26),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isScanned
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showWasteDetailPopup(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Gambar / thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget,
                ),
                const SizedBox(width: 12),

                // Info teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isScanned)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.softGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.weight.toStringAsFixed(1)} Kg  •  ${item.totalPrice.toInt()} Poin',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tombol Edit & Hapus
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isScanned ? AppColors.primary : AppColors.textSoft,
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
              ],
            ),
          ),
        ),
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
            color: isAccent ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
