import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();

  final _authService = AuthService();
  final _picker      = ImagePicker();

  File? _pickedImage;
  String? _existingPhotoUrl;
  String? _localAvatarPath;
  bool _isLoading       = false;
  bool _isFetching      = true;
  Map<String, dynamic>? _todayVehicle;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────
  // Data loading
  // ────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    setState(() => _isFetching = true);
    
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString('local_avatar_path');
    if (localPath != null && File(localPath).existsSync()) {
      _localAvatarPath = localPath;
    }

    final res = await ApiService.instance.get(ApiConfig.driverProfile);
    if (res.success && res.data != null) {
      final d = res.data as Map<String, dynamic>;
      _nameCtrl.text     = d['nama_lengkap'] ?? '';
      _usernameCtrl.text = d['username'] ?? '';
      _emailCtrl.text    = d['email'] ?? '';
      _phoneCtrl.text    = d['no_telepon'] ?? '';
      _todayVehicle      = d['today_vehicle'] as Map<String, dynamic>?;
      final foto = d['foto_profil']?.toString() ?? '';
      if (foto.isNotEmpty) _existingPhotoUrl = '${ApiConfig.baseUrl}$foto';
    } else {
      // Fallback ke cache
      final user = await _authService.getSavedUser();
      if (user != null) {
        _nameCtrl.text     = user['nama_lengkap'] ?? '';
        _usernameCtrl.text = user['username'] ?? '';
        _emailCtrl.text    = user['email'] ?? '';
        _phoneCtrl.text    = user['no_telepon'] ?? '';
        final localPath = prefs.getString('local_avatar_path');
        if (localPath != null && File(localPath).existsSync()) {
          _localAvatarPath = localPath;
        }
      }
    }
    if (mounted) setState(() => _isFetching = false);
  }

  // ────────────────────────────────────────────────────────
  // Image picker
  // ────────────────────────────────────────────────────────

  void _showPhotoActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    'Ambil Foto',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.camera);
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
                    'Pilih dari Galeri',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.gallery);
                  },
                ),
                if (_existingPhotoUrl != null || _pickedImage != null || _localAvatarPath != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Colors.red, size: 22),
                    ),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() {
                        _pickedImage = null;
                        _localAvatarPath = null;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('local_avatar_path');
                      _showError('Foto profil dihapus (Simpan untuk mengonfirmasi)');
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          if (!mounted) return;
          _showPermissionDialog('Kamera');
          return;
        }
      } else {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          var storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            if (!mounted) return;
            _showPermissionDialog('Galeri');
            return;
          }
        }
      }

      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null && mounted) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
        if (croppedFile != null && mounted) {
          setState(() => _pickedImage = File(croppedFile.path));
        }
      }
    } catch (e) {
      _showError('Gagal memilih foto: $e');
    }
  }

  void _showPermissionDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Izin Dibutuhkan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
        content: Text('Aplikasi membutuhkan izin akses $type untuk mengubah foto profil. Silakan izinkan melalui Pengaturan.', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Buka Pengaturan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Save
  // ────────────────────────────────────────────────────────

  Future<void> _confirmSave() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Simpan Perubahan?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 18)),
        content: const Text('Apakah Anda yakin ingin menyimpan pembaruan profil ini?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Ya, Simpan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _save();
    }
  }

  // Enable server sync for profile photo and details
  static const bool _enableServerSync = true;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Simpan perubahan ke penyimpanan lokal
      if (_pickedImage != null) {
        await prefs.setString('local_avatar_path', _pickedImage!.path);
      }

      final currentUser = await _authService.getSavedUser() ?? {};
      final updatedUser = Map<String, dynamic>.from(currentUser);
      updatedUser['nama_lengkap'] = _nameCtrl.text.trim();
      updatedUser['username']     = _usernameCtrl.text.trim();
      updatedUser['email']        = _emailCtrl.text.trim();
      updatedUser['no_telepon']   = _phoneCtrl.text.trim();

      await _authService.saveUser(updatedUser);

      // 2. Sinkronisasi ke server (hanya jika _enableServerSync aktif)
      if (_enableServerSync) {
        final token = prefs.getString('auth_token') ?? '';
        final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.profileUpdate));
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['nama_lengkap'] = _nameCtrl.text.trim();
        request.fields['username']     = _usernameCtrl.text.trim();
        request.fields['email']        = _emailCtrl.text.trim();
        request.fields['no_telepon']   = _phoneCtrl.text.trim();

        if (_pickedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath('foto_profil', _pickedImage!.path),
          );
        }

        final streamed = await request.send().timeout(const Duration(seconds: 30));
        final response = await http.Response.fromStream(streamed);

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final updRes = await ApiService.instance.get(ApiConfig.driverProfile);
          if (updRes.success && updRes.data != null) {
            final user = await _authService.getSavedUser() ?? {};
            await _authService.saveUser({...user, ...updRes.data as Map<String, dynamic>});
          }
        }
      }

      if (!mounted) return;

      // 3. Tampilkan pesan sukses tanpa error sinkronisasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan profil berhasil disimpan.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (_enableServerSync) {
        _showError('Error: $e');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan profil berhasil disimpan.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.badgeCancelled, behavior: SnackBarBehavior.floating),
    );
  }

  // ────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        actions: [],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Foto Profil ──────────────────────────────
                    _buildPhotoSection(),
                    const SizedBox(height: 32),

                    // ── Informasi Pribadi ────────────────────────
                    _sectionTitle('Informasi Pribadi'),
                    const SizedBox(height: 12),
                    _buildFormCard([
                      _buildField(
                        ctrl: _nameCtrl, label: 'NAMA LENGKAP', icon: Icons.person_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                      ),
                      _divider(),
                      _buildField(
                        ctrl: _usernameCtrl, label: 'USERNAME', icon: Icons.alternate_email_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Username wajib diisi' : null,
                      ),
                      _divider(),
                      _buildField(
                        ctrl: _emailCtrl, label: 'EMAIL', icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,4}$').hasMatch(v.trim())) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      _divider(),
                      _buildField(
                        ctrl: _phoneCtrl, label: 'NO. TELEPON', icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'No. telepon wajib diisi';
                          if (v.trim().length < 9) return 'No. telepon minimal 9 digit';
                          return null;
                        },
                      ),
                    ]),

                    // ── Kendaraan Hari Ini (Read Only) ───────────
                    if (_todayVehicle != null) ...[
                      const SizedBox(height: 28),
                      _sectionTitle('Kendaraan Hari Ini'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: DriverStyles.cardRadius,
                          border: Border.all(color: AppColors.border),
                          boxShadow: DriverStyles.cardShadow,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.softBlue, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _todayVehicle!['vehicle_type'] ?? '-',
                                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                                  ),
                                  Text(
                                    (_todayVehicle!['license_plate'] ?? '-').toString().toUpperCase(),
                                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Hari Ini',
                                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          '* Ubah kendaraan dari halaman Profil.',
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Tombol Simpan ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Simpan Perubahan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))],
                ),
                child: ClipOval(
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : (_localAvatarPath != null)
                          ? Image.file(File(_localAvatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback())
                          : (_existingPhotoUrl != null)
                              ? Image.network(_existingPhotoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback())
                              : _avatarFallback(),
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showPhotoActionBottomSheet,
            icon: const Icon(Icons.photo_camera_rounded, size: 18, color: AppColors.primary),
            label: const Text('Ubah Foto Profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    final name = _nameCtrl.text;
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'DR');
    return Container(
      color: AppColors.softBlue,
      alignment: Alignment.center,
      child: Text(initials, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary)),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
  );

  Widget _buildFormCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: DriverStyles.cardRadius,
      border: Border.all(color: AppColors.border),
      boxShadow: DriverStyles.cardShadow,
    ),
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Divider(color: AppColors.border, height: 1),
  );

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border:             OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.badgeCancelled)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.badgeCancelled, width: 2)),
          ),
        ),
      ],
    );
  }
}
