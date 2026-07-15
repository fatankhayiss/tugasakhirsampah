import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/repositories/waste_repository.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import 'checkout_screen.dart';

class ManualDepositScreen extends StatefulWidget {
  const ManualDepositScreen({super.key});

  @override
  State<ManualDepositScreen> createState() => _ManualDepositScreenState();
}

class _ManualDepositScreenState extends State<ManualDepositScreen> {
  final repository = WasteRepository();
  List<WasteItem> availableItems = [];
  List<WasteItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWasteData();
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
                  weightError = 'Berat tidak boleh negatif';
                });
                return;
              }
              if (cleanText.split('.').length > 2) {
                setModalState(() {
                  weightError = 'Format angka tidak valid';
                });
                return;
              }
              final parsed = double.tryParse(cleanText);
              if (parsed == null) {
                setModalState(() {
                  weightError = 'Format angka tidak valid (hanya angka dan desimal)';
                });
                return;
              }
              if (parsed <= 0) {
                setModalState(() {
                  weightError = 'Berat tidak boleh nol atau negatif';
                });
                return;
              }
              if (parsed < 0.5) {
                setModalState(() {
                  weightError = 'Minimal berat sampah adalah 0.5 Kg';
                });
                return;
              }
              if (parsed > 100.0) {
                setModalState(() {
                  weightError = 'Maksimal berat sampah adalah 100 Kg';
                });
                return;
              }
              setModalState(() {
                tempWeight = parsed;
                weightError = null;
              });
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Ubah Berat ${item.name}' : 'Tambah ${item.name}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masukkan perkiraan berat sampah (Kg)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stepper Container with Manual Input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: weightError != null ? const Color(0xFFEF4444) : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepperBtn(
                          icon: Icons.remove,
                          onTap: () {
                            double currentVal = double.tryParse(weightController.text.replaceAll(',', '.')) ?? tempWeight;
                            if (currentVal.isNaN || currentVal < 0) currentVal = 0.5;
                            if (currentVal > 0.5) {
                              double newVal = (currentVal - 0.5).clamp(0.5, 100.0);
                              weightController.text = newVal.toStringAsFixed(newVal.truncateToDouble() == newVal ? 1 : 2);
                              validateAndUpdate(weightController.text);
                            } else {
                              validateAndUpdate(weightController.text);
                            }
                          },
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              IntrinsicWidth(
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 50),
                                  child: TextField(
                                    controller: weightController,
                                    focusNode: weightFocusNode,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      validateAndUpdate(val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Kg',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStepperBtn(
                          icon: Icons.add,
                          onTap: () {
                            double currentVal = double.tryParse(weightController.text.replaceAll(',', '.')) ?? tempWeight;
                            if (currentVal.isNaN || currentVal < 0) currentVal = 0.5;
                            double newVal = (currentVal + 0.5).clamp(0.5, 100.0);
                            weightController.text = newVal.toStringAsFixed(newVal.truncateToDouble() == newVal ? 1 : 2);
                            validateAndUpdate(weightController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (weightError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            weightError!,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimasi Poin',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          weightError != null ? '0 Poin' : '${(tempWeight * item.pricePerKg).toInt()} Poin',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Konfirmasi',
                    onPressed: weightError != null
                        ? null
                        : () {
                            setState(() {
                              final idx = cartItems.indexWhere(
                                (i) => i.id == item.id,
                              );
                              if (idx >= 0) {
                                if (isEditing) {
                                  cartItems[idx].weight = tempWeight;
                                } else {
                                  cartItems[idx].weight += tempWeight;
                                }
                              } else {
                                final newItem = WasteItem(
                                  id: item.id,
                                  name: item.name,
                                  imageAsset: item.imageAsset,
                                  pricePerKg: item.pricePerKg,
                                  weight: tempWeight,
                                );
                                cartItems.add(newItem);
                              }
                            });
                            Navigator.pop(ctx);
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      weightController.dispose();
      weightFocusNode.dispose();
    });
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalWeight = cartItems.fold(0, (sum, i) => sum + i.weight);
    int totalEstPoints = cartItems.fold(
      0,
      (sum, i) => sum + i.totalPrice.toInt(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            top: true,
            bottom: false,
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pilih Sampah',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Pilih jenis sampah yang akan dijemput',
                      style: TextStyle(
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                const Text(
                  'Kategori Sampah',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ...availableItems.map((item) => _buildCategoryCard(item)),
                if (cartItems.isNotEmpty) ...[
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
                  ...cartItems.map((item) => _buildSelectedCard(item)),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
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
                  _buildSummaryCol('KATEGORI', '${cartItems.length}'),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.border,
                  ),
                  _buildSummaryCol(
                    'TOTAL BERAT',
                    '${totalWeight.toStringAsFixed(1)} kg',
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.border,
                  ),
                  _buildSummaryCol(
                    'EST. POIN',
                    '$totalEstPoints',
                    isAccent: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                text: 'Lanjutkan Penjemputan',
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(cartItems: cartItems),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
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
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: AppColors.primaryBlue,
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
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primaryBlue,
              size: 22,
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
                  '${item.weight.toStringAsFixed(1)} kg • ${item.totalPrice.toInt()} Poin',
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
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSoft,
              size: 20,
            ),
            onPressed: () => _openWeightBottomSheet(item, isEditing: true),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            onPressed: () {
              setState(() => cartItems.removeWhere((i) => i.id == item.id));
            },
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
