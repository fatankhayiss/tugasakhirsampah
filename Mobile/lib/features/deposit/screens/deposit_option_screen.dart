import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import 'manual_deposit_screen.dart';
import 'scan_deposit_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/utils/address_verification_helper.dart';

class DepositOptionScreen extends StatelessWidget {
  const DepositOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: const Text(
          'Setor Sampah',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Pilih Metode Setor Sampah',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan pilih metode penyetoran sampah yang paling memudahkan Anda hari ini.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSoft,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _OptionCard(
              icon: LucideIcons.square_pen,
              title: 'Setor Manual',
              description:
                  'Input sampah secara manual dengan memilih jenis dan berat sampah',
              color: AppColors.secondary,
              onTap: () {
                AddressVerificationHelper.checkAndPrompt(
                  context,
                  onValid: () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        page: const ManualDepositScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            _OptionCard(
              icon: LucideIcons.camera,
              title: 'Scan Sampah (AI)',
              description:
                  'Gunakan kamera AI untuk mendeteksi dan mengkategorikan sampah Anda',
              color: AppColors.primaryBlue,
              onTap: () {
                AddressVerificationHelper.checkAndPrompt(
                  context,
                  onValid: () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        page: const ScanDepositScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
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
                  color: widget.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.chevron_right, color: widget.color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
