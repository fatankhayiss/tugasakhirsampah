import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/utils/address_verification_helper.dart';
import '../../../shared/widgets/primary_button.dart';
import 'change_address_screen.dart';
import 'deposit_submitted_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<WasteItem> cartItems;
  final String pickupAddress;
  final String notes;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.pickupAddress =
        'Jl. Raya Bersinar No. 123, RT 04/RW 05, Kelurahan Hijau, Kota Bandung, Jawa Barat 40123',
    this.notes = '',
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _currentAddress;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.pickupAddress;
    _notesController = TextEditingController(text: widget.notes);
    _initializeSchedule();
  }

  void _initializeSchedule() {
    final now = DateTime.now();
    _selectedDate = now;

    final nextHour = now.hour + (now.minute > 30 ? 2 : 1);
    if (nextHour <= 17) {
      _selectedTime = TimeOfDay(hour: nextHour.clamp(8, 17), minute: 0);
    } else {
      _selectedDate = now.add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool _canScheduleToday(TimeOfDay time) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final pickMinutes = time.hour * 60 + time.minute;
    return (pickMinutes - nowMinutes) >= 30;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double get _totalWeight =>
      widget.cartItems.fold(0, (sum, item) => sum + item.weight);

  int get _totalPoints => widget.cartItems
      .fold(0, (sum, item) => sum + item.totalPrice.round());

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (DateUtils.isSameDay(picked, DateTime.now())) {
          if (!_canScheduleToday(_selectedTime)) {
            final n = DateTime.now();
            final nextHour = n.hour + (n.minute > 30 ? 2 : 1);
            if (nextHour <= 17) {
              _selectedTime = TimeOfDay(hour: nextHour.clamp(8, 17), minute: 0);
            }
          }
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isToday && !_canScheduleToday(picked)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Jadwal penjemputan hari ini minimal 30 menit dari waktu sekarang.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      if (picked.hour < 8 || picked.hour > 17) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Jam operasional penjemputan adalah pukul 08:00 - 17:00 WIB.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _changeAddress() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeAddressScreen(currentAddress: _currentAddress),
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _currentAddress = result.trim());
    }
  }

  Future<void> _confirmSetoran() async {
    if (widget.cartItems.isEmpty) return;

    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    if (isToday && !_canScheduleToday(_selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Jadwal penjemputan hari ini minimal 30 menit dari waktu sekarang.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final isValidAddress = await AddressVerificationHelper.checkAndPrompt(
      context,
      onValid: () {},
    );
    if (!isValidAddress) return;

    setState(() => _isSubmitting = true);

    try {
      final formattedDate = _formatFullDate(_selectedDate);
      final timeStr = _selectedTime.format(context);
      final endTime = TimeOfDay(
          hour: (_selectedTime.hour + 2).clamp(8, 17),
          minute: _selectedTime.minute);
      final endTimeStr = endTime.format(context);

      final newOrderIdInt = await OrderRepository.instance.createOrder(
        alamatJemput: _currentAddress,
        waktuDari: '$timeStr WIB',
        waktuSampai: '$endTimeStr WIB',
        estimasiBerat: _totalWeight.toStringAsFixed(1),
        estimasiPoin: _totalPoints,
        catatan: _notesController.text.trim(),
        items: widget.cartItems
            .map((item) => {
                  'id': item.id,
                  'nama': item.name,
                  'berat': item.weight,
                  'harga': item.pricePerKg,
                })
            .toList(),
      );

      final newOrderId = newOrderIdInt?.toString() ??
          'create_${DateTime.now().millisecondsSinceEpoch}';

      NotificationRepository.instance.addNotification(
        NotificationModel(
          id: 'pickup_$newOrderId',
          title: 'Penjemputan Dijadwalkan',
          message:
              'Setoran seberat ${_totalWeight.toStringAsFixed(1)} kg telah dijadwalkan pada $formattedDate pukul $timeStr WIB.',
          time: 'Baru saja',
          type: 'pickup',
          isRead: false,
        ),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat pesanan. Silakan coba lagi.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          'Checkout Setoran',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: 16),
                  Text(
                    'Memproses pesanan setoran Anda...',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8EED3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2DAA63),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Langkah Terakhir: Konfirmasi',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0A5C36),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Periksa kembali lokasi, jadwal & daftar sampah Anda',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2E7D4F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    icon: LucideIcons.map_pin,
                    iconBgColor: const Color(0xFFEAF8EF),
                    iconColor: const Color(0xFF2DAA63),
                    title: 'Alamat Penjemputan',
                    trailing: OutlinedButton.icon(
                      onPressed: _changeAddress,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Ubah'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            size: 18,
                            color: AppColors.textSoft,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentAddress,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: LucideIcons.calendar_check_2,
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: AppColors.primaryBlue,
                    title: 'Jadwal Penjemputan',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.calendar,
                                        size: 18,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tanggal',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSoft,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateUtils.isSameDay(_selectedDate,
                                                      DateTime.now())
                                                  ? 'Hari Ini'
                                                  : _formatDate(_selectedDate),
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
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
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.clock,
                                        size: 18,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Jam Pickup',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSoft,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_selectedTime.format(context)} WIB',
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                LucideIcons.info,
                                size: 14,
                                color: Color(0xFF854D0E),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jam pickup mengikuti waktu yang tersedia hari ini (min +30 menit).',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF854D0E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: LucideIcons.recycle,
                    iconBgColor: const Color(0xFFEAF8EF),
                    iconColor: const Color(0xFF2DAA63),
                    title: 'Daftar Sampah Disetor',
                    child: Column(
                      children: [
                        ...widget.cartItems.map((item) {
                          final subtotal = item.totalPrice.round();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.recycle,
                                      color: Color(0xFF2DAA63),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Rp ${item.pricePerKg} / kg',
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.weight.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+$subtotal Poin',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2DAA63),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: LucideIcons.receipt,
                    iconBgColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Ringkasan Estimasi',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Berat Sampah',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSoft,
                              ),
                            ),
                            Text(
                              '${_totalWeight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
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
                              'Estimasi Poin Didapat',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF8EF),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '+$_totalPoints Poin',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2DAA63),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: LucideIcons.file_text,
                    iconBgColor: const Color(0xFFF1F5F9),
                    iconColor: AppColors.textSoft,
                    title: 'Catatan Tambahan (Opsional)',
                    child: TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Contoh: Sampah sudah dipacking dalam 2 kantong besar di depan pagar.',
                        hintStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: AppColors.textSoft,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primaryBlue, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: _isSubmitting
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Estimasi',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+$_totalPoints Poin',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2DAA63),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: PrimaryButton(
                        text: 'Konfirmasi Setoran',
                        onPressed: _confirmSetoran,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
