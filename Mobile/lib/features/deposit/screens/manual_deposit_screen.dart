import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/repositories/waste_repository.dart';
import 'checkout_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';

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
          // Hanya gunakan item dari API jika bukan fallback, atau update saja
          availableItems = items;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading waste data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _addToCart(WasteItem item) {
    setState(() {
      final existingIndex = cartItems.indexWhere((i) => i.id == item.id);
      if (existingIndex >= 0) {
        cartItems[existingIndex].quantity++;
      } else {
        cartItems.add(
          WasteItem(
            id: item.id,
            name: item.name,
            imageAsset: item.imageAsset,
            pricePerKg: item.pricePerKg,
            quantity: 1,
            weight: 1.0,
          ),
        );
      }
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _incrementQuantity(String itemId) {
    setState(() {
      final item = cartItems.firstWhere((i) => i.id == itemId);
      item.quantity++;
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      final item = cartItems.firstWhere((i) => i.id == itemId);
      if (item.quantity > 1) {
        item.quantity--;
      }
    });
  }

  void _updateWeight(String itemId, double weight) {
    setState(() {
      final item = cartItems.firstWhere((i) => i.id == itemId);
      item.weight = weight;
    });
  }

  double get totalWeight {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.weight * item.quantity),
    );
  }

  double get totalPrice {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.totalPrice * item.quantity),
    );
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
          'Pilih Sampah',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                if (cartItems.isNotEmpty) ...[
                  const Text(
                    'Keranjang Setoran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map(
                    (item) => _CartItemCard(
                      item: item,
                      onRemove: () => _removeFromCart(item.id),
                      onIncrement: () => _incrementQuantity(item.id),
                      onDecrement: () => _decrementQuantity(item.id),
                      onWeightChanged: (weight) => _updateWeight(item.id, weight),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Kategori Sampah Tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Available Items
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (availableItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Tidak ada jenis sampah tersedia', style: TextStyle(color: AppColors.textSoft)),
                    ),
                  )
                else
                  ...availableItems.map((item) {
                    final inCart = cartItems.any((i) => i.id == item.id);
                    return _AvailableItemCard(
                      item: item,
                      inCart: inCart,
                      onAdd: () => _addToCart(item),
                    );
                  }),
              ],
            ),
          ),
          // Summary Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jenis Sampah',
                        style: TextStyle(
                          fontSize: 14, 
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${cartItems.length} Kategori',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimasi Berat',
                        style: TextStyle(
                          fontSize: 14, 
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${totalWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Poin Didapat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      PointAmountRow(
                        amount: '${totalPrice.toInt()}',
                        logoSize: 20,
                        pointColor: AppColors.primary,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedScale(
                      scale: cartItems.isEmpty ? 1.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    page: CheckoutScreen(cartItems: cartItems),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Lanjutkan Setoran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
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
}

class _CartItemCard extends StatelessWidget {
  final WasteItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(double) onWeightChanged;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8), // soft eco tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ===============================
          // CHANGE ICON CONTAINER HERE
          // Symmetrical 64x64, rounded border
          // ===============================
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              WasteRepository().getWasteIcon(item.name),
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                PointAmountRow(
                  amount: '${item.pricePerKg.toInt()}/kg',
                  logoSize: 14,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                  pointColor: AppColors.textSoft,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuantityButton(icon: Icons.remove, onTap: onDecrement),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    _QuantityButton(icon: Icons.add, onTap: onIncrement),
                    const SizedBox(width: 8),
                    const Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
          ),
        ],
      ),
    );
  }
}

class _AvailableItemCard extends StatefulWidget {
  final WasteItem item;
  final bool inCart;
  final VoidCallback onAdd;

  const _AvailableItemCard({
    required this.item,
    required this.inCart,
    required this.onAdd,
  });

  @override
  State<_AvailableItemCard> createState() => _AvailableItemCardState();
}

class _AvailableItemCardState extends State<_AvailableItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ===============================
          // CHANGE ICON CONTAINER HERE
          // Symmetrical 64x64, rounded border
          // ===============================
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              WasteRepository().getWasteIcon(widget.item.name),
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                PointAmountRow(
                  amount: '${widget.item.pricePerKg.toInt()}/kg',
                  logoSize: 14,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                  pointColor: AppColors.textSoft,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTapDown: widget.inCart ? null : (_) => setState(() => _pressed = true),
            onTapUp: widget.inCart ? null : (_) {
              setState(() => _pressed = false);
              widget.onAdd();
            },
            onTapCancel: widget.inCart ? null : () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: widget.inCart ? null : widget.onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    widget.inCart ? 'Ditambahkan' : 'Tambah',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.inCart ? AppColors.textSoft : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.softBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 16),
      ),
    );
  }
}
