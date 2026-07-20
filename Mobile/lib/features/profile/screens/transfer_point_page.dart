import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/repositories/profile_repository.dart';

class TransferPointPage extends StatefulWidget {
  const TransferPointPage({super.key});

  @override
  State<TransferPointPage> createState() => _TransferPointPageState();
}

class _TransferPointPageState extends State<TransferPointPage>
    with SingleTickerProviderStateMixin {
  int _currentBalance = 0;
  bool _isLoadingBalance = true;
  String? _selectedCategory; // 'Bank' or 'E-Wallet'
  String? _selectedProvider;

  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _entryAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _cardScale = 1.0;

  final List<Map<String, dynamic>> _banks = [
    {'name': 'BCA', 'icon': Icons.account_balance_rounded},
    {'name': 'BRI', 'icon': Icons.account_balance_rounded},
    {'name': 'BNI', 'icon': Icons.account_balance_rounded},
    {'name': 'Mandiri', 'icon': Icons.account_balance_rounded},
    {'name': 'BSI', 'icon': Icons.account_balance_rounded},
  ];

  final List<Map<String, dynamic>> _ewallets = [
    {'name': 'DANA', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'GoPay', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'OVO', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'ShopeePay', 'icon': Icons.account_balance_wallet_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    _entryAnimController.forward();

    _loadBalance();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _entryAnimController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    if (!mounted) return;
    setState(() => _isLoadingBalance = true);
    try {
      final profile = await ProfileRepository().getProfile();
      if (mounted) {
        setState(() {
          _currentBalance = profile.totalPoints;
          _isLoadingBalance = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBalance = false);
      }
    }
  }

  void _triggerCardScale() {
    setState(() => _cardScale = 0.98);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _cardScale = 1.0);
    });
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatRupiah(int value) {
    return 'Rp${_formatNumber(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBalance,
          color: AppColors.primary,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 28),
                      _buildDestinationSelection(),
                      if (_selectedCategory != null) ...[
                        const SizedBox(height: 28),
                        _buildProviderGrid(),
                        const SizedBox(height: 28),
                        _buildTransferRules(),
                        const SizedBox(height: 28),
                        Text(
                          'Detail Formulir ${_selectedCategory == 'Bank' ? 'Bank' : 'E-Wallet'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailForm(),
                        const SizedBox(height: 20),
                        _buildLiveEstimationCard(),
                        const SizedBox(height: 24),
                        _buildHelperInfo(),
                        const SizedBox(height: 16),
                        _buildWarningCard(),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
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
        'Tukar Poin',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AnimatedScale(
      scale: _cardScale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF1B8E5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B8E5F).withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _triggerCardScale,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      right: -18,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Opacity(
                          opacity: 0.10,
                          child: Image.asset(
                            AppImages.pointLogo,
                            width: 145,
                            height: 145,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saldo Poin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoadingBalance
                              ? _buildBalanceShimmer()
                              : TweenAnimationBuilder<int>(
                                  tween: IntTween(begin: 0, end: _currentBalance),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Text(
                                      '${_formatNumber(value)} Poin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Plus Jakarta Sans',
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 18),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.18),
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Minimal Penukaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '25.000 Poin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.15, end: 0.35),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        return Container(
          height: 34,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildDestinationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tujuan Pencairan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDestinationCard(
                title: 'Bank',
                subtitle: 'Transfer ke Rekening Bank',
                icon: Icons.account_balance_rounded,
                isSelected: _selectedCategory == 'Bank',
                onTap: () {
                  setState(() {
                    if (_selectedCategory != 'Bank') {
                      _selectedCategory = 'Bank';
                      _selectedProvider = null;
                      _accountController.clear();
                      _nameController.clear();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDestinationCard(
                title: 'E-Wallet',
                subtitle: 'DANA, GoPay, OVO, dll',
                icon: Icons.account_balance_wallet_rounded,
                isSelected: _selectedCategory == 'E-Wallet',
                onTap: () {
                  setState(() {
                    if (_selectedCategory != 'E-Wallet') {
                      _selectedCategory = 'E-Wallet';
                      _selectedProvider = null;
                      _accountController.clear();
                      _nameController.clear();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDestinationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSoft,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderGrid() {
    final items = _selectedCategory == 'Bank' ? _banks : _ewallets;
    final isEWallet = _selectedCategory == 'E-Wallet';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Provider ${_selectedCategory == 'Bank' ? 'Bank' : 'E-Wallet'}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isEWallet ? 2 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isEWallet ? 1.6 : 1.15,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _selectedProvider == item['name'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProvider = item['name'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.softGreen : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      color: isSelected ? AppColors.primary : AppColors.textSoft,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textDark,
                      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Ketentuan Penukaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRuleRow('Minimal Penukaran', '25.000 Poin'),
          const SizedBox(height: 8),
          _buildRuleRow('Kurs Konversi', '1 Poin = Rp 1'),
          const SizedBox(height: 8),
          _buildRuleRow('Waktu Proses', '1x24 Jam Kerja'),
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailForm() {
    final isBank = _selectedCategory == 'Bank';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Nama Pemilik ${isBank ? 'Rekening' : 'Akun E-Wallet'}'),
        _buildCustomTextField(
          controller: _nameController,
          hintText: isBank ? 'Masukkan nama pemilik rekening' : 'Masukkan nama pemilik akun',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),
        _buildTextFieldLabel(isBank ? 'Nomor Rekening Bank' : 'Nomor Telepon E-Wallet'),
        _buildCustomTextField(
          controller: _accountController,
          hintText: isBank ? 'Contoh: 1234567890' : 'Contoh: 081234567890',
          icon: isBank ? Icons.credit_card_outlined : Icons.phone_android_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),
        _buildTextFieldLabel('Jumlah Poin yang Ditukar (Minimal 25.000 Poin)'),
        _buildCustomTextField(
          controller: _amountController,
          hintText: 'Contoh: 25000',
          prefixWidget: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Image.asset(
              AppImages.pointLogo,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildLiveEstimationCard() {
    final pts = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final estAmount = _formatRupiah(pts);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimasi Pencairan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSoft,
                    ),
                  ),
                  Text(
                    '${_formatNumber(pts)} Poin',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Nilai Rupiah (1 Poin = Rp1)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSoft,
                ),
              ),
              Text(
                estAmount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixWidget ?? (icon != null ? Icon(icon, color: AppColors.textSoft, size: 20) : null),
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
        Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Permintaan yang dikirim akan berstatus Pending dan segera diperiksa oleh Admin.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              height: 1.4,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan informasi nama dan nomor tujuan sudah benar. Kesalahan input sepenuhnya menjadi tanggung jawab pemohon.',
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
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          if (_selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan pilih tujuan pencairan (Bank / E-Wallet) terlebih dahulu.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (_selectedProvider == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Silakan pilih provider $_selectedCategory terlebih dahulu.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (_nameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nama pemilik wajib diisi.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (_accountController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_selectedCategory == 'Bank' ? 'Nomor rekening bank' : 'Nomor telepon e-wallet'} wajib diisi.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (_amountController.text.isEmpty) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Input Kosong',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ],
                ),
                content: const Text(
                  'Jumlah poin yang ditukar wajib diisi.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          final pts = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          if (pts < 25000) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Minimum Redemption',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ],
                ),
                content: const Text(
                  'Minimal penukaran poin adalah 25.000 poin (Rp25.000).\n\nSilakan masukkan minimal 25.000 poin untuk melanjutkan.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          if (pts > _currentBalance) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Saldo Tidak Cukup',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ],
                ),
                content: Text(
                  'Saldo poin Anda saat ini (${_formatNumber(_currentBalance)} Poin) tidak mencukupi untuk menukar ${_formatNumber(pts)} Poin.',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          final destType = _selectedCategory == 'Bank' ? 'Bank Account' : 'E-Wallet';

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );

          final response = await OrderRepository.instance.createRedemptionRequest(
            destinationType: destType,
            provider: _selectedProvider!,
            accountName: _nameController.text.trim(),
            accountNumber: _accountController.text.trim(),
            redeemPoint: pts,
          );

          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading spinner
          }

          if (response.success && response.data != null) {
            final result = response.data as Map<String, dynamic>;
            final trxCode = result['transaction_code']?.toString() ??
                result['transaction_number']?.toString() ??
                'RDM-NEW';

            NotificationRepository().addNotification(
              NotificationModel(
                id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Tukar Poin Diterima',
                message: 'Permintaan penukaran $pts Poin dengan kode $trxCode telah dikirim dan dalam status Diproses.',
                time: 'Baru saja',
                type: 'transfer',
                isRead: false,
              ),
            );

            await _loadBalance();

            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Permintaan Berhasil Dikirim',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
                content: const Text(
                  'Permintaan penukaran poin Anda telah berhasil dikirim.\n\nPermintaan akan diproses oleh Admin.\n\nSilakan menunggu hingga proses verifikasi selesai.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.pop(context); // Navigate back
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Pengajuan Gagal',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ],
                  ),
                  content: Text(
                    response.message.isNotEmpty 
                        ? response.message 
                        : 'Terjadi kesalahan saat memproses permintaan.',
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Tukarkan Poin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
