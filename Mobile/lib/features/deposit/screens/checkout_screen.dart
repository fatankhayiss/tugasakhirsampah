import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/repositories/waste_repository.dart';
import 'change_address_screen.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../main/screens/main_navigation_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';

class CheckoutScreen extends StatefulWidget {
  final List<WasteItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedLocation =
      'Jl. Adhyaksa III, Sukajaya, Kab. Bandung, Jawa Barat 40163';
  DateTime? selectedPickupDate;
  TimeOfDay? selectedPickupTime;

  double get totalWeight {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.weight * item.quantity),
    );
  }

  double get totalPrice {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.totalPrice * item.quantity),
    );
  }

  bool get _isSchedulerValid {
    if (selectedPickupDate == null || selectedPickupTime == null) return false;

    final now = DateTime.now();
    final isToday = selectedPickupDate!.year == now.year &&
        selectedPickupDate!.month == now.month &&
        selectedPickupDate!.day == now.day;

    if (isToday) {
      final selectedDateTime = DateTime(
        selectedPickupDate!.year,
        selectedPickupDate!.month,
        selectedPickupDate!.day,
        selectedPickupTime!.hour,
        selectedPickupTime!.minute,
      );
      final minValidDateTime = now.add(const Duration(minutes: 30));
      return selectedDateTime.isAfter(minValidDateTime);
    }

    return true;
  }

  void _showValidationSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFFEBEE), // soft red tint
        elevation: 0,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFCDD2), width: 1), // soft border
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: const [
            Icon(
              LucideIcons.triangle_alert,
              color: Color(0xFFD32F2F), // dark red warning icon
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Silakan pilih waktu pickup yang masih tersedia.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFD32F2F), // dark red text
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPickupDate() async {
    final now = DateTime.now();
    final DateTime firstDate = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPickupDate ?? firstDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary, // Eco green theme
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedPickupDate = picked;
        // Validate pre-existing selected time against today
        if (selectedPickupTime != null) {
          final isToday = picked.year == now.year &&
              picked.month == now.month &&
              picked.day == now.day;

          if (isToday) {
            final selectedDateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              selectedPickupTime!.hour,
              selectedPickupTime!.minute,
            );
            final minValidDateTime = now.add(const Duration(minutes: 30));
            if (selectedDateTime.isBefore(minValidDateTime)) {
              _showValidationSnackbar();
              selectedPickupTime = null; // reset invalid time
            }
          }
        }
      });
    }
  }

  void _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedPickupTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary, // Eco green theme
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (selectedPickupDate != null) {
        final now = DateTime.now();
        final isToday = selectedPickupDate!.year == now.year &&
            selectedPickupDate!.month == now.month &&
            selectedPickupDate!.day == now.day;

        if (isToday) {
          final selectedDateTime = DateTime(
            selectedPickupDate!.year,
            selectedPickupDate!.month,
            selectedPickupDate!.day,
            picked.hour,
            picked.minute,
          );
          final minValidDateTime = now.add(const Duration(minutes: 30));

          if (selectedDateTime.isBefore(minValidDateTime)) {
            _showValidationSnackbar();
            setState(() {
              selectedPickupTime = null; // Do not save invalid time
            });
            return;
          }
        }
      }
      setState(() {
        selectedPickupTime = picked;
      });
    }
  }

  String _formatFullDate(DateTime date) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = _isSchedulerValid;

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
          'Checkout Setoran',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24, // Premium Typography Fix
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Location Section
              _SectionCard(
                title: 'Lokasi Penjemputan',
                icon: LucideIcons.map_pin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C8592), // Body Typography Fix
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            CustomPageRoute(
                              page: ChangeAddressScreen(
                                currentAddress: selectedLocation,
                              ),
                            ),
                          );
                          if (result != null && result is String) {
                            setState(() {
                              selectedLocation = result;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ubah Alamat Penjemputan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Pickup Time Section (Scheduler Refactor)
              _SectionCard(
                title: 'Waktu Penjemputan',
                icon: LucideIcons.calendar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selector Field (Rounded 24, Premium UI)
                    GestureDetector(
                      onTap: _selectPickupDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF8), // Premium subtle container bg
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.softGreen, // Eco soft green tint
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.calendar,
                                color: AppColors.secondary, // Eco green tint
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal Pickup',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedPickupDate != null
                                        ? _formatFullDate(selectedPickupDate!)
                                        : 'Pilih tanggal pickup',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: selectedPickupDate != null
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selectedPickupDate != null
                                          ? AppColors.textDark
                                          : const Color(0xFF9E9E9E), // soft gray text
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevron_right,
                              color: AppColors.textSoft,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Time Selector Field (Rounded 24, Premium UI)
                    GestureDetector(
                      onTap: _selectPickupTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF8), // Premium subtle container bg
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.softGreen, // Eco soft green tint
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.clock,
                                color: AppColors.secondary, // Eco green tint
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Waktu Pickup',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedPickupTime != null
                                        ? _formatTimeOfDay(selectedPickupTime!)
                                        : 'Pilih waktu pickup',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: selectedPickupTime != null
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selectedPickupTime != null
                                          ? AppColors.textDark
                                          : const Color(0xFF9E9E9E), // soft gray text
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevron_right,
                              color: AppColors.textSoft,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedPickupDate != null) ...[
                      () {
                        final now = DateTime.now();
                        final isToday = selectedPickupDate!.year == now.year &&
                            selectedPickupDate!.month == now.month &&
                            selectedPickupDate!.day == now.day;
                        if (isToday) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: const [
                                Icon(
                                  LucideIcons.info,
                                  color: AppColors.secondary, // Eco green info icon
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Jam pickup mengikuti waktu yang tersedia hari ini.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Waste Type Section
              _SectionCard(
                title: 'Detail Sampah yang Disetor',
                icon: LucideIcons.recycle,
                child: Column(
                  children:
                      widget.cartItems.map((item) {
                        return _WasteItemRow(item: item);
                      }).toList(),
                ),
              ),
              const SizedBox(height: 120), // extra padding for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: isButtonEnabled
                  ? const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isButtonEnabled ? null : AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              boxShadow: isButtonEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                      // Tampilkan loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final itemsData = widget.cartItems.map((item) => {
                          'id_jenis_sampah': int.tryParse(item.id) ?? 0,
                          'estimasi_berat_kg': item.weight * item.quantity,
                        }).toList();

                        double totalWeight = widget.cartItems.fold(0, (sum, item) => sum + (item.weight * item.quantity));

                        final orderId = await OrderRepository.instance.createOrder(
                          alamatJemput: selectedLocation,
                          waktuDari: '${selectedPickupTime!.hour.toString().padLeft(2, '0')}:${selectedPickupTime!.minute.toString().padLeft(2, '0')}',
                          waktuSampai: '${((selectedPickupTime!.hour + 1) % 24).toString().padLeft(2, '0')}:${selectedPickupTime!.minute.toString().padLeft(2, '0')}',
                          estimasiBerat: '${totalWeight.toStringAsFixed(1)} Kg',
                          estimasiPoin: totalPrice.toInt(),
                          catatan: '',
                          items: itemsData,
                        );

                        final newId = orderId?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

                        NotificationRepository().addNotification(
                          NotificationModel(
                            id: 'create_$newId',
                            title: 'Order setor sampah berhasil dibuat',
                            message: 'Pesanan Anda sedang menunggu konfirmasi dari Admin.',
                            time: 'Baru saja',
                            type: 'pickup',
                            isRead: false,
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan berhasil dibuat. Menunggu Konfirmasi dari admin.'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainNavigationScreen(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal membuat pesanan: $e')),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Konfirmasi & Jadwalkan Pickup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isButtonEnabled
                      ? Colors.white
                      : AppColors.primaryBlue.withValues(alpha: 0.4),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28), // Premium Card Style
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.softGreen, // eco green tint
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.secondary, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18, // Typography Hierarchy Fix
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
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
}

class _WasteItemRow extends StatelessWidget {
  final WasteItem item;

  const _WasteItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Symmetrical 64x64, rounded border
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                PointAmountRow(
                  amount: '${item.pricePerKg.toInt()}/kg',
                  logoSize: 12,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft,
                  ),
                  pointColor: AppColors.textSoft,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity} kg',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              PointAmountRow(
                amount: '${(item.totalPrice * item.quantity).toInt()}',
                logoSize: 14,
                pointColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
