import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/address_verification_helper.dart';
import '../../../core/navigation/app_dialog_transitions.dart';

/// Premium bottom sheet — pilih metode setor sampah.
class DepositMethodModal extends StatefulWidget {
  const DepositMethodModal({super.key});

  static Future<void> show(BuildContext context) async {
    await AddressVerificationHelper.checkAndPrompt(
      context,
      onValid: () {
        if (!context.mounted) return;
        AppDialogTransitions.showSlideBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const _AnimatedModalWrapper(
            child: DepositMethodModal(),
          ),
        );
      },
    );
  }

  @override
  State<DepositMethodModal> createState() => _DepositMethodModalState();
}

class _AnimatedModalWrapper extends StatefulWidget {
  final Widget child;

  const _AnimatedModalWrapper({required this.child});

  @override
  State<_AnimatedModalWrapper> createState() => _AnimatedModalWrapperState();
}

class _AnimatedModalWrapperState extends State<_AnimatedModalWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.bottomCenter,
        child: widget.child,
      ),
    );
  }
}

class _DepositMethodModalState extends State<DepositMethodModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pilih Metode Setor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih cara setor sampah yang ingin digunakan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSoft,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _OptionCard(
            title: 'Setor Manual',
            description: 'Input jenis sampah dan berat secara manual',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              AddressVerificationHelper.checkAndPrompt(
                context,
                onValid: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.manualDeposit);
                },
              );
            },
          ),
          const SizedBox(height: 14),
          _OptionCard(
            title: 'Scan Sampah AI',
            description:
                'Gunakan kamera untuk mendeteksi sampah otomatis',
            icon: Icons.qr_code_scanner_rounded,
            secondaryIcon: Icons.camera_alt_rounded,
            onTap: () {
              AddressVerificationHelper.checkAndPrompt(
                context,
                onValid: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.scan);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final IconData? secondaryIcon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.softGreen,
                    shape: BoxShape.circle,
                  ),
                  child: secondaryIcon != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: AppColors.primary, size: 22),
                            const SizedBox(width: 2),
                            Icon(
                              secondaryIcon,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ],
                        )
                      : Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSoft,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSoft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
