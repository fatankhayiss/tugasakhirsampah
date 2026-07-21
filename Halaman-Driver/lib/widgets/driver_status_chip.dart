import 'package:flutter/material.dart';
import '../constants/api_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Widget chip interaktif yang menampilkan status operasional driver.
/// Tap untuk membuka bottom sheet pilihan status.
class DriverStatusChip extends StatefulWidget {
  final String? initialStatus;
  final ValueChanged<String>? onStatusChanged;

  const DriverStatusChip({
    super.key,
    this.initialStatus,
    this.onStatusChanged,
  });

  @override
  State<DriverStatusChip> createState() => _DriverStatusChipState();
}

class _DriverStatusChipState extends State<DriverStatusChip> {
  String _status = 'offline';
  bool _isUpdating = false;

  static const _statusOptions = [
    _StatusOption('online',  'Online (Tersedia)', Icons.check_circle_rounded, Color(0xFF10B981)),
    _StatusOption('offline', 'Offline (Tidak Tersedia)', Icons.power_settings_new_rounded, Color(0xFF94A3B8)),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? 'offline';
  }

  @override
  void didUpdateWidget(DriverStatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != null && widget.initialStatus != oldWidget.initialStatus) {
      setState(() => _status = widget.initialStatus!);
    }
  }

  _StatusOption get _current =>
      _statusOptions.firstWhere((s) => s.value == _status, orElse: () => _statusOptions.last);

  Future<void> _showPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Operasional',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Admin hanya akan menugaskan order ke driver dengan status Online.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            ..._statusOptions.map((opt) {
              final isSelected = opt.value == _status;
              return GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _updateStatus(opt.value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? opt.color.withValues(alpha: 0.08) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? opt.color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.icon, color: opt.color, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? opt.color : AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: opt.color, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      final authService = AuthService();
      final user = await authService.getSavedUser();
      if (user != null) {
        user['driver_status'] = newStatus;
        await authService.saveUser(user);
      }
    } catch (_) {}

    await ApiService.instance.post(
      ApiConfig.driverUpdateDriverStatus,
      body: {'driver_status': newStatus},
    );

    if (mounted) {
      setState(() {
        _status = newStatus;
        _isUpdating = false;
      });
      widget.onStatusChanged?.call(newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opt = _current;
    return GestureDetector(
      onTap: _isUpdating ? null : _showPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: opt.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: opt.color.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isUpdating)
              SizedBox(width: 9, height: 9, child: CircularProgressIndicator(strokeWidth: 1.5, color: opt.color))
            else
              Container(width: 8, height: 8, decoration: BoxDecoration(color: opt.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              opt.label.split(' ').first, // Hanya kata pertama agar ringkas
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: opt.color, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: opt.color, size: 15),
          ],
        ),
      ),
    );
  }
}

class _StatusOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatusOption(this.value, this.label, this.icon, this.color);
}
