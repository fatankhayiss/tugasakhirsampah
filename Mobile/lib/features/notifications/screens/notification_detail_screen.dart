import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'pickup':
        return AppColors.secondary; // Eco green accent
      case 'reward':
        return const Color(0xFFEAB308); // Gold/amber reward
      case 'transfer':
        return AppColors.primaryBlue; // Fintech blue
      default:
        return AppColors.textSoft;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type) {
      case 'pickup':
        return AppColors.softGreen;
      case 'reward':
        return const Color(0xFFFEF9C3); // Soft gold
      case 'transfer':
        return AppColors.softBlue; // Soft blue
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pickup':
        return LucideIcons.truck;
      case 'reward':
        return LucideIcons.sparkles;
      case 'transfer':
        return LucideIcons.wallet;
      default:
        return LucideIcons.bell;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'pickup':
        return 'Penjemputan';
      case 'reward':
        return 'Reward Poin';
      case 'transfer':
        return 'Pencairan Saldo';
      default:
        return 'Notifikasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(notification.type);
    final typeBg = _getTypeBgColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);
    final typeLabel = _getTypeLabel(notification.type);

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
          'Detail Notifikasi',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symmetrical rounded container containing large icon
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: typeBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  typeLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              notification.title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: AppColors.textSoft,
                ),
                const SizedBox(width: 6),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  notification.isRead ? 'Sudah dibaca' : 'Baru',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: notification.isRead ? AppColors.textSoft : AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border, thickness: 1),
            const SizedBox(height: 24),
            const Text(
              'Pesan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notification.message,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            // Symmetrical modern card for premium additional metadata info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF8), // soft gray surface
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        LucideIcons.shield_check,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Aktivitas Terverifikasi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seluruh pesan dan notifikasi dari sistem iTrashy dienkripsi dan terverifikasi secara aman langsung ke akun Anda.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSoft,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Premium CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kembali ke Notifikasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
