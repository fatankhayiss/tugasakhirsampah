import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/repositories/notification_repository.dart';

class TransferPointPage extends StatefulWidget {
  const TransferPointPage({super.key});

  @override
  State<TransferPointPage> createState() => _TransferPointPageState();
}

class _TransferPointPageState extends State<TransferPointPage> {
  String? selectedTransferMethod;
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _nameController = TextEditingController();

  final List<Map<String, dynamic>> _banks = [
    {'name': 'BCA', 'icon': Icons.account_balance},
    {'name': 'Mandiri', 'icon': Icons.account_balance},
    {'name': 'BNI', 'icon': Icons.account_balance},
    {'name': 'BRI', 'icon': Icons.account_balance},
  ];

  final List<Map<String, dynamic>> _ewallets = [
    {'name': 'GoPay', 'icon': Icons.wallet_rounded},
    {'name': 'OVO', 'icon': Icons.wallet_rounded},
    {'name': 'DANA', 'icon': Icons.wallet_rounded},
    {'name': 'ShopeePay', 'icon': Icons.wallet_rounded},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: 32),
                      const Text(
                        'Pilih Metode Pencairan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTransferGrid('BANK', _banks),
                      const SizedBox(height: 24),
                      _buildTransferGrid('E-WALLET', _ewallets),
                      const SizedBox(height: 32),
                      _buildTransferRules(),
                      const SizedBox(height: 32),
                      const Text(
                        'Detail Transfer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailForm(),
                      const SizedBox(height: 24),
                      _buildHelperInfo(),
                      const SizedBox(height: 16),
                      _buildWarningCard(),
                      // Add extra spacing at the bottom so content isn't hidden under the button
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Transfer Poin',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 16,
            bottom: 8,
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                AppImages.pointLogo,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Poin Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const PointBadge.balanceAmount(
                amount: '7.500',
                logoSize: 22,
                suffix: 'Poin',
              ),
              const SizedBox(height: 16),
              Text(
                'Poin akan dicairkan langsung ke saldo tujuan Anda.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferGrid(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSoft,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = selectedTransferMethod == item['name'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTransferMethod = item['name'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.softGreen : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        item['icon'],
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textSoft,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransferRules() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Ketentuan Transfer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleRow('Transfer Bank', 'min. 2.500 Poin'),
          const SizedBox(height: 8),
          _buildRuleRow('GoPay / OVO / DANA', 'min. 1.000 Poin'),
          const SizedBox(height: 8),
          _buildRuleRow('ShopeePay', 'min. 1.500 Poin'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.black12, height: 1),
          ),
          const Text(
            'Minimal transfer ditentukan berdasarkan biaya admin dan proses pencairan.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSoft,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Masukkan Jumlah Poin'),
        _buildCustomTextField(
          controller: _amountController,
          hintText: 'Masukkan jumlah poin',
          prefixWidget: Image.asset(
            AppImages.pointLogo,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),
        _buildTextFieldLabel('Nomor Rekening / E-Wallet'),
        _buildCustomTextField(
          controller: _accountController,
          hintText: 'Contoh: 08123456789',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),
        _buildTextFieldLabel('Nama Penerima'),
        _buildCustomTextField(
          controller: _nameController,
          hintText: 'Masukkan nama penerima',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
      ],
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    Widget? prefixWidget,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: prefixWidget,
                )
              : Icon(icon, color: AppColors.textSoft, size: 20),
          prefixIconConstraints: prefixWidget != null
              ? const BoxConstraints(minWidth: 40, minHeight: 24)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHelperInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.verified, color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Poin akan diproses otomatis dalam beberapa menit.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan nomor tujuan sudah benar sebelum melakukan transfer poin.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSoft,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (selectedTransferMethod == null ||
              _amountController.text.isEmpty ||
              _accountController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lengkapi tujuan dan detail transfer'),
              ),
            );
            return;
          }

          // Push success notification
          NotificationRepository().addNotification(
            NotificationModel(
              id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Penukaran poin ke saldo berhasil',
              message: 'Pencairan ${_amountController.text} Poin berhasil dikirim ke nomor ${_accountController.text} via $selectedTransferMethod.',
              time: 'Baru saja',
              type: 'transfer',
              isRead: false,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Penukaran poin berhasil diproses dan dikirim!'),
              backgroundColor: AppColors.secondary,
            ),
          );

          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Cairkan Poin Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}







