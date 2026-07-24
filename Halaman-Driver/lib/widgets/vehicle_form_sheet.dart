import 'package:flutter/material.dart';
import '../constants/api_config.dart';
import '../services/api_service.dart';

class VehicleOption {
  final String type;
  final String name;
  final String description;
  final IconData icon;

  const VehicleOption({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });
}

const List<VehicleOption> _vehicleOptions = [
  VehicleOption(
    type: 'Motor',
    name: 'Motor',
    description: 'Untuk penjemputan kecil',
    icon: Icons.directions_bike_rounded,
  ),
  VehicleOption(
    type: 'Motor Tossa',
    name: 'Motor Tossa',
    description: 'Untuk sampah sedang',
    icon: Icons.two_wheeler_rounded,
  ),
  VehicleOption(
    type: 'Pick Up',
    name: 'Pick Up',
    description: 'Untuk kapasitas menengah',
    icon: Icons.local_shipping_outlined,
  ),
  VehicleOption(
    type: 'Truk Kecil',
    name: 'Truk Kecil',
    description: 'Untuk kapasitas besar',
    icon: Icons.local_shipping_rounded,
  ),
  VehicleOption(
    type: 'Truk Besar',
    name: 'Truk Besar',
    description: 'Untuk volume sangat besar',
    icon: Icons.airport_shuttle_rounded,
  ),
];

class VehicleFormSheet extends StatefulWidget {
  final Map<String, dynamic>? initialVehicle;
  final VoidCallback? onSaved;

  const VehicleFormSheet({
    super.key,
    this.initialVehicle,
    this.onSaved,
  });

  static Future<bool?> showValidationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Data Kendaraan Belum Diisi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Anda harus mengisi data kendaraan yang digunakan hari ini sebelum mengambil tugas penjemputan. Silakan lengkapi data kendaraan terlebih dahulu.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSoft,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Isi Kendaraan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showVehicleSheet(
    BuildContext context, {
    Map<String, dynamic>? initialVehicle,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: VehicleFormSheet(
          initialVehicle: initialVehicle,
          onSaved: onSaved,
        ),
      ),
    );
  }

  @override
  State<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _vehicleTypes = ['Motor', 'Motor Tossa', 'Pick Up', 'Truk Kecil', 'Truk Besar'];
  
  late String _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _plateController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialVehicle;
    _selectedType = (init != null && _vehicleTypes.contains(init['vehicle_type']))
        ? init['vehicle_type'].toString()
        : 'Motor';
    _nameController = TextEditingController(text: init?['vehicle_name']?.toString() ?? '');
    _plateController = TextEditingController(text: init?['license_plate']?.toString() ?? '');
    _notesController = TextEditingController(text: init?['notes']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showVehicleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.softGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Pilih Kendaraan',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pilih kendaraan yang digunakan hari ini',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Options List
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _vehicleOptions.map((opt) {
                          final isSelected = opt.type == _selectedType;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedType = opt.type;
                                });
                                Navigator.pop(ctx);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.softGreen : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      opt.icon,
                                      color: isSelected ? AppColors.primary : AppColors.textSoft,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            opt.name,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            opt.description,
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12,
                                              color: AppColors.textSoft,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    debugPrint("[VehicleFormSheet] Button pressed");
    if (!_formKey.currentState!.validate()) {
      debugPrint("[VehicleFormSheet] Validation failed in UI fields");
      return;
    }
    debugPrint("[VehicleFormSheet] Validation passed in UI fields");

    setState(() => _isLoading = true);
    debugPrint("[VehicleFormSheet] API request started with values - Name: ${_nameController.text.trim()}, Type: $_selectedType, Plate: ${_plateController.text.trim()}, Notes: ${_notesController.text.trim()}");

    final res = await ApiService().saveDailyVehicle(
      vehicleName: _nameController.text.trim(),
      vehicleType: _selectedType,
      licensePlate: _plateController.text.trim().toUpperCase(),
      notes: _notesController.text.trim(),
    );
    setState(() => _isLoading = false);

    debugPrint("[VehicleFormSheet] API response received: $res");

    if (mounted) {
      if (res['success'] == true) {
        debugPrint("[VehicleFormSheet] Database insert/update reported success");
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kendaraan berhasil didaftarkan.'),
            backgroundColor: AppColors.primary,
          ),
        );
        widget.onSaved?.call();

        // Navigate directly to the Pickup Detail page if we are not already there
        final parentRouteName = ModalRoute.of(context)?.settings.name;
        debugPrint("[VehicleFormSheet] Parent route name: $parentRouteName");
        if (parentRouteName != '/pickup-detail') {
          debugPrint("[VehicleFormSheet] Fetching active task for redirect...");
          final resTask = await ApiService.instance.get(ApiConfig.driverActiveTask);
          if (resTask.success && resTask.data != null) {
            final activeTask = resTask.data;
            if (mounted) {
              debugPrint("[VehicleFormSheet] Navigation executing to /pickup-detail with active task");
              Navigator.of(context).pushNamed(
                '/pickup-detail',
                arguments: activeTask,
              );
            }
          } else {
            debugPrint("[VehicleFormSheet] No active task found for redirect");
          }
        } else {
          debugPrint("[VehicleFormSheet] Already on /pickup-detail, no navigation needed");
        }
      } else {
        final errMsg = res['message']?.toString() ?? 'Gagal menyimpan data kendaraan';
        debugPrint("[VehicleFormSheet] Registration failed with message: $errMsg");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: AppColors.badgeCancelled,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    widget.initialVehicle != null ? 'Edit Data Kendaraan' : 'Daftar Kendaraan',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nama Kendaraan
              _label('NAMA KENDARAAN'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                decoration: _inputDecoration(Icons.edit_note_rounded, 'Contoh: Honda Vario / Suzuki Carry'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kendaraan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jenis Kendaraan
              _label('JENIS KENDARAAN'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _showVehicleSelector(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedType,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSoft, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nomor Polisi
              _label('NOMOR POLISI (PLAT NOMOR)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                decoration: _inputDecoration(Icons.pin_outlined, 'Contoh: D 1234 ABC'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor polisi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Catatan (Optional)
              _label('CATATAN (OPSIONAL)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                decoration: _inputDecoration(Icons.notes_rounded, 'Catatan kondisi kendaraan / muatan...'),
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          widget.initialVehicle != null ? 'Perbarui Kendaraan' : 'Simpan Kendaraan',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textSoft,
      letterSpacing: 0.8,
    ),
  );

  InputDecoration _inputDecoration(IconData icon, String hintText) => InputDecoration(
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w400, fontFamily: 'Plus Jakarta Sans'),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );
}
