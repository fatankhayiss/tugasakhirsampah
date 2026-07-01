import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_fab.dart';
import '../../home/screens/home_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../deposit/screens/deposit_option_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final int _currentIndex = 0;
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  String? _selectedBank;

  final List<Map<String, String>> _banks = [
    {'name': 'Bank Mandiri', 'icon': 'ðŸ¦'},
    {'name': 'BCA', 'icon': 'ðŸ¦'},
    {'name': 'BNI', 'icon': 'ðŸ¦'},
    {'name': 'CIMB Niaga', 'icon': 'ðŸ¦'},
    {'name': 'OVO', 'icon': 'ðŸ’³'},
    {'name': 'GCash', 'icon': 'ðŸ’³'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _handleTransfer() {
    if (_amountController.text.isEmpty ||
        _selectedBank == null ||
        _accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data transfer')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Transfer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank: $_selectedBank'),
                const SizedBox(height: 8),
                Text('Rekening: ${_accountNumberController.text}'),
                const SizedBox(height: 8),
                Text('Jumlah: ${_amountController.text} Poin'),
                const SizedBox(height: 12),
                const Text(
                  'Lanjutkan transfer poin?',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfer berhasil!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  _accountNumberController.clear();
                  _amountController.clear();
                  setState(() {
                    _selectedBank = null;
                  });
                },
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Transfer Poin'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Poin Anda',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const PointBadge.balanceAmount(
                      amount: '7.500',
                      logoSize: 24,
                      fontSize: 28,
                      suffix: 'Poin',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bank Account Section
              const Text(
                'Pilih Rekening',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_banks.length, (index) {
                    final bank = _banks[index];
                    final isSelected = _selectedBank == bank['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank['name'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withValues(alpha: 0.04)
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bank['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              bank['name']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),

              // Account Number Section
              if (_selectedBank != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Rekening',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _accountNumberController,
                      labelText: 'Nomor Rekening',
                      hintText: 'Masukkan nomor rekening',
                      prefixIcon: Icons.account_balance,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bank: $_selectedBank',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.04),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Silakan pilih bank terlebih dahulu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),

              // Transfer Form
              const Text(
                'Detail Transfer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Amount Field
              CustomTextField(
                controller: _amountController,
                labelText: 'Jumlah Poin',
                hintText: '0',
                prefixWidget: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Image.asset(
                    AppImages.pointLogo,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.04)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF007AFF),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Poin akan langsung diterima oleh penerima',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Transfer Button
              CustomButton(
                text: 'Transfer Poin',
                onPressed: _handleTransfer,
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFAB(
        onTap: () {
          Navigator.push(
            context,
            CustomPageRoute(
              page: const DepositOptionScreen(),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              CustomPageRoute(page: const HomeScreen()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.of(context).pushAndRemoveUntil(
              CustomPageRoute(page: const OrdersScreen()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              CustomPageRoute(
                page: const NotificationsScreen(),
              ),
              (route) => false,
            );
          } else if (index == 3) {
            Navigator.of(context).pushAndRemoveUntil(
              CustomPageRoute(page: const ProfileScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}





