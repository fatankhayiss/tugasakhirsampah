import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../../core/routes/app_routes.dart';
import '../../main/screens/main_navigation_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AvatarPreset {
  final String label;
  final String? assetPath;
  final Color? backgroundColor;
  final IconData? icon;

  const AvatarPreset({
    required this.label,
    this.assetPath,
    this.backgroundColor,
    this.icon,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = ProfileRepository();
  
  String _name = 'User';
  String _email = '-';
  String? _avatarUrl;
  int _totalWaste = 0;
  int _totalPoints = 0;
  int _selectedAvatarIndex = 0;

  static const List<AvatarPreset> _avatarPresets = [
    AvatarPreset(
      label: 'Default',
      assetPath: AppImages.avatar,
    ),
    AvatarPreset(
      label: 'Eco Green',
      backgroundColor: AppColors.primary,
      icon: Icons.eco_rounded,
    ),
    AvatarPreset(
      label: 'Premium Blue',
      backgroundColor: AppColors.primaryBlue,
      icon: Icons.stars_rounded,
    ),
    AvatarPreset(
      label: 'Golden Sun',
      backgroundColor: Color(0xFFFF9500),
      icon: Icons.wb_sunny_rounded,
    ),
    AvatarPreset(
      label: 'Sunset Purple',
      backgroundColor: Color(0xFF8E57C2),
      icon: Icons.flash_on_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      if (mounted) {
        setState(() {
          _name = profile.name;
          _email = profile.email;
          _avatarUrl = profile.avatarUrl;
          _totalWaste = profile.totalWaste;
          _totalPoints = profile.totalPoints;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Force 1:1
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Sesuaikan Foto',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        final success = await _repository.uploadAvatar(bytes, pickedFile.name);
        if (success && mounted) {
          _loadProfile();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!')));
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunggah foto profil')));
        }
      }
    }
  }

  Widget _buildAvatar(double radius, int index, {bool useNetwork = true}) {
    if (useNetwork && index == 0 && _avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_avatarUrl!),
        backgroundColor: Colors.white,
      );
    }
    final preset = _avatarPresets[index];
    if (preset.assetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(preset.assetPath!),
        backgroundColor: Colors.white,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: preset.backgroundColor,
        child: Icon(
          preset.icon,
          color: Colors.white,
          size: radius * 1.1,
        ),
      );
    }
  }

  void _showEditProfileBottomSheet() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    int tempAvatarIndex = _selectedAvatarIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLanguage.translate('edit_profile'),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Avatar Preset Selector
                  Text(
                    AppLanguage.translate('select_avatar'),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _avatarPresets.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final isSelected = tempAvatarIndex == index;
                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              Navigator.pop(context);
                              _pickAndUploadImage();
                            } else {
                              setModalState(() {
                                tempAvatarIndex = index;
                              });
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected && index != 0 ? AppColors.primaryBlue : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _buildAvatar(26, index, useNetwork: true),
                                    if (index == 0)
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected && index != 0)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name field
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: AppLanguage.translate('enter_name'),
                      hintStyle: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: AppColors.textSoft,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      filled: true,
                      fillColor: AppColors.background,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email field
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: AppLanguage.translate('enter_email'),
                      hintStyle: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: AppColors.textSoft,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      filled: true,
                      fillColor: AppColors.background,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLanguage.translate('cancel'),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _name = nameController.text.trim().isNotEmpty
                                  ? nameController.text.trim()
                                  : _name;
                              _email = emailController.text.trim().isNotEmpty
                                  ? emailController.text.trim()
                                  : _email;
                              _selectedAvatarIndex = tempAvatarIndex;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLanguage.translate('save_changes'),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguage.currentLanguage,
          builder: (context, currentLang, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLanguage.translate('select_language'),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLanguageOption(
                      context,
                      label: AppLanguage.translate('indonesian'),
                      code: 'id',
                      isSelected: currentLang == 'id',
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      context,
                      label: AppLanguage.translate('english'),
                      code: 'en',
                      isSelected: currentLang == 'en',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String label,
    required String code,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        AppLanguage.setLanguage(code);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.secondary : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Background with elegant rich gradient and leaf-like designs
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 360,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.22,
                            child: Image.asset(
                              AppImages.coverProfile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Geometric/leaf decorative overlays
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          top: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            transform: Matrix4.rotationZ(0.4),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            transform: Matrix4.rotationZ(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          AppLanguage.translate('profile'),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Avatar with edit button
                      Stack(
                        children: [
                          Hero(
                            tag: 'profile_avatar',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _buildAvatar(50, _selectedAvatarIndex),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _showEditProfileBottomSheet,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name and Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _email,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Stats Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      AppLanguage.translate('total_waste').toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.softGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            AppImages.image3Small,
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$_totalWaste Kg',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1.5,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.border.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      AppLanguage.translate('total_points').toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF9E6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            AppImages.pointLogo,
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$_totalPoints',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Menu Items Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MenuItem(
                                icon: Icons.notifications_none_outlined,
                                title: AppLanguage.translate('menu_notifications'),
                                onTap: () {
                                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                                  if (navState != null) {
                                    navState.setTab(2);
                                  }
                                },
                              ),
                              _MenuItem(
                                icon: Icons.language_outlined,
                                title: AppLanguage.translate('menu_language'),
                                onTap: _showLanguageBottomSheet,
                              ),
                              _MenuItem(
                                icon: Icons.logout_rounded,
                                title: AppLanguage.translate('menu_logout'),
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.login,
                                    (route) => false,
                                  );
                                },
                                showDivider: false,
                                isDestructive: true,
                              ),
                              const SizedBox(height: 80), // extra padding for bottom navigation floating clearance
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFFF3B30) : AppColors.textDark;
    final iconColor = isDestructive ? const Color(0xFFFF3B30) : AppColors.primary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? const Color(0xFFFFEBEA)
                        : AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive
                      ? const Color(0xFFFF3B30).withValues(alpha: 0.6)
                      : Colors.black38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: AppColors.border),
          ),
      ],
    );
  }
}
