import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/location_picker_map.dart';
import 'deposit_submitted_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<WasteItem> cartItems;
  final ProfileModel profile;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.profile,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // State
  late String _currentAddress;
  double? _latitude;
  double? _longitude;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.profile.address ?? 'Menunggu lokasi...';
    _latitude = widget.profile.latitude;
    _longitude = widget.profile.longitude;
    _initializeSchedule();
  }

  void _initializeSchedule() {
    final now = DateTime.now();
    _selectedDate = now;

    final nextHour = now.hour + 1;
    if (nextHour >= 6 && nextHour <= 21) {
      _selectedTime = TimeOfDay(hour: nextHour, minute: 0);
    } else {
      _selectedDate = now.add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 6, minute: 0);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalWeight => widget.cartItems.fold(0, (sum, item) => sum + item.weight);
  int get _totalPoints => widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice.round());

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerMap(
          initialLocation: _latitude != null && _longitude != null ? LatLng(_latitude!, _longitude!) : null,
          initialAddress: widget.profile.address,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _currentAddress = result['address'];
      });
    }
  }

  void _openSchedulePicker() {
    DateTime tempDate = _selectedDate;
    TimeOfDay tempTime = _selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Atur Jadwal Penjemputan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),
                  
                  const Text('Tanggal Penjemputan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 14)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: AppColors.textDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setModalState(() => tempDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text('${tempDate.day}/${tempDate.month}/${tempDate.year}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Waktu Penjemputan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: tempTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onSurface: AppColors.textDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setModalState(() => tempTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(tempTime.format(context), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Jam operasional: 06:00 - 21:00', style: TextStyle(fontSize: 12, color: AppColors.textSoft)),
                  const SizedBox(height: 32),
                  
                  PrimaryButton(
                    text: 'Terapkan',
                    isGreen: false, // Must be blue for primary action!
                    onPressed: () {
                      Navigator.pop(context);
                      _applySchedule(tempDate, tempTime);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applySchedule(DateTime newDate, TimeOfDay newTime) {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(newDate, now);

    // Check if time is between 06:00 and 21:00
    if (newTime.hour < 6 || newTime.hour >= 21) {
      newDate = newDate.add(const Duration(days: 1));
      newTime = const TimeOfDay(hour: 6, minute: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam operasional penjemputan adalah pukul 06.00–21.00. Jadwal Anda otomatis dipindahkan ke pukul 06.00 pada hari berikutnya.'),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 4),
        ),
      );
    } else if (isToday && (newTime.hour * 60 + newTime.minute) <= (now.hour * 60 + now.minute)) {
      final nextHour = now.hour + 1;
      if (nextHour >= 6 && nextHour <= 21) {
        newTime = TimeOfDay(hour: nextHour, minute: 0);
      } else {
        newDate = now.add(const Duration(days: 1));
        newTime = const TimeOfDay(hour: 6, minute: 0);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu penjemputan hari ini telah disesuaikan ke jam terdekat yang tersedia.'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }

    setState(() {
      _selectedDate = newDate;
      _selectedTime = newTime;
    });
  }

  Future<void> _confirmCheckout() async {
    setState(() => _isSubmitting = true);

    try {
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
      final endTime = TimeOfDay(hour: (_selectedTime.hour + 2).clamp(6, 21), minute: _selectedTime.minute);
      final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

      final newOrderIdInt = await OrderRepository.instance.createOrder(
        alamatJemput: _currentAddress,
        latitude: _latitude,
        longitude: _longitude,
        waktuDari: timeStr,
        waktuSampai: endTimeStr,
        estimasiBerat: _totalWeight.toStringAsFixed(1),
        estimasiPoin: _totalPoints,
        catatan: _notesController.text.trim(),
        items: widget.cartItems.map((item) => {
          'id_jenis_sampah': item.id,
          'estimasi_berat_kg': item.weight,
        }).toList(),
      );

      final newOrderId = newOrderIdInt?.toString() ?? 'create_${DateTime.now().millisecondsSinceEpoch}';

      NotificationRepository.instance.addNotification(
        NotificationModel(
          id: 'pickup_$newOrderId',
          title: 'Penjemputan Dijadwalkan',
          message: 'Setoran seberat ${_totalWeight.toStringAsFixed(1)} kg telah dijadwalkan.',
          time: 'Baru saja',
          type: 'pickup',
          isRead: false,
        ),
      );

      OrderRepository.instance.refresh();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DepositSubmittedScreen(
            orderId: newOrderId,
            totalWeight: _totalWeight,
            estPoints: _totalPoints,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildSectionHeader(String title, {String? buttonText, VoidCallback? onButtonTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        if (buttonText != null && onButtonTap != null)
          TextButton(
            onPressed: onButtonTap,
            child: Text(buttonText, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
      ],
    );
  }

  Widget _buildWasteItem(WasteItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('${item.weight.toStringAsFixed(1)} Kg', style: const TextStyle(fontSize: 12, color: AppColors.textSoft)),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.round()} Poin',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Konfirmasi Penjemputan', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup Address
            _buildSectionHeader('Alamat Penjemputan', buttonText: 'Ubah', onButtonTap: _openAddressPicker),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8FAF8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.map_pin, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_currentAddress, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Pickup Schedule
            _buildSectionHeader('Jadwal Penjemputan', buttonText: 'Ubah', onButtonTap: _openSchedulePicker),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8FAF8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 24, color: AppColors.border),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clock, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(_selectedTime.format(context), style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Waste Summary
            const Text('Rincian Sampah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  ...widget.cartItems.map((item) => _buildWasteItem(item)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.border),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Berat', style: TextStyle(fontSize: 14, color: AppColors.textSoft)),
                      Text('${_totalWeight.toStringAsFixed(1)} Kg', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimasi Poin', style: TextStyle(fontSize: 14, color: AppColors.textSoft)),
                      Text('$_totalPoints Poin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional Notes
            const Text('Catatan Tambahan (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              cursorColor: AppColors.primary,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Pagar warna hitam. Tolong hubungi terlebih dahulu.',
                hintStyle: const TextStyle(color: AppColors.textSoft, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAF8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 40), // Extra space for scrolling comfortably
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: PrimaryButton(
          text: 'Checkout Sekarang',
          isGreen: false, // Must be blue for primary action
          isLoading: _isSubmitting,
          onPressed: _confirmCheckout,
        ),
      ),
    );
  }
}
