import 'package:flutter/material.dart';
import '../constants/api_config.dart';
import '../services/api_service.dart';

/// Bottom sheet untuk mendaftarkan kendaraan driver hari ini.
/// Menyimpan ke backend DB (driver_daily_vehicle) — bukan hanya SharedPreferences.
class DailyVehicleSheet extends StatefulWidget {
  final Map<String, dynamic>? existingVehicle;

  const DailyVehicleSheet({super.key, this.existingVehicle});

  /// Tampilkan sheet dari mana saja. Return true jika berhasil disimpan.
  static Future<bool?> show(BuildContext context, {Map<String, dynamic>? existingVehicle}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DailyVehicleSheet(existingVehicle: existingVehicle),
      ),
    );
  }

  @override
  State<DailyVehicleSheet> createState() => _DailyVehicleSheetState();
}

class _DailyVehicleSheetState extends State<DailyVehicleSheet> {
  final _plateController    = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController    = TextEditingController();
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Motor', 'Motor Tossa', 'Pick Up', 'Truk Kecil', 'Truk Besar'];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    final v = widget.existingVehicle;
    if (v != null) {
      _selectedType = _vehicleTypes.contains(v['vehicle_type']) ? v['vehicle_type'] : null;
      _plateController.text    = v['license_plate'] ?? '';
      _capacityController.text = v['capacity']      ?? '';
      _notesController.text    = v['notes']          ?? '';
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vehicleType = _selectedType ?? '';
    final plate       = _plateController.text.trim();

    if (vehicleType.isEmpty || plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis kendaraan dan isi plat nomor'),
          backgroundColor: AppColors.badgeCancelled,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.instance.post(
      ApiConfig.driverSaveDailyVehicle,
      body: {
        'vehicle_type'  : vehicleType,
        'license_plate' : plate,
        'capacity'      : _capacityController.text.trim(),
        'notes'         : _notesController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.badgeCancelled,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingVehicle != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Ubah Kendaraan Hari Ini' : 'Daftarkan Kendaraan Hari Ini',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const Text(
                      'Data tersinkron ke dashboard & profil',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Jenis Kendaraan
          _label('JENIS KENDARAAN'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            hint: const Text('Pilih jenis kendaraan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontSize: 14)),
            decoration: _inputDecoration(Icons.local_shipping_outlined),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            items: _vehicleTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => setState(() => _selectedType = val),
          ),
          const SizedBox(height: 14),

          // Plat Nomor
          _label('PLAT NOMOR'),
          const SizedBox(height: 8),
          TextField(
            controller: _plateController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            decoration: _inputDecoration(Icons.pin_outlined).copyWith(hintText: 'Contoh: H 1234 AB'),
          ),
          const SizedBox(height: 14),

          // Kapasitas
          _label('KAPASITAS ANGKUT (OPSIONAL)'),
          const SizedBox(height: 8),
          TextField(
            controller: _capacityController,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            decoration: _inputDecoration(Icons.scale_rounded).copyWith(hintText: 'Contoh: 500 kg'),
          ),
          const SizedBox(height: 14),

          // Catatan
          _label('CATATAN (OPSIONAL)'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            decoration: _inputDecoration(Icons.notes_rounded).copyWith(hintText: 'Kondisi kendaraan, dll.'),
          ),
          const SizedBox(height: 28),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      isEdit ? 'Perbarui Kendaraan' : 'Simpan Kendaraan',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
  );

  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    hintStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w400, fontFamily: 'Plus Jakarta Sans'),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
  );
}
