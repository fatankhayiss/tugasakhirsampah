import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/screens/main_navigation_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../shared/widgets/scale_tap.dart';

class ProfileScreen extends StatefulWidget {
  final bool autoOpenEditAddress;
  const ProfileScreen({super.key, this.autoOpenEditAddress = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _repository = ProfileRepository();
  late AnimationController _bgAnimationController;
  
  String? _username;
  String _email = '-';
  String? _avatarUrl;
  String? _address;
  String? _phone;
  int _totalWaste = 0;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _loadProfile();
    if (widget.autoOpenEditAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showEditAddressDialog(onSuccess: () => _loadProfile());
        }
      });
    }
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoOpenEditAddress && !oldWidget.autoOpenEditAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showEditAddressDialog(onSuccess: () => _loadProfile());
        }
      });
    }
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      if (mounted) {
        setState(() {
          _username = profile.username ?? profile.name;
          _email = profile.email;
          _avatarUrl = profile.avatarUrl;
          _address = profile.address;
          _phone = profile.phone;
          _totalWaste = profile.totalWaste;
          _totalPoints = profile.totalPoints;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
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
          await _loadProfile();
          _showSuccessDialog('Your profile has been updated successfully.');
        } else if (mounted) {
          _showValidationDialog('Save Failed', 'Gagal mengunggah foto profil.');
        }
      }
    }
  }

  Widget _buildAvatar(double radius) {
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            _avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: radius * 1.1,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: radius * 1.1,
      ),
    );
  }

  void _showPhotoActionBottomSheet() {
    AppDialogTransitions.showSlideBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
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
                const SizedBox(height: 20),
                const Text(
                  'Foto Profil',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 22),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 22),
                  ),
                  title: const Text(
                    'Choose From Gallery',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
                if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30), size: 22),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFF3B30)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeletePhoto();
                    },
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePhoto() {
    _confirmSaveChanges(
      onConfirm: () async {
        final success = await _repository.removeAvatar();
        if (success && mounted) {
          await _loadProfile();
          _showSuccessDialog('Your profile has been updated successfully.');
        } else if (mounted) {
          _showValidationDialog('Save Failed', 'Gagal menghapus foto profil.');
        }
      },
    );
  }

  void _showValidationDialog(String title, String message) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('OK', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String description) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Profile Updated',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: AppColors.textSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('OK', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmSaveChanges({required Future<void> Function() onConfirm}) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Save Changes?',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: const Text(
            'Are you sure you want to update this information?',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Logout',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.pop(context);
                await AuthRepository().logout();
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEditUsernameDialog({VoidCallback? onSuccess}) {
    final controller = TextEditingController(text: _username == 'User' ? '' : _username);
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Username',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan username',
              hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isEmpty) {
                  _showValidationDialog('Invalid Username', 'Username is required.');
                  return;
                }
                if (val.length < 3) {
                  _showValidationDialog('Invalid Username', 'Username must be at least 3 characters.');
                  return;
                }
                Navigator.pop(context);
                _confirmSaveChanges(
                  onConfirm: () async {
                    final res = await _repository.updateProfile(username: val);
                    if (res.success && mounted) {
                      await _loadProfile();
                      onSuccess?.call();
                      _showSuccessDialog('Your profile has been updated successfully.');
                    } else if (mounted) {
                      _showValidationDialog('Save Failed', res.message);
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEditEmailDialog({VoidCallback? onSuccess}) {
    final controller = TextEditingController(text: _email == '-' ? '' : _email);
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Email',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Masukkan alamat email',
              hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isEmpty) {
                  _showValidationDialog('Invalid Email', 'Email is required.');
                  return;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                  _showValidationDialog('Invalid Email', 'Please enter a valid email address.');
                  return;
                }
                Navigator.pop(context);
                _confirmSaveChanges(
                  onConfirm: () async {
                    final res = await _repository.updateProfile(email: val);
                    if (res.success && mounted) {
                      await _loadProfile();
                      onSuccess?.call();
                      _showSuccessDialog('Your profile has been updated successfully.');
                    } else if (mounted) {
                      _showValidationDialog('Save Failed', res.message);
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhoneDialog({VoidCallback? onSuccess}) {
    final controller = TextEditingController(text: _phone ?? '');
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Phone Number',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Masukkan nomor HP (10 - 15 digit)',
              hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isEmpty) {
                  _showValidationDialog('Invalid Phone Number', 'Phone number is required.');
                  return;
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(val) || val.length < 10 || val.length > 15) {
                  _showValidationDialog('Invalid Phone Number', 'Phone number must contain only digits and be between 10 and 15 digits long.');
                  return;
                }
                Navigator.pop(context);
                _confirmSaveChanges(
                  onConfirm: () async {
                    final res = await _repository.updateProfile(noTelepon: val);
                    if (res.success && mounted) {
                      await _loadProfile();
                      onSuccess?.call();
                      _showSuccessDialog('Your profile has been updated successfully.');
                    } else if (mounted) {
                      _showValidationDialog('Save Failed', res.message);
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showEditAddressDialog({VoidCallback? onSuccess}) {
    final controller = TextEditingController(text: _address ?? '');
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Address',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Masukkan alamat lengkap',
              hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textSoft),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isEmpty) {
                  _showValidationDialog('Invalid Address', 'Address cannot be empty.');
                  return;
                }
                Navigator.pop(context);
                _confirmSaveChanges(
                  onConfirm: () async {
                    final res = await _repository.updateProfile(alamat: val);
                    if (res.success && mounted) {
                      await _loadProfile();
                      onSuccess?.call();
                      _showSuccessDialog('Your profile has been updated successfully.');
                    } else if (mounted) {
                      _showValidationDialog('Save Failed', res.message);
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return ScaleTap(
      onTap: onEdit,
      scaleDown: 0.98,
      duration: const Duration(milliseconds: 160),
      executeOnTap: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onEdit();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileInfoWindow() {
    AppDialogTransitions.showSlideBottomSheet(
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
            return SafeArea(
              child: Padding(
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Profil',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tekan pada informasi yang ingin diubah',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.alternate_email_rounded,
                      label: 'Username',
                      value: (_username != null && _username!.isNotEmpty) ? _username! : '-',
                      onEdit: () {
                        _showEditUsernameDialog(onSuccess: () => setModalState(() {}));
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _email,
                      onEdit: () {
                        _showEditEmailDialog(onSuccess: () => setModalState(() {}));
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: (_phone != null && _phone!.isNotEmpty) ? _phone! : '-',
                      onEdit: () {
                        _showEditPhoneDialog(onSuccess: () => setModalState(() {}));
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat Lengkap',
                      value: (_address != null && _address!.isNotEmpty) ? _address! : 'Belum menambahkan alamat',
                      onEdit: () {
                        _showEditAddressDialog(onSuccess: () => setModalState(() {}));
                      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background with elegant rich gradient and leaf-like designs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: (MediaQuery.of(context).size.height * 0.48).clamp(360.0, 480.0),
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                final val = _bgAnimationController.value;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.primary,
                        Color(0xFF0D9488),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.55, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.18,
                            child: Image.asset(
                              AppImages.coverProfile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Top-Right animated glowing circle
                        Positioned(
                          right: -40 + 15 * math.sin(val * 2 * math.pi),
                          top: -40 + 10 * math.cos(val * 2 * math.pi),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top-Left animated rotating glass diamond/box
                        Positioned(
                          left: -30 + 12 * math.cos(val * 2 * math.pi),
                          top: -20 + 15 * math.sin(val * 2 * math.pi),
                          child: Transform.rotate(
                            angle: 0.4 + 0.15 * math.sin(val * 2 * math.pi),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(42),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-Right animated floating box
                        Positioned(
                          right: 30 + 18 * math.cos(val * 2 * math.pi),
                          bottom: -20 + 12 * math.sin(val * 2 * math.pi),
                          child: Transform.rotate(
                            angle: 0.8 - 0.2 * math.cos(val * 2 * math.pi),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
                              ),
                            ),
                          ),
                        ),
                        // Subtle floating glow dots
                        Positioned(
                          left: 90 + 12 * math.sin(val * 2 * math.pi),
                          bottom: 70 + 15 * math.cos(val * 2 * math.pi),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 130 - 14 * math.sin(val * 2 * math.pi),
                          top: 80 + 10 * math.cos(val * 2 * math.pi),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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

                  // Profile Avatar with camera/edit button
                  Stack(
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: GestureDetector(
                          onTap: _showPhotoActionBottomSheet,
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
                            child: _buildAvatar(50),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: _showPhotoActionBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Username and Address
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _username ?? 'User',
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
                  if (_address != null && _address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _address!,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                            icon: Icons.person_outline_rounded,
                            title: 'Informasi Profil',
                            onTap: _showProfileInfoWindow,
                          ),
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
                            icon: Icons.logout_rounded,
                            title: AppLanguage.translate('menu_logout'),
                            onTap: _confirmLogout,
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
        ScaleTap(
          onTap: onTap,
          scaleDown: 0.98,
          duration: const Duration(milliseconds: 160),
          executeOnTap: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
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
